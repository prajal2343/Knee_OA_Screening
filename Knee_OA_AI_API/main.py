
from database import SessionLocal, Patient
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import FileResponse
from interface import predict_gait_video
import os
import uuid
import cv2
import shutil

app = FastAPI(title="Knee OA AI API")

UPLOAD_FOLDER = "videos"

os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# ============================================================
# CREATE PATIENT
# ============================================================

@app.post("/patients")
def create_patient(
    name: str,
    age: int,
    gender: str = "",
    phone: str = "",
    pain_level: int = 0,
    stiffness: str = "",
    swelling: str = "",
):

    db = SessionLocal()

    try:

        patient = Patient(
            name=name,
            age=age,
            gender=gender,
            phone=phone,
            pain_level=pain_level,
            stiffness=stiffness,
            swelling=swelling,
        )

        db.add(patient)
        db.commit()
        db.refresh(patient)

        return {
            "status": "success",
            "message": "Patient created successfully",
            "patient_id": patient.id
        }

    finally:

        db.close()

# ============================================================
# GET ALL PATIENTS
# ============================================================

@app.get("/patients")
def get_patients():

    db = SessionLocal()

    try:

        patients = db.query(Patient).order_by(
            Patient.screening_date.desc()
        ).all()

        return {
            "status": "success",
            "count": len(patients),
            "patients": [
                {
                    "id": patient.id,
                    "name": patient.name,
                    "age": patient.age,
                    "gender": patient.gender,
                    "phone": patient.phone,
                    "pain_level": patient.pain_level,
                    "stiffness": patient.stiffness,
                    "swelling": patient.swelling,
                    "risk_score": patient.risk_score,
                    "risk_level": patient.risk_level,
                    "video_filename": patient.video_filename,
                    "screening_date": (
                        patient.screening_date.isoformat()
                        if patient.screening_date
                        else None
                    )
                }
                for patient in patients
            ]
        }

    finally:

        db.close()
# ============================================================
# HOME
# ============================================================

@app.get("/")
def home():
    return {
        "status": "online",
        "message": "Knee OA AI API is running"
    }


# ============================================================
# GET SAVED VIDEOS
# ============================================================

@app.get("/videos")
def get_videos():

    videos = []

    for filename in os.listdir(UPLOAD_FOLDER):

        file_path = os.path.join(
            UPLOAD_FOLDER,
            filename
        )

        # Ignore folders
        if not os.path.isfile(file_path):
            continue

        # Only include video files
        if not filename.lower().endswith(
            (".mp4", ".mov", ".avi", ".mkv")
        ):
            continue

        # Get file size
        file_size = os.path.getsize(file_path)

        # Get last modified time
        modified_time = os.path.getmtime(file_path)

        videos.append({
            "filename": filename,
            "size_bytes": file_size,
            "modified_time": modified_time,
            "url": f"/videos/{filename}"
        })

    # Newest videos first
    videos.sort(
        key=lambda video: video["modified_time"],
        reverse=True
    )

    return {
        "status": "success",
        "count": len(videos),
        "videos": videos
    }


# ============================================================
# SERVE A SAVED VIDEO
# ============================================================

@app.get("/videos/{filename}")
def get_video(filename: str):

    file_path = os.path.join(
        UPLOAD_FOLDER,
        filename
    )

    # Check whether video exists
    if not os.path.exists(file_path):

        return {
            "status": "error",
            "message": "Video not found"
        }

    # Make sure the path points to a file
    if not os.path.isfile(file_path):

        return {
            "status": "error",
            "message": "Invalid video path"
        }

    return FileResponse(
        file_path,
        media_type="video/mp4",
        filename=filename
    )


# ============================================================
# DELETE A SAVED VIDEO
# ============================================================

@app.delete("/videos/{filename}")
def delete_video(filename: str):

    file_path = os.path.join(
        UPLOAD_FOLDER,
        filename
    )

    # Check whether video exists
    if not os.path.exists(file_path):

        return {
            "status": "error",
            "message": "Video not found"
        }

    # Make sure it is a file
    if not os.path.isfile(file_path):

        return {
            "status": "error",
            "message": "Invalid video path"
        }

    try:

        # Delete the video
        os.remove(file_path)

        return {
            "status": "success",
            "message": "Video deleted successfully",
            "filename": filename
        }

    except Exception as e:

        return {
            "status": "error",
            "message": f"Could not delete video: {e}"
        }


# ============================================================
# ANALYZE VIDEO
# ============================================================

@app.post("/analyze")
async def analyze_video(
    video: UploadFile = File(...)
):

    # --------------------------------------------------------
    # Create unique filename
    # --------------------------------------------------------

    filename = f"{uuid.uuid4().hex[:8]}_{video.filename}"
    filepath = os.path.join(UPLOAD_FOLDER, filename)

    with open(filepath, "wb") as buffer:
        shutil.copyfileobj(video.file, buffer)

    try:
        diagnosis, confidence = predict_gait_video(filepath)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI Inference failed: {str(e)}")

    # 3. Map the LSTM diagnosis to the UI's Risk Score (0-100)
    if "NM" in diagnosis:
        risk_level = "Low Risk"
        risk_score = 15.0 + (confidence * 0.1) # e.g. 23.5
    elif "EL" in diagnosis:
        risk_level = "Moderate Risk"
        risk_score = 45.0 + (confidence * 0.1)
    elif "MD" in diagnosis:
        risk_level = "High Risk"
        risk_score = 75.0 + (confidence * 0.1)
    else: # SV
        risk_level = "Severe Risk"
        risk_score = 90.0 + (confidence * 0.1)

    # Note: walking_speed, sit_to_stand, and symmetry require separate tracking algorithms. 
    # For now, we return clinical baselines based on severity to populate the UI.
    mock_speed = 1.2 if risk_level == "Low Risk" else 0.8
    mock_symmetry = 95.0 if risk_level == "Low Risk" else 75.0

    return {
        "status": "success",
        "filename": filename,
        "risk_level": risk_level,
        "risk_score": round(risk_score, 1),
        "walking_speed": mock_speed,
        "sit_to_stand_time": 2.5,
        "knee_flexion": 120.0, # You can extract this directly from YOLO inside inference.py later
        "movement_symmetry": mock_symmetry
    }

# ============================================================
# COMPLETE SCREENING
# ============================================================

@app.post("/patients/complete")
def complete_patient_screening(
    name: str,
    age: int,
    gender: str = "",
    pain_level: int = 0,
    affected_knee: str = "",
    walking_difficulty: str = "",
    previous_injury: str = "",
    knee_mobility: float = 0,
    knee_flexion: float = 0,
    walking_speed: float = 0,
    sit_to_stand_time: float = 0,
    movement_symmetry: float = 0,
    risk_score: float = 0,
    risk_level: str = "Unknown",
    video_filename: str = "",
):

    db = SessionLocal()

    try:
        patient = Patient(
            name=name,
            age=age,
            gender=gender,
            pain_level=pain_level,
            affected_knee=affected_knee,
            walking_difficulty=walking_difficulty,
            previous_injury=previous_injury,
            knee_mobility=knee_mobility,
            knee_flexion=knee_flexion,
            walking_speed=walking_speed,
            sit_to_stand_time=sit_to_stand_time,
            movement_symmetry=movement_symmetry,
            risk_score=risk_score,
            risk_level=risk_level,
            video_filename=video_filename,
        )

        db.add(patient)
        db.commit()
        db.refresh(patient)

        return {
            "status": "success",
            "message": "Complete screening saved successfully",
            "patient_id": patient.id,
            "name": patient.name,
            "risk_score": patient.risk_score,
            "risk_level": patient.risk_level,
        }

    except Exception as e:
        db.rollback()
        return {
            "status": "error",
            "message": str(e),
        }

    finally:
        db.close()
