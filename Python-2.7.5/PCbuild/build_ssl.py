from __future__ import with_statement, print_function
# Script for building the _ssl and _hashlib modules for Windows.
# Uses Perl to setup the OpenSSL environment correctly
# and build OpenSSL, then invokes a simple nmake session
# for the actual _ssl.pyd and _hashlib.pyd DLLs.

# THEORETICALLY, you can:
# * Unpack the latest SSL release one level above your main Python source
#   directory.  It is likely you will already find the zlib library and
#   any other external packages there.
# * Install ActivePerl and ensure it is somewhere on your path.
# * Run this script from the PCBuild directory.
#
# it should configure and build SSL, then build the _ssl and _hashlib
# Python extensions without intervention.

# Modified by Christian Heimes
# Now this script supports pre-generated makefiles and assembly files.
# Developers don't need an installation of Perl anymore to build Python. A svn
# checkout from our svn repository is enough.
#
# In Order to create the files in the case of an update you still need Perl.
# Run build_ssl in this order:
# python.exe build_ssl.py Release x64
# python.exe build_ssl.py Release Win32

import argparse, os, sys, re, shutil, subprocess

def run_command(args, fail_on_non_zero_exit_code=True):
    args_str = subprocess.list2cmdline(args)
    print("Starting command: {}".format(args_str))
    try:
        process = subprocess.Popen(args)
    except OSError as e:
        print("ERROR: unable to start process: {} ({})".format(args[0], e.strerror))
        sys.exit(1)
    else:
        rc = process.wait()
        if fail_on_non_zero_exit_code:
            if rc == 0:
                print("{} command completed successfully".format(args[0]))
            else:
                print("ERROR: command completed with non-zero exit code {}: {}"
                    .format(rc, args_str))
                sys.exit(1)
        else:
            print("{} command completed with exit code: {}".format(args[0], rc))

    return rc

# Find all "foo.exe" files on the PATH.
def find_all_on_path(filename, extras = None):
    entries = os.environ["PATH"].split(os.pathsep)
    ret = []
    for p in entries:
        fname = os.path.abspath(os.path.join(p, filename))
        if os.path.isfile(fname) and fname not in ret:
            ret.append(fname)
    if extras:
        for p in extras:
            fname = os.path.abspath(os.path.join(p, filename))
            if os.path.isfile(fname) and fname not in ret:
                ret.append(fname)
    return ret

# Find a suitable Perl installation for OpenSSL.
# cygwin perl does *not* work.  ActivePerl does.
# Being a Perl dummy, the simplest way I can check is if the "Win32" package
# is available.
def find_working_perl(perls):
    for perl in perls:
        print("Testing Perl from {} for ability to build OpenSSL".format(perl))
        args = [perl, "-e", "use Win32;"]
        rc = run_command(args, fail_on_non_zero_exit_code=False)
        if rc == 0:
            print("Using Perl: {}".format(perl))
            return perl
    print("Can not find a suitable PERL:")
    if perls:
        print(" the following perl interpreters were found:")
        for p in perls:
            print(" ", p)
        print(" None of these versions appear suitable for building OpenSSL")
    else:
        print(" NO perl interpreters were found on this machine at all!")
    print(" Please install ActivePerl and ensure it appears on your path")
    return None

# Fetch SSL directory from VC properties
def get_ssl_dir():
    propfile = (os.path.join(os.path.dirname(__file__), 'pyproject.vsprops'))
    with open(propfile) as f:
        m = re.search('openssl-([^"]+)"', f.read())
        return "..\..\openssl-"+m.group(1)


def create_makefile64(makefile, m32):
    """Create and fix makefile for 64bit

    Replace 32 with 64bit directories
    """
    if not os.path.isfile(m32):
        return
    with open(m32) as fin:
        with open(makefile, 'w') as fout:
            for line in fin:
                line = line.replace("=tmp32", "=tmp64")
                line = line.replace("=out32", "=out64")
                line = line.replace("=inc32", "=inc64")
                # force 64 bit machine
                line = line.replace("MKLIB=lib", "MKLIB=lib /MACHINE:X64")
                line = line.replace("LFLAGS=", "LFLAGS=/MACHINE:X64 ")
                # don't link against the lib on 64bit systems
                line = line.replace("bufferoverflowu.lib", "")
                fout.write(line)
    os.unlink(m32)

def fix_makefile(makefile):
    """Fix some stuff in all makefiles
    """
    if not os.path.isfile(makefile):
        return
    # 2.4 compatibility
    fin = open(makefile)
    if 1: # with open(makefile) as fin:
        lines = fin.readlines()
        fin.close()
    fout = open(makefile, 'w')
    if 1: # with open(makefile, 'w') as fout:
        for line in lines:
            if line.startswith("PERL="):
                continue
            if line.startswith("CP="):
                line = "CP=copy\n"
            if line.startswith("MKDIR="):
                line = "MKDIR=mkdir\n"
            fout.write(line)
    fout.close()

def run_configure(configure, do_script):
    configure_args = ["perl", "Configure", "enable-camellia", "disable-idea", configure]
    run_command(configure_args)
    run_command([do_script])

def main():
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument("target", choices=("Win32", "x64"))
    arg_parser.add_argument("-a", "--build-all", action="store_true", default=False)
    parsed_args = arg_parser.parse_args()
    build_all = parsed_args.build_all

    if parsed_args.target == "Win32":
        arch = "x86"
        configure = "VC-WIN32"
        do_script = "ms\\do_nasm.bat"
        makefile="ms\\nt.mak"
        m32 = makefile
    elif parsed_args.target == "x64":
        arch="amd64"
        configure = "VC-WIN64A"
        do_script = "ms\\do_win64a.bat"
        makefile = "ms\\nt64.mak"
        m32 = makefile.replace('64', '')
        #os.environ["VSEXTCOMP_USECL"] = "MS_OPTERON"
    else:
        raise AssertionError("invalid target: {!r}".format(parsed_args.target))

    make_flags = ""
    if build_all:
        make_flags = "-a"
    # perl should be on the path, but we also look in "\perl" and "c:\\perl"
    # as "well known" locations
    perls = find_all_on_path("perl.exe", ["\\perl\\bin", "C:\\perl\\bin"])
    perl = find_working_perl(perls)
    if perl:
        print("Found a working perl at '%s'" % (perl,))
    else:
        print("No Perl installation was found. Existing Makefiles are used.")
    sys.stdout.flush()
    # Look for SSL 2 levels up from pcbuild - ie, same place zlib etc all live.
    ssl_dir = get_ssl_dir()
    if ssl_dir is None:
        sys.exit(1)

    old_cd = os.getcwd()
    try:
        os.chdir(ssl_dir)
        # rebuild makefile when we do the role over from 32 to 64 build
        if arch == "amd64" and os.path.isfile(m32) and not os.path.isfile(makefile):
            os.unlink(m32)

        # If the ssl makefiles do not exist, we invoke Perl to generate them.
        # Due to a bug in this script, the makefile sometimes ended up empty
        # Force a regeneration if it is.
        if not os.path.isfile(makefile) or os.path.getsize(makefile)==0:
            if perl is None:
                print("Perl is required to build the makefiles!")
                sys.exit(1)

            print("Creating the makefiles...")
            sys.stdout.flush()
            # Put our working Perl at the front of our path
            os.environ["PATH"] = os.path.dirname(perl) + \
                                          os.pathsep + \
                                          os.environ["PATH"]
            run_configure(configure, do_script)

            if arch == "amd64":
                create_makefile64(makefile, m32)
            fix_makefile(makefile)
            shutil.copy(r"crypto\buildinf.h", r"crypto\buildinf_%s.h" % arch)
            shutil.copy(r"crypto\opensslconf.h", r"crypto\opensslconf_%s.h" % arch)

        # Now run make.
        if arch == "amd64":
            run_command(["ml64", "-c", "-Foms\\uptable.obj", "ms\\uptable.asm"])

        shutil.copy(r"crypto\buildinf_%s.h" % arch, r"crypto\buildinf.h")
        shutil.copy(r"crypto\opensslconf_%s.h" % arch, r"crypto\opensslconf.h")

        #makeCommand = "nmake /nologo PERL=\"%s\" -f \"%s\"" %(perl, makefile)
        sys.stdout.flush()
        makeArgs = ["nmake", "/nologo", "-f", makefile]
        run_command(makeArgs)
    finally:
        os.chdir(old_cd)

if __name__=='__main__':
    main()
