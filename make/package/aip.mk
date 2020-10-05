#
# Remarks:
# The package/aip module provides support for building an AdvancedInstaller Windows Executable
#
# NOTE: AIC cannot deal with forward slashes in directory path, hence the 'subst'
# NOTE: as we are using msys on windows, add /NewProject;/Execute;/Build to the
#       MSYS_ARG_CONV_EXCL list in the project makefile and/or environment.
#
# The builder expects a $(PACKAGE).aip.in file present which it will use to create a full
# aip-file

AIC ?= AdvancedInstaller.com

package: $(PACKAGE_DIR)/$(PACKAGE).exe

# building an aip file, the local makefile needs to give all files to be packaged as
# prerequisites. Currently, this is assumed a flat structure in APPDIR. In addition,
# the first prerequisite must be the .aip file.
# TODO: add support for directory structure.
%.aip: %.aip.in $(AIP_SRC)
	$(ECHO_TARGET)
	$(file > $@.args,;aic)
	$(file >>$@.args,SetProperty ProductName=$(PRODUCT_NAME))
	$(file >>$@.args,SetProperty Manufacturer=$(MANUFACTURER))
	$(file >>$@.args,SetVersion $(VERSION))
	$(file >>$@.args,$(PRODUCT_ICON:%=SetIcon -icon %))
	$(file >>$@.args,SetPackageName $(PACKAGE))
	$(file >>$@.args,SetOutputLocation -buildname DefaultBuild -path $(shell cygpath -aw $(PACKAGE_DIR)))
	$(foreach f,$(filter-out $<,$^),$(file >>$@.args,AddFile APPDIR $(subst /,\,$f)))
	$(file >>$@.args,$(PRODUCT_MAIN:%=NewShortcut -name % -dir SHORTCUTDIR ) $(PRODUCT_MAIN:%=-target APPDIR\\%.exe -wkdir APPDIR))
	$(file >>$@.args,$(PRODUCT_MAIN:%=NewShortcut -name % -dir DesktopDir ) $(PRODUCT_MAIN:%=-target APPDIR\\%.exe -wkdir APPDIR))
	$(file >>$@.args,Save)
	@$(CP) $< $@
	$(AIC) /Execute $(subst /,\,$@) $(subst /,\,$@.args)
	@$(RM) $@.args

# build the aip file into an executable.
$(PACKAGE_DIR)/%.exe: %.aip
	$(AIC) /Build $(subst /,\,$<)


clean: clean-aip
distclean: distclean-aip

clean-aip:
	$(RM) $(PACKAGE_DIR)/$(PACKAGE).exe *.aip

distclean-aip: clean-aip
	$(RM) -r $(PACKAGE_DIR) $(PACKAGE)-cache
