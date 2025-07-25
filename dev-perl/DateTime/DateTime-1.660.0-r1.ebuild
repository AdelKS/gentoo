# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=DROLSKY
DIST_VERSION=1.66
inherit perl-module

DESCRIPTION="Date and time object"

LICENSE="Artistic-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos"

CONFLICTS="
	!<=dev-perl/DateTime-Format-Mail-0.402.0
"
RDEPEND="
	${CONFLICTS}
	>=dev-perl/DateTime-Locale-1.60.0
	>=dev-perl/DateTime-TimeZone-2.440.0
	>=dev-perl/Dist-CheckConflicts-0.20.0
	>=dev-perl/Params-ValidationCompiler-0.260.0
	>=dev-perl/Specio-0.500.0
	dev-perl/Try-Tiny
	>=dev-perl/namespace-autoclean-0.190.0
"
BDEPEND="
	${RDEPEND}
	>=dev-perl/Dist-CheckConflicts-0.20.0
	test? (
		>=dev-perl/CPAN-Meta-Check-0.11.0
		dev-perl/Test-Fatal
		>=virtual/perl-Test-Simple-0.960.0
		>=dev-perl/Test-Warnings-0.5.0
		dev-perl/Test-Without-Module
	)
"
