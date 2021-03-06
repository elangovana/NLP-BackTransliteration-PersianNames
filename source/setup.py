from setuptools import setup
from Cython.Build import cythonize

ext_options = {"compiler_directives": {"profile": True}, "annotate": True}

setup(
    name='Weighted-Levenshtein',
    version='',
    packages=[''],
    url='',
    license='',
    author='Team bluebird',
    author_email='',
    description='', install_requires=['numpy','weighted_levenshtein','pandas', 'fuzzy', 'ngram'],
    ext_modules = cythonize("*.pyx", **ext_options)

)
