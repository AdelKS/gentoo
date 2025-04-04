# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit pypi

DESCRIPTION="Shared setuptools wheel for ensurepip Python module"
HOMEPAGE="https://pypi.org/project/setuptools/"
SRC_URI="$(pypi_wheel_url "${PN#ensurepip-}")"
S=${DISTDIR}

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"

src_install() {
	insinto /usr/lib/python/ensurepip
	doins "${A}"
}
