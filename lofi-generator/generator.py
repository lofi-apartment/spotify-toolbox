import os
from moviepy.audio.io.AudioFileClip import AudioFileClip
from moviepy.audio.AudioClip import CompositeAudioClip
from moviepy.video.VideoClip import ImageClip
from moviepy.video.compositing.CompositeVideoClip import CompositeVideoClip
from moviepy.video.fx.all import loop

class LofiGenerator:

    def __init__(self, audio_dir, gif, out_file):
        self.audio_dir = audio_dir or ''
        self.gif_path = gif or ''
        self.out_file = out_file

    # load audio clips, parse durations and metadata
    def load_audios(self):
        audio_paths = [file for file in os.listdir(self.audio_dir) if file.endswith('.mp3')]
        clips = []
        for path in audio_paths:
            file = AudioFileClip(self.audio_dir+'/'+path)
            clips.append(file)

        # combine all audio clips
        composite = CompositeAudioClip(clips)

        return (composite, clips)

    # load gif
    def load_image(self):
        return ImageClip(self.gif_path or '', duration=5)

    def combine(gif, audio):
        final = CompositeVideoClip([gif]).fx(loop, duration=audio.duration)
        final.set_audio(audio)
        return final

    def generate(self):
        composite_audio, _ = self.load_audios()
        gif = self.load_image()

        final = self.combine(gif, composite_audio)
        final.write_videofile(self.out_file, fps=24)
