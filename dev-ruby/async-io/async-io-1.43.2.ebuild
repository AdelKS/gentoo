# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby32 ruby33"

RUBY_FAKEGEM_RECIPE_TEST="rspec3"
RUBY_FAKEGEM_EXTRA_DOC="readme.md"
RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"

inherit ruby-fakegem

DESCRIPTION="Provides support for asynchronous TCP, UDP, UNIX and SSL sockets"
HOMEPAGE="https://github.com/socketry/async-io"
SRC_URI="https://github.com/socketry/async-io/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="$(ver_cut 1)"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~riscv ~sparc ~x86"
IUSE="test"

ruby_add_rdepend "<dev-ruby/async-2.24"

ruby_add_bdepend "test? (
	>=dev-ruby/async-2.8.1:2
	>=dev-ruby/async-container-0.15:0
	>=dev-ruby/async-rspec-1.10:1
	dev-ruby/rack-test
)"

all_ruby_prepare() {
	sed -i -E 's/require_relative "(.+)"/require File.expand_path("\1")/g' "${RUBY_FAKEGEM_GEMSPEC}" || die

	# Avoid test dependency on covered
	sed -i -e '/covered/ s:^:#:' spec/spec_helper.rb || die

	# Avoid tests for TCPSocket which does not have public methods to test.
	sed -e '13 s:^:#:' \
		-i spec/async/io/tcp_socket_spec.rb || die
	# and for Generic which has mismatching methods.
	sed -e '/it_should_behave_like/,/ignore/ s:^:#:'\
		-i spec/async/io/generic_spec.rb || die
}
