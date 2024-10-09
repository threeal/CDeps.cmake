# Asserts that the build directory of the specified package is valid.
#
# assert_cdeps_package_build_dir(<name>)
#
# This function checks whether the `<name>_BUILD_DIR` variable is defined and
# points to an existing and valid build directory.
function(assert_cdeps_package_build_dir NAME)
  assert(DEFINED ${NAME}_BUILD_DIR)
  assert(EXISTS "${${NAME}_BUILD_DIR}")

  cdeps_get_package_dir("${NAME}" PACKAGE_DIR)
  assert(${NAME}_BUILD_DIR STREQUAL "${PACKAGE_DIR}/build")
endfunction()

# Asserts that the install directory of the specified package is valid.
#
# assert_cdeps_package_install_dir(<name>)
#
# This function checks whether the `<name>_INSTALL_DIR` variable is defined and
# points to an existing and valid install directory.
function(assert_cdeps_package_install_dir NAME)
  assert(DEFINED ${NAME}_INSTALL_DIR)
  assert(EXISTS "${${NAME}_INSTALL_DIR}")

  cdeps_get_package_dir("${NAME}" PACKAGE_DIR)
  assert(${NAME}_INSTALL_DIR STREQUAL "${PACKAGE_DIR}/install")
endfunction()
