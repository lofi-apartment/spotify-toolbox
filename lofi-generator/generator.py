import os
from moviepy.audio.io.AudioFileClip import AudioFileClip
from moviepy.audio.AudioClip import CompositeAudioClip
from moviepy.video.io.VideoFileClip import VideoFileClip
from moviepy.video.VideoClip import ImageClip
from moviepy.video.compositing.CompositeVideoClip import CompositeVideoClip
from moviepy.video.fx.all import loop
from moviepy.audio.fx.all import volumex

class LofiGenerator:

    def __init__(self, audios_path, bg_file, out_path):
        self.audios_path = audios_path or '/root'
        self.bg_file = bg_file or '/root/lofi.jpeg'
        self.out_path = out_path or '/root'

    # load audio clips, parse durations and metadata
    def load_audios(self):
        audio_paths = [file for file in os.listdir(self.audios_path) if file.endswith('.mp3')]
        clips = []
        for path in audio_paths:
            file = AudioFileClip(self.audios_path + '/' + path)
            clips.append(file)

        # combine all audio clips
        composite = CompositeAudioClip(clips)

        return (composite, clips)

    # load background
    def load_background(self):
        if self.bg_file.endswith('.jpg') or self.bg_file.endswith('.jpeg'):
            clip = ImageClip(self.bg_file or '', duration=5)
            return clip
        else:
            clip = VideoFileClip(self.bg_file or '')
            return clip

    def generate(self):
        composite_audio, audio_clips = self.load_audios()
        gif = self.load_background()

        final = CompositeVideoClip([gif]).fx(loop, duration=composite_audio.duration)

        composite_audio.write_audiofile(self.out_path + '/audio.mp3', fps=44100)
        final.write_videofile(self.out_path + '/video.mp4', fps=30, audio=False)

        # Cleanup
        composite_audio.close()
        final.close()

        gif.close()
        for clip in audio_clips:
            clip.close()
