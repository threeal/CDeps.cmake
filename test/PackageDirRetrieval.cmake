cmake_minimum_required(VERSION 3.5)

find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)
include(Assertion.cmake)

section("it should retrieve the path of a package directory")
  set(CMAKE_SOURCE_DIR source-dir)
  cdeps_get_package_dir(cpp-starter OUTPUT)
  assert(OUTPUT STREQUAL source-dir/.cdeps/cpp-starter)
endsection()

section("it should retrieve the path of a package directory if the root is specified")
  set(CDEPS_ROOT some-root)
  cdeps_get_package_dir(cpp-starter OUTPUT)
  assert(OUTPUT STREQUAL some-root/cpp-starter)
endsection()
