import cv2
import numpy as np
import torch
import torch.nn as nn
from ultralytics import YOLO
from scipy.interpolate import interp1d

class GaitKinematicLSTM(nn.Module):
    def __init__(self, input_dim=2, hidden_dim=64, num_layers=2, num_classes=4, dropout=0.3):
        super(GaitKinematicLSTM, self).__init__()
        self.lstm = nn.LSTM(
            input_size=input_dim, hidden_size=hidden_dim, 
            num_layers=num_layers, batch_first=True, 
            bidirectional=True, dropout=dropout if num_layers > 1 else 0.0
        )
        self.classifier = nn.Sequential(
            nn.Linear(hidden_dim * 2, 64),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(64, num_classes)
        )

    def forward(self, x):
        lstm_out, _ = self.lstm(x)
        context_vector = torch.mean(lstm_out, dim=1) 
        return self.classifier(context_vector)


def calculate_angle(a, b, c):
    a, b, c = np.array(a), np.array(b), np.array(c)
    ba, bc = a - b, c - b
    cosine_angle = np.dot(ba, bc) / (np.linalg.norm(ba) * np.linalg.norm(bc))
    angle = np.arccos(np.clip(cosine_angle, -1.0, 1.0))
    return np.degrees(angle)

def resample_sequence(sequence, target_len=60):
    curr_len = len(sequence)
    if curr_len == target_len: return sequence
    x_old = np.linspace(0, 1, curr_len)
    x_new = np.linspace(0, 1, target_len)
    interpolator = interp1d(x_old, sequence, axis=0, kind='linear')
    return interpolator(x_new)

def predict_gait_video(video_path, model_path="best_gait_lstm.pth"):
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Loading YOLO and LSTM on {device}...")

    # Load Models
    yolo_model = YOLO('yolo11n-pose.pt')
    lstm_model = GaitKinematicLSTM().to(device)
    
    # Load weights and normalization stats
    checkpoint = torch.load(model_path, map_location=device, weights_only=False)
    lstm_model.load_state_dict(checkpoint['model_state_dict'])
    lstm_model.eval()
    
    norm_mean = np.squeeze(checkpoint['norm_mean'])
    norm_std = np.squeeze(checkpoint['norm_std'])
    
    # Class mapping
    class_names = ["Normal (NM)", "Early KOA (EL)", "Moderate KOA (MD)", "Severe KOA (SV)"]

    print(f"Extracting kinematics from: {video_path}")
    cap = cv2.VideoCapture(video_path)
    features = []
    
    KEYPOINTS = {"L_Shoulder": 5, "R_Shoulder": 6, "L_Hip": 11, "R_Hip": 12, 
                 "L_Knee": 13, "R_Knee": 14, "L_Ankle": 15, "R_Ankle": 16}

    # Run YOLO on the video
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret: break
        
        results = yolo_model.track(frame, persist=True, verbose=False)
        
        if results[0].keypoints is not None and len(results[0].keypoints.data) > 0:
            kp = results[0].keypoints.data[0].cpu().numpy()
            
            # Auto-detect which side of the body is facing the camera
            l_conf = kp[KEYPOINTS["L_Hip"]][2] + kp[KEYPOINTS["L_Knee"]][2]
            r_conf = kp[KEYPOINTS["R_Hip"]][2] + kp[KEYPOINTS["R_Knee"]][2]
            side = "L" if l_conf > r_conf else "R"
            
            shoulder, hip = kp[KEYPOINTS[f"{side}_Shoulder"]][:2], kp[KEYPOINTS[f"{side}_Hip"]][:2]
            knee, ankle = kp[KEYPOINTS[f"{side}_Knee"]][:2], kp[KEYPOINTS[f"{side}_Ankle"]][:2]
            
            knee_angle = calculate_angle(hip, knee, ankle)
            hip_angle = calculate_angle(shoulder, hip, knee)
            
            features.append([knee_angle, hip_angle])
            
    cap.release()

    if len(features) < 15:
        return "Error: Video too short or no person detected.", 0.0

    # 4. Process and Predict
    features_np = np.array(features)
    resampled = resample_sequence(features_np, target_len=60)
    
    # Apply the exact same normalization used during training
    normalized = (resampled - norm_mean) / norm_std
    
    # Convert to tensor and add batch dimension (1, 60, 2)
    input_tensor = torch.tensor(normalized, dtype=torch.float32).unsqueeze(0).to(device)
    
    with torch.no_grad():
        outputs = lstm_model(input_tensor)
        probabilities = torch.softmax(outputs, dim=1).cpu().numpy()[0]
        
    pred_class_idx = np.argmax(probabilities)
    confidence = probabilities[pred_class_idx] * 100
    
    return class_names[pred_class_idx], confidence

if __name__ == "__main__":
    # Put the path to a video you want to test here!
    test_video = "test2.mp4" 
    
    diagnosis, confidence = predict_gait_video(test_video)
    
    print("\n" + "="*40)
    print("📋 GAIT ANALYSIS REPORT")
    print("="*40)
    print(f"Diagnosis  : {diagnosis}")
    print(f"Confidence : {confidence:.2f}%")
    print("="*40)