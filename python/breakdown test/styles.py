light_stylesheet = """
QMainWindow, QWidget {
    background-color: #ffffff;
    color: #000;
    font-family: "Segoe UI", sans-serif;
    font-size: 10pt;
}
QPushButton {
    background-color: #e6e6e6;
    border: 1px solid #ccc;
    border-radius: 3px;
    padding: 5px 10px;
}
QPushButton:hover {
    background-color: #d9d9d9;
}
QLineEdit, QComboBox, QSlider {
    background-color: #ffffff;
    border: 1px solid #ccc;
    border-radius: 3px;
    padding: 3px;
}
QLabel {
    color: #000;
}
QTabWidget::pane {
    border: none;
    background-color: #ffffff;
}
QTabBar::tab {
    background: #e6e6e6;
    padding: 8px;
    margin: 2px;
    border-radius: 3px;
    color: #000;
}
QTabBar::tab:selected {
    background: #ffffff;
    border-bottom: 2px solid #0078d7;
}
"""

dark_stylesheet = """
QMainWindow, QWidget {
    background-color: #121212;
    color: #e0e0e0;
    font-family: "Segoe UI", sans-serif;
    font-size: 10pt;
}
QPushButton {
    background-color: #2a2a2a;
    border: 1px solid #333;
    border-radius: 3px;
    padding: 5px 10px;
}
QPushButton:hover {
    background-color: #333333;
}
QLineEdit, QComboBox, QSlider {
    background-color: #1e1e1e;
    border: 1px solid #333;
    border-radius: 3px;
    padding: 3px;
    color: #e0e0e0;
}
QLabel {
    color: #e0e0e0;
}
QTabWidget::pane {
    border: none;
    background-color: #121212;
}
QTabBar::tab {
    background: #1e1e1e;
    padding: 8px;
    margin: 2px;
    border-radius: 3px;
    color: #e0e0e0;
}
QTabBar::tab:selected {
    background: #121212;
    border-bottom: 2px solid #0078d7;
}
"""
