# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit check-reqs pax-utils toolchain-funcs

PYVER=$(ver_cut 1-2)
PATCHSET_PV=$(ver_cut 3-)
PYPY_PV=${PATCHSET_PV%_p*}

MY_P="pypy${PYVER}-v${PYPY_PV/_}"
PATCHSET="pypy${PYVER}-gentoo-patches-${PATCHSET_PV/_rc/rc}"

DESCRIPTION="PyPy3.11 executable (build from source)"
HOMEPAGE="
	https://pypy.org/
	https://github.com/pypy/pypy/
"
SRC_URI="
	https://downloads.python.org/pypy/${MY_P}-src.tar.bz2
	https://buildbot.pypy.org/pypy/${MY_P}-src.tar.bz2
	https://dev.gentoo.org/~mgorny/dist/python/${PATCHSET}.tar.xz
"
S="${WORKDIR}/${MY_P}-src"

LICENSE="MIT"
SLOT="${PV%_p*}"
KEYWORDS="~amd64 ~arm64 ~ppc64 x86 ~amd64-linux ~x86-linux"
IUSE="+jit low-memory ncurses cpu_flags_x86_sse2"

RDEPEND="
	app-arch/bzip2:0=
	dev-libs/expat:0=
	dev-libs/libffi:0=
	>=sys-libs/zlib-1.1.3:0=
	virtual/libintl:0=
	ncurses? ( sys-libs/ncurses:0= )
	!dev-lang/pypy3-exe-bin:${SLOT}
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	|| (
		dev-lang/pypy:2.7
		dev-python/pypy
	)
	virtual/pkgconfig
"

check_env() {
	if use low-memory; then
		CHECKREQS_MEMORY="1750M"
		use amd64 && CHECKREQS_MEMORY="3500M"
	else
		CHECKREQS_MEMORY="3G"
		use amd64 && CHECKREQS_MEMORY="6G"
	fi

	check-reqs_pkg_pretend
}

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && check_env
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && check_env
}

src_prepare() {
	local PATCHES=(
		"${WORKDIR}/${PATCHSET}"
	)
	default
}

src_configure() {
	tc-export CC

	local jit_backend
	if use jit; then
		jit_backend='--jit-backend='

		# We only need the explicit sse2 switch for x86.
		# On other arches we can rely on autodetection which uses
		# compiler macros. Plus, --jit-backend= doesn't accept all
		# the modern values...

		if use x86; then
			if use cpu_flags_x86_sse2; then
				jit_backend+=x86
			else
				jit_backend+=x86-without-sse2
			fi
		else
			jit_backend+=auto
		fi
	fi

	local args=(
		--no-shared
		$(usex jit -Ojit -O2)

		${jit_backend}

		pypy/goal/targetpypystandalone
		--withmod-bz2
		$(usex ncurses --with{,out}mod-_minimal_curses)
	)

	local interp=( pypy )
	if use low-memory; then
		local -x PYPY_GC_MAX_DELTA=200MB
		interp+=( --jit loop_longevity=300 )
	fi

	# translate into the C sources
	# we're going to build them ourselves since otherwise pypy does not
	# free up the unneeded memory before spawning the compiler
	set -- "${interp[@]}" rpython/bin/rpython --batch --source "${args[@]}"
	echo -e "\033[1m${@}\033[0m"
	"${@}" || die "translation failed"
}

src_compile() {
	emake -C "${T}"/usession*-0/testing_1
}

src_install() {
	cd "${T}"/usession*-0 || die
	newbin "testing_1/pypy${PYVER}-c" "pypy${PYVER}-c-${PYPY_PV}"
	insinto "/usr/include/pypy${PYVER}/${PYPY_PV}"
	doins *.h
	pax-mark m "${ED}/usr/bin/pypy${PYVER}-c-${PYPY_PV}"
}
