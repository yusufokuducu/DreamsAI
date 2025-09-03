# Video Editor

This is a simple video editor application built with Python and PySide6.

## Features

*   **Timeline:** A multi-track timeline for video, audio, and text clips.
*   **Media Import:** Import video and audio files into the media bin.
*   **Transitions:** Add transitions between video clips, including Crossfade, Fade to Black, and Wipe Left. Transition duration is editable.
*   **Video Effects:** Apply effects like Grayscale to video clips.
*   **Audio Control:** Adjust the volume of individual audio and video clips.
*   **Text Clips:** Add text overlays with customizable font, size, and color.
*   **Snapping:** Clips snap to the playhead and to each other for easier editing.
*   **Undo/Redo:** A robust undo/redo system for most actions.
*   **Exporting:** Export the timeline to an MP4 video file with a progress bar.
*   **Project Save/Load:** Save and load your project as a JSON file.

## Project Structure

The project is organized into the following structure:

```
VideoEditor/
├── main.py             # Main entry point of the application
├── requirements.txt
├── README.md
└── src/
    ├── __init__.py
    ├── ui/               # UI-related classes
    │   ├── main_window.py
    │   ├── properties_panel.py
    │   ├── timeline.py
    │   └── media_bin.py
    ├── commands/         # Undo/Redo command classes
    │   └── command.py
    ├── logic/            # Business logic
    │   ├── exporter.py
    │   └── timeline_items.py
    └── utils/            # Utility functions
        └── theme.py
```

## Setup and Usage

1.  **Install Dependencies:**

    ```bash
    pip install -r requirements.txt
    ```

2.  **Run the Application:**

    ```bash
    python main.py
    ```
