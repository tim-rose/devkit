# build a Visual Studio Project with msbuild.
# Seems a bit superfluous, as msbuild is a make alternative, but
# this is useful when managing a larger project with make, whilst some subcomponents are done with Visual Studio & MSBuild.
.PHONY: $(recursive-targets:%=%-vsproj)

# MSBUILD_DIR can be set in project specific make include
MSBUILD ?= msbuild.exe
LOG_FILE ?= $(ARCH)_$(VARIANT)_build.log

TARGET.BUILD_FLAGS = -fl -flp:logfile=$(gendir)$(LOG_FILE)

ALL_BUILD_FLAGS = $(VARIANT.BUILD_FLAGS) $(OS.BUILD_FLAGS) $(ARCH.BUILD_FLAGS) \
	$(LOCAL.BUILD_FLAGS) $(TARGET.BUILD_FLAGS) $(PROJECT.BUILD_FLAGS)

build: build-vsproj
build-vsproj: $(VSPROJ_SRC) | $(archdir) $(gendir)
	$(MSBUILD) $< $(ALL_BUILD_FLAGS) -t:Build

clean: clean-vsproj
clean-vsproj:
	$(MSBUILD) $< $(ALL_BUILD_FLAGS) -t:Clean
	$(RM) $(gendir)$(LOG_FILE)

distclean: distclean-vs
distclean-vs:
	$(RM) -r bin obj

src: src-vsproj
src-vsproj:
	$(ECHO_TARGET)
	@mk-filelist -f $(MAKEFILE) -qn VSPROJ_SRC *.csproj *.vcxproj
