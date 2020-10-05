#
# PROTOBUF.MK --Rules for building protobuf protocols.
#
# Contents:
# %.pb.cc:  --build the C++ stubs from a ".proto" file.
# %.py:     --Build the python stubs from a ".proto" file.
# build:    --Build the protobuf files.
# clean:    --Remove objects and intermediates created from protobuf files.
# src:      --Update the PROTOBUF_SRC macro.
# todo:     --Find "unfinished work" comments in protobuf files.
# +version: --Report details of tools used by protobuf
#
# Remarks:
# The protobuf module adds support for building Protobuf-related software.
# It defines some pattern rules for compiling ".proto" files into
# C++, python (but not java, yet).
# REVISIT: consider a flag for optionally building various language stubs (e.g. protobuf-lang = c++ python java)
#
.PHONY: $(recursive-targets:%=%-protobuf)

PRINT_protoc_VERSION = protoc --version

ifdef autosrc
    LOCAL_PROTOBUF_SRC := $(wildcard *.proto)

    PROTOBUF_SRC ?= $(LOCAL_PROTOBUF_SRC)
endif

PROTOC	?= protoc
PROTOBUF_FLAGS = $(TARGET.PROTOBUF_FLAGS) $(LOCAL.PROTOBUF_FLAGS) \
    $(PROJECT.PROTOBUF_FLAGS) $(ARCH.PROTOBUF_FLAGS) $(OS.PROTOBUF_FLAGS)

C++_SUFFIX ?= cc
H++_SUFFIX ?= h

PROTOBUF_C++ = $(PROTOBUF_SRC:%.proto=$(gendir)/%.pb.$(C++_SUFFIX))
PROTOBUF_H++ = $(PROTOBUF_SRC:%.proto=$(gendir)/%.pb.$(H++_SUFFIX))
PROTOBUF_PY = $(PROTOBUF_SRC:%.proto=$(gendir)/%.py)
PROTOBUF_CS = $(PROTOBUF_SRC:%=%.cs)
PROTOBUF_TRG  = $(PROTOBUF_C++) $(PROTOBUF_H++) $(PROTOBUF_PY) \
	$(PROTOBUF_CS)

.PRECIOUS: $(PROTOBUF_TRG)

## this should move to c.mk or c++.k; it breaks non-C builds
#ifdef o
#PROTOBUF_OBJ = $(PROTOBUF_SRC:%.proto=$(archdir)/%.pb.$(o))
#endif
#ifdef s.o
#PROTOBUF_PIC_OBJ += $(PROTOBUF_SRC:%.proto=$(archdir)/%.pb.$(s.o))
#endif

#
# %.pb.cc: --build the C++ stubs from a ".proto" file.
#
# Remarks:
# This is a little more involved than a simple tool invocation,
# because makeshift supports custom C++ file extensions, and so this
# rule adapts protoc's output accordingly.
#
$(gendir)/%.pb.$(C++_SUFFIX) $(gendir)/%.pb.$(H++_SUFFIX):	%.proto | $(gendir)
	$(ECHO_TARGET)
	$(PROTOC) $(PROTOBUF_FLAGS) --cpp_out=$(gendir) $<
	cd $(gendir) ; \
	if [ "$(H++_SUFFIX)" != "h" ]; then \
	    $(MV) $*.pb.h $*.pb.$(H++_SUFFIX); \
	    $(CP) $*.pb.cc $*.pb.cc.bak; \
	    sed -e "s/$*\.pb\.h/$*.pb.$(H++_SUFFIX)/" <$*.pb.cc.bak >$*.pb.cc; \
	    $(RM)  $*.pb.cc.bak; \
	fi
	cd $(gendir) ; \
	if [ "$(C++_SUFFIX)" != "cc" ]; then \
	    $(MV) $*.pb.cc $*.pb.$(C++_SUFFIX); \
	fi

#
# %.py: --Build the python stubs from a ".proto" file.
#
$(gendir)/%.py:	%.proto | $(gendir)
	$(ECHO_TARGET)
	$(PROTOC) $(PROTOBUF_FLAGS) --python_out=$(gendir) $<
	cd $(gendir); $(MV) $*_pb2.py $*.py

#
# pattern to generate a .proto.cs from a .proto file
# this uses protobuf-net rather protobuf-csharp-port
# TODO: these should go in $(gendir), but i'm not sure how to
# reference them in Visual Studio.
%.proto.cs: %.proto
	$(PROTOC) -i:$< -o:$@ $(PROTOBUF_FLAGS)

#
# build: --Build the protobuf files.
#
build:	$(PROTOBUF_OBJ)

#
# clean: --Remove objects and intermediates created from protobuf files.
#
clean:	clean-protobuf
clean-protobuf:
	$(ECHO_TARGET)
	$(RM) $(PROTOBUF_TRG) $(PROTOBUF_OBJ) $(PROTOBUF_SRC:%.proto=$(archdir)/%.pb.d)

#
# src: --Update the PROTOBUF_SRC macro.
#
src:	src-protobuf
src-protobuf:
	$(ECHO_TARGET)
	$(Q)mk-filelist -f $(MAKEFILE) -qn PROTOBUF_SRC *.proto

#
# todo: --Find "unfinished work" comments in protobuf files.
#
todo:	todo-protobuf
todo-protobuf:
	$(ECHO_TARGET)
	@$(GREP) $(TODO_PATTERN) $(PROTOBUF_SRC) /dev/null ||:

#
# +version: --Report details of tools used by protobuf
#
+version: cmd-version[$(PROTOC)]
