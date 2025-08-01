# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

inherit cmake desktop fortran-2 python-r1 toolchain-funcs xdg-utils

DESCRIPTION="Three-dimensional finite element mesh generator"
HOMEPAGE="https://gmsh.info https://gitlab.onelab.info/gmsh/gmsh"
SRC_URI="https://gmsh.info/src/${P}-source.tgz"
S="${WORKDIR}/${P}-source"

LICENSE="
	GPL-2+ free-noncomm
	alglib? ( MIT )
	gmm? ( LGPL-2.1+ )
	metis? ( Apache-2.0 )
	netgen? ( LGPL-2.1+ )
	voro? ( BSD )
"
SLOT="0"
KEYWORDS="~amd64 ~x86"
## cgns is not compiling ATM, maybe fix cgns lib first
IUSE="+alglib +blas cgns eigen examples +gmm gui jpeg med metis mpi mumps netgen opencascade petsc pdf png python shared slepc voro zlib"

REQUIRED_USE="
	^^ ( blas eigen )
	mumps? ( blas )
	slepc? ( petsc )
	python? ( shared ${PYTHON_REQUIRED_USE} )
"

RDEPEND="
	virtual/fortran
	gui? ( x11-libs/fltk:1=[xft(+)] )
	alglib? ( sci-libs/alglib )
	blas? (
		sci-libs/fftw:3.0
		virtual/blas
		virtual/lapack
	)
	cgns? (
		sci-libs/cgnslib
		sci-libs/hdf5:=[mpi=]
	)
	eigen? ( dev-cpp/eigen )
	gmm? ( sci-mathematics/gmm )
	jpeg? ( media-libs/libjpeg-turbo )
	med? (
		sci-libs/hdf5:=[mpi=]
		sci-libs/med[mpi=]
	)
	metis? ( >=sci-libs/metis-5.2.0 )
	mpi? ( virtual/mpi )
	mumps? ( sci-libs/mumps[mpi=] )
	opencascade? ( sci-libs/opencascade:* )
	pdf? ( app-text/poppler:= )
	png? ( media-libs/libpng:0 )
	petsc? ( sci-mathematics/petsc[mpi=] )
	python? ( ${PYTHON_DEPS} )
	slepc? ( sci-mathematics/slepc[mpi=] )
	voro? ( sci-libs/voro++ )
	zlib? ( sys-libs/zlib )
"

DEPEND="
	${RDEPEND}
	${PYTHON_DEPS}
	virtual/pkgconfig
	python? ( dev-lang/swig )
"

PATCHES=(
	"${FILESDIR}"/${PN}-4.9.5-opencascade.patch
	"${FILESDIR}"/${PN}-4.11.1-metis-5-2.patch
)

src_configure() {
	local mycmakeargs=( )

	use blas && \
		mycmakeargs+=( -DCMAKE_Fortran_COMPILER=$(tc-getF77) )

	mycmakeargs+=(
		-DENABLE_ALGLIB="$(usex alglib)"
		-DENABLE_BLAS_LAPACK="$(usex blas)"
		-DENABLE_BUILD_DYNAMIC="$(usex shared)"
		-DENABLE_CGNS="$(usex cgns)"
		-DENABLE_EIGEN="$(usex eigen)"
		-DENABLE_FLTK="$(usex gui)"
		-DENABLE_GMM="$(usex gmm)"
		-DENABLE_GRAPHICS="$(usex gui)"
		-DENABLE_MED="$(usex med)"
		-DENABLE_MPI="$(usex mpi)"
		-DENABLE_METIS="$(usex metis)"
		-DENABLE_MUMPS="$(usex mumps)"
		-DENABLE_NETGEN="$(usex netgen)"
		-DENABLE_OCC="$(usex opencascade)"
		-DENABLE_PETSC="$(usex petsc)"
		-DENABLE_POPPLER="$(usex pdf)"
		-DENABLE_SLEPC="$(usex slepc)"
		-DENABLE_PRIVATE_API="$(usex shared)"
		-DENABLE_SYSTEM_CONTRIB="YES"
		-DENABLE_VOROPP="$(usex voro)"
		-DENABLE_WRAP_PYTHON="$(usex python)"
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use examples ; then
		dodoc -r examples tutorials
		docompress -x /usr/share/doc/${PF}/{examples,tutorials}
	fi

	if use python; then
		python_foreach_impl python_domodule api/gmsh.py
	fi

	if use gui ; then
		newicon -s 64 "/${S}/utils/icons/gmsh-no-text.png" gmsh.png
		make_desktop_entry "/usr/bin/gmsh" "Gmsh ${PV}" "gmsh" "Science;Math"
	fi
}

pkg_postinst() {
	if use gui ; then
		xdg_icon_cache_update
	fi
}

pkg_postrm() {
	if use gui ; then
		xdg_icon_cache_update
	fi
}
