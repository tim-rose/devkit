# makefile to run nunit unit tests

.PHONY: $(recursive-targets:%=%-nunit)

# can be set by project specific .mk
NUNIT ?= $(NUNIT_BINDIR)nunit-console-$(ARCH).exe
# location for nunit reports; can be set by project specific or local makefile
# simply defaults to archdir
NUNIT.REPORT_DIR ?= $(archdir)
# local makefile must set NUNIT_SRC to the assemblies with the tests,
# these are expected to be in $(archdir)
NUNIT.REPORT ?= $(NUNIT_SRC:%.dll=_Report_%.xml)

test: test-nunit
test-nunit: $(NUNIT.REPORT_DIR)$(NUNIT.REPORT)

$(NUNIT.REPORT_DIR)_Report_%.xml: $(archdir)%.dll | $(NUNIT.REPORT_DIR)
	$(NUNIT) $< -xml $@

$(NUNIT.REPORT_DIR): ; $(MKDIR) $@
