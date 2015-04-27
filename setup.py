#!/usr/bin/env python

from version import get_git_version
import os
import sys

try:
  # We'd better have this shit installed, or else you're like totally fucked.
  from Cython.Build import cythonize
  from Cython.Distutils import build_ext
  from setuptools import Command, Extension, setup
  from setuptools.command.install import install
  from subprocess import call
  from distutils.command.build import build
  import numpy as np
except ImportError as exc_info:
  print "Fucking shit! %s." % exc_info.message
  sys.exit(1)

# Get the README and requirements
CWD = os.path.abspath(os.path.dirname(__file__))
with open(CWD + '/README.rst') as f:
  readme = f.read()

with open(CWD + '/requirements.txt') as f:
  INSTALL_REQUIRES = [i.strip() for i in f.readlines()]

PLATFORMS = ['linux', 'osx', 'win32']

class SwiftCInstall(build):
  """Compile and install libswiftnav C bindings. Why does someone have
  to write something like this from scratch?

  """

  def run(self):
    """Before building extensions, build and copy libswiftnav.

    """
    print "Building libswiftnav C library!"
    path = os.path.join(CWD, 'libswiftnav')
    cmd = ['mkdir -v -p %s/build' % path,
           'cd %s/build/' % path,
           'cmake ../',
           'make',
           'cd %s' % path]
    target_files = [os.path.join(path, 'build/src/libswiftnav-static.a')]
    print "Produced...%s\n" % target_files
    def compile():
      print '*' * 80
      os.system(";\n".join(cmd))
      print '*' * 80
    self.execute(compile, [], '\nCompiling libswiftnav C!\n')
    # copy resulting tool to library build folder
    self.build_lib = 'build/lib'
    self.mkpath(self.build_lib)
    if not self.dry_run:
      for target in target_files:
        print "\nCopying %s to %s.\n" % (target, self.build_lib)
        self.copy_file(target, self.build_lib)
    build.run(self)
    print("\n\n\n\nSuccessfully built libswiftnav C libraries!\n\n\n\n")

SETUP_ARGS = dict(name='swiftnav',
                  version=get_git_version(),
                  description='Python bindings to the libswiftnav library',
                  long_description=readme,
                  license='LGPLv3',
                  url='https://github.com/swift-nav/libswiftnav-python',
                  author='Swift Navigation',
                  author_email='dev@swiftnav.com',
                  maintainer='Fergus Noble',
                  maintainer_email='fergus@swift-nav.com',
                  install_requires=INSTALL_REQUIRES,
                  platforms=PLATFORMS,
                  use_2to3=False,
                  zip_safe=False,
                  packages=['swiftnav'])

def make_extension(ext_name):
  """Create a C extension for Python, given an extension name.

  """
  ext_path = ext_name.replace('.', os.path.sep) + '.pyx'
  return Extension(ext_name,
                   [ext_path],
                   include_dirs=[np.get_include(), '.'],
                   extra_compile_args=['-O3', '-g', '-Wno-unused-function'],
                   extra_link_args=['-g'],
                   libraries=['m', 'swiftnav'])


def setup_package():
  """Setup the package and required Cython extensions.

  """
  # Override ARCHFLAGS to build native, not universal on OS X.
  os.environ['ARCHFLAGS'] = ""
  extensions = Extension("*",
                         ["swiftnav/*.pyx"],
                         include_dirs=[np.get_include(), '.'],
                         extra_compile_args=['-O3', '-g', '-Wno-unused-function'],
                         extra_link_args=['-g'],
                         libraries=['m', 'swiftnav'])
  SETUP_ARGS['ext_modules'] = cythonize(extensions)
  SETUP_ARGS['cmdclass'] = {'build': SwiftCInstall,
                            'build_ext': build_ext}
  setup(**SETUP_ARGS)

if __name__ == "__main__":
  setup_package()
