# Zip a number of files in a zip archive


ZIP ?= zip

package: $(PACKAGE_DIR)/$(PACKAGE).zip



# building a zip file, the local makefile needs to give all files to be packaged
# as prerequisites.
%.zip: $(ZIP_SRC) | $(PACKAGE_DIR)
	$(ZIP) -r $@ $^

$(PACKAGE_DIR):		;	$(MKDIR) $@


clean: clean-zip
distclean: distclean-zip

clean-zip:
	$(RM) $(PACKAGE_DIR)/$(PACKAGE).zip

distclean-zip:
	$(RM) -r $(PACKAGE_DIR)
