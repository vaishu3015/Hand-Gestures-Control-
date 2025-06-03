import os
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"
import absl.logging
absl.logging.set_verbosity(absl.logging.ERROR)

import asyncio
import base64
import cv2
import numpy as np
import socketio
from fastapi import FastAPI
import pyautogui
import mediapipe as mp
import time

last_action_time = 0  
gesture_cooldown = 2  # 2 seconds delay for each gesture

# Initialize FastAPI app
app = FastAPI()

# Initialize Socket.IO with ASGI
sio = socketio.AsyncServer(
    async_mode="asgi", 
    cors_allowed_origins="*",
    logger=True, 
    engineio_logger=True
)
socket_app = socketio.ASGIApp(sio, app)

# OpenCV - Initialize video capture
camera = cv2.VideoCapture(0)
is_camera_running = False  
camera_task = None  

# Initialize MediaPipe Hands
mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils
hands = mp_hands.Hands(max_num_hands=1, min_detection_confidence=0.7)

# Get screen dimensions
screen_width, screen_height = pyautogui.size()

def get_finger_positions(landmarks):
    return [1 if landmarks[i].y < landmarks[i - 2].y else 0 for i in [4, 8, 12, 16, 20]]

def is_pinch(landmarks):
    thumb_tip = landmarks[4]
    index_tip = landmarks[8]
    distance = np.sqrt((thumb_tip.x - index_tip.x)**2 + (thumb_tip.y - index_tip.y)**2)
    return distance < 0.05

async def generate_frames():
    global is_camera_running, camera, last_action_time

    try:
        while is_camera_running:
            if not camera.isOpened():
                print("⚠️ Camera disconnected. Reconnecting...")
                camera = cv2.VideoCapture(0)

            success, frame = camera.read()
            if not success:
                print("❌ Failed to capture frame.")
                continue

            frame = cv2.flip(frame, 1)
            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = hands.process(rgb_frame)

            current_time = time.time()
            action = None

            if results.multi_hand_landmarks:
                for hand_landmarks in results.multi_hand_landmarks:
                    mp_drawing.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)

                    landmarks = hand_landmarks.landmark
                    fingers = get_finger_positions(landmarks)

                    if current_time - last_action_time > gesture_cooldown:
                        if fingers == [1, 0, 0, 0, 0]:  
                            action = "Go Back"
                            pyautogui.hotkey("alt", "left")
                        elif fingers == [1, 1, 1, 1, 1]:  
                            action = "Default Gesture"
                        elif is_pinch(landmarks):  
                            action = "Screenshot"
                            pyautogui.screenshot().save("screenshot.png")
                        elif fingers == [0, 1, 0, 0, 0]:  
                            action = "Scroll"
                            pyautogui.scroll(15)
                        elif fingers == [1, 0, 0, 0, 1]:  
                            action = "Increase Volume"
                            pyautogui.press("volumeup")
                        elif fingers == [1, 1, 0, 0, 1]:  
                            action = "Decrease Volume"
                            pyautogui.press("volumedown")
                        elif fingers == [0, 1, 0, 0, 0]:  
                            action = "Move Cursor"
                            pyautogui.moveTo(landmarks[8].x * screen_width, landmarks[8].y * screen_height)
                        elif fingers == [0, 1, 1, 0, 0]:  
                            action = "Open Notifications"
                            pyautogui.hotkey("win", "a")
                        elif fingers == [0, 1, 1, 1, 1]:  
                            action = "Close Notifications"
                            pyautogui.hotkey("esc")
                        elif fingers == [1, 1, 0, 0, 0]:  
                            action = "Left Click"
                            pyautogui.click()
                        elif fingers == [1, 1, 1, 0, 0]:  
                            action = "Right Click"
                            pyautogui.rightClick()

                        if action:
                            print(f"🖐 Gesture detected: {action}")
                            await sio.emit("action", {"action": action})
                            last_action_time = current_time  
                            await asyncio.sleep(2)  # Ensure at least 2 secs per gesture
            
            _, buffer = cv2.imencode(".jpg", frame)
            frame_base64 = base64.b64encode(buffer).decode("utf-8")
            await sio.emit("frame", {"frame": frame_base64})
            await asyncio.sleep(0.05)
    except asyncio.CancelledError:
        print("⚠️ Camera streaming task was cancelled.")

@sio.event
async def connect(sid, environ):
    print(f"✅ Client {sid} connected")

@sio.event
async def disconnect(sid):
    print(f"❌ Client {sid} disconnected")

@sio.on("start_camera")
async def start_camera(sid):
    global is_camera_running, camera_task

    if is_camera_running:
        print("⚠️ Camera already running!")
        return

    is_camera_running = True
    print(f"🎥 Client {sid} requested to start camera...")
    camera_task = asyncio.create_task(generate_frames())

@sio.on("stop_camera")
async def stop_camera(sid):
    global is_camera_running, camera_task, camera
    
    active_clients = len(sio.manager.get_participants("/", "start_camera"))
    if active_clients > 1:
        print(f"⚠️ Camera stop requested, but {active_clients} clients are still connected.")
        return

    print(f"📴 Stopping Camera - Last client {sid} disconnected.")
    is_camera_running = False

    if camera_task:
        camera_task.cancel()
        try:
            await camera_task
        except asyncio.CancelledError:
            pass
        camera_task = None

    if camera.isOpened():
        camera.release()
        print("📸 Camera released successfully.")

    await sio.emit("camera_stopped", {"message": "Camera stopped successfully"})

@app.get("/")
async def home():
    return {"message": "Gesture Control Server Running"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(socket_app, host="192.168.83.185", port=5000)
