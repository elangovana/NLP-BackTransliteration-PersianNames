__author__ = 'aparnaelangovan'
import persiannames
import os

parser= persiannames.persiannames()
dir = os.path.dirname(__file__)
parser.load(os.path.join(dir,"input_data/train.txt"),os.path.join(dir,"input_data/names.txt"))

