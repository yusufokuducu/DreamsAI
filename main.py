import sys
from PySide6.QtWidgets import QApplication

from src.ui.main_window import MainWindow
from src.utils.theme import set_dark_theme

if __name__ == "__main__":
    app = QApplication(sys.argv)
    set_dark_theme(app)
    main_win = MainWindow()
    main_win.show()
    sys.exit(app.exec())
