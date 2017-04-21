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
    """Script usage"""
    print "usage: install.py [--arch=arm-eabi|aarch64-elf] [--prefix=<path>]"
    print "  --arch: only build for the specified architecture"
    print "  --prefix: installation prefix for the runtimes"
    print ""
    print "By default:"
    print "  Builds and installs all targets for which a compiler is available."
    print "  The runtimes are installed in the toolchain itself."


def which(program):
    """Finds 'program' on the path, and returns its absolute path.

    Returns None if not found.
    """
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


def abspath(path):
    """Returns the absolute path of 'path', relative to the repository"""
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
    exe = os.path.basename(argv[0])
    print "[%s] %s" % (exe, " ".join(argv[1:]))
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

    if len(stderr) > 0:
        print stderr
    if len(stdout) > 0:
        print stdout

    return p.returncode


def build(archs, prefix):
    projects = glob(abspath(os.path.join('BSPs', '*.gpr')))
    overall_check = True

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
                os.path.basename(gpr), target)
            continue

        print '** %s **' % os.path.basename(gpr)

        gcc_dir = os.path.dirname(gcc_bin)
        gprbuild = os.path.join(gcc_dir, 'gprbuild')
        gprinstall = os.path.join(gcc_dir, 'gprinstall')

        # clean-up the old rts if any
        if prefix is not None:
            rts_dir = prefix
        else:
            gcc_base = os.path.abspath(os.path.join(gcc_dir, os.pardir))
            rts_dir = os.path.join(gcc_base, target, 'lib', 'gnat')
        rts_name = os.path.basename(gpr).replace('_', '-').replace('.gpr', '')
        rts_path = os.path.join(rts_dir, rts_name)
        if os.path.isdir(rts_path):
            print '[rmtree] %s' % rts_path
            rmtree(rts_path)
        else:
            print "not found: %s" % rts_path

        cmd = [gprbuild, '-P', gpr, '-p', '-q', '-j0']
        error = False
        returncode = run_program(cmd)
        if returncode:
            print 'Build error (gprbuild returned {}):\n{}'.format(
                returncode, stderr)
            overall_check = False
            error = True
            continue

        cmd = [gprinstall, '-P', gpr, '-p', '-q', '-f']
        if prefix is not None:
            cmd += ['-XPREFIX=%s' % prefix]
        returncode = run_program(cmd)
        if returncode:
            print 'Build error (gprinstall returned {}):\n{}'.format(
                returncode, stderr)
            overall_check = False
            error = True
            continue

        if error:
            print "Failed"
        else:
            print "OK"
        print ""


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
