# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
PYTHON_REQ_USE="xml(+)"
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1

DESCRIPTION="Command line client for Amazon S3"
HOMEPAGE="https://s3tools.org/s3cmd"
SRC_URI="https://downloads.sourceforge.net/s3tools/${P/_/-}.tar.gz"
S="${WORKDIR}/${P/_/-}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~loong x86 ~amd64-linux ~x64-macos"

RDEPEND="
	|| (
		dev-python/python-magic[${PYTHON_USEDEP}]
		sys-apps/file[python,${PYTHON_USEDEP}]
	)
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	"

src_install() {
	distutils-r1_src_install
	rm -r "${ED}/usr/share/doc/packages" || die
}
