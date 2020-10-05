#
# CS.MK --Rules for building C# libraries and programs. The rules are written
#         for the Microsoft CSC.EXE compiler. Support for buiding on Linux or BSD with mono
#         has not yet been implemented.
#
#
# Contents:
# build:   --Build all the c# sources that have changed.
# install: --install c# binaries and libraries.
# clean:   --Remove c# class files.
# src:     --Update the CS_SRC macro.
# todo:    --Report "unfinished work" comments in CSC files.
#
#
.PHONY: $(recursive-targets:%=%-cs)
################################################################################
# Tools definition
################################################################################
# 1. C-Sharp compiler
CSC ?= csc.exe
# 2. Resource generator
RESGEN ?= resgen.exe
# 3. posix find
FIND ?= find
################################################################################
# Suffixes
################################################################################
CS_SUFFIX ?= cs
LIB_SUFFIX ?= dll
EXE_SUFFIX ?= exe
# TODO: is this also supported by mono?
RSX_SUFFIX ?= resx

# this regex searches for the main-function in C#, which normally is:
# static void Main or static int Main
CS_MAIN_RGX ?= '^[ \t]*static[ \t]*.*[ \t]Main'

ifdef autosrc
    LOCAL_CS_SRC := $(shell find . -path ./obj -prune -o -type f -name '*.$(CS_SUFFIX)' -print)
    LOCAL_CS_MAIN := $(shell grep -l $(CS_MAIN_RGX) '*.$(CS_SUFFIX)')
    LOCAL_RSX_SRC := $(shell find . -path ./obj -prune -o -type f -name '*.$(RSX_SUFFIX)' -print)
    CS_SRC ?= $(LOCAL_CS_SRC)
    CS_MAIN_SRC ?= $(LOCAL_CS_MAIN)
		RSX_SRC ?= $(LOCAL_RSX_SRC)
endif

# these rules assume that the C# code is organised as follows:
#  - the assembly or program name is the same as the directory name where the Makefile resides
#  - the cs source files are at the same level or in subdirectories; these subdirs have no further
#    Makefile recursion!
#  - if this builds an executable, the main file resides in the same directory as the Makefile and
#    has the 'static void Main' function
# when organised this way, these rules autodetect whether to build a library or executable and
# what name to give it. The name can be overridden in the local Makefile.
MODULE_NAME ?= $(shell basename $$(pwd))

ifdef CS_MAIN_SRC
  # Main file detected, so we are building an executable
    TARGET := $(MODULE_NAME).$(EXE_SUFFIX)
    TARGET.CS_FLAGS += -target:winexe
else
  # no main file, so we assume we're building a library
    TARGET := $(MODULE_NAME).$(LIB_SUFFIX)
    TARGET.CS_FLAGS += -target:library
endif

# application config file specified, so create one in archdir
ifdef APP_CONFIG
	TARGET.CONFIG = $(archdir)/$(TARGET).config
endif

# if an icon file was given, we include it in the binary
ifdef ICON_FILE
	TARGET.CS_FLAGS += -win32icon:$(ICON_FILE)
endif

# collect all compiler flags
ALL_CS_FLAGS = $(VARIANT.CS_FLAGS) $(OS.CS_FLAGS) $(ARCH.CS_FLAGS) \
    $(TARGET.CS_FLAGS) $(PROJECT.CS_FLAGS) $(CS_FLAGS) $(LOCAL.CS_FLAGS)
# collect all resources generator flags
ALL_RSX_FLAGS = $(VARIANT.RSX_FLAGS) $(OS.RSX_FLAGS) $(ARCH.RSX_FLAGS) $(LOCAL.RSX_FLAGS) \
    $(TARGET.RSX_FLAGS) $(PROJECT.RSX_FLAGS) $(RSX_FLAGS)
# All assemblies that are references need to be passed to the compiler; Because of the variety
# of .Net Framework versions that exist and can be used in mixed fashion, the references
# are passed to the compiler with full-path, thus enabling cherry picking across versions
# How to use:
# similar to languages, specify dotnet_frameworks. The names for each framework can be
# freely chosen. For example:
# dotnet_frameworks = v2_0 v3_5 v4_5_1
# then for each of the specified frameworks, you need to specify the directory where the
# frameworks reside as <framework_name>.dir. This can easily be done in the project.mk
# makefile as the locations would be static across the project. For the example above, the
# project make could have:
# v2_0.dir = /c/Windows/Framework/2.0.5057/
# v3_5.dir = /c/Program Files (x86)/Reference Assemblies/Microsoft/Framework/v3.5/
# and so forth.
# NOTE: make sure to have the trailing '/'
# Lastly, at the module level, one would define a variable <framework_name>.ref with
# all references to use from that framework (without the extension). E.g.
# v2_0.ref = mscorlib System System.Data
TARGET.CS_REFS = $(foreach f,$(dotnet_frameworks),$($(f).ref:%=-r:$($(f).dir)%.$(LIB_SUFFIX)))

# besides the the system libs, which are just referenced, the local makefile can specify local.ref
# which has librarires that will be copied to the local archdir (mimic the Visual Studio "copy local")
# lastly, for local refs that do not need copying, a -r can be added to LOCAL.CS_FLAGS directly
# TODO: filenames with spaces don't work with below expansion; work around: use the DOS name
# NOTE: when adding references, use -r rather than -reference so RESGEN won't fail
# NOTE: using sort to filter out duplicates if present.
LOCAL.CS_REFS += $(sort $(local.ref:%=-r:%.$(LIB_SUFFIX)))
LOCAL.CS_REFS += $(sort $(local.exe:%=-r:%.$(EXE_SUFFIX)))

# create build rules for local references
define copy_local
$(patsubst %, $(archdir)/%.$(2), $(notdir $(1))): $(1).$(2)
		$$(INSTALL_DATA) $$? $$@
# if this reference has a .pdb file with debug symbols, also copy it
		$$(if $$(wildcard $$(?:%.$(2)=%.pdb)), \
			$$(INSTALL_DATA) $$(?:%.$(2)=%.pdb) $$(@:%.$(2)=%.pdb))
# if this reference has a .config app config file, also copy it
		$$(if $$(wildcard $$(?:%=%.config)), \
			$$(INSTALL_DATA) $$(?:%=%.config) $$(@:%=%.config))
# if this reference has an associated xml file, also copy it
		$$(if $$(wildcard $$(?:%.$(2)=%.xml)), \
			$$(INSTALL_DATA) $$(?:%.$(2)=%.xml) $$(@:%.$(2)=%.xml))
endef

# dependency generation for resources files
define make-deps-resx
$(gendir)/$(MODULE_NAME).$(subst /,.,$(1:%.$(RSX_SUFFIX)=%.resources)): $1 | $(gendir)
endef

ALL_CS_REFS = $(VARIANT.CS_REFS) $(OS.CS_REFS) $(ARCH.CS_REFS) $(LOCAL.CS_REFS) \
    $(TARGET.CS_REFS) $(PROJECT.CS_REFS) $(CS_REFS)
RESOURCES = $(addprefix $(gendir)/$(MODULE_NAME).,$(subst /,.,$(RSX_SRC:%.$(RSX_SUFFIX)=%.resources)))

# add target framework attribute file to CS_SRC if it was specified
CS_SRC += $(TARGET_FRAMEWORK:%=$(gendir)/%.cs)

# create the target framework attribute file if a target was specified
$(gendir)/$(TARGET_FRAMEWORK).cs : | $(gendir)
	$(ECHO_TARGET)
	@echo 'using System;' > $@
	@echo 'using System.Reflection;' >> $@
	@echo -n '[assembly: global::System.Runtime.Versioning.TargetFrameworkAttribute(' >> $@
	@echo -n '".NETFramework,Version=v$(@:$(gendir)/%.cs=%)",' >> $@
	@echo ' FrameworkDisplayName = ".NET Framework $(@:$(gendir)/%.cs=%)")]' >> $@

#
# build: --Build all the cs sources that have changed.
#
build:		build-cs
build-cs: $(archdir)/$(TARGET) $(TARGET.CONFIG) \
	$(foreach ref,$(sort $(local.ref)),$(archdir)/$(notdir $(ref).$(LIB_SUFFIX))) \
	$(foreach exe,$(sort $(local.exe)),$(archdir)/$(notdir $(exe).$(EXE_SUFFIX)))

# for each of the local references, generate the build rules for copy-local behaviour
$(foreach ref,$(sort $(local.ref)),$(eval $(call copy_local,$(ref),$(LIB_SUFFIX))))
$(foreach exe,$(sort $(local.exe)),$(eval $(call copy_local,$(exe),$(EXE_SUFFIX))))

# somewhat ugly, but there is only a single invocation that needs to get all files
$(archdir)/$(TARGET): $(CS_SRC) $(RESOURCES) $(MANIFEST_FILE) $(KEY_FILE) \
		$(ICON_FILE) $(APP_CONFIG) | $(archdir)
	$(ECHO_TARGET)
	$(CSC) $(ALL_CS_FLAGS) $(MANIFEST_FILE:%=-win32manifest:%) $(ALL_CS_REFS) \
		$(RESOURCES:%=-res:%) $(KEY_FILE:%=-keyfile:%) $(ICON_FILE:%=-win32icon:%) \
		$(APP_CONFIG:%=-appconfig:%) $(CS_SRC) "-out:$@"

# install the application config file if it was specified.
$(TARGET.CONFIG): $(APP_CONFIG)
	$(INSTALL_DATA) $? $@

# build the resources files
$(foreach d, $(RSX_SRC), $(eval $(call make-deps-resx,$d)))
# NOTE: resgen.exe doesn't accept -compile (yay, consistency Microsoft!) so
# we have to pass /compile. Msys by default will convert that to c:\msys64\compile.
# to avoid that, we  need to set the MSYS_ARG_CONV_EXCL environment variable to include
# /compile. This can be done in the project mk-file.
%.resources :
	$(ECHO_TARGET)
	$(RESGEN) $(ALL_RSX_FLAGS) $(ALL_CS_REFS) /compile $<,$@

#
# TODO: install: --install cs binaries and libraries.
#
install-cs:
	$(ECHO_TARGET)

uninstall-cs:
	$(ECHO_TARGET)

#
# clean: --Remove build outputs
#
distclean:	distclean-cs
clean:	clean-cs
clean-cs:
	$(ECHO_TARGET)
	$(RM) -r $(archdir)/*
	$(RM) -r $(gendir)/*
	$(RM) $(PROTO_SRC:%=%.cs)
distclean-cs: clean-cs
	$(ECHO_TARGET)
	$(RM) -r bin obj

#
# src: --Update the CS_SRC macro.
#      exclude ./obj from the search path, Visual Studio sometimes generates files here.
#      other than that, all .cs files in the directory tree from here are condidered part of
#      this module.
#
src:	src-cs
src-cs:
	$(ECHO_TARGET)
	@mk-filelist -f $(MAKEFILE) -qn CS_SRC $$($(FIND) . -path ./obj -prune -o -type f -name '*.$(CS_SUFFIX)' -print)
	@mk-filelist -f $(MAKEFILE) -qn CS_MAIN_SRC $$(grep -l $(CS_MAIN_RGX) ''*.$(CS_SUFFIX)'' 2>/dev/null)
	@mk-filelist -f $(MAKEFILE) -qn RSX_SRC $$($(FIND) . -path ./obj -prune -o -type f -name '*.$(RSX_SUFFIX)' -print)

#
# todo: --Report "unfinished work" comments in Java files.
#
todo:	todo-cs
todo-cs:
	$(ECHO_TARGET)
	@$(GREP) $(TODO_PATTERN) $(CS_SRC) /dev/null || true
