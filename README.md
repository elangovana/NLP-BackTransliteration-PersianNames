# NLP-BackTransliteration-PersianNames
This Python scripts uses edit distance to predict Latin spellings from Persian.

### Prerequisties 
1. Install Python 2.7 from https://www.python.org/downloads/release/python-2713/
2. Create a virtual environment as detailed in http://python-guide-pt-br.readthedocs.io/en/latest/dev/virtualenvs/.
3. Within the virtual environment Install python package cython using the command
    pip install cython

### Set up this python module.
In your virtual environment run 
> python setup.py develop

### How to run 
To get help
> python main.py -h

To run this script using training data traindata.txt, with names dictionary names.txt and use only 100 records from the training data, with output in outdir use
> python main.py -i traindata.txt -n names.txt -o outdir --samplesize 100
  
## Input data format

1. Training data file is a tab separated file containing the Persian spelling and the correspnding Latin name :
2. The names dictionary is a list of valid latin names
