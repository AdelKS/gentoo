# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib

DESCRIPTION="PEM file reader for Network Security Services (NSS)"
HOMEPAGE="https://github.com/kdudka/nss-pem"
SRC_URI="https://github.com/kdudka/${PN}/releases/download/${P}/${P}.tar.xz"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~m68k ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~x64-solaris"

DEPEND="dev-libs/nss
	dev-libs/nspr"
RDEPEND="${DEPEND}"
BDEPEND="dev-libs/nss
	virtual/pkgconfig"

S="${WORKDIR}/${P}/src"
