# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=( luajit )

inherit autotools lua-single

DESCRIPTION="A scriptable multi-threaded benchmark tool based on LuaJIT"
HOMEPAGE="https://github.com/akopytov/sysbench"
SRC_URI="https://github.com/akopytov/sysbench/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 x86"
IUSE="+aio attachsql drizzle +largefile mysql postgres test"
REQUIRED_USE="${LUA_REQUIRED_USE}"
RESTRICT="!test? ( test )"

RDEPEND="
	aio? ( dev-libs/libaio )
	mysql? ( dev-db/mysql-connector-c:= )
	postgres? ( dev-db/postgresql:= )
	${LUA_DEPS}
"
DEPEND="${RDEPEND}
	dev-libs/concurrencykit
	dev-libs/libxslt
"
BDEPEND="
	dev-build/libtool
	virtual/pkgconfig
	test? ( dev-util/cram )
"

pkg_setup() {
	lua-single_pkg_setup
}

src_prepare() {
	default

	rm -r third_party/{concurrency_kit/ck,cram,luajit/luajit} || die

	# Use system cram for running tests.
	sed -i tests/test_run.sh -e 's@$PYTHON $(command -v cram)@cram@' || die

	sed -i configure.ac -e 's@$(which git)@$(command -v git)@' || die

	eautoreconf
}

src_configure() {
	# Current versions of 'dev-db/oracle-instantclient' aren't supported.
	# See: https://github.com/akopytov/sysbench/issues/390.
	local myeconfargs=(
		--disable-rpath
		$(use_enable aio)
		$(use_enable largefile)
		$(use_with attachsql)
		$(use_with drizzle)
		$(use_with mysql)
		$(use_with postgres pgsql)
		--with-system-ck
		--with-system-luajit
		--without-oracle
		LUAJIT_CFLAGS="$(lua_get_CFLAGS)"
		LUAJIT_LIBS="$(lua_get_LIBS)"
	)

	econf "${myeconfargs[@]}"
}

src_test() {
	emake check test
}
