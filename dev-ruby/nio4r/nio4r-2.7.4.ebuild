# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby31 ruby32 ruby33 ruby34"

RUBY_FAKEGEM_RECIPE_TEST="rspec3"

RUBY_FAKEGEM_RECIPE_DOC=""
RUBY_FAKEGEM_EXTRADOC="changes.md readme.md"

RUBY_FAKEGEM_EXTENSIONS=(ext/nio4r/extconf.rb)
RUBY_FAKEGEM_GEMSPEC="nio4r.gemspec"

inherit flag-o-matic ruby-fakegem

DESCRIPTION="A high performance selector API for monitoring IO objects"
HOMEPAGE="https://github.com/socketry/nio4r"
SRC_URI="https://github.com/socketry/nio4r/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT || ( BSD GPL-2 )"
SLOT="$(ver_cut 1)"
KEYWORDS="amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~riscv ~sparc x86 ~ppc-macos ~x64-macos ~x64-solaris"

# Note that nio4r bundles a patched copy of libev, and without these
# patches the tests fail: https://github.com/celluloid/nio4r/issues/15

all_ruby_prepare() {
	# See bug #855869 and its large number of dupes in bundled libev copies.
	filter-lto
	append-flags -fno-strict-aliasing

	sed -i -e '/[Bb]undler/d' spec/spec_helper.rb || die
	sed -e '/extension/ s:^:#:' -i Rakefile || die

	sed -e 's:_relative ": "./:' -i ${RUBY_FAKEGEM_GEMSPEC} || die
}
