#
# x86_64-w64-mingw32 --Definitions for x86_64-w64-mingw32 (intel) cross-compile builds.
#
# ARCH.C_DEFS = -m64
# ARCH.C++_DEFS = -m64

compiler_id  = x86_64-w64-mingw32
CC      = /usr/bin/$(compiler_id)-gcc
CXX     = /usr/bin/$(compiler_id)-g++
AR      = /usr/bin/$(compiler_id)-ar
LD      = /usr/bin/$(compiler_id)-ld
RANLIB  = /usr/bin/$(compiler_id)-ranlib

mingw_qt = /usr/$(compiler_id)

RCC ?= $(mingw_qt)/bin/rcc
MOC ?= $(mingw_qt)/bin/moc
UIC ?= $(mingw_qt)/bin/uic

ARCH.CFLAGS   = -I/usr/$(compiler_id)/include 
ARCH.CXXFLAGS = $(ARCH.CFLAGS)
ARCH.LDFLAGS  = -static -L/usr/$(compiler_id)/lib -Wl,-subsystem,windows
ARCH.LDLIBS   =

ARCH.C_DEFS = -m64 -D__MINGW64__
ARCH.C++_DEFS = -mwindows -m64 -D__MINGW64__

ARCH_LIBDIR = /usr/$(compiler_id)/bin

