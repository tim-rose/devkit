#
# PYTEST.MK --Rules for running tests with Python's "pytest" framework.
#
# Contents:
# test:           --Run all tests, and save the results to pytest.xml.
# test-pytest[%]: --Run an individual test.
# clean-pytest:   --Cleanup files generated by running tests.
#
# Remarks:
# To add a test to the suite run by *pytest*, add it as a dependant
# of the `test-pytest` target.

PYTEST ?= py.test
ALL_PYTEST_FLAGS = $(TARGET.PYTEST_FLAGS) $(LOCAL.PYTEST_FLAGS) \
    $(PROJECT.PYTEST_FLAGS) $(ARCH.PYTEST_FLAGS) $(OS.PYTEST_FLAGS) \
    $(PYTEST_FLAGS)
#
# test: --Run all tests, and save the results to pytest.xml.
#
test:	test-pytest

test-pytest: | cmd-exists[$(PYTEST)]
	$(PYTEST) $(ALL_PYTEST_FLAGS) $^

#
# test-pytest[%]: --Run an individual test.
#
test[%.py]:
	$(PYTEST) $(ALL_PYTEST_FLAGS) $*.py

clean:		clean-pytest
distclean:	clean-pytest
#
# clean-pytest: --Cleanup files generated by running tests.
#
.PHONY:		clean-pytest
clean-pytest:
	$(RM) pytest-tests.xml
