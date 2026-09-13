
from database import SessionLocal, Patient
from fastapi import FastAPI, File, UploadFile 
from fastapi.responses import FileResponse
import os
import uuid
import cv2

app = FastAPI(title="Knee OA AI API")

UPLOAD_FOLDER = "uploaded_videos"

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

    original_filename = video.filename or "uploaded_video.mp4"

    file_extension = os.path.splitext(
        original_filename
    )[1]

    # Default extension if none was provided
    if not file_extension:
        file_extension = ".mp4"

    unique_filename = (
        f"{uuid.uuid4()}"
        f"{file_extension}"
    )

    video_path = os.path.join(
        UPLOAD_FOLDER,
        unique_filename
    )

    # --------------------------------------------------------
    # Read uploaded video
    # --------------------------------------------------------

    video_data = await video.read()

    # --------------------------------------------------------
    # Save uploaded video
    # --------------------------------------------------------

    with open(
        video_path,
        "wb"
    ) as file:

        file.write(video_data)

    # --------------------------------------------------------
    # Read video information
    # --------------------------------------------------------

    cap = cv2.VideoCapture(
        video_path
    )

    if not cap.isOpened():

        # Delete invalid uploaded file
        if os.path.exists(video_path):
            os.remove(video_path)

        return {
            "status": "error",
            "message": "Could not open uploaded video"
        }

    # --------------------------------------------------------
    # Extract video information
    # --------------------------------------------------------

    frame_count = int(
        cap.get(
            cv2.CAP_PROP_FRAME_COUNT
        )
    )

    fps = cap.get(
        cv2.CAP_PROP_FPS
    )

    width = int(
        cap.get(
            cv2.CAP_PROP_FRAME_WIDTH
        )
    )

    height = int(
        cap.get(
            cv2.CAP_PROP_FRAME_HEIGHT
        )
    )

    # --------------------------------------------------------
    # Calculate duration
    # --------------------------------------------------------

    if fps > 0:

        duration = (
            frame_count /
            fps
        )

    else:

        duration = 0

    cap.release()

    # --------------------------------------------------------
    # Return analysis result
    # --------------------------------------------------------

    return {

        "status": "success",

        "filename": original_filename,

        "saved_filename": unique_filename,

        "video_url": f"/videos/{unique_filename}",

        "video_analysis": {

            "frame_count": frame_count,

            "fps": round(
                fps,
                2
            ),

            "width": width,

            "height": height,

            "duration_seconds": round(
                duration,
                2
            )
        },

        # Prototype result for now
        "risk_score": 64,

        "risk_level": "Moderate Risk"
    }
