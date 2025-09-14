import cv2
import numpy as np
from PySide6.QtWidgets import QGraphicsView, QGraphicsScene
from PySide6.QtGui import QPainter, QColor, QPen, QFont, QImage
from PySide6.QtCore import Signal, QRectF, QTimer, Qt, QUrl
from PySide6.QtMultimedia import QMediaPlayer, QAudioOutput
from mutagen.mp3 import MP3
from PIL import Image, ImageDraw, ImageFont

from src.logic.timeline_items import (
    VideoClipItem, TextClipItem, AudioClipItem, TransitionItem, 
    CLIP_TYPE, TEXT_TYPE, AUDIO_TYPE, TRANSITION_TYPE
)
from src.commands.command import CommandHistory, AddItemCommand, DeleteItemCommand, ChangePropertyCommand

class Timeline(QGraphicsView):
    frame_ready = Signal(QImage)
    item_selected = Signal(object)

    def __init__(self, main_window):
        super().__init__()
        self.scene = QGraphicsScene()
        self.setScene(self.scene)
        self.main_window = main_window
        self.setRenderHint(QPainter.Antialiasing)
        self.setBackgroundBrush(QColor("#252525"))
        self.setFrameShape(QGraphicsView.NoFrame)
        self.ruler_height = 30
        self.pixels_per_second = 50
        self.track_height = 60
        self.video_track_y = self.ruler_height + 10
        self.text_track_y = self.video_track_y + self.track_height
        self.audio_track_y = self.text_track_y + self.track_height
        self.video_captures = {}
        self.setup_scene()
        self.playback_timer = QTimer(self)
        self.playback_timer.setInterval(1000 // 30)
        self.playback_timer.timeout.connect(self.update_playback)
        self.scene.selectionChanged.connect(self.on_selection_changed)
        self.command_history = CommandHistory(self.main_window)

        self.track_header_width = 60
        self.track_labels = []
        self.horizontalScrollBar().valueChanged.connect(self.update_track_labels)

        self.player = QMediaPlayer()
        self.audio_output = QAudioOutput()
        self.player.setAudioOutput(self.audio_output)

    def setup_scene(self):
        self.scene.clear()
        self.draw_background_and_ruler()
        self.playhead = self.scene.addLine(0, 0, 0, 600, QPen(Qt.red, 2))
        self.playhead.setZValue(1)

    def update_track_labels(self, value):
        for label in self.track_labels:
            label.setPos(value + 5, label.y())

    def draw_background_and_ruler(self):
        for item in self.scene.items():
            if item.zValue() == -1:
                self.scene.removeItem(item)
        
        for label in self.track_labels:
            self.scene.removeItem(label)
        self.track_labels.clear()

        self.scene.setSceneRect(0, 0, self.pixels_per_second * 60 * 10, 600)
        
        track_color_1 = QColor("#2A2A2A")
        track_color_2 = QColor("#2E2E2E")
        
        bg_rect1 = self.scene.addRect(0, self.video_track_y, self.scene.width(), self.track_height, QPen(Qt.NoPen), track_color_1)
        bg_rect2 = self.scene.addRect(0, self.text_track_y, self.scene.width(), self.track_height, QPen(Qt.NoPen), track_color_2)
        bg_rect3 = self.scene.addRect(0, self.audio_track_y, self.scene.width(), self.track_height, QPen(Qt.NoPen), track_color_1)
        bg_rect1.setZValue(-1)
        bg_rect2.setZValue(-1)
        bg_rect3.setZValue(-1)

        header_font = QFont("Arial", 10, QFont.Bold)
        
        v_label = self.scene.addText("V1", header_font)
        v_label.setDefaultTextColor(Qt.white)
        v_label.setPos(0, self.video_track_y + (self.track_height - v_label.boundingRect().height()) / 2)
        v_label.setZValue(2)
        self.track_labels.append(v_label)

        t_label = self.scene.addText("T1", header_font)
        t_label.setDefaultTextColor(Qt.white)
        t_label.setPos(0, self.text_track_y + (self.track_height - t_label.boundingRect().height()) / 2)
        t_label.setZValue(2)
        self.track_labels.append(t_label)

        a_label = self.scene.addText("A1", header_font)
        a_label.setDefaultTextColor(Qt.white)
        a_label.setPos(0, self.audio_track_y + (self.track_height - a_label.boundingRect().height()) / 2)
        a_label.setZValue(2)
        self.track_labels.append(a_label)

        self.update_track_labels(self.horizontalScrollBar().value())

        pen = QPen(Qt.white)
        font = QFont("Arial", 8)
        ruler_line = self.scene.addLine(0, self.ruler_height, self.scene.width(), self.ruler_height, pen)
        ruler_line.setZValue(-1)

        for i in range(int(self.scene.width() / self.pixels_per_second)):
            x = i * self.pixels_per_second
            if x < self.track_header_width: continue
            
            if i % 5 == 0:
                line = self.scene.addLine(x, self.ruler_height - 10, x, self.ruler_height, pen)
                text = self.scene.addText(f"{i}s", font)
                text.setDefaultTextColor(Qt.white)
                text.setPos(x + 2, self.ruler_height - 25)
                line.setZValue(-1)
                text.setZValue(-1)
            else:
                line = self.scene.addLine(x, self.ruler_height - 5, x, self.ruler_height, pen)
                line.setZValue(-1)

    def add_clip(self, file_path):
        try:
            if file_path not in self.video_captures:
                self.video_captures[file_path] = cv2.VideoCapture(file_path)
            cap = self.video_captures[file_path]
            fps = cap.get(cv2.CAP_PROP_FPS)
            duration = cap.get(cv2.CAP_PROP_FRAME_COUNT) / fps
            clip_width = duration * self.pixels_per_second
            x_pos = 0
            for item in self.scene.items():
                if isinstance(item, VideoClipItem):
                    x_pos = max(x_pos, item.sceneBoundingRect().right())
            clip_rect = VideoClipItem(x_pos, self.video_track_y, clip_width, self.track_height - 10)
            clip_rect.setData(0, file_path)
            clip_rect.setData(1, duration)
            clip_rect.setData(2, 0.0)
            clip_rect.setData(3, False) # Grayscale
            clip_rect.setData(4, 1.0) # Volume
            self.command_history.execute(AddItemCommand(self.scene, clip_rect))

            audio_clip_rect = AudioClipItem(x_pos, self.audio_track_y, clip_width, self.track_height - 10)
            audio_clip_rect.setData(0, file_path)
            audio_clip_rect.setData(1, duration)
            audio_clip_rect.setData(2, 1.0) # Volume
            self.command_history.execute(AddItemCommand(self.scene, audio_clip_rect))
        except Exception as e:
            print(f"Error adding clip: {e}")

    def add_text_clip(self):
        default_duration = 5
        clip_width = default_duration * self.pixels_per_second
        text_item = TextClipItem(0, self.text_track_y, clip_width, self.track_height - 10)
        text_item.setData(0, "New Text")
        text_item.setData(1, default_duration)
        text_item.setData(2, "Arial")
        text_item.setData(3, 70)
        text_item.setData(4, "white")
        text_item.setData(5, "center")
        text_item.setData(6, 0)
        text_item.setData(7, 0)
        self.command_history.execute(AddItemCommand(self.scene, text_item))

    def add_audio_clip(self, file_path):
        try:
            audio = MP3(file_path)
            duration = audio.info.length
            clip_width = duration * self.pixels_per_second
            x_pos = 0
            for item in self.scene.items():
                if isinstance(item, AudioClipItem):
                    x_pos = max(x_pos, item.sceneBoundingRect().right())
            clip_rect = AudioClipItem(x_pos, self.audio_track_y, clip_width, self.track_height - 10)
            clip_rect.setData(0, file_path)
            clip_rect.setData(1, duration)
            clip_rect.setData(2, 1.0) # Volume
            self.command_history.execute(AddItemCommand(self.scene, clip_rect))
        except Exception as e:
            print(f"Error adding audio clip: {e}")

    def add_transition(self):
        playhead_x = self.playhead.line().x1()
        items_at_pos = self.scene.items(QRectF(playhead_x - 1, self.video_track_y, 2, self.track_height))
        video_clips = [item for item in items_at_pos if isinstance(item, VideoClipItem)]

        if len(video_clips) == 2:
            clip1 = min(video_clips, key=lambda c: c.sceneBoundingRect().right())
            clip2 = max(video_clips, key=lambda c: c.sceneBoundingRect().left())

            if abs(clip1.sceneBoundingRect().right() - clip2.sceneBoundingRect().left()) < 1:
                duration = 1.0
                width = duration * self.pixels_per_second
                transition_item = TransitionItem(clip1.sceneBoundingRect().right() - width / 2, self.video_track_y, width, self.track_height - 10)
                transition_item.setData(0, 'Crossfade')
                transition_item.setData(1, duration)
                self.command_history.execute(AddItemCommand(self.scene, transition_item))

    def to_dict(self):
        project_data = []
        for item in self.scene.items():
            if not isinstance(item, QGraphicsRectItem): continue
            num_data = 0
            if item.type() == CLIP_TYPE: num_data = 5
            elif item.type() == TEXT_TYPE: num_data = 8
            elif item.type() == AUDIO_TYPE: num_data = 3
            elif item.type() == TRANSITION_TYPE: num_data = 2
            item_data = {
                'type': item.type(),
                'x': item.x(),
                'y': item.y(),
                'width': item.rect().width(),
                'height': item.rect().height(),
                'data': [item.data(i) for i in range(num_data)]
            }
            project_data.append(item_data)
        return project_data

    def from_dict(self, project_data):
        self.scene.clear()
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
        self.command_history.undo_stack.clear()
        self.command_history.redo_stack.clear()
        self.command_history.update_actions()

    def on_selection_changed(self): 
        selected_items = self.scene.selectedItems()
        self.item_selected.emit(selected_items[0] if selected_items else None)
    
    def on_property_changed(self, item, data_index, old_value, new_value):
        command = ChangePropertyCommand(item, data_index, old_value, new_value, self)
        self.command_history.execute(command)

    def wheelEvent(self, event):
        if event.modifiers() == Qt.ControlModifier:
            scene_pos = self.mapToScene(event.position().toPoint())
            time_at_mouse = scene_pos.x() / self.pixels_per_second

            delta = event.angleDelta().y()
            if delta > 0:
                new_pixels_per_second = self.pixels_per_second * 1.2
            else:
                new_pixels_per_second = max(10, self.pixels_per_second / 1.2)
            
            scale_factor = new_pixels_per_second / self.pixels_per_second
            self.pixels_per_second = new_pixels_per_second

            for item in self.scene.items():
                if isinstance(item, (VideoClipItem, AudioClipItem, TextClipItem, TransitionItem)):
                    item.setPos(item.x() * scale_factor, item.y())
                    rect = item.rect()
                    item.setRect(rect.x(), rect.y(), rect.width() * scale_factor, rect.height())

            self.draw_background_and_ruler()
            playhead_line = self.playhead.line()
            self.playhead.setLine(playhead_line.x1() * scale_factor, playhead_line.y1(), playhead_line.x2() * scale_factor, playhead_line.y2())
            
            new_mouse_x = time_at_mouse * self.pixels_per_second
            delta_x = new_mouse_x - scene_pos.x()
            self.horizontalScrollBar().setValue(self.horizontalScrollBar().value() - delta_x)

        else:
            super().wheelEvent(event)

    def play(self):
        if self.player.playbackState() == QMediaPlayer.PlaybackState.PausedState:
            self.player.play()
        else:
            playhead_x = self.playhead.line().x1()
            items_at_pos = self.scene.items(QRectF(playhead_x, self.audio_track_y, 1, self.track_height))
            audio_clips = [item for item in items_at_pos if isinstance(item, AudioClipItem)]

            if audio_clips:
                clip = audio_clips[0]
                file_path = clip.data(0)
                
                time_in_clip_seconds = (playhead_x - clip.scenePos().x()) / self.pixels_per_second
                
                self.player.setSource(QUrl.fromLocalFile(file_path))
                self.player.setPosition(int(time_in_clip_seconds * 1000))
                self.player.play()

        self.playback_timer.start()

    def pause(self):
        self.player.pause()
        self.playback_timer.stop()
    
    def delete_selected(self):
        selected_items = self.scene.selectedItems()
        if not selected_items: return
        command = DeleteItemCommand(self.scene, selected_items[0])
        self.command_history.execute(command)

    def split_selected(self):
        selected_items = self.scene.selectedItems()
        if not selected_items or selected_items[0].type() != CLIP_TYPE: return
        # This action is complex and not yet undoable
        clip_to_split = selected_items[0]
        split_x = self.playhead.line().x1()
        if not clip_to_split.sceneBoundingRect().contains(split_x, clip_to_split.sceneBoundingRect().center().y()): return
        original_rect = clip_to_split.rect()
        original_duration = clip_to_split.data(1)
        original_start_time = clip_to_split.data(2)
        left_width = split_x - clip_to_split.scenePos().x()
        right_width = original_rect.width() - left_width
        clip_to_split.setRect(original_rect.x(), original_rect.y(), left_width, original_rect.height())
        new_left_duration = (left_width / self.pixels_per_second)
        clip_to_split.setData(1, new_left_duration)
        new_clip = VideoClipItem(split_x, clip_to_split.scenePos().y(), right_width, original_rect.height())
        new_clip.setData(0, clip_to_split.data(0))
        new_clip.setData(1, original_duration - new_left_duration)
        new_clip.setData(2, original_start_time + new_left_duration)
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
                if clip_item.data(3): # Grayscale
                    gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
                    frame = cv2.cvtColor(gray_frame, cv2.COLOR_GRAY2BGR)
                return frame
        return np.zeros((100, 100, 3), np.uint8)

    def get_video_frame_at(self, x_pos):
        transition_items = [item for item in self.scene.items(QRectF(x_pos, self.video_track_y, 1, self.track_height)) if item.type() == TRANSITION_TYPE]
        if transition_items:
            transition_item = transition_items[0]
            transition_type = transition_item.data(0)
            transition_rect = transition_item.sceneBoundingRect()
            progress = (x_pos - transition_rect.left()) / transition_rect.width()

            clip1_items = [item for item in self.scene.items(QRectF(transition_rect.left() - 1, self.video_track_y, 1, self.track_height)) if item.type() == CLIP_TYPE]
            clip2_items = [item for item in self.scene.items(QRectF(transition_rect.right(), self.video_track_y, 1, self.track_height)) if item.type() == CLIP_TYPE]

            if clip1_items and clip2_items:
                clip1 = clip1_items[0]
                clip2 = clip2_items[0]
                frame1 = self.get_frame_from_clip(clip1, x_pos)
                frame2 = self.get_frame_from_clip(clip2, x_pos)
                h, w, _ = frame1.shape
                frame2 = cv2.resize(frame2, (w, h))

                if transition_type == "Crossfade":
                    return cv2.addWeighted(frame1, 1 - progress, frame2, progress, 0)
                elif transition_type == "Fade to Black":
                    if progress < 0.5:
                        return cv2.addWeighted(frame1, 1 - (progress * 2), np.zeros_like(frame1), progress * 2, 0)
                    else:
                        return cv2.addWeighted(np.zeros_like(frame2), 1 - ((progress - 0.5) * 2), frame2, (progress - 0.5) * 2, 0)
                elif transition_type == "Wipe Left":
                    mask = np.zeros_like(frame1)
                    wipe_x = int(w * progress)
                    mask[:, :wipe_x] = 255
                    return np.where(mask == 255, frame2, frame1)

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
            frame_pil = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            draw = ImageDraw.Draw(frame_pil)
            try:
                font = ImageFont.truetype(font_name, font_size)
            except IOError:
                font = ImageFont.load_default()
            text_bbox = draw.textbbox((0,0), text, font=font)
            text_width = text_bbox[2] - text_bbox[0]
            text_height = text_bbox[3] - text_bbox[1]
            position = ((frame_pil.width - text_width) // 2, (frame_pil.height - text_height) // 2)
            draw.text(position, text, font=font, fill=color)
            frame = cv2.cvtColor(np.array(frame_pil), cv2.COLOR_RGB2BGR)
        return frame
