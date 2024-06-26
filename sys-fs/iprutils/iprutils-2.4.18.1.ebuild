# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools bash-completion-r1

DESCRIPTION="IBM's tools for support of the ipr SCSI controller"
SRC_URI="https://downloads.sourceforge.net/iprdd/${P}.tar.gz"
HOMEPAGE="https://sourceforge.net/projects/iprdd/"

SLOT="0"
LICENSE="IBM"
KEYWORDS="ppc ppc64"
IUSE=""

IPRUTILS_DEPEND="
	>=sys-libs/ncurses-5.4-r5:=
	>=sys-apps/pciutils-2.1.11-r1
"
RDEPEND="
	${IPRUTILS_DEPEND}
	virtual/logger
	virtual/udev
"
DEPEND="
	${IPRUTILS_DEPEND}
	virtual/pkgconfig
"
PATCHES=(
	"${FILESDIR}"/${PN}-2.4.8-tinfo.patch
	"${FILESDIR}"/${PN}-2.4.11.1-basename.patch
)

src_prepare() {
	default

	eautoreconf
}

src_install() {
	emake \
		DESTDIR="${D}" \
		bashcompdir=$(get_bashcompdir) \
		install

	mv "${D}"/$(get_bashcompdir)/iprconfig{-bash-completion.sh,} || die

	newinitd "${FILESDIR}"/iprinit-r1 iprinit
	newinitd "${FILESDIR}"/iprupdate-r1 iprupdate
	newinitd "${FILESDIR}"/iprdump-r1 iprdump
}
