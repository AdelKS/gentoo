# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..13} )

inherit distutils-r1

DESCRIPTION="Python S-expression emulation using tuple-like objects"
HOMEPAGE="
	https://pypi.org/project/etuples/
	https://github.com/pythological/etuples/
"
# tests not in sdist, as of 0.3.9
SRC_URI="
	https://github.com/pythological/etuples/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~loong ~riscv x86"

RDEPEND="
	dev-python/cons[${PYTHON_USEDEP}]
	dev-python/multipledispatch[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}
