from PySide6.QtWidgets import QWidget, QVBoxLayout, QLabel, QFileDialog
from PySide6.QtGui import QPalette, QColor, QPixmap
from PySide6.QtCore import Qt, Signal

class MediaBin(QWidget):
    file_selected = Signal(str, str)
    def __init__(self):
        super().__init__()
        self.setAutoFillBackground(True)
        palette = self.palette()
        palette.setColor(QPalette.Window, QColor("#252525"))
        self.setPalette(palette)

    def open_file_dialog(self, media_type):
        if media_type == 'video':
            paths, _ = QFileDialog.getOpenFileNames(self, "Open Video Files", "", "Video Files (*.mp4 *.mov *.avi)")
        elif media_type == 'audio':
            paths, _ = QFileDialog.getOpenFileNames(self, "Open Audio Files", "", "Audio Files (*.mp3 *.wav)")
        if paths:
            for p in paths:
                self.file_selected.emit(p, media_type)

class PreviewPanel(QWidget):
    def __init__(self):
        super().__init__()
        self.setAutoFillBackground(True)
        palette = self.palette()
        palette.setColor(QPalette.Window, QColor("#1E1E1E"))
        self.setPalette(palette)
        self.layout = QVBoxLayout(self)
        self.video_label = QLabel("It's empty here")
        self.video_label.setAlignment(Qt.AlignCenter)
        self.layout.addWidget(self.video_label)

    def set_frame(self, q_image):
        self.video_label.setPixmap(QPixmap.fromImage(q_image).scaled(self.video_label.size(), Qt.KeepAspectRatio, Qt.SmoothTransformation))
