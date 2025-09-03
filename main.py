import sys
import cv2
import json
import numpy as np
from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QGridLayout, QLabel, QVBoxLayout,
    QFileDialog, QGraphicsView, QGraphicsScene, QGraphicsRectItem, QPushButton,
    QHBoxLayout, QProgressBar, QLineEdit, QFontComboBox, QSpinBox, QColorDialog
)
from PySide6.QtGui import (
    QColor, QPalette, QMouseEvent, QPen, QBrush, QFont, QPainter, QImage, QPixmap
)
from PySide6.QtCore import Qt, Signal, QRectF, QTimer, QObject, QThread
from moviepy.editor import (VideoFileClip, concatenate_videoclips, TextClip, 
                              CompositeVideoClip, AudioFileClip, concatenate_audioclips)
from PIL import Image, ImageDraw, ImageFont

# --- Data Types ---
CLIP_TYPE = 1001
TEXT_TYPE = 1002
AUDIO_TYPE = 1003
TRANSITION_TYPE = 1004

# --- Exporter Worker ---
class Exporter(QObject):
    progress = Signal(int); finished = Signal(); error = Signal(str)
    def export(self, clips_data, output_path):
        try:
            video_clips_info = [c for c in clips_data if c['type'] == CLIP_TYPE]
            text_clips_info = [c for c in clips_data if c['type'] == TEXT_TYPE]
            audio_clips_info = [c for c in clips_data if c['type'] == AUDIO_TYPE]
            if not video_clips_info: self.error.emit("No video clips on timeline to export."); return
            
            # Sort clips by their x position
            video_clips_info.sort(key=lambda c: c['x'])

            moviepy_video_clips = [VideoFileClip(c['data'][0]).subclip(c['data'][2], c['data'][2] + c['data'][1]) for c in video_clips_info]
            
            # Handle transitions (assuming crossfade for now)
            final_clips = []
            if moviepy_video_clips:
                final_clips.append(moviepy_video_clips[0])
                for i in range(len(moviepy_video_clips) - 1):
                    # Check if there is a transition between clip i and i+1
                    transition_duration = 1 # default 1 second
                    # A more robust way would be to get this from transition_items on timeline
                    
                    clip1 = final_clips.pop()
                    clip2 = moviepy_video_clips[i+1]

                    # Adjust clip durations for the transition
                    clip1 = clip1.subclip(0, clip1.duration - transition_duration)
                    
                    # Create the transition
                    from moviepy.effects.vfx.fadein import fadein
                    from moviepy.effects.vfx.fadeout import fadeout
                    
                    # This is a simple crossfade, more complex logic needed for other transitions
                    final_clip = CompositeVideoClip([clip1, clip2.set_start(clip1.duration-transition_duration).crossfadein(transition_duration)])
                    final_clips.append(final_clip)


            base_video = concatenate_videoclips(final_clips)
            self.progress.emit(20)

            moviepy_text_clips = [TextClip(c['data'][0], fontsize=c['data'][3], color=c['data'][4], font=c['data'][2], size=base_video.size).set_duration(c['data'][1]).set_start(c['x'] / 50.0) for c in text_clips_info]
            self.progress.emit(40)
            
            final_audio = None
            if audio_clips_info:
                moviepy_audio_clips = [AudioFileClip(c['data'][0]).set_duration(c['data'][1]) for c in audio_clips_info]
                final_audio = concatenate_audioclips(moviepy_audio_clips)
            self.progress.emit(60)

            final_clip = CompositeVideoClip([base_video] + moviepy_text_clips)
            if final_audio: final_clip.audio = final_audio
            
            def moviepy_progress(t, duration): self.progress.emit(60 + int((t / duration) * 40))
            final_clip.write_videofile(output_path, codec="libx264", audio_codec="aac", progress_handler=moviepy_progress)
            self.finished.emit()
        except Exception as e: self.error.emit(str(e))

# --- Custom Graphics Items ---
class VideoClipItem(QGraphicsRectItem):
    def type(self): return CLIP_TYPE
    def __init__(self, *args, **kwargs): super().__init__(*args, **kwargs); self.setBrush(QBrush(QColor("#4a82da"))); self.setPen(QPen(Qt.NoPen)); self.setFlag(QGraphicsRectItem.ItemIsMovable); self.setFlag(QGraphicsRectItem.ItemIsSelectable)

class TextClipItem(QGraphicsRectItem):
    def type(self): return TEXT_TYPE
    def __init__(self, *args, **kwargs): super().__init__(*args, **kwargs); self.setBrush(QBrush(QColor("#db8d4a"))); self.setPen(QPen(Qt.NoPen)); self.setFlag(QGraphicsRectItem.ItemIsMovable); self.setFlag(QGraphicsRectItem.ItemIsSelectable)

class AudioClipItem(QGraphicsRectItem):
    def type(self): return AUDIO_TYPE
    def __init__(self, *args, **kwargs): super().__init__(*args, **kwargs); self.setBrush(QBrush(QColor("#4adbad"))); self.setPen(QPen(Qt.NoPen)); self.setFlag(QGraphicsRectItem.ItemIsMovable); self.setFlag(QGraphicsRectItem.ItemIsSelectable)

class TransitionItem(QGraphicsRectItem):
    def type(self): return TRANSITION_TYPE
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.setBrush(QBrush(QColor(255, 0, 0, 128))) # Semi-transparent red
        self.setPen(QPen(Qt.NoPen))
        self.setFlag(QGraphicsRectItem.ItemIsSelectable)

# --- UI Widgets ---
class MediaBin(QWidget):
    file_selected = Signal(str, str)
    def __init__(self):
        super().__init__(); self.setAutoFillBackground(True)
        palette = self.palette(); palette.setColor(QPalette.Window, QColor("#252525")); self.setPalette(palette)
    def open_file_dialog(self, media_type):
        if media_type == 'video': paths, _ = QFileDialog.getOpenFileNames(self, "Open Video Files", "", "Video Files (*.mp4 *.mov *.avi)")
        elif media_type == 'audio': paths, _ = QFileDialog.getOpenFileNames(self, "Open Audio Files", "", "Audio Files (*.mp3 *.wav)")
        if paths: [self.file_selected.emit(p, media_type) for p in paths]

class PreviewPanel(QWidget):
    def __init__(self):
        super().__init__(); self.setAutoFillBackground(True)
        palette = self.palette(); palette.setColor(QPalette.Window, QColor("#1E1E1E")); self.setPalette(palette)
        self.layout = QVBoxLayout(self); self.video_label = QLabel("It's empty here"); self.video_label.setAlignment(Qt.AlignCenter); self.layout.addWidget(self.video_label)
    def set_frame(self, q_image): self.video_label.setPixmap(QPixmap.fromImage(q_image).scaled(self.video_label.size(), Qt.KeepAspectRatio, Qt.SmoothTransformation))

class PropertiesPanel(QWidget):
    text_changed = Signal(str)
    font_changed = Signal(str)
    font_size_changed = Signal(int)
    color_changed = Signal(QColor)

    def __init__(self):
        super().__init__(); self.setAutoFillBackground(True)
        palette = self.palette(); palette.setColor(QPalette.Window, QColor("#2E2E2E")); self.setPalette(palette)
        self.layout = QVBoxLayout(self); self.layout.setAlignment(Qt.AlignTop); self.layout.setContentsMargins(10, 10, 10, 10)
        title = QLabel("Properties"); title.setStyleSheet("font-weight: bold; font-size: 14px;"); self.layout.addWidget(title)
        self.path_label = QLabel(); self.path_label.setWordWrap(True); self.duration_label = QLabel()
        
        self.text_edit_label = QLabel("Text Content:"); self.text_edit = QLineEdit()
        self.font_label = QLabel("Font:"); self.font_combo = QFontComboBox()
        self.font_size_label = QLabel("Font Size:"); self.font_size_spinbox = QSpinBox(); self.font_size_spinbox.setRange(1, 200); self.font_size_spinbox.setValue(70)
        self.color_label = QLabel("Color:"); self.color_button = QPushButton("Select Color")

        self.layout.addWidget(self.path_label); self.layout.addWidget(self.duration_label)
        self.layout.addWidget(self.text_edit_label); self.layout.addWidget(self.text_edit)
        self.layout.addWidget(self.font_label); self.layout.addWidget(self.font_combo)
        self.layout.addWidget(self.font_size_label); self.layout.addWidget(self.font_size_spinbox)
        self.layout.addWidget(self.color_label); self.layout.addWidget(self.color_button)

        self.text_edit.textChanged.connect(self.text_changed.emit)
        self.font_combo.currentFontChanged.connect(lambda font: self.font_changed.emit(font.family()))
        self.font_size_spinbox.valueChanged.connect(self.font_size_changed.emit)
        self.color_button.clicked.connect(self.open_color_dialog)
        
        self.clear_properties()

    def open_color_dialog(self):
        color = QColorDialog.getColor()
        if color.isValid():
            self.color_changed.emit(color)
            self.update_color_button(color)

    def update_color_button(self, color):
        self.color_button.setStyleSheet(f"background-color: {color.name()};")

    def update_for_item(self, item):
        self.clear_properties()
        if not item: return
        if item.type() in [CLIP_TYPE, AUDIO_TYPE]:
            self.path_label.show(); self.duration_label.show()
            self.path_label.setText(f"File: {item.data(0)}"); self.duration_label.setText(f"Duration: {item.data(1):.2f}s")
        elif item.type() == TEXT_TYPE:
            self.text_edit_label.show(); self.text_edit.show(); self.text_edit.setText(item.data(0))
            self.font_label.show(); self.font_combo.show(); self.font_combo.setCurrentFont(QFont(item.data(2)))
            self.font_size_label.show(); self.font_size_spinbox.show(); self.font_size_spinbox.setValue(item.data(3))
            self.color_label.show(); self.color_button.show(); self.update_color_button(QColor(item.data(4)))
        elif item.type() == TRANSITION_TYPE:
            self.path_label.show()
            self.path_label.setText("Transition")


    def clear_properties(self):
        self.path_label.hide(); self.duration_label.hide()
        self.text_edit_label.hide(); self.text_edit.hide()
        self.font_label.hide(); self.font_combo.hide()
        self.font_size_label.hide(); self.font_size_spinbox.hide()
        self.color_label.hide(); self.color_button.hide()

class Timeline(QGraphicsView):
    frame_ready = Signal(QImage); item_selected = Signal(QGraphicsRectItem)
    def __init__(self):
        super().__init__(); self.scene = QGraphicsScene(); self.setScene(self.scene)
        self.setRenderHint(QPainter.Antialiasing); self.setBackgroundBrush(QColor("#252525")); self.setFrameShape(QGraphicsView.NoFrame)
        self.ruler_height = 30; self.pixels_per_second = 50; self.track_height = 60
        self.video_track_y = self.ruler_height + 10; self.text_track_y = self.video_track_y + self.track_height; self.audio_track_y = self.text_track_y + self.track_height
        self.video_captures = {}; self.setup_scene()
        self.playback_timer = QTimer(self); self.playback_timer.setInterval(1000 // 30); self.playback_timer.timeout.connect(self.update_playback)
        self.scene.selectionChanged.connect(self.on_selection_changed)

    def setup_scene(self):
        self.scene.clear()
        self.draw_ruler()
        self.playhead = self.scene.addLine(0, 0, 0, 600, QPen(Qt.red, 2))

    def draw_ruler(self):
        self.scene.setSceneRect(0, 0, self.pixels_per_second * 60 * 10, 600)
        pen = QPen(Qt.white); font = QFont("Arial", 8); self.scene.addLine(0, self.ruler_height, self.scene.width(), self.ruler_height, pen)
        for i in range(int(self.scene.width() / self.pixels_per_second)):
            x = i * self.pixels_per_second
            if i % 5 == 0: self.scene.addLine(x, self.ruler_height - 10, x, self.ruler_height, pen); text = self.scene.addText(f"{i}s", font); text.setDefaultTextColor(Qt.white); text.setPos(x + 2, self.ruler_height - 25)
            else: self.scene.addLine(x, self.ruler_height - 5, x, self.ruler_height, pen)

    def add_clip(self, file_path):
        try:
            if file_path not in self.video_captures: self.video_captures[file_path] = cv2.VideoCapture(file_path)
            cap = self.video_captures[file_path]; fps = cap.get(cv2.CAP_PROP_FPS); duration = cap.get(cv2.CAP_PROP_FRAME_COUNT) / fps
            clip_width = duration * self.pixels_per_second; x_pos = 0
            for item in self.scene.items():
                if isinstance(item, VideoClipItem): x_pos = max(x_pos, item.sceneBoundingRect().right())
            clip_rect = VideoClipItem(x_pos, self.video_track_y, clip_width, self.track_height - 10)
            clip_rect.setData(0, file_path); clip_rect.setData(1, duration); clip_rect.setData(2, 0.0); self.scene.addItem(clip_rect)
        except Exception as e: print(f"Error adding clip: {e}")

    def add_text_clip(self):
        default_duration = 5; clip_width = default_duration * self.pixels_per_second
        text_item = TextClipItem(0, self.text_track_y, clip_width, self.track_height - 10)
        text_item.setData(0, "New Text"); text_item.setData(1, default_duration)
        text_item.setData(2, "Arial"); text_item.setData(3, 70); text_item.setData(4, "white") # font, size, color
        self.scene.addItem(text_item)

    def add_audio_clip(self, file_path):
        try:
            audio = AudioFileClip(file_path); duration = audio.duration; clip_width = duration * self.pixels_per_second; x_pos = 0
            for item in self.scene.items():
                if isinstance(item, AudioClipItem): x_pos = max(x_pos, item.sceneBoundingRect().right())
            clip_rect = AudioClipItem(x_pos, self.audio_track_y, clip_width, self.track_height - 10)
            clip_rect.setData(0, file_path); clip_rect.setData(1, duration); self.scene.addItem(clip_rect)
        except Exception as e: print(f"Error adding audio clip: {e}")

    def add_transition(self):
        playhead_x = self.playhead.line().x1()
        
        # Find two adjacent video clips at the playhead position
        items_at_pos = self.scene.items(QRectF(playhead_x - 1, self.video_track_y, 2, self.track_height))
        video_clips = [item for item in items_at_pos if isinstance(item, VideoClipItem)]

        if len(video_clips) == 2:
            clip1 = min(video_clips, key=lambda c: c.sceneBoundingRect().right())
            clip2 = max(video_clips, key=lambda c: c.sceneBoundingRect().left())

            # Check if they are adjacent
            if clip1.sceneBoundingRect().right() == clip2.sceneBoundingRect().left():
                duration = 1.0 # 1 second
                width = duration * self.pixels_per_second
                
                # Create and add the transition item
                transition_item = TransitionItem(clip1.sceneBoundingRect().right() - width / 2, self.video_track_y, width, self.track_height - 10)
                transition_item.setData(0, 'crossfade')
                transition_item.setData(1, duration)
                self.scene.addItem(transition_item)


    def to_dict(self):
        project_data = []
        for item in self.scene.items():
            if not isinstance(item, QGraphicsRectItem): continue
            
            num_data = 0
            if item.type() == TEXT_TYPE:
                num_data = 5
            elif item.type() in [CLIP_TYPE, AUDIO_TYPE]:
                num_data = 3
            elif item.type() == TRANSITION_TYPE:
                num_data = 2

            item_data = {
                'type': item.type(),
                'x': item.x(), 'y': item.y(), 'width': item.rect().width(), 'height': item.rect().height(),
                'data': [item.data(i) for i in range(num_data)]
            }
            project_data.append(item_data)
        return project_data

    def from_dict(self, project_data):
        self.setup_scene()
        for item_data in project_data:
            item_type = item_data['type']
            if item_type == CLIP_TYPE: item = VideoClipItem()
            elif item_type == TEXT_TYPE: item = TextClipItem()
            elif item_type == AUDIO_TYPE: item = AudioClipItem()
            elif item_type == TRANSITION_TYPE: item = TransitionItem()
            else: continue
            item.setRect(0, 0, item_data['width'], item_data['height'])
            item.setPos(item_data['x'], item_data['y'])
            for i, data in enumerate(item_data['data']):
                item.setData(i, data)
            self.scene.addItem(item)

    def on_selection_changed(self): selected_items = self.scene.selectedItems(); self.item_selected.emit(selected_items[0] if selected_items else None)
    
    def update_selected_text(self, text): 
        selected_items = self.scene.selectedItems()
        if selected_items and selected_items[0].type() == TEXT_TYPE: selected_items[0].setData(0, text)

    def update_selected_text_font(self, font):
        selected_items = self.scene.selectedItems()
        if selected_items and selected_items[0].type() == TEXT_TYPE: selected_items[0].setData(2, font)

    def update_selected_text_font_size(self, size):
        selected_items = self.scene.selectedItems()
        if selected_items and selected_items[0].type() == TEXT_TYPE: selected_items[0].setData(3, size)

    def update_selected_text_color(self, color):
        selected_items = self.scene.selectedItems()
        if selected_items and selected_items[0].type() == TEXT_TYPE: selected_items[0].setData(4, color.name())

    def play(self): self.playback_timer.start()
    def pause(self): self.playback_timer.stop()
    def delete_selected(self): [self.scene.removeItem(item) for item in self.scene.selectedItems()]
    def split_selected(self):
        selected_items = self.scene.selectedItems()
        if not selected_items or selected_items[0].type() != CLIP_TYPE: return
        clip_to_split = selected_items[0]; split_x = self.playhead.line().x1()
        if not clip_to_split.sceneBoundingRect().contains(split_x, clip_to_split.sceneBoundingRect().center().y()): return
        original_rect = clip_to_split.rect(); original_duration = clip_to_split.data(1); original_start_time = clip_to_split.data(2)
        left_width = split_x - clip_to_split.scenePos().x(); right_width = original_rect.width() - left_width
        clip_to_split.setRect(original_rect.x(), original_rect.y(), left_width, original_rect.height())
        new_left_duration = (left_width / self.pixels_per_second); clip_to_split.setData(1, new_left_duration)
        new_clip = VideoClipItem(split_x, clip_to_split.scenePos().y(), right_width, original_rect.height())
        new_clip.setData(0, clip_to_split.data(0)); new_clip.setData(1, original_duration - new_left_duration); new_clip.setData(2, original_start_time + new_left_duration)
        self.scene.addItem(new_clip)

    def update_playback(self):
        current_x = self.playhead.line().x1()
        new_x = current_x + (self.pixels_per_second / 30.0)
        self.playhead.setLine(new_x, 0, new_x, self.scene.height())
        
        frame = self.get_video_frame_at(new_x)
        if frame is not None:
            final_frame = self.overlay_text_at(frame, new_x)
            rgb_image = cv2.cvtColor(final_frame, cv2.COLOR_BGR2RGB)
            h, w, ch = rgb_image.shape
            bytes_per_line = ch * w
            qt_image = QImage(rgb_image.data, w, h, bytes_per_line, QImage.Format_RGB888)
            self.frame_ready.emit(qt_image)

    def get_frame_from_clip(self, clip_item, x_pos):
        file_path = clip_item.data(0)
        clip_start_x = clip_item.scenePos().x()
        time_in_clip = (x_pos - clip_start_x) / self.pixels_per_second
        total_time_in_source = clip_item.data(2) + time_in_clip
        
        cap = self.video_captures.get(file_path)
        if cap:
            cap.set(cv2.CAP_PROP_POS_MSEC, total_time_in_source * 1000)
            ret, frame = cap.read()
            if ret:
                return frame
        return np.zeros((100, 100, 3), np.uint8)


    def get_video_frame_at(self, x_pos):
        # Check for transition
        transition_items = [item for item in self.scene.items(QRectF(x_pos, self.video_track_y, 1, self.track_height)) if item.type() == TRANSITION_TYPE]
        if transition_items:
            transition_item = transition_items[0]
            transition_rect = transition_item.sceneBoundingRect()
            
            # Find the two clips for the transition
            clip1_items = [item for item in self.scene.items(QRectF(transition_rect.left() - 1, self.video_track_y, 1, self.track_height)) if item.type() == CLIP_TYPE]
            clip2_items = [item for item in self.scene.items(QRectF(transition_rect.right(), self.video_track_y, 1, self.track_height)) if item.type() == CLIP_TYPE]

            if clip1_items and clip2_items:
                clip1 = clip1_items[0]
                clip2 = clip2_items[0]

                # Get frames from both clips
                frame1 = self.get_frame_from_clip(clip1, x_pos)
                frame2 = self.get_frame_from_clip(clip2, x_pos)

                # Blend the frames
                progress = (x_pos - transition_rect.left()) / transition_rect.width()
                
                # Resize frames to be the same size before blending
                h, w, _ = frame1.shape
                frame2_resized = cv2.resize(frame2, (w, h))

                blended_frame = cv2.addWeighted(frame1, 1 - progress, frame2_resized, progress, 0)
                return blended_frame


        # If no transition, get the frame from the single clip
        video_items = [item for item in self.scene.items(QRectF(x_pos, self.video_track_y, 1, self.track_height)) if item.type() == CLIP_TYPE]
        if not video_items: return np.zeros((100, 100, 3), np.uint8)
        
        return self.get_frame_from_clip(video_items[0], x_pos)


    def overlay_text_at(self, frame, x_pos):
        text_items = [item for item in self.scene.items(QRectF(x_pos, self.text_track_y, 1, self.track_height)) if item.type() == TEXT_TYPE]
        if text_items:
            item = text_items[0]
            text = item.data(0)
            font_name = item.data(2)
            font_size = item.data(3)
            color = item.data(4)

            # Convert OpenCV (BGR) to Pillow (RGB)
            frame_pil = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            draw = ImageDraw.Draw(frame_pil)
            
            try:
                font = ImageFont.truetype(font_name, font_size)
            except IOError:
                font = ImageFont.load_default()

            # Calculate text position
            text_bbox = draw.textbbox((0,0), text, font=font)
            text_width = text_bbox[2] - text_bbox[0]
            text_height = text_bbox[3] - text_bbox[1]

            position = ((frame_pil.width - text_width) // 2, (frame_pil.height - text_height) // 2)
            
            draw.text(position, text, font=font, fill=color)
            
            # Convert back to OpenCV format
            frame = cv2.cvtColor(np.array(frame_pil), cv2.COLOR_RGB2BGR)
        return frame

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__(); self.setWindowTitle("Video Editor"); self.setGeometry(100, 100, 1280, 720)
        central_widget = QWidget(); self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget); main_layout.setContentsMargins(0,0,0,0); main_layout.setSpacing(0)
        header = self.create_header(); main_layout.addWidget(header)
        content_widget = QWidget(); grid_layout = QGridLayout(content_widget); main_layout.addWidget(content_widget)
        left_panel = QWidget(); left_layout = QHBoxLayout(left_panel); left_layout.setContentsMargins(0,0,0,0); left_layout.setSpacing(0)
        toolbar = QWidget(); toolbar.setFixedWidth(60); toolbar.setStyleSheet("background-color: #2E2E2E;")
        toolbar_layout = QVBoxLayout(toolbar)
        video_button = QPushButton("Video"); text_button = QPushButton("Text"); audio_button = QPushButton("Audio")
        toolbar_layout.addWidget(video_button); toolbar_layout.addWidget(text_button); toolbar_layout.addWidget(audio_button); toolbar_layout.addStretch()
        self.media_bin_widget = QWidget(); mb_layout = QVBoxLayout(self.media_bin_widget); self.media_bin = MediaBin(); mb_layout.addWidget(self.media_bin)
        left_layout.addWidget(toolbar); left_layout.addWidget(self.media_bin_widget)
        self.preview_panel = PreviewPanel(); self.properties_panel = PropertiesPanel()
        timeline_container = QWidget(); timeline_layout = QVBoxLayout(timeline_container); timeline_layout.setContentsMargins(0,0,0,0)
        self.timeline_panel = Timeline()
        controls_widget = QWidget(); controls_layout = QHBoxLayout(controls_widget)
        play_button = QPushButton("Play"); pause_button = QPushButton("Pause"); split_button = QPushButton("Split"); delete_button = QPushButton("Delete")
        add_transition_button = QPushButton("Add Fade")
        controls_layout.addWidget(play_button); controls_layout.addWidget(pause_button); controls_layout.addWidget(split_button); controls_layout.addWidget(delete_button)
        controls_layout.addWidget(add_transition_button)
        timeline_layout.addWidget(controls_widget); timeline_layout.addWidget(self.timeline_panel)
        grid_layout.addWidget(left_panel, 0, 0, 1, 1); grid_layout.addWidget(self.preview_panel, 0, 1, 1, 2)
        grid_layout.addWidget(self.properties_panel, 0, 3, 1, 1); grid_layout.addWidget(timeline_container, 1, 0, 1, 4)
        grid_layout.setColumnStretch(0, 25); grid_layout.setColumnStretch(1, 50); grid_layout.setColumnStretch(3, 25)
        grid_layout.setRowStretch(0, 70); grid_layout.setRowStretch(1, 30)
        self.status_bar = self.statusBar(); self.progress_bar = QProgressBar(); self.status_bar.addPermanentWidget(self.progress_bar); self.progress_bar.hide()
        video_button.clicked.connect(lambda: self.media_bin.open_file_dialog('video'))
        audio_button.clicked.connect(lambda: self.media_bin.open_file_dialog('audio'))
        self.media_bin.file_selected.connect(self.add_media_to_timeline)
        text_button.clicked.connect(self.timeline_panel.add_text_clip)
        self.timeline_panel.item_selected.connect(self.properties_panel.update_for_item)
        self.properties_panel.text_changed.connect(self.timeline_panel.update_selected_text)
        self.properties_panel.font_changed.connect(self.timeline_panel.update_selected_text_font)
        self.properties_panel.font_size_changed.connect(self.timeline_panel.update_selected_text_font_size)
        self.properties_panel.color_changed.connect(self.timeline_panel.update_selected_text_color)
        self.timeline_panel.frame_ready.connect(self.preview_panel.set_frame)
        play_button.clicked.connect(self.timeline_panel.play); pause_button.clicked.connect(self.timeline_panel.pause)
        split_button.clicked.connect(self.timeline_panel.split_selected); delete_button.clicked.connect(self.timeline_panel.delete_selected)
        add_transition_button.clicked.connect(self.timeline_panel.add_transition)

    def add_media_to_timeline(self, path, media_type):
        if media_type == 'video': self.timeline_panel.add_clip(path)
        elif media_type == 'audio': self.timeline_panel.add_audio_clip(path)

    def create_header(self):
        header_widget = QWidget(); header_widget.setAutoFillBackground(True)
        pal = header_widget.palette(); pal.setColor(QPalette.Window, QColor("#3c3c3c")); header_widget.setPalette(pal)
        header_layout = QHBoxLayout(header_widget); header_layout.setContentsMargins(10, 5, 10, 5)
        title = QLabel("Video Editor"); title.setStyleSheet("font-weight: bold; font-size: 14px;")
        save_button = QPushButton("Save Project"); save_button.clicked.connect(self.save_project)
        load_button = QPushButton("Load Project"); load_button.clicked.connect(self.load_project)
        export_button = QPushButton("Export"); export_button.clicked.connect(self.export_video)
        header_layout.addWidget(title); header_layout.addStretch(); header_layout.addWidget(save_button); header_layout.addWidget(load_button); header_layout.addWidget(export_button)
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
        self.progress_bar.show(); self.progress_bar.setValue(0)
        self.thread = QThread(); self.exporter = Exporter(); self.exporter.moveToThread(self.thread)
        self.thread.started.connect(lambda: self.exporter.export(clips_data, output_path))
        self.exporter.finished.connect(self.on_export_finished); self.exporter.error.connect(self.on_export_error)
        self.exporter.progress.connect(self.on_export_progress)
        self.thread.start()

    def on_export_progress(self, value): self.progress_bar.setValue(value)
    def on_export_finished(self): self.progress_bar.setValue(100); self.thread.quit(); self.thread.wait(); self.progress_bar.hide()
    def on_export_error(self, error_msg): print(f"Export Error: {error_msg}"); self.thread.quit(); self.thread.wait(); self.progress_bar.hide()

def set_dark_theme(app):
    dark_palette = QPalette()
    dark_palette.setColor(QPalette.Window, QColor(37, 37, 37)); dark_palette.setColor(QPalette.WindowText, Qt.white)
    dark_palette.setColor(QPalette.Base, QColor(25, 25, 25)); dark_palette.setColor(QPalette.AlternateBase, QColor(53, 53, 53))
    dark_palette.setColor(QPalette.ToolTipBase, Qt.white); dark_palette.setColor(QPalette.ToolTipText, Qt.white)
    dark_palette.setColor(QPalette.Text, Qt.white); dark_palette.setColor(QPalette.Button, QColor(53, 53, 53))
    dark_palette.setColor(QPalette.ButtonText, Qt.white); dark_palette.setColor(QPalette.BrightText, Qt.red)
    dark_palette.setColor(QPalette.Link, QColor(42, 130, 218)); dark_palette.setColor(QPalette.Highlight, QColor(42, 130, 218))
    dark_palette.setColor(QPalette.HighlightedText, Qt.black)
    app.setPalette(dark_palette)
    app.setStyleSheet("QToolTip { color: #ffffff; background-color: #2a82da; border: 1px solid white; }")

if __name__ == "__main__":
    app = QApplication(sys.argv)
    set_dark_theme(app)
    main_win = MainWindow()
    main_win.show()
    sys.exit(app.exec())