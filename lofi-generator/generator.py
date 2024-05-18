import os
from moviepy.audio.io.AudioFileClip import AudioFileClip
from moviepy.audio.AudioClip import CompositeAudioClip

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

    def generate(self):
        composite_audio, audio_clips = self.load_audios()
        composite_audio.write_audiofile(self.out_path + '/audio.wav', fps=44100)

        with open(self.out_path + '/duration.txt', 'w+') as duration:
            duration.write(str(composite_audio.duration))
            duration.close()

        # Cleanup
        composite_audio.close()
        for clip in audio_clips:
            clip.close()
