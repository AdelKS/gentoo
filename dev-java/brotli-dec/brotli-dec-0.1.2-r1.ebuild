# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

JAVA_PKG_IUSE="doc source"
MAVEN_ID="org.brotli:dec:${PV}"

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="Brotli decompressor"
HOMEPAGE="https://brotli.org/ https://github.com/google/brotli"
SRC_URI="https://repo1.maven.org/maven2/org/brotli/dec/${PV}/dec-${PV}-sources.jar -> ${P}-sources.jar"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64 ppc64"

BDEPEND="app-arch/unzip"
DEPEND=">=virtual/jdk-1.8:*"
RDEPEND=">=virtual/jre-1.8:*"
