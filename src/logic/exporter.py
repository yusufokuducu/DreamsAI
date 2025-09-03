from PySide6.QtCore import QObject, Signal
from moviepy.editor import (VideoFileClip, concatenate_videoclips, TextClip, 
                              CompositeVideoClip, AudioFileClip, concatenate_audioclips, ColorClip)
import moviepy.video.fx.all as vfx

from src.logic.timeline_items import CLIP_TYPE, TEXT_TYPE, AUDIO_TYPE, TRANSITION_TYPE

class Exporter(QObject):
    progress = Signal(int); finished = Signal(); error = Signal(str)
    def export(self, clips_data, output_path):
        try:
            video_clips_info = sorted([c for c in clips_data if c['type'] == CLIP_TYPE], key=lambda c: c['x'])
            text_clips_info = [c for c in clips_data if c['type'] == TEXT_TYPE]
            audio_clips_info = [c for c in clips_data if c['type'] == AUDIO_TYPE]
            transition_info = sorted([c for c in clips_data if c['type'] == TRANSITION_TYPE], key=lambda c: c['x'])

            if not video_clips_info: self.error.emit("No video clips on timeline to export."); return

            moviepy_video_clips = []
            for c in video_clips_info:
                clip = VideoFileClip(c['data'][0]).subclip(c['data'][2], c['data'][2] + c['data'][1])
                if c['data'][3]: clip = clip.fx(vfx.blackwhite)
                clip = clip.volumex(c['data'][4])
                moviepy_video_clips.append(clip)
            
            final_clips = []
            if moviepy_video_clips:
                final_clips.append(moviepy_video_clips[0])
                for i in range(len(moviepy_video_clips) - 1):
                    prev_clip = final_clips.pop()
                    current_clip = moviepy_video_clips[i+1]
                    transition = None
                    if i < len(transition_info):
                        transition = transition_info[i]

                    if transition:
                        duration = transition['data'][1]
                        trans_type = transition['data'][0]

                        if trans_type == "Crossfade":
                            composed = CompositeVideoClip([prev_clip, current_clip.set_start(prev_clip.duration - duration).crossfadein(duration)])
                            final_clips.append(composed)
                        elif trans_type == "Fade to Black":
                            faded_out = prev_clip.fx(vfx.fadeout, duration / 2)
                            faded_in = current_clip.fx(vfx.fadein, duration / 2)
                            final_clips.append(concatenate_videoclips([faded_out, faded_in]))
                        elif trans_type == "Wipe Left":
                            wipe_clip = current_clip.fx(vfx.scroll, w=current_clip.w, duration=duration, x_speed=-current_clip.w/duration)
                            composed = CompositeVideoClip([prev_clip, wipe_clip.set_start(prev_clip.duration - duration)])
                            final_clips.append(composed)
                        else:
                            final_clips.append(prev_clip)
                            final_clips.append(current_clip)
                    else:
                        final_clips.append(prev_clip)
                        final_clips.append(current_clip)

            final_video = concatenate_videoclips(final_clips)
            self.progress.emit(20)

            moviepy_text_clips = [TextClip(c['data'][0], fontsize=c['data'][3], color=c['data'][4], font=c['data'][2], size=final_video.size).set_duration(c['data'][1]).set_start(c['x'] / 50.0) for c in text_clips_info]
            self.progress.emit(40)
            
            final_audio = None
            if audio_clips_info:
                moviepy_audio_clips = []
                for c in audio_clips_info:
                    clip = AudioFileClip(c['data'][0]).set_duration(c['data'][1])
                    clip = clip.volumex(c['data'][2])
                    moviepy_audio_clips.append(clip)
                final_audio = concatenate_audioclips(moviepy_audio_clips)
            self.progress.emit(60)

            final_clip = CompositeVideoClip([final_video] + moviepy_text_clips)
            if final_audio: final_clip.audio = final_audio
            
            def moviepy_progress(t, duration): self.progress.emit(60 + int((t / duration) * 40))
            final_clip.write_videofile(output_path, codec="libx264", audio_codec="aac", progress_handler=moviepy_progress)
            self.finished.emit()
        except Exception as e: self.error.emit(str(e))
