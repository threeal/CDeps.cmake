find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)

set(CDEPS_ROOT ${CMAKE_CURRENT_BINARY_DIR}/.cdeps)
file(REMOVE_RECURSE "${CDEPS_ROOT}")

section("it should fail to install an external package with invalid options")
  assert_fatal_error(
    CALL cdeps_install_package CppStarter github.com/threeal/cpp-starter v1.0.0
      OPTIONS CMAKE_SKIP_INSTALL_RULES=ON
    MESSAGE "CDeps: Failed to install CppStarter:")
endsection()

section("it should install an external package")
  cdeps_install_package(CppStarter github.com/threeal/cpp-starter v1.0.0)

  section("it should install to the correct path")
    assert(DEFINED CppStarter_INSTALL_DIR)
    assert(EXISTS "${CppStarter_INSTALL_DIR}")

    cdeps_get_package_dir(CppStarter PACKAGE_DIR)
    assert(CppStarter_INSTALL_DIR STREQUAL "${PACKAGE_DIR}/install")
  endsection()

  section("it should install the correct targets")
    assert_execute_process(
      COMMAND ${CppStarter_INSTALL_DIR}/bin/generate_sequence 5
      OUTPUT "1 1 2 3 5")
  endsection()
endsection()

section("it should not reinstall an external package")
  set(PREV_CMAKE_COMMAND "${CMAKE_COMMAND}")
  set(CMAKE_COMMAND invalid)

  cdeps_install_package(CppStarter github.com/threeal/cpp-starter v1.0.0)

  set(CMAKE_COMMAND "${PREV_CMAKE_COMMAND}")

  section("it should keep the correct path")
    assert(DEFINED CppStarter_INSTALL_DIR)
    assert(EXISTS "${CppStarter_INSTALL_DIR}")

    cdeps_get_package_dir(CppStarter PACKAGE_DIR)
    assert(CppStarter_INSTALL_DIR STREQUAL "${PACKAGE_DIR}/install")
  endsection()

  section("it should keep the install targets")
    assert_execute_process(
      COMMAND ${CppStarter_INSTALL_DIR}/bin/generate_sequence 5
      OUTPUT "1 1 2 3 5")
  endsection()
endsection()
