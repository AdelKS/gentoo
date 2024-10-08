# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic toolchain-funcs

DESCRIPTION="New GNU Portable Threads Library"
HOMEPAGE="https://git.gnupg.org/cgi-bin/gitweb.cgi?p=npth.git"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="hppa"
IUSE="test"
RESTRICT="!test? ( test )"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	# ideally we want !tc-ld-is-bfd for best future-proofing, but it needs
	# https://github.com/gentoo/gentoo/pull/28355
	# mold needs this too but right now tc-ld-is-mold is also not available
	if tc-ld-is-lld; then
		append-ldflags -Wl,--undefined-version
	fi

	econf \
		--disable-static \
		$(use_enable test tests)
}

src_install() {
	default

	# no static archives
	find "${ED}" -name '*.la' -delete || die
}
