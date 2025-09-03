from PySide6.QtWidgets import QGraphicsRectItem
from PySide6.QtGui import QColor, QBrush, QPen, QMouseEvent
from PySide6.QtCore import QPointF

from src.commands.command import MoveItemCommand

# --- Data Types ---
CLIP_TYPE = 1001
TEXT_TYPE = 1002
AUDIO_TYPE = 1003
TRANSITION_TYPE = 1004

class TimelineClipItem(QGraphicsRectItem):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.setFlag(QGraphicsRectItem.ItemIsMovable)
        self.setFlag(QGraphicsRectItem.ItemIsSelectable)
        self.start_pos = None

    def mousePressEvent(self, event: QMouseEvent):
        self.start_pos = self.pos()
        super().mousePressEvent(event)

    def mouseMoveEvent(self, event: QMouseEvent):
        new_pos_x = event.scenePos().x() - event.lastScenePos().x() + self.scenePos().x()
        snap_distance = 10
        snapped = False
        all_items = self.scene().items()
        snap_points = []
        for item in all_items:
            if item is not self and isinstance(item, QGraphicsRectItem):
                snap_points.append(item.sceneBoundingRect().left())
                snap_points.append(item.sceneBoundingRect().right())
        playhead = self.scene().views()[0].playhead
        snap_points.append(playhead.line().x1())
        my_left = new_pos_x
        my_right = new_pos_x + self.rect().width()
        for point in snap_points:
            if abs(my_left - point) < snap_distance:
                new_pos_x = point
                snapped = True
                break
            if abs(my_right - point) < snap_distance:
                new_pos_x = point - self.rect().width()
                snapped = True
                break
        
        self.setPos(QPointF(new_pos_x, self.y()))

    def mouseReleaseEvent(self, event: QMouseEvent):
        super().mouseReleaseEvent(event)
        if self.start_pos != self.pos():
            command = MoveItemCommand(self, self.start_pos, self.pos())
            self.scene().views()[0].command_history.execute(command)

class VideoClipItem(TimelineClipItem):
    def type(self): return CLIP_TYPE
    def __init__(self, *args, **kwargs): 
        super().__init__(*args, **kwargs)
        self.setBrush(QBrush(QColor("#4a82da")))
        self.setPen(QPen(Qt.NoPen))

class TextClipItem(TimelineClipItem):
    def type(self): return TEXT_TYPE
    def __init__(self, *args, **kwargs): 
        super().__init__(*args, **kwargs)
        self.setBrush(QBrush(QColor("#db8d4a")))
        self.setPen(QPen(Qt.NoPen))

class AudioClipItem(TimelineClipItem):
    def type(self): return AUDIO_TYPE
    def __init__(self, *args, **kwargs): 
        super().__init__(*args, **kwargs)
        self.setBrush(QBrush(QColor("#4adbad")))
        self.setPen(QPen(Qt.NoPen))

class TransitionItem(QGraphicsRectItem):
    def type(self): return TRANSITION_TYPE
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.setBrush(QBrush(QColor(255, 0, 0, 128)))
        self.setPen(QPen(Qt.NoPen))
        self.setFlag(QGraphicsRectItem.ItemIsSelectable)
