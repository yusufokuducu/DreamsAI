import json
from PySide6.QtWidgets import (
    QMainWindow, QWidget, QVBoxLayout, QGridLayout, QHBoxLayout, 
    QPushButton, QProgressBar, QFileDialog, QLabel
)
from PySide6.QtGui import QAction, QColor, QPalette
from PySide6.QtCore import QThread

from src.ui.timeline import Timeline
from src.ui.properties_panel import PropertiesPanel
from src.ui.media_bin import MediaBin, PreviewPanel
from src.logic.exporter import Exporter

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Video Editor")
        self.setGeometry(100, 100, 1280, 720)
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)
        main_layout.setContentsMargins(0,0,0,0)
        main_layout.setSpacing(0)

        self.create_menu()
        self.timeline_panel = Timeline(self)
        self.undo_action.triggered.connect(self.timeline_panel.command_history.undo)
        self.redo_action.triggered.connect(self.timeline_panel.command_history.redo)
        header = self.create_header()
        main_layout.addWidget(header)

        content_widget = QWidget()
        grid_layout = QGridLayout(content_widget)
        main_layout.addWidget(content_widget)

        left_panel = QWidget()
        left_layout = QHBoxLayout(left_panel)
        left_layout.setContentsMargins(0,0,0,0)
        left_layout.setSpacing(0)

        toolbar = QWidget()
        toolbar.setFixedWidth(60)
        toolbar.setStyleSheet("background-color: #2E2E2E;")
        toolbar_layout = QVBoxLayout(toolbar)
        video_button = QPushButton("Video")
        text_button = QPushButton("Text")
        audio_button = QPushButton("Audio")
        toolbar_layout.addWidget(video_button)
        toolbar_layout.addWidget(text_button)
        toolbar_layout.addWidget(audio_button)
        toolbar_layout.addStretch()

        self.media_bin_widget = QWidget()
        mb_layout = QVBoxLayout(self.media_bin_widget)
        self.media_bin = MediaBin()
        mb_layout.addWidget(self.media_bin)
        left_layout.addWidget(toolbar)
        left_layout.addWidget(self.media_bin_widget)

        self.preview_panel = PreviewPanel()
        self.properties_panel = PropertiesPanel()

        timeline_container = QWidget()
        timeline_layout = QVBoxLayout(timeline_container)
        timeline_layout.setContentsMargins(0,0,0,0)
        
        controls_widget = QWidget()
        controls_layout = QHBoxLayout(controls_widget)
        play_button = QPushButton("Play")
        pause_button = QPushButton("Pause")
        split_button = QPushButton("Split")
        delete_button = QPushButton("Delete")
        add_transition_button = QPushButton("Add Transition")
        controls_layout.addWidget(play_button)
        controls_layout.addWidget(pause_button)
        controls_layout.addWidget(split_button)
        controls_layout.addWidget(delete_button)
        controls_layout.addWidget(add_transition_button)
        timeline_layout.addWidget(controls_widget)
        timeline_layout.addWidget(self.timeline_panel)

        grid_layout.addWidget(left_panel, 0, 0, 1, 1)
        grid_layout.addWidget(self.preview_panel, 0, 1, 1, 2)
        grid_layout.addWidget(self.properties_panel, 0, 3, 1, 1)
        grid_layout.addWidget(timeline_container, 1, 0, 1, 4)
        grid_layout.setColumnStretch(0, 25)
        grid_layout.setColumnStretch(1, 50)
        grid_layout.setColumnStretch(3, 25)
        grid_layout.setRowStretch(0, 70)
        grid_layout.setRowStretch(1, 30)

        self.status_bar = self.statusBar()
        self.progress_bar = QProgressBar()
        self.status_bar.addPermanentWidget(self.progress_bar)
        self.progress_bar.hide()

        # Connect signals
        video_button.clicked.connect(lambda: self.media_bin.open_file_dialog('video'))
        audio_button.clicked.connect(lambda: self.media_bin.open_file_dialog('audio'))
        self.media_bin.file_selected.connect(self.add_media_to_timeline)
        text_button.clicked.connect(self.timeline_panel.add_text_clip)
        self.timeline_panel.item_selected.connect(self.properties_panel.update_for_item)
        self.properties_panel.property_changed.connect(self.timeline_panel.on_property_changed)
        self.timeline_panel.frame_ready.connect(self.preview_panel.set_frame)
        play_button.clicked.connect(self.timeline_panel.play)
        pause_button.clicked.connect(self.timeline_panel.pause)
        split_button.clicked.connect(self.timeline_panel.split_selected)
        delete_button.clicked.connect(self.timeline_panel.delete_selected)
        add_transition_button.clicked.connect(self.timeline_panel.add_transition)

    def add_media_to_timeline(self, path, media_type):
        if media_type == 'video':
            self.timeline_panel.add_clip(path)
        elif media_type == 'audio':
            self.timeline_panel.add_audio_clip(path)

    def create_menu(self):
        menu_bar = self.menuBar()
        edit_menu = menu_bar.addMenu("Edit")
        self.undo_action = QAction("Undo", self)
        self.redo_action = QAction("Redo", self)
        edit_menu.addAction(self.undo_action)
        edit_menu.addAction(self.redo_action)

    def create_header(self):
        header_widget = QWidget()
        header_widget.setAutoFillBackground(True)
        pal = header_widget.palette()
        pal.setColor(QPalette.Window, QColor("#3c3c3c"))
        header_widget.setPalette(pal)
        header_layout = QHBoxLayout(header_widget)
        header_layout.setContentsMargins(10, 5, 10, 5)
        title = QLabel("Video Editor")
        title.setStyleSheet("font-weight: bold; font-size: 14px;")
        save_button = QPushButton("Save Project")
        save_button.clicked.connect(self.save_project)
        load_button = QPushButton("Load Project")
        load_button.clicked.connect(self.load_project)
        export_button = QPushButton("Export")
        export_button.clicked.connect(self.export_video)
        header_layout.addWidget(title)
        header_layout.addStretch()
        header_layout.addWidget(save_button)
        header_layout.addWidget(load_button)
        header_layout.addWidget(export_button)
        return header_widget

    def save_project(self):
        path, _ = QFileDialog.getSaveFileName(self, "Save Project", "", "JSON Files (*.json)")
        if not path: return
        project_data = self.timeline_panel.to_dict()
        with open(path, 'w') as f:
            json.dump(project_data, f, indent=4)

    def load_project(self):
        path, _ = QFileDialog.getOpenFileName(self, "Load Project", "", "JSON Files (*.json)")
        if not path: return
        with open(path, 'r') as f:
            project_data = json.load(f)
        self.timeline_panel.from_dict(project_data)

    def export_video(self):
        clips_data = self.timeline_panel.to_dict()
        if not clips_data: return
        output_path, _ = QFileDialog.getSaveFileName(self, "Save Video", "", "MP4 Files (*.mp4)")
        if not output_path: return
        self.progress_bar.show()
        self.progress_bar.setValue(0)
        self.thread = QThread()
        self.exporter = Exporter()
        self.exporter.moveToThread(self.thread)
        self.thread.started.connect(lambda: self.exporter.export(clips_data, output_path))
        self.exporter.finished.connect(self.on_export_finished)
        self.exporter.error.connect(self.on_export_error)
        self.exporter.progress.connect(self.on_export_progress)
        self.thread.start()

    def on_export_progress(self, value):
        self.progress_bar.setValue(value)

    def on_export_finished(self):
        self.progress_bar.setValue(100)
        self.thread.quit()
        self.thread.wait()
        self.progress_bar.hide()

    def on_export_error(self, error_msg):
        print(f"Export Error: {error_msg}")
        self.thread.quit()
        self.thread.wait()
        self.progress_bar.hide()
