# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN=${PN/-bin/}
MY_P=${MY_PN}-${PV/_/-}
MY_PV=$(ver_cut 1-2)
BASE_SRC_URI="https://julialang-s3.julialang.org/bin"

inherit edo

DESCRIPTION="High-performance programming language for technical computing"
HOMEPAGE="https://julialang.org/"
SRC_URI="
	x86? ( ${BASE_SRC_URI}/linux/x86/${MY_PV}/${MY_P}-linux-i686.tar.gz )
	amd64? (
		elibc_glibc? ( ${BASE_SRC_URI}/linux/x64/${MY_PV}/${MY_P}-linux-x86_64.tar.gz )
		elibc_musl? ( ${BASE_SRC_URI}/musl/x64/${MY_PV}/${MY_P}-musl-x86_64.tar.gz )
	)
	arm64? ( ${BASE_SRC_URI}/linux/aarch64/${MY_PV}/${MY_P}-linux-aarch64.tar.gz )
"
S="${WORKDIR}/${MY_P}"

LICENSE="MIT"
SLOT="${MY_PV}"
KEYWORDS="-* ~amd64 ~arm64 ~x86"

RESTRICT="strip"

RDEPEND="app-arch/p7zip"
BDEPEND="dev-util/patchelf"

QA_PREBUILT="*"
QA_SONAME="*"

# the following libs require libblastrampoline.so, which is however generated
# at runtime...
QA_DT_NEEDED="*"

src_prepare() {
	default

	# Workaround for bug #956047. This can be dropped with >=1.10.9.
	edo patchelf --clear-execstack lib/julia/libopenlibm.so*
}

src_test() {
	# Smoke test to catch issues like bug #956047
	edo bin/julia --version
}

src_install() {
	insinto "/usr/$(get_libdir)/${MY_P}/"
	doins -r ./etc
	doins -r ./include
	doins -r ./lib
	doins -r ./share

	exeinto "/usr/$(get_libdir)/${MY_P}/bin"
	doexe "bin/${MY_PN}"
	dosym "../$(get_libdir)/${MY_P}/bin/${MY_PN}" "/usr/bin/${MY_PN}${SLOT}"

	local revord=$(( 9999 - $(ver_cut 1) * 100 - $(ver_cut 2) )) # 1.6 -> 106
	newenvd - 99${MY_PN}${revord} <<-EOF
		PATH="${EPREFIX}/usr/$(get_libdir)/${MY_P}/bin"
	EOF

	elog "QA warnings about unresolved SONAME dependencies can be safely ignored."
}
