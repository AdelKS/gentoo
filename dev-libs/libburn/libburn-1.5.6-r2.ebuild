# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="Open-source library for reading, mastering and writing optical discs"
HOMEPAGE="https://dev.lovelyhq.com/libburnia/web/wiki/Libburn https://dev.lovelyhq.com/libburnia/libburn"
SRC_URI="https://files.libburnia-project.org/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~loong ~mips ppc ppc64 ~riscv ~s390 sparc x86"
IUSE="debug static-libs"

BDEPEND="
	virtual/pkgconfig
"
DEPEND="
	${RDEPEND}
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.5.6-c23.patch
	"${FILESDIR}"/${PN}-1.5.6_slibtool.patch
)

src_prepare() {
	default

	# Ancient libtool version in 1.5.6 at least (debian's 2.4.2-1.11)
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable static-libs static) \
		--disable-ldconfig-at-install \
		$(use_enable debug)
}

src_install() {
	default

	dodoc CONTRIBUTORS doc/{comments,*.txt}

	docinto cdrskin
	dodoc cdrskin/{*.txt,README}
	docinto cdrskin/html
	dodoc cdrskin/cdrskin_eng.html

	find "${D}" -name '*.la' -delete || die
}
