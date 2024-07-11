find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)

set(CDEPS_ROOT ${CMAKE_CURRENT_BINARY_DIR}/.cdeps)
file(REMOVE_RECURSE "${CDEPS_ROOT}")

section("it should fail to install an external package")
  assert_fatal_error(
    CALL cdeps_install_package CppStarter github.com/threeal/cpp-starter main
      OPTIONS CMAKE_SKIP_INSTALL_RULES=ON
    MESSAGE "CDeps: Failed to install CppStarter:")
endsection()

section("it should install an external package")
  # TODO: Need to reset the CDeps directory.
  file(REMOVE_RECURSE "${CDEPS_ROOT}")

  cdeps_install_package(CppStarter github.com/threeal/cpp-starter main)
endsection()

section("it should install an external package in the correct path")
  assert(DEFINED CppStarter_INSTALL_DIR)
  assert(EXISTS "${CppStarter_INSTALL_DIR}")

  cdeps_get_package_dir(CppStarter PACKAGE_DIR)
  assert(CppStarter_INSTALL_DIR STREQUAL "${PACKAGE_DIR}/install")
endsection()
