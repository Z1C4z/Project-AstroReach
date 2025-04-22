import os
import json
from threading import Thread

from PyQt5 import QtWidgets, QtCore
from PyQt5.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QInputDialog, QMessageBox, QLabel, QPushButton

from udp_socket import sock

class CameraControllerApp(QWidget):
    message_signal = QtCore.pyqtSignal(str, str)  # (type, message)

    def __init__(self):
        super().__init__()
        self.setWindowTitle("Godot Camera Controller")
        layout = QVBoxLayout(self)
        layout.setContentsMargins(10, 10, 10, 10)
        self.message_signal.connect(self.show_message)

        # Preset combobox and buttons
        top_layout = QHBoxLayout()
        self.preset_combobox = QtWidgets.QComboBox()
        self.preset_combobox.addItem("Selecione Predefinição")
        self.preset_combobox.currentIndexChanged.connect(self.load_preset)
        top_layout.addWidget(self.preset_combobox)

        self.save_button = QPushButton("Salvar")
        self.save_button.clicked.connect(self.save_preset)
        top_layout.addWidget(self.save_button)

        self.delete_button = QPushButton("Excluir")
        self.delete_button.clicked.connect(self.delete_preset)
        top_layout.addWidget(self.delete_button)
        layout.addLayout(top_layout)

        # IP entry for Godot device
        layout.addWidget(QLabel("IP do Dispositivo Godot:"))
        self.ip_entry = QtWidgets.QLineEdit("127.0.0.1")
        layout.addWidget(self.ip_entry)

        # Reset button
        self.reset_button = QPushButton("Resetar Rotação")
        self.reset_button.clicked.connect(self.on_reset_click)
        layout.addWidget(self.reset_button)

        # IPD slider
        self.ipd_label = QLabel("Distância IPD: 2.0")
        layout.addWidget(self.ipd_label)
        self.ipd_scale = QtWidgets.QSlider(QtCore.Qt.Horizontal)
        self.ipd_scale.setRange(0, 200)
        self.ipd_scale.setValue(20)
        self.ipd_scale.valueChanged.connect(self.update_ipd_label)
        layout.addWidget(self.ipd_scale)

        # Subviewport Scale slider
        self.svs_label = QLabel("Subviewport Scale: 1.5")
        layout.addWidget(self.svs_label)
        self.svs_scale = QtWidgets.QSlider(QtCore.Qt.Horizontal)
        self.svs_scale.setRange(10, 30)  # 10 -> 1.0, 30 -> 3.0
        self.svs_scale.setValue(15)
        self.svs_scale.valueChanged.connect(self.update_svs_label)
        layout.addWidget(self.svs_scale)

        # Gyro Sensitivity slider
        self.gs_label = QLabel("Gyro Sensitive: 50")
        layout.addWidget(self.gs_label)
        self.gs_scale = QtWidgets.QSlider(QtCore.Qt.Horizontal)
        self.gs_scale.setRange(0, 100)
        self.gs_scale.setValue(50)
        self.gs_scale.valueChanged.connect(self.update_gs_label)
        layout.addWidget(self.gs_scale)

        # Button to send values (uses port 6000)
        self.send_values_button = QPushButton("Enviar Valores")
        self.send_values_button.clicked.connect(self.on_send_values_click)
        layout.addWidget(self.send_values_button)

        self.load_presets()

    def show_message(self, msg_type, message):
        if msg_type == "info":
            QMessageBox.information(self, "Sucesso", message)
        elif msg_type == "error":
            QMessageBox.critical(self, "Erro", message)

    def update_ipd_label(self):
        self.ipd_label.setText(f"Distância IPD: {self.ipd_scale.value() / 10:.1f}")

    def update_svs_label(self):
        self.svs_label.setText(f"Subviewport Scale: {self.svs_scale.value() / 10:.1f}")

    def update_gs_label(self):
        self.gs_label.setText(f"Gyro Sensitive: {self.gs_scale.value()}")

    def load_presets(self):
        if os.path.exists("presets.json"):
            with open("presets.json", "r") as f:
                presets = json.load(f)
            for preset in presets:
                self.preset_combobox.addItem(preset)

    def save_presets(self, preset_name, values):
        presets = self.load_presets_from_file()
        presets[preset_name] = values
        with open("presets.json", "w") as f:
            json.dump(presets, f)

    def load_presets_from_file(self):
        if os.path.exists("presets.json"):
            with open("presets.json", "r") as f:
                return json.load(f)
        return {}

    def save_preset(self):
        preset_name, ok = QInputDialog.getText(self, "Salvar Predefinição", "Nome da predefinição:")
        if ok and preset_name:
            values = {
                "ipd": self.ipd_scale.value() / 10,
                "subviewport_scale": self.svs_scale.value() / 10,
                "gyro_sensitivity": self.gs_scale.value()
            }
            self.save_presets(preset_name, values)
            self.preset_combobox.addItem(preset_name)
            self.message_signal.emit("info", "Predefinição salva com sucesso!")

    def delete_preset(self):
        preset_name = self.preset_combobox.currentText()
        if preset_name == "Selecione Predefinição":
            self.message_signal.emit("error", "Selecione uma predefinição para excluir.")
            return

        presets = self.load_presets_from_file()
        if preset_name in presets:
            del presets[preset_name]
            with open("presets.json", "w") as f:
                json.dump(presets, f)
            self.preset_combobox.removeItem(self.preset_combobox.currentIndex())
            self.message_signal.emit("info", "Predefinição excluída com sucesso!")

    def load_preset(self):
        preset_name = self.preset_combobox.currentText()
        if preset_name == "Selecione Predefinição":
            return
        presets = self.load_presets_from_file()
        if preset_name in presets:
            values = presets[preset_name]
            self.ipd_scale.setValue(int(values["ipd"] * 10))
            self.svs_scale.setValue(int(values["subviewport_scale"] * 10))
            self.gs_scale.setValue(values["gyro_sensitivity"])

    def send_reset(self, ip, port=6000):
        self.send_message({"reset": 0}, ip, port)

    def send_message(self, message, ip, port=6000):
        try:
            data = json.dumps(message)
            sock.sendto(data.encode("utf-8"), (ip, port))
            self.message_signal.emit("info", "Sinal enviado com sucesso!")
        except Exception as e:
            self.message_signal.emit("error", f"Erro na conexão: {str(e)}")

    def on_reset_click(self):
        ip = self.ip_entry.text()
        if ip:
            Thread(target=self.send_reset, args=(ip,)).start()

    def on_send_values_click(self):
        ip = self.ip_entry.text()
        data = {
            "ipd": self.ipd_scale.value() / 10,
            "subviewport_scale": self.svs_scale.value() / 10,
            "gyro_sensitivity": self.gs_scale.value()
        }
        Thread(target=self.send_message, args=(data, ip, 6000)).start()
