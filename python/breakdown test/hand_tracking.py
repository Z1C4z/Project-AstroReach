import cv2
import json
import numpy as np
import subprocess
import platform
from threading import Thread

from PyQt5 import QtWidgets, QtCore, QtGui
from PyQt5.QtWidgets import QWidget, QLabel, QPushButton, QVBoxLayout, QHBoxLayout, QMessageBox
from PyQt5.QtGui import QImage, QPixmap, QFont
from PyQt5.QtCore import QTimer, Qt

import mediapipe as mp
from udp_socket import sock

class HandTrackingWidget(QWidget):
    message_signal = QtCore.pyqtSignal(str, str)  # (type, message)

    def __init__(self, ip_getter):
        """
        ip_getter: function that returns the current IP (from the ip_entry field)
        """
        super().__init__()
        self.setWindowTitle("Hand Pose Detection")
        self.ip_getter = ip_getter
        layout = QVBoxLayout(self)
        layout.setContentsMargins(10, 10, 10, 10)
        
        # Video area with placeholder
        self.video_label = QLabel()
        self.video_label.setFixedSize(640, 480)
        self.video_label.setAlignment(Qt.AlignCenter)
        self.set_placeholder()
        layout.addWidget(self.video_label, alignment=Qt.AlignCenter)
        
        # Label for detected pose
        self.pose_label = QLabel("Pose da Mão: Desconhecida")
        self.pose_label.setAlignment(Qt.AlignCenter)
        self.pose_label.setFont(QFont("Segoe UI", 12))
        layout.addWidget(self.pose_label)

        # Label for connection status
        self.connectionLabel = QLabel("Dispositivo não conectado!")
        self.connectionLabel.setAlignment(Qt.AlignCenter)
        self.connectionLabel.setFont(QFont("Segoe UI", 12))
        self.connectionLabel.setVisible(False)
        layout.addWidget(self.connectionLabel)
        
        # Control buttons
        buttons_layout = QHBoxLayout()
        self.start_button = QPushButton("Iniciar")
        self.start_button.clicked.connect(self.start_tracking)
        buttons_layout.addWidget(self.start_button)
        
        self.stop_button = QPushButton("Parar")
        self.stop_button.clicked.connect(self.stop_tracking)
        buttons_layout.addWidget(self.stop_button)
        layout.addLayout(buttons_layout)
        
        # Control variables
        self.cap = None
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update_frame)
        
        # Timer for periodic UDP transmission (send data at a lower frequency, e.g., every 100 ms)
        self.udp_timer = QTimer(self)
        self.udp_timer.timeout.connect(self.send_udp_data)
        self.udp_timer.start(100)
        
        # Timer for periodic connectivity check (every 5 seconds)
        self.connection_timer = QTimer(self)
        self.connection_timer.timeout.connect(self.check_connection)
        self.connection_timer.start(5000)
        self.is_connected = False  # Cached connection status
        
        # Variable to store the latest hand data
        self.current_hand_data = {}
        
        # MediaPipe configuration
        self.mp_hands = mp.solutions.hands
        self.mp_drawing = mp.solutions.drawing_utils
        self.mp_drawing_styles = mp.solutions.drawing_styles
        self.hands = self.mp_hands.Hands(min_detection_confidence=0.5, min_tracking_confidence=0.5)

    def set_placeholder(self):
        placeholder_color = QtGui.QColor("#cccccc")
        image = QImage(640, 480, QImage.Format_RGB888)
        image.fill(placeholder_color)
        self.video_label.setPixmap(QPixmap.fromImage(image))

    def start_tracking(self):
        self.cap = cv2.VideoCapture(0)
        self.timer.start(30)

    def show_message(self, msg_type, message):
        if msg_type == "info":
            QMessageBox.information(self, "Sucesso", message)
        elif msg_type == "error":
            QMessageBox.critical(self, "Erro", message)

    def update_frame(self):
        if self.cap is not None and self.cap.isOpened():
            ret, frame = self.cap.read()
            if not ret:
                return
            frame = cv2.flip(frame, 1)
            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = self.hands.process(rgb_frame)
 
            pose = "unknown"
            hand_data = {}
            if results.multi_hand_landmarks:
                for hand_landmarks, handedness in zip(results.multi_hand_landmarks, results.multi_handedness):
                    self.mp_drawing.draw_landmarks(
                        frame, hand_landmarks, self.mp_hands.HAND_CONNECTIONS,
                        self.mp_drawing_styles.get_default_hand_landmarks_style(),
                        self.mp_drawing_styles.get_default_hand_connections_style()
                    )
                    label = handedness.classification[0].label
                    pose = self.detect_gesture(hand_landmarks)
                   
                    landmarks = []
                    for lm in hand_landmarks.landmark:
                        landmarks.append({"x": lm.x, "y": lm.y})
                    hand_data[label] = {"landmarks": landmarks, "pose": pose}
                   
                    pos = (50, 50 if label == "Right" else 100)
                    cv2.putText(frame, f"{label}: {pose}", pos, cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
 
            # Update the stored hand data (to be sent via UDP)
            self.current_hand_data = hand_data

            self.pose_label.setText(f"Pose da Mão: {pose}")
 
            # Convert the image to QImage and update the QLabel
            rgb_image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            h, w, ch = rgb_image.shape
            bytes_per_line = ch * w
            qt_image = QImage(rgb_image.data, w, h, bytes_per_line, QImage.Format_RGB888)
            self.video_label.setPixmap(QPixmap.fromImage(qt_image))

    def send_udp_data(self):
        """Send UDP data at a lower frequency using the latest hand data."""
        if self.current_hand_data:
            udp_ip = self.ip_getter()
            message = json.dumps(self.current_hand_data)
            if self.is_connected:
                try:
                    sock.sendto(message.encode(), (udp_ip, 5005))
                    self.connectionLabel.setVisible(False)
                except Exception:
                    self.connectionLabel.setVisible(True)
            else:
                self.connectionLabel.setVisible(True)

    def stop_tracking(self):
        self.set_placeholder()
        self.timer.stop()
        if self.cap is not None:
            self.cap.release()
            self.cap = None

    def is_finger_extended(self, hand_landmarks, finger_tip, finger_dip):
        return hand_landmarks.landmark[finger_tip].y < hand_landmarks.landmark[finger_dip].y
    
    def distance(self, a, b):
        return np.sqrt((a.x - b.x) ** 2 + (a.y - b.y) ** 2)

    def detect_gesture(self, hand_landmarks):
        indicador = self.is_finger_extended(hand_landmarks, 8, 6)
        medio = self.is_finger_extended(hand_landmarks, 12, 10)
        anelar = self.is_finger_extended(hand_landmarks, 16, 14)
        mindinho = self.is_finger_extended(hand_landmarks, 20, 18)
       
        thumb_tip = hand_landmarks.landmark[4]
        index_tip = hand_landmarks.landmark[8]
        thumb_index_dist = self.distance(thumb_tip, index_tip)
 
        if indicador and not medio and not anelar and not mindinho:
            return "pointer"
        elif indicador and medio and anelar and mindinho:
            return "open"
        elif not indicador and not medio and not anelar and not mindinho:
            return "close"
        elif indicador and medio and not anelar and not mindinho:
            return "two"
        else:
            return "unknown"

    def check_connection(self):
        """Periodically checks if the target IP is reachable using a ping command."""
        ip = self.ip_getter()
        if ip:
            reachable = self.is_ip_reachable(ip)
            self.is_connected = reachable
            self.connectionLabel.setVisible(not reachable)
        else:
            self.is_connected = False
            self.connectionLabel.setVisible(True)

    def is_ip_reachable(self, ip):
        """
        Pings the given IP address. Returns True if reachable, False otherwise.
        Uses different parameters for Windows and Unix-based systems.
        """
        param = '-n' if platform.system().lower() == 'windows' else '-c'
        timeout_param = '-w' if platform.system().lower() == 'windows' else '-W'
        # For Windows, -w timeout is in milliseconds; for Unix, -W is in seconds.
        command = ['ping', param, '1', timeout_param, '1', ip]
        try:
            result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            return result.returncode == 0
        except Exception:
            return False
