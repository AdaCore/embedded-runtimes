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
import shutil
import subprocess
import sys

def usage():
    print "usage: install.py [--prefix=<path>]"
    print "  --prefix: installation prefix for the runtimes"
    print ""
    print "By default the runtimes are installed in the toolchain itself."

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

def build(prefix):
    sfp_projects = glob(os.path.join('ravenscar-*', 'sfp'))
    full_projects = glob(os.path.join('ravenscar-*', 'full'))

    all_projects = sfp_projects + full_projects

    # Check for a cross compiler
    target = 'arm-eabi'
    gcc = '%s-gcc' % target
    gcc_bin = which(gcc)
    gcc_dir = os.path.dirname(gcc_bin)
    gprbuild = os.path.join(gcc_dir, 'gprbuild')
    gprinstall = os.path.join(gcc_dir, 'gprinstall')

    if gcc_bin is None:
        print "no compiler found for target %s" % target
        sys.exit(2)

    # Check the installation dir
    if prefix is not None:
        install = prefix
    else:
        install = os.path.join(
            os.path.dirname(gcc_dir), target, 'lib', 'gnat')

    # install the source files first
    dest_bsps = os.path.join(install, 'bsps')
    dest_rts = os.path.join(install, 'base_runtimes')
    if os.path.isdir(dest_bsps):
        shutil.rmtree(dest_bsps)
    if os.path.isdir(dest_rts):
        shutil.rmtree(dest_rts)
    shutil.copytree('bsps', dest_bsps)
    shutil.copytree('base_runtimes', dest_rts)

    for d in all_projects:
        root = os.path.dirname(d)
        gpr = os.path.join(root, 'ravenscar_build.gpr')

        print 'Build %s:' % d

        cmd = [gprbuild, '-p', '-P', gpr, '-j0', '-q']
        if d in sfp_projects:
            cmd += ['-XRTS=ravenscar-sfp']
        else:
            cmd += ['-XRTS=ravenscar-full']

        print '... gprbuild %s' % ' '.join(cmd[1:])
        subprocess.call(cmd, stdout=sys.stdout, stderr=sys.stderr, shell=False)

        # Compute the rts name
        variant = os.path.basename(d)
        base = os.path.basename(os.path.dirname(d)).replace(
            'ravenscar', 'ravenscar-%s' % variant)
        dst = os.path.join(install, base)

        print '... install in %s:' % dst
        if os.path.isdir(dst):
            shutil.rmtree(dst)
        shutil.copytree(d, dst)
        # filter runtime.xml and ada_source_path according to the installation
        # schema
        runtime_xml = os.path.join(dst, 'runtime.xml')
        with open(runtime_xml, 'r') as fp:
            cnt = fp.read()
        lines = []
        for l in cnt.splitlines():
            lines.append(l.replace('../bsps', 'bsps'))
        with open(runtime_xml, 'w') as fp:
            fp.write('\n'.join(lines))

        source_path = os.path.join(dst, 'ada_source_path')
        with open(source_path, 'r') as fp:
            cnt = fp.read()
        lines = []
        for l in cnt.splitlines():
            lines.append(
                l.replace('../bsps', 'bsps').replace(
                    '../base_runtimes', 'base_runtimes'))
        with open(source_path, 'w') as fp:
            fp.write('\n'.join(lines))


def main():
    try:
       opts, args = getopt.getopt(
           sys.argv[1:], "", ["prefix=", "help"])
    except getopt.GetoptError, e:
        print "error: " + str(e)
        usage()
        sys.exit(2)

    prefix = None

    for opt, arg in opts:
        if opt == '--help':
            usage()
            sys.exit()
        elif opt == '--prefix':
            prefix = os.path.abspath(arg)

    build(prefix)

if __name__ == '__main__':
    main()
