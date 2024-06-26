# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

MY_PN="nagios-plugins-linux"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Additional and alternative Nagios plugins for Linux"
HOMEPAGE="https://github.com/madrisan/nagios-plugins-linux"
SRC_URI="https://github.com/madrisan/${MY_PN}/releases/download/v${PV}/${MY_P}.tar.xz -> ${P}.tar.xz"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="curl systemd"

DEPEND="
	curl? ( net-misc/curl:0= )
	systemd? ( sys-apps/systemd:= )
"
RDEPEND="${DEPEND}"

src_prepare() {
	default
	# Avoid collision with net-analyzer/monitoring-plugins
	# and net-analyzer/nagios-plugins
	sed -ri "s/check_(load|swap|uptime|users)/&_madrisan/" plugins/Makefile.am || die
	eautoreconf
}

src_configure() {
	local myconf=(
		--libexecdir="${EPREFIX}/usr/$(get_libdir)/nagios/plugins"
		# Most options are already defaults for Gentoo
		--disable-hardening
		$(use_enable curl libcurl)
		$(use_enable systemd)
	)
	econf "${myconf[@]}"
}

src_test() {
	emake check VERBOSE=1
}
