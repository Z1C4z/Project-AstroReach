from PyQt5 import QtWidgets, QtCore
from PyQt5.QtWidgets import QMainWindow, QTabWidget, QStatusBar, QMessageBox

from camera_controller import CameraControllerApp
from hand_tracking import HandTrackingWidget
from styles import light_stylesheet, dark_stylesheet

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Aplicativo Unificado")
        self.setFixedSize(800, 600)

        # Apply light theme as default
        self.current_theme = "light"
        QtWidgets.QApplication.instance().setStyleSheet(light_stylesheet)

        # Create tabs for modules
        self.tabs = QTabWidget()
        self.camera_controller = CameraControllerApp()
        self.hand_tracking = HandTrackingWidget(ip_getter=lambda: self.camera_controller.ip_entry.text())
        self.tabs.addTab(self.camera_controller, "Controles")
        self.tabs.addTab(self.hand_tracking, "Hand Tracking")
        self.setCentralWidget(self.tabs)

        # Minimalist options menu
        self.create_menu()

        # Status bar
        self.status_bar = QStatusBar()
        self.setStatusBar(self.status_bar)

    def create_menu(self):
        menu_bar = self.menuBar()
        theme_menu = menu_bar.addMenu("Tema")
        light_action = theme_menu.addAction("Tema Claro")
        dark_action = theme_menu.addAction("Tema Escuro")
        light_action.triggered.connect(self.set_light_theme)
        dark_action.triggered.connect(self.set_dark_theme)
        help_menu = menu_bar.addMenu("Ajuda")
        about_action = help_menu.addAction("Sobre")
        about_action.triggered.connect(self.show_about)

    def set_light_theme(self):
        QtWidgets.QApplication.instance().setStyleSheet(light_stylesheet)
        self.current_theme = "light"
        self.status_bar.showMessage("Tema claro ativado", 3000)

    def set_dark_theme(self):
        QtWidgets.QApplication.instance().setStyleSheet(dark_stylesheet)
        self.current_theme = "dark"
        self.status_bar.showMessage("Tema escuro ativado", 3000)

    def show_about(self):
        QMessageBox.information(self, "Sobre", "Aplicativo Unificado\nVersão 1.0\nDesenvolvido com PyQt5.")
