#
# MINGW64_NT.MK	--Definitions for Windows using the mingw64 environment.
#
# Remarks:
# For builds on windows, OS is pre-set to "Windows_NT".  However,
# uname(1) outputs "mingw64_NT" for the system name, this file allows
# it to be used as an alternative.
#
include os/posix.mk

# setting find to full path to avoid windows find in /c/windows/system32
FIND = /usr/bin/find

OS.CFLAGS 	= -MMD
OS.C_DEFS	= -D__Mingw64_NT__  -D_XOPEN_SOURCE -D_BSD_SOURCE

OS.CXXFLAGS 	= -MMD
OS.C++_DEFS	= -D__Mingw64_NT__   -D_XOPEN_SOURCE -D_BSD_SOURCE


DESTDIR		= /
