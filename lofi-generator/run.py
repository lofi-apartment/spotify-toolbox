import os
from generator import LofiGenerator

AUDIOS_PATH = os.environ.get('AUDIOS_PATH')
IMAGE_PATH = os.environ.get('IMAGE_PATH')
IMAGE_NAME = os.environ.get('IMAGE_NAME')
OUTPUT_PATH = os.environ.get('OUTPUT_PATH')
OUTPUT_NAME = os.environ.get('OUTPUT_NAME')

generator = LofiGenerator(
    audios_path=AUDIOS_PATH,
    image_path=IMAGE_PATH,
    image_name=IMAGE_NAME,
    out_path=OUTPUT_PATH,
    out_name=OUTPUT_NAME,
)

generator.generate()
