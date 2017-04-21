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
import stat
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
        (base, ext) = os.path.splitext(program)
        if not ext:
            program += '.exe'
    for p in paths:
        f = os.path.join(p, program)
        if os.path.isfile(f):
            return f
    return None


def abspath(path):
    if os.path.isabs(path):
        return path
    else:
        pwd = os.path.dirname(os.path.abspath(__file__))
        return os.path.join(pwd, path)


def rmtree(path):
    def del_rw(action, name, exc):
        os.chmod(name, stat.S_IWRITE)
        os.remove(name)
    shutil.rmtree(path, onerror=del_rw)


def run_program(argv):
    print "$ %s" % " ".join(argv)
    p = subprocess.Popen(
        argv,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    stdout, stderr = p.communicate()

    try:
        stdout = stdout.decode('ascii')
    except UnicodeError:
        return 'stdout is not ASCII'

    try:
        stderr = stderr.decode('ascii')
    except UnicodeError:
        return 'stderr is not ASCII'

    return (p.returncode, stdout, stderr)


def build(prefix):
    sfp_projects = glob(abspath(os.path.join('ravenscar-*', 'sfp')))
    full_projects = glob(abspath(os.path.join('ravenscar-*', 'full')))

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
        install = abspath(prefix)
    else:
        install = os.path.join(
            os.path.dirname(gcc_dir), target, 'lib', 'gnat')

    # install the source files first
    dest_bsps = os.path.join(install, 'bsps')
    dest_rts = os.path.join(install, 'base_runtimes')
    if os.path.isdir(dest_bsps):
        rmtree(dest_bsps)
    if os.path.isdir(dest_rts):
        rmtree(dest_rts)
    shutil.copytree(abspath('bsps'), dest_bsps)
    shutil.copytree(abspath('base_runtimes'), dest_rts)

    overall_check = True

    for d in all_projects:
        root = os.path.dirname(d)
        gpr = os.path.join(root, 'ravenscar_build.gpr')

        print 'Build %s:' % d

        cmd = [gprbuild, '-p', '-P', gpr, '-j0', '-q']
        if d in sfp_projects:
            cmd += ['-XRTS=ravenscar-sfp']
        else:
            cmd += ['-XRTS=ravenscar-full']

        returncode, stdout, stderr = run_program(cmd)
        print stderr
        print stdout
        if returncode:
            print 'Build error (gprbuild returned {}):\n{}'.format(
                returncode, stderr)
            overall_check = False
            continue

        # Compute the rts name
        variant = os.path.basename(d)
        base = os.path.basename(os.path.dirname(d)).replace(
            'ravenscar', 'ravenscar-%s' % variant)
        dst = os.path.join(install, base)

        print '... install in %s:' % dst
        if os.path.isdir(dst):
            rmtree(dst)
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

    return overall_check


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

    success = build(prefix)
    if not success:
        sys.exit(2)

if __name__ == '__main__':
    main()
