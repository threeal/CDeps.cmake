cmake_minimum_required(VERSION 3.5)

find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)
include(Assertion.cmake)

set(CDEPS_ROOT ${CMAKE_CURRENT_BINARY_DIR}/.cdeps)
file(REMOVE_RECURSE "${CDEPS_ROOT}")

section("it should fail to configure an external package build")
  assert_fatal_error(
    CALL cdeps_build_package
      ProjectStarter github.com/threeal/project-starter main
    MESSAGE "CDeps: Failed to configure ProjectStarter:")
endsection()

section("it should fail to build an external package")
  assert_fatal_error(
    CALL cdeps_build_package CppStarter github.com/threeal/cpp-starter main
      OPTIONS CMAKE_CXX_FLAGS=invalid CMAKE_CXX_COMPILER_WORKS=ON
    MESSAGE "CDeps: Failed to build CppStarter:")
endsection()

section("it should build an external package")
  cdeps_build_package(CppStarter github.com/threeal/cpp-starter main)
endsection()

section("it should build an external package in the correct path")
  assert(DEFINED CppStarter_BUILD_DIR)
  assert(EXISTS "${CppStarter_BUILD_DIR}")

  cdeps_get_package_dir(CppStarter PACKAGE_DIR)
  assert(CppStarter_BUILD_DIR STREQUAL "${PACKAGE_DIR}/build")
endsection()
