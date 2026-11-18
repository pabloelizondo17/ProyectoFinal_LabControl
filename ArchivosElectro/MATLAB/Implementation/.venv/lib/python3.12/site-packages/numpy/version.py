
"""
Module to expose more detailed version info for the installed `numpy`
"""
version = "2.5.5"
__version__ = version
full_version = version

git_revision = "afcbc6d21a88a7b59c5bfe115198e24ed51b3dae"
release = 'dev' not in version and '+' not in version
short_version = version.split("+")[0]
