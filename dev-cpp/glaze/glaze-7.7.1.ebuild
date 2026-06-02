# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

GLAZE_UT_VERSION="1.1.0"

DESCRIPTION="Extremely fast, in memory, JSON and interface library for modern C++"
HOMEPAGE="https://github.com/stephenberry/glaze"
SRC_URI="
	https://github.com/stephenberry/glaze/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	test? (
		https://github.com/openalgz/ut/archive/refs/tags/v${GLAZE_UT_VERSION}.tar.gz -> glaze-ut-v${GLAZE_UT_VERSION}.tar.gz
	)
"

S="${WORKDIR}/glaze-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="examples fuzzing test"
RESTRICT="!test? ( test )"

DEPEND="
	test? (
		dev-cpp/asio
		>=dev-cpp/eigen-3.4:=
	)
"
RDEPEND="${DEPEND}"

# Unbundle test dependencies otherwise they are fetched from github at build time
PATCHES=(
	"${FILESDIR}/${P}-unbundle-test-deps.patch"
)

src_unpack() {
	default

	if use 'test'; then
		# move the glaze-ut single header file library into the tests folder for glaze
		mkdir "${S}"/tests/ut || die
		cp "${WORKDIR}"/ut-${GLAZE_UT_VERSION}/include/ut/ut.hpp "${S}"/tests/ut/ || die
	fi
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_INSTALL_RULES=OFF
		-Dglaze_DEVELOPER_MODE=ON
		-Dglaze_ENABLE_FUZZING=$(usex fuzzing)
		-Dglaze_BUILD_EXAMPLES=$(usex examples)
		-DBUILD_TESTING=$(usex test)
	)
	if use 'test'; then
		mycmakeargs+=(-Dglaze_USE_BUNDLED_ASIO=OFF)
	fi

	cmake_src_configure
}
