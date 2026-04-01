vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO leon-bckl/lsp-framework
    REF 1.3.0
    SHA512 <run_vcpkg_download_to_get_this>
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME lsp)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
