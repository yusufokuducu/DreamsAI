from PySide6.QtCore import QObject, Signal
import cv2


from src.logic.timeline_items import CLIP_TYPE, TEXT_TYPE, AUDIO_TYPE, TRANSITION_TYPE

class Exporter(QObject):
    progress = Signal(int); finished = Signal(); error = Signal(str)
    def export(self, clips_data, output_path):
        try:
            video_clips_info = sorted([c for c in clips_data if c['type'] == CLIP_TYPE], key=lambda c: c['x'])
            if not video_clips_info:
                self.error.emit("No video clips on timeline to export.")
                return

            # Get the properties of the first clip to determine the output video properties
            first_clip_path = video_clips_info[0]['data'][0]
            cap = cv2.VideoCapture(first_clip_path)
            width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
            height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
            fps = cap.get(cv2.CAP_PROP_FPS)
            cap.release()

            # Create a VideoWriter object
            fourcc = cv2.VideoWriter_fourcc(*'mp4v')
            out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))

            total_frames = 0
            for clip_info in video_clips_info:
                clip_path = clip_info['data'][0]
                start_time = clip_info['data'][2]
                duration = clip_info['data'][1]
                
                cap = cv2.VideoCapture(clip_path)
                cap.set(cv2.CAP_PROP_POS_MSEC, start_time * 1000)
                
                frames_to_write = int(duration * fps)
                for i in range(frames_to_write):
                    ret, frame = cap.read()
                    if ret:
                        out.write(frame)
                        total_frames += 1
                        self.progress.emit(int(total_frames / (len(video_clips_info) * duration * fps) * 100))
                    else:
                        break
                cap.release()

            out.release()
            self.finished.emit()

        except Exception as e:
            self.error.emit(str(e))
