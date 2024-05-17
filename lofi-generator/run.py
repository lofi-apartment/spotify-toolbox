import argparse
from generator import LofiGenerator

parser = argparse.ArgumentParser(
    prog='generate',
    description='Generate some lofi!',
)

parser.add_argument('-a', '--audio-dir', required=True)
parser.add_argument('-g', '--gif', required=True)
parser.add_argument('-o', '--out-file', required=True)

args = parser.parse_args()

generator = LofiGenerator(args.audio_dir, args.gif, args.out_file)

generator.generate()
