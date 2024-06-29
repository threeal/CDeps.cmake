cmake_minimum_required(VERSION 3.5)

find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)
include(Assertion.cmake)

set(CDEPS_ROOT ${CMAKE_CURRENT_BINARY_DIR}/.cdeps)
file(REMOVE_RECURSE "${CDEPS_ROOT}")

section("it should fail to configure an external package build")
  # TODO: Currently, a Git tag is always required.
  assert_fatal_error(
    CALL cdeps_build_package github.com/threeal/project-starter
      NAME project-starter GIT_TAG main
    MESSAGE "CDeps: Failed to configure github.com/threeal/project-starter:")
endsection()

section("it should fail to build an external package")
  # TODO: Currently, a Git tag is always required.
  assert_fatal_error(
    CALL cdeps_build_package github.com/threeal/cpp-starter
      NAME cpp-starter GIT_TAG main
      OPTIONS CMAKE_CXX_FLAGS=invalid CMAKE_CXX_COMPILER_WORKS=ON
    MESSAGE "CDeps: Failed to build github.com/threeal/cpp-starter:")
endsection()

section("it should build an external package")
  # TODO: Currently, a Git tag is always required.
  cdeps_build_package(
    github.com/threeal/cpp-starter
    NAME cpp-starter
    GIT_TAG main)

  assert(DEFINED github.com/threeal/cpp-starter_BUILD_DIR)
  assert(EXISTS "${github.com/threeal/cpp-starter_BUILD_DIR}")
endsection()
