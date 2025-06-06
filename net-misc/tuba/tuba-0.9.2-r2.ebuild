# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome2-utils meson optfeature vala

MY_P=${P^}
DESCRIPTION="Browse the Fediverse (GTK client)"
HOMEPAGE="
	https://tuba.geopjr.dev/
	https://github.com/GeopJr/Tuba/
"
SRC_URI="
	https://github.com/GeopJr/Tuba/archive/v${PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S=${WORKDIR}/${MY_P}

LICENSE="GPL-3 CC-BY-SA-4.0"
SLOT="0"
KEYWORDS="amd64"
IUSE="gstreamer spell"

# note: some dependencies are optional but if they are found without [vala],
# they end up breaking the build
DEPEND="
	app-crypt/libsecret[introspection,vala]
	>=dev-libs/glib-2.76.0:2
	dev-libs/icu:=
	>=dev-libs/json-glib-1.4.4[introspection]
	>=dev-libs/libgee-0.8.5:0.8[introspection]
	dev-libs/libxml2:=
	>=gui-libs/gtk-4.13.4:4[introspection]
	>=gui-libs/libadwaita-1.6:1[introspection,vala]
	>=gui-libs/gtksourceview-5.6.0:5[introspection,vala]
	net-libs/libsoup:3.0[introspection,vala]
	gstreamer? (
		>=gui-libs/gtk-4.13.4:4[gstreamer,introspection]
		media-libs/gstreamer[introspection]
	)
	spell? (
	app-text/libspelling[vala]
	)
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	$(vala_depend)
	sys-devel/gettext
	virtual/pkgconfig
"

PATCHES=(
	# https://github.com/GeopJr/Tuba/pull/1423
	"${FILESDIR}/${P}-meson-feature.patch"
)

src_configure() {
	local emesonargs=(
		# disable calling updaters (see pkg_post*)
		-Ddistro=true
		$(meson_feature spell spelling)
		# not packaged
		-Dclapper=disabled
		$(meson_feature gstreamer)
	)

	vala_setup
	meson_src_configure
}

src_install() {
	meson_src_install
	dosym dev.geopjr.Tuba /usr/bin/tuba
}

pkg_postinst() {
	optfeature "WebP image support" gui-libs/gdk-pixbuf-loader-webp

	gnome2_schemas_update
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	gnome2_schemas_update
	xdg_desktop_database_update
	xdg_icon_cache_update
}
