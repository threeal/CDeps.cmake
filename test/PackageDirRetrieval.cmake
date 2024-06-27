cmake_minimum_required(VERSION 3.5)

find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)
include(Assertion.cmake)

set(CMAKE_SOURCE_DIR source-dir)

section("it should retrieve the path of a package directory")
  cdeps_get_package_dir(github.com/threeal/cpp-starter OUTPUT)
  assert(OUTPUT STREQUAL source-dir/.cdeps/github.com/threeal/cpp-starter)
endsection()

section("it should retrieve the path of a package directory with URL that contains an HTTP protocol")
  cdeps_get_package_dir(http://github.com/threeal/cpp-starter OUTPUT)
  assert(OUTPUT STREQUAL source-dir/.cdeps/github.com/threeal/cpp-starter)
endsection()

section("it should retrieve the path of a package directory with URL that contains an HTTPS protocol")
  cdeps_get_package_dir(https://github.com/threeal/cpp-starter OUTPUT)
  assert(OUTPUT STREQUAL source-dir/.cdeps/github.com/threeal/cpp-starter)
endsection()

section("it should retrieve the path of a package directory if the root is specified")
  set(CDEPS_ROOT some-root)
  cdeps_get_package_dir(github.com/threeal/cpp-starter OUTPUT)
  assert(OUTPUT STREQUAL some-root/github.com/threeal/cpp-starter)
endsection()
