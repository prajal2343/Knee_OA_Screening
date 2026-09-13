import pandas as pd
import numpy as np
import os
import sys


# ============================================================
# KNEE OA MOVEMENT FEATURE EXTRACTION
# ============================================================

if len(sys.argv) < 2:
    print()
    print("Usage:")
    print("python feature_extraction.py path_to_movement_csv.csv")
    print()
    sys.exit(1)


csv_path = sys.argv[1]


# ------------------------------------------------------------
# Check file
# ------------------------------------------------------------

if not os.path.exists(csv_path):
    print()
    print("ERROR: CSV file does not exist.")
    print(f"Path: {csv_path}")
    print()
    sys.exit(1)


print()
print("========================================")
print("KNEE OA MOVEMENT FEATURE EXTRACTION")
print("========================================")
print()

print(f"Input CSV: {csv_path}")
print()


# ------------------------------------------------------------
# Load dataset
# ------------------------------------------------------------

df = pd.read_csv(csv_path)


print("DATASET INFORMATION")
print("----------------------------------------")
print(f"Rows: {len(df)}")
print(f"Columns: {len(df.columns)}")
print()


# ------------------------------------------------------------
# Convert numeric columns
# ------------------------------------------------------------

numeric_columns = [
    "timestamp_seconds",
    "left_knee_angle",
    "right_knee_angle",
    "left_knee_x",
    "left_knee_y",
    "right_knee_x",
    "right_knee_y"
]

for column in numeric_columns:
    df[column] = pd.to_numeric(
        df[column],
        errors="coerce"
    )


# ------------------------------------------------------------
# Basic measurement counts
# ------------------------------------------------------------

left_valid = df["left_knee_angle"].dropna()
right_valid = df["right_knee_angle"].dropna()


print("MEASUREMENT AVAILABILITY")
print("----------------------------------------")

print(
    f"Left knee measurements: "
    f"{len(left_valid)}"
)

print(
    f"Right knee measurements: "
    f"{len(right_valid)}"
)

print()


# ============================================================
# FEATURE EXTRACTION
# ============================================================

features = {}


# ------------------------------------------------------------
# 1. Left knee features
# ------------------------------------------------------------

if len(left_valid) > 0:

    features["left_average_angle"] = (
        left_valid.mean()
    )

    features["left_min_angle"] = (
        left_valid.min()
    )

    features["left_max_angle"] = (
        left_valid.max()
    )

    features["left_range_of_motion"] = (
        left_valid.max() -
        left_valid.min()
    )

    features["left_std_angle"] = (
        left_valid.std()
    )

else:

    features["left_average_angle"] = np.nan
    features["left_min_angle"] = np.nan
    features["left_max_angle"] = np.nan
    features["left_range_of_motion"] = np.nan
    features["left_std_angle"] = np.nan


# ------------------------------------------------------------
# 2. Right knee features
# ------------------------------------------------------------

if len(right_valid) > 0:

    features["right_average_angle"] = (
        right_valid.mean()
    )

    features["right_min_angle"] = (
        right_valid.min()
    )

    features["right_max_angle"] = (
        right_valid.max()
    )

    features["right_range_of_motion"] = (
        right_valid.max() -
        right_valid.min()
    )

    features["right_std_angle"] = (
        right_valid.std()
    )

else:

    features["right_average_angle"] = np.nan
    features["right_min_angle"] = np.nan
    features["right_max_angle"] = np.nan
    features["right_range_of_motion"] = np.nan
    features["right_std_angle"] = np.nan


# ------------------------------------------------------------
# 3. Left/right symmetry
# ------------------------------------------------------------

if (
    len(left_valid) > 0
    and len(right_valid) > 0
):

    features["average_angle_difference"] = abs(
        left_valid.mean() -
        right_valid.mean()
    )

    features["rom_difference"] = abs(
        (
            left_valid.max() -
            left_valid.min()
        )
        -
        (
            right_valid.max() -
            right_valid.min()
        )
    )

else:

    features["average_angle_difference"] = np.nan
    features["rom_difference"] = np.nan


# ------------------------------------------------------------
# 4. Movement duration
# ------------------------------------------------------------

if len(df) > 0:

    timestamps = (
        df["timestamp_seconds"]
        .dropna()
    )

    if len(timestamps) > 1:

        features["movement_duration_seconds"] = (
            timestamps.max() -
            timestamps.min()
        )

    else:

        features["movement_duration_seconds"] = 0

else:

    features["movement_duration_seconds"] = 0


# ------------------------------------------------------------
# 5. Angle velocity
# ------------------------------------------------------------

if len(left_valid) > 1:

    left_angles = (
        df["left_knee_angle"]
        .dropna()
        .to_numpy()
    )

    left_velocity = np.abs(
        np.diff(left_angles)
    )

    features["left_average_angle_change"] = (
        left_velocity.mean()
    )

    features["left_max_angle_change"] = (
        left_velocity.max()
    )

else:

    features["left_average_angle_change"] = np.nan
    features["left_max_angle_change"] = np.nan


if len(right_valid) > 1:

    right_angles = (
        df["right_knee_angle"]
        .dropna()
        .to_numpy()
    )

    right_velocity = np.abs(
        np.diff(right_angles)
    )

    features["right_average_angle_change"] = (
        right_velocity.mean()
    )

    features["right_max_angle_change"] = (
        right_velocity.max()
    )

else:

    features["right_average_angle_change"] = np.nan
    features["right_max_angle_change"] = np.nan


# ------------------------------------------------------------
# 6. Knee position movement
# ------------------------------------------------------------

if (
    df["left_knee_x"].notna().sum() > 1
    and df["left_knee_y"].notna().sum() > 1
):

    left_x_change = np.abs(
        np.diff(
            df["left_knee_x"]
            .dropna()
            .to_numpy()
        )
    )

    left_y_change = np.abs(
        np.diff(
            df["left_knee_y"]
            .dropna()
            .to_numpy()
        )
    )

    features["left_position_movement"] = (
        left_x_change.mean() +
        left_y_change.mean()
    )

else:

    features["left_position_movement"] = np.nan


if (
    df["right_knee_x"].notna().sum() > 1
    and df["right_knee_y"].notna().sum() > 1
):

    right_x_change = np.abs(
        np.diff(
            df["right_knee_x"]
            .dropna()
            .to_numpy()
        )
    )

    right_y_change = np.abs(
        np.diff(
            df["right_knee_y"]
            .dropna()
            .to_numpy()
        )
    )

    features["right_position_movement"] = (
        right_x_change.mean() +
        right_y_change.mean()
    )

else:

    features["right_position_movement"] = np.nan


# ============================================================
# DISPLAY FEATURES
# ============================================================

print("EXTRACTED MOVEMENT FEATURES")
print("----------------------------------------")

for name, value in features.items():

    if pd.isna(value):

        print(
            f"{name}: N/A"
        )

    else:

        print(
            f"{name}: {value:.4f}"
        )

print()


# ============================================================
# SAVE FEATURES
# ============================================================

input_filename = os.path.basename(csv_path)

input_name = os.path.splitext(
    input_filename
)[0]


output_filename = (
    f"{input_name}_features.csv"
)


output_folder = os.path.dirname(
    csv_path
)

output_path = os.path.join(
    output_folder,
    output_filename
)


features_df = pd.DataFrame(
    [features]
)


features_df.to_csv(
    output_path,
    index=False
)


print("========================================")
print("FEATURE EXTRACTION COMPLETED")
print("========================================")
print()

print(
    f"Features saved to:"
)

print(output_path)

print()

print(
    f"Total features: "
    f"{len(features)}"
)

print()