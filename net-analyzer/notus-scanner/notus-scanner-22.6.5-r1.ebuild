# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} pypy3_11 )
DISTUTILS_USE_PEP517=poetry
inherit distutils-r1 greadme systemd

DESCRIPTION="Notus is a vulnerability scanner for creating results from local security checks"
HOMEPAGE="https://github.com/greenbone/notus-scanner"
SRC_URI="https://github.com/greenbone/notus-scanner/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="AGPL-3 AGPL-3+"
SLOT="0"
KEYWORDS="amd64"

DEPEND="
	acct-user/gvm
	net-libs/paho-mqtt-c
	>=dev-python/psutil-6.1[${PYTHON_USEDEP}]
	>=dev-python/python-gnupg-0.5.3[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	>=dev-python/paho-mqtt-1.5.1[${PYTHON_USEDEP}]
"

RDEPEND="
	${DEPEND}
	app-misc/mosquitto
"

PATCHES=(
	"${FILESDIR}"/notus-scanner-22.6.2-remove-tests.patch
)

GREADME_DISABLE_AUTOFORMAT=1

distutils_enable_tests unittest

python_install() {
	distutils-r1_python_install

	insinto /etc/gvm
	newins "${FILESDIR}/${PN}.toml" "${PN}.toml"

	# Set proper permissions on required files/directories
	keepdir /var/lib/notus
	keepdir /var/lib/notus/products
	keepdir /var/lib/notus/advisories
	keepdir /var/log/gvm
	if ! use prefix; then
		fowners -R gvm:gvm /etc/gvm
		fowners -R gvm:gvm /var/lib/notus
		fowners -R gvm:gvm /var/log/gvm
	fi

	# Adding notus-scanner.log to logrotate
	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate" "${PN}"

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"

	systemd_dounit config/${PN}.service

	systemd_install_serviced "${FILESDIR}/notus-scanner.service.conf" \
			${PN}.service

	greadme_stdin <<-EOF
For validating the feed content, a GnuPG keychain with the Greenbone Community Feed
integrity key needs to be created. Please, read here on how to create it:
  - https://greenbone.github.io/docs/latest/22.4/source-build/index.html#feed-validation
  - https://wiki.gentoo.org/wiki/Greenbone_Vulnerability_Management#Notus_Scanner

To enable feed validation, edit /etc/gvm/${PN}.toml and set
  disable-hashsum-verification = false
EOF
}
