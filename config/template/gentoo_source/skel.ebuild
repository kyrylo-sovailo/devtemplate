EAPI=8
inherit cmake
DESCRIPTION="@DEV_DESCRIPTION@"
HOMEPAGE="@DEV_HOMEPAGE@"
SRC_URI="mirror://local/@DEV_FILE_NAME@/@DEV_FILE_NAME@-@DEV_VERSION@.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~*"
IUSE=""
RDEPEND="media-libs/libpng x11-libs/libX11 dev-lang/python"
DEPEND="media-libs/libpng x11-libs/libX11 dev-cpp/gtest dev-python/pybind11"
BDEPEND="dev-build/cmake net-misc/rsync"

src_configure() {
	local mycmakeargs=(
		-DDEV_FLAVOR=gentoo
		-DCMAKE_INSTALL_PREFIX="/usr"
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile core
}

src_install() {
	cmake_src_install
}
