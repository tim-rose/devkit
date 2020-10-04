#
# std-directories.mk --Definitions of the common/standard directories.
#
# Remarks:
# These directories are set according to a blend of the following variables:
#
#  * DESTDIR	-- an alternative root (e.g. chroot jail, pkg-building root)
#  * prefix	-- the application's idea of its root installation directory
#  * opt	-- FSHS "opt" component (undefined if not FSHS)
#  * usr	-- bindir modifier: either undefined or "usr"
#  * archdir	-- system+architecture-specific bindir modifier (unused)
#
# In typical usage, DESTDIR should be undefined (it's explicitly set
# as needed by some of the packaging targets), and prefix should be
# set to either "/usr/local" or $HOME (or a subdirectory).  Note that
# GNU make will search for include files in /usr/local/include, so
# installing makeshift itself into /usr/local is a win.  However if you
# install makeshift into (e.g., $HOME), you must use/alias make as
# "make -I$HOME/include".
#
system_root	= $(DESTDIR)

#
# Remarks:
# system_confdir is a bit of a hack, for folks that want to install
# into "/etc" as well as the adjusted $sysconfdir.
#
system_confdir	= $(abspath $(system_root)/etc/$(subdir))
export pkgver	= $(PACKAGE)$(VERSION:%=-%)

archdir         ?= $(VARIANT:%=%-)$(OS:%=%-)$(ARCH)
export archdir
gendir	?= $(archdir)/gen
export gendir

rootdir	 	= $(abspath $(DESTDIR)/$(prefix))
optdir	 	= $(opt:%=opt/%)
rootdir_opt 	= $(abspath $(DESTDIR)/$(prefix)/$(optdir))
#exec_prefix = $(abspath $(rootdir)/$(archdir)	# (GNU std))
exec_prefix	= $(abspath $(rootdir_opt)/$(usr))

bindir		= $(abspath $(exec_prefix)/bin)
sbindir 	= $(abspath $(exec_prefix)/sbin)
#libexecdir	= $(abspath $(exec_prefix)/libexec/$(PACKAGE)/$(archdir)/$(subdir)	# (GNU std))
libexecdir	= $(abspath $(exec_prefix)/libexec/$(subdir))
datarootdir     = $(abspath $(exec_prefix)/share/$(subdir))
#datadir	= $(abspath $(exec_prefix)/share/$(PACKAGE)/$(subdir)	# (GNU std))
datadir		= $(abspath $(datarootdir))

sysconfdir	= $(abspath $(rootdir)/etc/$(optdir)/$(subdir))

divertdir	= $(abspath $(rootdir)/var/lib/divert/$(subdir))
sharedstatedir	= $(abspath $(rootdir_opt)/com/$(subdir))
localstatedir	= $(abspath $(rootdir)/var/$(optdir)/$(subdir))
srvdir 		= $(abspath $(rootdir)/srv/$(subdir))
wwwdir 		= $(abspath $(rootdir)/srv/www/$(subdir))
localedir 	= $(abspath $(exec_prefix)/share/locale)

includedir	= $(abspath $(rootdir_opt)/$(usr)/include/$(subdir))
librootdir	= $(abspath $(exec_prefix)/lib)
libdir		= $(abspath $(librootdir)/$(subdir))
lispdir		= $(abspath $(rootdir_opt)/share/emacs/site-lisp)

infodir		= $(abspath $(rootdir_opt)/info)
docdir		= $(abspath $(exec_prefix)/share/doc/$(PACKAGE)/$(subdir))
htmldir		= $(abspath $(docdir))
dvidir		= $(abspath $(docdir))
psdir		= $(abspath $(docdir))
pdfdir		= $(abspath $(docdir))

mandir		= $(abspath $(datadir)/man)
man1dir		= $(abspath $(mandir)/man1)
man2dir		= $(abspath $(mandir)/man2)
man3dir		= $(abspath $(mandir)/man3)
man4dir		= $(abspath $(mandir)/man4)
man5dir		= $(abspath $(mandir)/man5)
man6dir		= $(abspath $(mandir)/man6)
man7dir		= $(abspath $(mandir)/man7)
man8dir		= $(abspath $(mandir)/man8)
