from os import getenv
from setuptools import Extension, setup
from Cython.Build import cythonize
from dotenv import load_dotenv
load_dotenv()



setup(
    name='3d_projection_mapper',  # Required
    ext_modules = cythonize('./*.pyx', compiler_directives={"language_level": 3, "profile": False}),
)