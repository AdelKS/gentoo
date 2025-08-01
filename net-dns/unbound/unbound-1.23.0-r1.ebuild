# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/unbound.net.asc
inherit autotools flag-o-matic python-single-r1 systemd verify-sig multilib-minimal

MY_P=${PN}-${PV/_/}
DESCRIPTION="A validating, recursive and caching DNS resolver"
HOMEPAGE="https://unbound.net/ https://nlnetlabs.nl/projects/unbound/about/"
SRC_URI="
	https://nlnetlabs.nl/downloads/unbound/${MY_P}.tar.gz
	verify-sig? ( https://nlnetlabs.nl/downloads/unbound/${MY_P}.tar.gz.asc )
"
S="${WORKDIR}"/${MY_P}

LICENSE="BSD GPL-2"
SLOT="0/8" # ABI version of libunbound.so
if [[ ${PV} != *_rc* ]] ; then
	KEYWORDS="~alpha amd64 arm arm64 ~hppa ~mips ppc ppc64 ~riscv ~sparc x86"
fi
IUSE="debug dnscrypt dnstap +ecdsa ecs gost +http2 python redis selinux static-libs systemd test +tfo threads"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
RESTRICT="!test? ( test )"

# Note: expat is needed by executable only but the Makefile is custom
# and doesn't make it possible to easily install the library without
# the executables. MULTILIB_USEDEP may be dropped once build system
# is fixed.
DEPEND="
	acct-group/unbound
	acct-user/unbound
	>=dev-libs/expat-2.1.0-r3[${MULTILIB_USEDEP}]
	>=dev-libs/libevent-2.0.21:0=[${MULTILIB_USEDEP}]
	>=dev-libs/openssl-1.0.1h-r2:0=[${MULTILIB_USEDEP}]
	dnscrypt? ( dev-libs/libsodium:=[${MULTILIB_USEDEP}] )
	dnstap? (
		dev-libs/fstrm[${MULTILIB_USEDEP}]
		>=dev-libs/protobuf-c-1.0.2-r1:=[${MULTILIB_USEDEP}]
	)
	ecdsa? (
		dev-libs/openssl:0[-bindist(-)]
	)
	http2? ( net-libs/nghttp2:=[${MULTILIB_USEDEP}] )
	python? ( ${PYTHON_DEPS} )
	redis? ( dev-libs/hiredis:= )
	systemd? ( sys-apps/systemd )
"
BDEPEND="
	virtual/pkgconfig
	python? ( dev-lang/swig )
	test? (
		net-libs/ldns[examples(-)]
		dev-util/splint
		app-text/wdiff
	)
	verify-sig? ( >=sec-keys/openpgp-keys-unbound-20250515 )
"
RDEPEND="
	${DEPEND}
	net-dns/dnssec-root
	selinux? ( sec-policy/selinux-bind )
"

QA_CONFIG_IMPL_DECL_SKIP=(
	ioctlsocket # not on Linux (bug #900060)
)

PATCHES=(
	"${FILESDIR}"/${PN}-1.5.7-trust-anchor-file.patch
	"${FILESDIR}"/${PN}-1.6.3-pkg-config.patch
	"${FILESDIR}"/${PN}-1.10.1-find-ar.patch
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	default

	eautoreconf

	# Required for the python part
	multilib_copy_sources
}

src_configure() {
	[[ ${CHOST} == *-darwin* ]] || append-ldflags -Wl,-z,noexecstack
	multilib-minimal_src_configure
}

multilib_src_configure() {
	local myeconfargs=(
		$(multilib_native_use_enable debug)
		$(multilib_native_use_enable gost)
		$(multilib_native_use_enable dnscrypt)
		$(multilib_native_use_enable dnstap)
		$(multilib_native_use_enable ecdsa)
		$(multilib_native_use_enable ecs subnet)
		$(multilib_native_use_enable redis cachedb)
		$(multilib_native_use_enable static-libs static)
		$(multilib_native_use_enable systemd)
		$(multilib_native_use_with python pythonmodule)
		$(multilib_native_use_with python pyunbound)
		$(multilib_native_use_with threads pthreads)
		$(multilib_native_use_with http2 libnghttp2)
		$(multilib_native_use_enable tfo tfo-client)
		$(multilib_native_use_enable tfo tfo-server)

		--disable-flto
		--disable-rpath
		--enable-event-api
		--enable-ipsecmod

		--with-libevent="${ESYSROOT}"/usr
		$(multilib_native_usex redis --with-libhiredis="${ESYSROOT}/usr" --without-libhiredis)

		--with-pidfile="${EPREFIX}"/run/unbound.pid
		--with-rootkey-file="${EPREFIX}"/etc/dnssec/root-anchors.txt
		--with-ssl="${ESYSROOT}"/usr
		--with-libexpat="${ESYSROOT}"/usr

		# http://unbound.nlnetlabs.nl/pipermail/unbound-users/2011-April/001801.html
		# $(use_enable debug lock-checks)
		# $(use_enable debug alloc-checks)
		# $(use_enable debug alloc-lite)
		# $(use_enable debug alloc-nonregional)
	)

	econf "${myeconfargs[@]}"
}

multilib_src_install() {
	emake DESTDIR="${D}" install
	systemd_dounit contrib/unbound.service
	systemd_dounit contrib/unbound.socket
	systemd_dounit contrib/unbound_portable.service
}

multilib_src_install_all() {
	use python && python_optimize

	newinitd "${FILESDIR}"/unbound-r1.initd unbound
	newconfd "${FILESDIR}"/unbound-r1.confd unbound

	systemd_newunit "${FILESDIR}"/unbound-anchor-r1.service unbound-anchor.service

	dodoc doc/{README,CREDITS,TODO,Changelog,FEATURES}
	dodoc contrib/{unbound_munin_,metrics.awk}

	docinto selinux
	dodoc contrib/selinux/*

	exeinto /usr/share/${PN}
	doexe contrib/{update-anchor.sh,unbound_cache.sh}

	# Create space for auto-trust-anchor-file eventually
	# downloaded by unbound-anchor
	keepdir /etc/unbound/var
	fowners root:unbound /etc/unbound/var
	fperms 0770 /etc/unbound/var

	# Used to store cache data
	keepdir /var/lib/${PN}
	fowners root:unbound /var/lib/${PN}
	fperms 0770 /var/lib/${PN}

	find "${ED}" -name '*.la' -delete || die
	if ! use static-libs ; then
		find "${ED}" -name "*.a" -delete || die
	fi
}

pkg_postinst() {
	if [[ ! -f "${EROOT}/etc/unbound/unbound_control.key" ]]; then
		einfo "Trying to create unbound control key ..."
		if ! unbound-control-setup &>/dev/null ; then
			ewarn "Failed to create unbound control key!"
		fi
	fi

	if [[ ! -f "${EROOT}/etc/unbound/var/root-anchors.txt" ]]; then
		einfo ""
		einfo "If you want unbound to automatically update the root-anchor file for DNSSEC validation"
		einfo "set 'auto-trust-anchor-file: ${EROOT}/etc/unbound/var/root-anchors.txt' in ${EROOT}/etc/unbound/unbound.conf"
		einfo "and run"
		einfo ""
		einfo "  su -s /bin/sh -c '${EROOT}/usr/sbin/unbound-anchor -a ${EROOT}/etc/unbound/var/root-anchors.txt' unbound"
		einfo ""
		einfo "as root to create it initially before starting unbound for the first time after enabling this."
		einfo ""
		einfo "If using systemd you may also enable the unbound-anchor.service"
	fi

	# Our user is not available on prefix
	use prefix && return

	local _perm_check_testfile=$(mktemp --dry-run "${EPREFIX}"/etc/unbound/var/.pkg_postinst-perm-check.XXXXXXXXX)
	su -s /bin/sh -c "touch ${_perm_check_testfile}" unbound &>/dev/null
	if [[ $? -ne 0 ]]; then
		ewarn "WARNING: unbound user cannot write to \"${EPREFIX}/etc/unbound/var\"!"
		ewarn "Run the following commands to restore default permission:"
		ewarn ""
		ewarn "    chown root:unbound ${EPREFIX}/etc/unbound/var"
		ewarn "    chmod 0770 ${EPREFIX}/etc/unbound/var"
	else
		# Cleanup -- no reason to die here!
		rm -f "${_perm_check_testfile}"
	fi
}
