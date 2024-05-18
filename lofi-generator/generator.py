import os
from moviepy.audio.io.AudioFileClip import AudioFileClip
from moviepy.audio.AudioClip import CompositeAudioClip
from moviepy.video.io.VideoFileClip import VideoFileClip
from moviepy.video.VideoClip import ImageClip
from moviepy.video.compositing.CompositeVideoClip import CompositeVideoClip
from moviepy.video.fx.all import loop

class LofiGenerator:

    def __init__(self, audios_path, image_path, image_name, out_path, out_name):
        self.audios_path = audios_path or '/root'
        self.image_path = image_path or '/root'
        self.image_name = image_name
        self.out_path = out_path or '/root'
        self.out_name = out_name or 'lofi.mp4'

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
        image_name = self.image_name
        if image_name is None:
            for file in os.listdir(self.image_path):
                if file.startswith('image.'):
                    image_name = file
                    break

        image_filename = self.image_path + '/' + image_name
        if image_filename.endswith('.jpg') or image_filename.endswith('.jpeg'):
            clip = ImageClip(image_filename or '', duration=5)
            clip.close()
            return clip
        else:
            clip = VideoFileClip(image_filename or '')
            clip.close()
            return clip

    def combine(self, gif, audio):
        final = CompositeVideoClip([gif]).fx(loop, duration=audio.duration)
        final.set_audio(audio)
        return final

    def generate(self):
        composite_audio, _ = self.load_audios()
        gif = self.load_background()

        final = self.combine(gif, composite_audio)
        final.write_videofile(self.out_path + '/' + self.out_name, fps=24)
