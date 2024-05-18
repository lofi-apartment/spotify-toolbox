import os
from generator import LofiGenerator

AUDIOS_PATH = os.environ.get('AUDIOS_PATH')
BG_FILE = os.environ.get('BG_FILE')
OUTPUT_PATH = os.environ.get('OUTPUT_PATH')

generator = LofiGenerator(
    audios_path=AUDIOS_PATH,
    bg_file=BG_FILE,
    out_path=OUTPUT_PATH,
)

generator.generate()
