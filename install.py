#!/usr/bin/env python
#
# Copyright (C) 2016, AdaCore
#
# Python script to build and install the embedded runtimes for bare metal
# targets.

import getopt
from glob import glob
import os
import re
import subprocess
import sys

def usage():
    print "usage: install.py [--arch=arm-eabi|aarch64-elf] [--prefix=<path>]"
    print "  --arch: only build for the specified architecture"
    print "  --prefix: installation prefix for the runtimes"
    print ""
    print "By default:"
    print "  Builds and installs all targets for which a compiler is available."
    print "  The runtimes are installed in the toolchain itself."

def which(program):
    paths = os.environ['PATH'].split(os.pathsep)
    if sys.platform == 'win32':
        (base, ext) = os.path.splitext(executable)
        if not ext:
            program += '.exe'
    for p in paths:
        f = os.path.join(p, program)
        if os.path.isfile(f):
            return f
    return None

def build(archs, prefix):
    projects = glob(os.path.join('BSPs', '*.gpr'))
    for gpr in projects:
        # retrieve the rts target compiler
        with open(gpr, 'r') as fp:
            cnt = fp.read()
        target = None

        for l in cnt.splitlines():
            match = re.match(' *for Target use "([^"]*)";', l)
            if match is not None:
                target = match.group(1)
                break
        assert target is not None, \
            "Unexpected project file %s: no Target defined" % gpr

        if len(archs) > 0 and target not in archs:
            continue

        # find the proper toolchain
        gcc = '%s-gcc' % target
        gcc_bin = which(gcc)

        if gcc_bin is None:
            print "skip %s: no compiler found for target %s" % (
                gpr, target)
            continue

        gcc_dir = os.path.dirname(gcc_bin)
        gprbuild = os.path.join(gcc_dir, 'gprbuild')
        gprinstall = os.path.join(gcc_dir, 'gprinstall')

        cmd = [gprbuild, '-P', gpr, '-j0', '-q']
        print ' '.join(cmd)
        subprocess.call(cmd, stdout=sys.stdout, stderr=sys.stderr, shell=False)

        cmd = [gprinstall, '-P', gpr, '-p', '-f', '-q']
        if prefix is not None:
            cmd += ['-XPREFIX=%s' % prefix]
        print ' '.join(cmd)
        subprocess.call(cmd, stdout=sys.stdout, stderr=sys.stderr, shell=False)


def main():
    try:
       opts, args = getopt.getopt(
           sys.argv[1:], "", ["arch=", "prefix=", "help"])
    except getopt.GetoptError, e:
        print "error: " + str(e)
        usage()
        sys.exit(2)

    prefix = None
    archs = []

    for opt, arg in opts:
        if opt == '--help':
            usage()
            sys.exit()
        elif opt == '--arch':
            archs.append(arg)
        elif opt == '--prefix':
            prefix = os.path.abspath(arg)

    build(archs, prefix)

if __name__ == '__main__':
    main()
