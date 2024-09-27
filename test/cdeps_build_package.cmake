find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)

set(CDEPS_ROOT ${CMAKE_CURRENT_BINARY_DIR}/.cdeps)
file(REMOVE_RECURSE "${CDEPS_ROOT}")

function(test_build_external_package)
  section("it should build an external package")
    cdeps_build_package(CppStarter github.com/threeal/cpp-starter v1.0.0)

    section("it should build in the correct path")
      assert(DEFINED CppStarter_BUILD_DIR)
      assert(EXISTS "${CppStarter_BUILD_DIR}")

      cdeps_get_package_dir(CppStarter PACKAGE_DIR)
      assert(CppStarter_BUILD_DIR STREQUAL "${PACKAGE_DIR}/build")
    endsection()

    section("it should build the correct targets")
      assert_execute_process(
        COMMAND ${CppStarter_BUILD_DIR}/generate_sequence 5 OUTPUT "1 1 2 3 5")

      assert(NOT EXISTS ${CppStarter_BUILD_DIR}/sequence_test)
    endsection()
  endsection()
endfunction()

test_build_external_package()

section("it should rebuild an external package with a different options")
  cdeps_build_package(
    CppStarter github.com/threeal/cpp-starter v1.0.0 OPTIONS BUILD_TESTING=ON)

  section("it should rebuild in the correct path")
    assert(DEFINED CppStarter_BUILD_DIR)
    assert(EXISTS "${CppStarter_BUILD_DIR}")

    cdeps_get_package_dir(CppStarter PACKAGE_DIR)
    assert(CppStarter_BUILD_DIR STREQUAL "${PACKAGE_DIR}/build")
  endsection()

  section("it should rebuild the correct targets")
    assert_execute_process(
      COMMAND ${CppStarter_BUILD_DIR}/generate_sequence 5 OUTPUT "1 1 2 3 5")

    assert_execute_process(COMMAND ${CppStarter_BUILD_DIR}/sequence_test)
  endsection()
endsection()

section("it should fail to configure an invalid external package build")
  assert_fatal_error(
    CALL cdeps_build_package
      ProjectStarter github.com/threeal/project-starter v1.0.0
    MESSAGE "CDeps: Failed to configure ProjectStarter:")
endsection()

section("it should fail to build an external package with invalid options")
  assert_fatal_error(
    CALL cdeps_build_package CppStarter github.com/threeal/cpp-starter v1.0.0
      OPTIONS CMAKE_CXX_FLAGS=invalid CMAKE_CXX_COMPILER_WORKS=ON
    MESSAGE "CDeps: Failed to build CppStarter:")
endsection()

test_build_external_package()

section("it should not rebuild an external package")
  set(PREV_CMAKE_COMMAND "${CMAKE_COMMAND}")
  set(CMAKE_COMMAND invalid)

  cdeps_build_package(CppStarter github.com/threeal/cpp-starter v1.0.0)

  set(CMAKE_COMMAND "${PREV_CMAKE_COMMAND}")

  section("it should keep the correct path")
    assert(DEFINED CppStarter_BUILD_DIR)
    assert(EXISTS "${CppStarter_BUILD_DIR}")

    cdeps_get_package_dir(CppStarter PACKAGE_DIR)
    assert(CppStarter_BUILD_DIR STREQUAL "${PACKAGE_DIR}/build")
  endsection()

  section("it should keep the build targets")
    assert_execute_process(
      COMMAND ${CppStarter_BUILD_DIR}/generate_sequence 5 OUTPUT "1 1 2 3 5")

    assert(NOT EXISTS ${CppStarter_BUILD_DIR}/sequence_test)
  endsection()
endsection()
