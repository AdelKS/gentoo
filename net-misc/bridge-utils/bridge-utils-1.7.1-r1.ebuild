# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools linux-info toolchain-funcs

DESCRIPTION="Tools for configuring the Linux kernel 802.1d Ethernet Bridge"
HOMEPAGE="https://bridge.sourceforge.net/"
SRC_URI="https://www.kernel.org/pub/linux/utils/net/${PN}/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~hppa ~mips ppc ppc64 ~riscv sparc x86"
IUSE="selinux"

DEPEND="virtual/os-headers"
RDEPEND="selinux? ( sec-policy/selinux-brctl )"

CONFIG_CHECK="~BRIDGE"
WARNING_BRIDGE="CONFIG_BRIDGE is required to get bridge devices in the kernel"

get_headers() {
	CTARGET=${CTARGET:-${CHOST}}
	dir=/usr/include
	tc-is-cross-compiler && dir=/usr/${CTARGET}/usr/include
	echo "${dir}"
}

src_prepare() {
	local PATCHES=(
		"${FILESDIR}"/libbridge-substitute-AR-variable-from-configure.patch
		"${FILESDIR}"/${P}-musl.patch  #828902
	)
	default
	eautoreconf
}

src_configure() {
	# use santitized headers and not headers from /usr/src
	local myeconfargs=(
		--prefix=/
		--libdir=/usr/$(get_libdir)
		--includedir=/usr/include
		--with-linux-headers="$(get_headers)"
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	emake install DESTDIR="${D}"
	dodoc AUTHORS ChangeLog README THANKS \
		doc/{FAQ,FIREWALL,HOWTO,PROJECTS,RPM-GPG-KEY,SMPNOTES,WISHLIST}

	[ -f "${ED}"/sbin/brctl ] || die "upstream makefile failed to install binary"
}
