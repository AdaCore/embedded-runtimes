# embedded-runtimes

This repository contains runtimes that add support for various boards to the
GNAT GPL compiler for ARM.

To build the runtimes: make sure GNAT GPL is in your PATH, and that you have
also a python interpreter installed:

    $ cd embedded-runtimes
    $ python ./install.py

Those runtimes can be either runtimes updated from the ones delivered with the
compiler, or new ones.

You will then be able to use it as any standard runtime, either via

    $ gprbuild --RTS=ravenscar-sfp-stm32f769disco -P <my_project>

or add in your project:

    for Runtime ("Ada") use "ravenscar-sfp-stm32f769disco";

# install.py options

usage: install.py [--prefix=<path>]
       install.py --help
  --prefix: installation prefix for the runtimes.
  --help: displays available options and exits.

By default the runtimes are installed in the toolchain itself.
