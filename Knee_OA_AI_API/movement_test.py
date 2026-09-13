import cv2
import mediapipe as mp
import math
import sys
import os
import csv
from datetime import datetime

MODEL_PATH = os.path.join(
    os.path.dirname(__file__),
    "models",
    "pose_landmarker_lite.task"
)

DATASET_FOLDER = os.path.join(
    os.path.dirname(__file__),
    "movement_dataset"
)

os.makedirs(DATASET_FOLDER, exist_ok=True)


def calculate_angle(a, b, c):
    angle = math.degrees(
        math.atan2(c[1] - b[1], c[0] - b[0])
        -
        math.atan2(a[1] - b[1], a[0] - b[0])
    )

    angle = abs(angle)

    if angle > 180:
        angle = 360 - angle

    return angle


if len(sys.argv) < 2:
    print()
    print("Usage:")
    print("python movement_test.py path_to_video.mp4")
    print()
    sys.exit(1)


video_path = sys.argv[1]


if not os.path.exists(video_path):
    print()
    print("ERROR: Video file does not exist.")
    print(f"Path: {video_path}")
    print()
    sys.exit(1)


if not os.path.exists(MODEL_PATH):
    print()
    print("ERROR: MediaPipe pose model not found.")
    print(f"Expected: {MODEL_PATH}")
    print()
    sys.exit(1)


video_name = os.path.basename(video_path)
video_name_without_extension = os.path.splitext(video_name)[0]

csv_filename = (
    f"{video_name_without_extension}_movement.csv"
)

csv_path = os.path.join(
    DATASET_FOLDER,
    csv_filename
)


print()
print("========================================")
print("KNEE OA MOVEMENT DATASET ANALYSIS")
print("========================================")
print()

print(f"Video: {video_path}")
print(f"Model: {MODEL_PATH}")
print()

cap = cv2.VideoCapture(video_path)

if not cap.isOpened():
    print("ERROR: Could not open video.")
    sys.exit(1)


fps = cap.get(cv2.CAP_PROP_FPS)
frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))


if fps > 0:
    duration = frame_count / fps
else:
    duration = 0


print("VIDEO INFORMATION")
print("----------------------------------------")
print(f"Frames: {frame_count}")
print(f"FPS: {fps:.2f}")
print(f"Resolution: {width} x {height}")
print(f"Duration: {duration:.2f} seconds")
print()

print("DATASET OUTPUT")
print("----------------------------------------")
print(f"CSV file: {csv_path}")
print()

print("STARTING POSE DETECTION")
print("----------------------------------------")
print()


BaseOptions = mp.tasks.BaseOptions

PoseLandmarker = mp.tasks.vision.PoseLandmarker

PoseLandmarkerOptions = (
    mp.tasks.vision.PoseLandmarkerOptions
)

VisionRunningMode = mp.tasks.vision.RunningMode


options = PoseLandmarkerOptions(
    base_options=BaseOptions(
        model_asset_path=MODEL_PATH
    ),
    running_mode=VisionRunningMode.VIDEO,
    num_poses=1,
    min_pose_detection_confidence=0.5,
    min_pose_presence_confidence=0.5,
    min_tracking_confidence=0.5
)


LEFT_HIP = 23
LEFT_KNEE = 25
LEFT_ANKLE = 27

RIGHT_HIP = 24
RIGHT_KNEE = 26
RIGHT_ANKLE = 28


detected_frames = 0
processed_frames = 0

left_angles = []
right_angles = []

dataset_rows = []


with PoseLandmarker.create_from_options(options) as landmarker:

    while True:

        success, frame = cap.read()

        if not success:
            break

        processed_frames += 1

        timestamp_seconds = (
            processed_frames / fps
            if fps > 0
            else 0
        )

        timestamp_ms = int(
            timestamp_seconds * 1000
        )

        rgb_frame = cv2.cvtColor(
            frame,
            cv2.COLOR_BGR2RGB
        )

        mp_image = mp.Image(
            image_format=mp.ImageFormat.SRGB,
            data=rgb_frame
        )

        result = landmarker.detect_for_video(
            mp_image,
            timestamp_ms
        )

        left_angle = None
        right_angle = None

        left_knee_x = None
        left_knee_y = None

        right_knee_x = None
        right_knee_y = None

        if result.pose_landmarks:

            detected_frames += 1

            landmarks = result.pose_landmarks[0]

            # -------------------------------
            # LEFT KNEE
            # -------------------------------

            left_hip = landmarks[LEFT_HIP]
            left_knee = landmarks[LEFT_KNEE]
            left_ankle = landmarks[LEFT_ANKLE]

            if (
                left_hip.visibility > 0.5
                and left_knee.visibility > 0.5
                and left_ankle.visibility > 0.5
            ):

                left_angle = calculate_angle(
                    (left_hip.x, left_hip.y),
                    (left_knee.x, left_knee.y),
                    (left_ankle.x, left_ankle.y)
                )

                left_angles.append(left_angle)

                left_knee_x = left_knee.x
                left_knee_y = left_knee.y

            # -------------------------------
            # RIGHT KNEE
            # -------------------------------

            right_hip = landmarks[RIGHT_HIP]
            right_knee = landmarks[RIGHT_KNEE]
            right_ankle = landmarks[RIGHT_ANKLE]

            if (
                right_hip.visibility > 0.5
                and right_knee.visibility > 0.5
                and right_ankle.visibility > 0.5
            ):

                right_angle = calculate_angle(
                    (right_hip.x, right_hip.y),
                    (right_knee.x, right_knee.y),
                    (right_ankle.x, right_ankle.y)
                )

                right_angles.append(right_angle)

                right_knee_x = right_knee.x
                right_knee_y = right_knee.y


        # -----------------------------------
        # SAVE FRAME DATA
        # -----------------------------------

        dataset_rows.append([
            processed_frames,
            round(timestamp_seconds, 4),

            left_angle
            if left_angle is not None
            else "",

            right_angle
            if right_angle is not None
            else "",

            left_knee_x
            if left_knee_x is not None
            else "",

            left_knee_y
            if left_knee_y is not None
            else "",

            right_knee_x
            if right_knee_x is not None
            else "",

            right_knee_y
            if right_knee_y is not None
            else ""
        ])


cap.release()


# ---------------------------------------
# SAVE CSV DATASET
# ---------------------------------------

with open(
    csv_path,
    "w",
    newline="",
    encoding="utf-8"
) as csv_file:

    writer = csv.writer(csv_file)

    writer.writerow([
        "frame",
        "timestamp_seconds",
        "left_knee_angle",
        "right_knee_angle",
        "left_knee_x",
        "left_knee_y",
        "right_knee_x",
        "right_knee_y"
    ])

    writer.writerows(dataset_rows)


# ---------------------------------------
# RESULTS
# ---------------------------------------

print()
print("========================================")
print("POSE DETECTION RESULTS")
print("========================================")
print()

print(
    f"Processed frames: {processed_frames}"
)

print(
    f"Frames with pose detected: {detected_frames}"
)

if processed_frames > 0:

    detection_rate = (
        detected_frames /
        processed_frames
    ) * 100

    print(
        f"Pose detection rate: "
        f"{detection_rate:.2f}%"
    )

print()

print("LEFT KNEE")
print("----------------------------------------")

if left_angles:

    average_left = (
        sum(left_angles) /
        len(left_angles)
    )

    minimum_left = min(left_angles)
    maximum_left = max(left_angles)

    print(
        f"Measurements: "
        f"{len(left_angles)}"
    )

    print(
        f"Average angle: "
        f"{average_left:.2f} degrees"
    )

    print(
        f"Minimum angle: "
        f"{minimum_left:.2f} degrees"
    )

    print(
        f"Maximum angle: "
        f"{maximum_left:.2f} degrees"
    )

else:

    print(
        "No reliable left knee measurements."
    )


print()

print("RIGHT KNEE")
print("----------------------------------------")

if right_angles:

    average_right = (
        sum(right_angles) /
        len(right_angles)
    )

    minimum_right = min(right_angles)
    maximum_right = max(right_angles)

    print(
        f"Measurements: "
        f"{len(right_angles)}"
    )

    print(
        f"Average angle: "
        f"{average_right:.2f} degrees"
    )

    print(
        f"Minimum angle: "
        f"{minimum_right:.2f} degrees"
    )

    print(
        f"Maximum angle: "
        f"{maximum_right:.2f} degrees"
    )

else:

    print(
        "No reliable right knee measurements."
    )


print()

print("KNEE MOVEMENT SYMMETRY")
print("----------------------------------------")

if left_angles and right_angles:

    average_left = (
        sum(left_angles) /
        len(left_angles)
    )

    average_right = (
        sum(right_angles) /
        len(right_angles)
    )

    symmetry_difference = abs(
        average_left -
        average_right
    )

    print(
        f"Left average: "
        f"{average_left:.2f} degrees"
    )

    print(
        f"Right average: "
        f"{average_right:.2f} degrees"
    )

    print(
        f"Difference: "
        f"{symmetry_difference:.2f} degrees"
    )

    if symmetry_difference < 5:

        print(
            "Symmetry status: GOOD"
        )

    elif symmetry_difference < 10:

        print(
            "Symmetry status: MODERATE"
        )

    else:

        print(
            "Symmetry status: ASYMMETRIC"
        )

else:

    print(
        "Not enough data to calculate "
        "knee symmetry."
    )


print()

print("========================================")
print("DATASET CREATED")
print("========================================")
print()

print(
    f"CSV saved to:"
)

print(csv_path)

print()

print(
    f"Rows saved: {len(dataset_rows)}"
)

print()

print(
    "Movement analysis completed successfully."
)

print()
