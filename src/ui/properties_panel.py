from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QLabel, QLineEdit, QFontComboBox, QSpinBox, 
    QPushButton, QColorDialog, QDoubleSpinBox, QComboBox, QCheckBox, QSlider
)
from PySide6.QtGui import QPalette, QColor, QFont
from PySide6.QtCore import Qt, Signal

from src.logic.timeline_items import CLIP_TYPE, TEXT_TYPE, AUDIO_TYPE, TRANSITION_TYPE

class PropertiesPanel(QWidget):
    property_changed = Signal(object, int, object, object) # item, data_index, old_value, new_value

    def __init__(self):
        super().__init__()
        self.setAutoFillBackground(True)
        palette = self.palette()
        palette.setColor(QPalette.Window, QColor("#2E2E2E"))
        self.setPalette(palette)
        self.layout = QVBoxLayout(self)
        self.layout.setAlignment(Qt.AlignTop)
        self.layout.setContentsMargins(10, 10, 10, 10)
        title = QLabel("Properties")
        title.setStyleSheet("font-weight: bold; font-size: 14px;")
        self.layout.addWidget(title)
        self.path_label = QLabel()
        self.path_label.setWordWrap(True)
        self.duration_label = QLabel()
        self.current_item = None
        
        self.text_edit_label = QLabel("Text Content:")
        self.text_edit = QLineEdit()
        self.font_label = QLabel("Font:")
        self.font_combo = QFontComboBox()
        self.font_size_label = QLabel("Font Size:")
        self.font_size_spinbox = QSpinBox()
        self.font_size_spinbox.setRange(1, 200)
        self.font_size_spinbox.setValue(70)
        self.color_label = QLabel("Color:")
        self.color_button = QPushButton("Select Color")

        self.transition_type_label = QLabel("Transition Type:")
        self.transition_type_combo = QComboBox()
        self.transition_type_combo.addItems(["Crossfade", "Fade to Black", "Wipe Left"])
        self.transition_duration_label = QLabel("Transition Duration (s):")
        self.transition_duration_spinbox = QDoubleSpinBox()
        self.transition_duration_spinbox.setRange(0.1, 10.0)
        self.transition_duration_spinbox.setSingleStep(0.1)

        self.effects_label = QLabel("Effects")
        self.effects_label.setStyleSheet("font-weight: bold; margin-top: 10px;")
        self.grayscale_checkbox = QCheckBox("Grayscale")

        self.volume_label = QLabel("Volume:")
        self.volume_slider = QSlider(Qt.Horizontal)
        self.volume_slider.setRange(0, 150)
        self.volume_value_label = QLabel("100%")

        self.layout.addWidget(self.path_label)
        self.layout.addWidget(self.duration_label)
        self.layout.addWidget(self.text_edit_label)
        self.layout.addWidget(self.text_edit)
        self.layout.addWidget(self.font_label)
        self.layout.addWidget(self.font_combo)
        self.layout.addWidget(self.font_size_label)
        self.layout.addWidget(self.font_size_spinbox)
        self.layout.addWidget(self.color_label)
        self.layout.addWidget(self.color_button)
        self.layout.addWidget(self.transition_type_label)
        self.layout.addWidget(self.transition_type_combo)
        self.layout.addWidget(self.transition_duration_label)
        self.layout.addWidget(self.transition_duration_spinbox)
        self.layout.addWidget(self.effects_label)
        self.layout.addWidget(self.grayscale_checkbox)
        self.layout.addWidget(self.volume_label)
        self.layout.addWidget(self.volume_slider)
        self.layout.addWidget(self.volume_value_label)

        self.text_edit.editingFinished.connect(lambda: self.on_property_changed(0, self.text_edit.text()))
        self.font_combo.currentFontChanged.connect(lambda font: self.on_property_changed(2, font.family()))
        self.font_size_spinbox.editingFinished.connect(lambda: self.on_property_changed(3, self.font_size_spinbox.value()))
        self.color_button.clicked.connect(self.open_color_dialog)
        self.transition_duration_spinbox.editingFinished.connect(lambda: self.on_property_changed(1, self.transition_duration_spinbox.value()))
        self.transition_type_combo.currentTextChanged.connect(lambda text: self.on_property_changed(0, text))
        self.grayscale_checkbox.toggled.connect(lambda state: self.on_property_changed(3, bool(state)))
        self.volume_slider.sliderReleased.connect(lambda: self.on_property_changed(4 if self.current_item.type() == CLIP_TYPE else 2, self.volume_slider.value() / 100.0))
        self.volume_slider.valueChanged.connect(lambda value: self.volume_value_label.setText(f"{value}%"))
        
        self.clear_properties()

    def on_property_changed(self, data_index, new_value):
        if self.current_item:
            old_value = self.current_item.data(data_index)
            if old_value != new_value:
                self.property_changed.emit(self.current_item, data_index, old_value, new_value)

    def open_color_dialog(self):
        if not self.current_item: return
        old_color = QColor(self.current_item.data(4))
        color = QColorDialog.getColor(old_color)
        if color.isValid() and color.name() != old_color.name():
            self.on_property_changed(4, color.name())
            self.update_color_button(color)

    def update_color_button(self, color):
        self.color_button.setStyleSheet(f"background-color: {color.name()};")

    def update_for_item(self, item):
        self.current_item = item
        self.clear_properties()
        if not item: return
        if item.type() == CLIP_TYPE:
            self.path_label.show(); self.duration_label.show()
            self.path_label.setText(f"File: {item.data(0)}"); self.duration_label.setText(f"Duration: {item.data(1):.2f}s")
            self.effects_label.show(); self.grayscale_checkbox.show()
            self.grayscale_checkbox.setChecked(item.data(3))
            self.volume_label.show(); self.volume_slider.show(); self.volume_value_label.show()
            self.volume_slider.setValue(int(item.data(4) * 100))
        elif item.type() == AUDIO_TYPE:
            self.path_label.show(); self.duration_label.show()
            self.path_label.setText(f"File: {item.data(0)}"); self.duration_label.setText(f"Duration: {item.data(1):.2f}s")
            self.volume_label.show(); self.volume_slider.show(); self.volume_value_label.show()
            self.volume_slider.setValue(int(item.data(2) * 100))
        elif item.type() == TEXT_TYPE:
            self.text_edit_label.show(); self.text_edit.show(); self.text_edit.setText(item.data(0))
            self.font_label.show(); self.font_combo.show(); self.font_combo.setCurrentFont(QFont(item.data(2)))
            self.font_size_label.show(); self.font_size_spinbox.show(); self.font_size_spinbox.setValue(item.data(3))
            self.color_label.show(); self.color_button.show(); self.update_color_button(QColor(item.data(4)))
        elif item.type() == TRANSITION_TYPE:
            self.transition_type_label.show(); self.transition_type_combo.show()
            self.transition_type_combo.setCurrentText(item.data(0))
            self.transition_duration_label.show(); self.transition_duration_spinbox.show()
            self.transition_duration_spinbox.setValue(item.data(1))

    def clear_properties(self):
        self.current_item = None
        self.path_label.hide(); self.duration_label.hide()
        self.text_edit_label.hide(); self.text_edit.hide()
        self.font_label.hide(); self.font_combo.hide()
        self.font_size_label.hide(); self.font_size_spinbox.hide()
        self.color_label.hide(); self.color_button.hide()
        self.transition_type_label.hide(); self.transition_type_combo.hide()
        self.transition_duration_label.hide(); self.transition_duration_spinbox.hide()
        self.effects_label.hide(); self.grayscale_checkbox.hide()
        self.volume_label.hide(); self.volume_slider.hide(); self.volume_value_label.hide()
