cmake_minimum_required(VERSION 3.5)

find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)
include(Assertion.cmake)

set(CDEPS_ROOT ${CMAKE_CURRENT_BINARY_DIR}/.cdeps)
file(REMOVE_RECURSE "${CDEPS_ROOT}")

section("it should fail to download the source code of an external package")
  assert_fatal_error(
    CALL cdeps_download_package Google google.com main
    MESSAGE "CDeps: Failed to download Google:")
endsection()

section("it should download the source code of an external package")
  cdeps_download_package(ProjectStarter github.com/threeal/project-starter main)

  assert(DEFINED ProjectStarter_SOURCE_DIR)
  assert(EXISTS "${ProjectStarter_SOURCE_DIR}")
endsection()
