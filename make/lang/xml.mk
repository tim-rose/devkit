#
# XML.MK --Rules for installing xml data.
#
# Contents:
# %.xml:       --Rules for installing xml files in other places.
# install-xml: --Install XML files to datadir.
# src:         --Update the XML_SRC macro.
# todo:        --Report unfinished work in XML files.
#

.PHONY: $(recursive-targets:%=%-xml)

ifdef autosrc
    LOCAL_XML_SRC := $(wildcard *.xml)

    XML_SRC ?= $(LOCAL_XML_SRC)
endif

#
# %.xml: --Rules for installing xml files in other places.
#
$(sysconfdir)/%.xml:	%.xml;	$(INSTALL_DATA) $? $@
$(libdir)/%.xml:	%.xml;	$(INSTALL_DATA) $? $@
$(archdir)/%.xml:	%.xml;	$(INSTALL_DATA) $? $@

#
# install-xml: --Install XML files to datadir.
#
install-xml: $(XML_SRC:%=$(datadir)/%)

#
# src: --Update the XML_SRC macro.
#
src:	src-xml
src-xml:
	$(ECHO_TARGET)
	$(Q)mk-filelist -f $(MAKEFILE) -qn XML_SRC *.xml

#
# todo: --Report unfinished work in XML files.
#
todo:	xml-todo
xml-todo:
	$(ECHO_TARGET)
	@$(GREP) $(TODO_PATTERN) $(XML_SRC)  /dev/null ||:
