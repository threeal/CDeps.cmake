cmake_minimum_required(VERSION 3.5)

file(
  DOWNLOAD https://threeal.github.io/assertion-cmake/v0.2.0
    ${CMAKE_BINARY_DIR}/Assertion.cmake
  EXPECTED_MD5 4ee0e5217b07442d1a31c46e78bb5fac
)
include(${CMAKE_BINARY_DIR}/Assertion.cmake)

include(CDeps)

function("Parse arguments")
  _cdeps_parse_arguments(
    NAME Foo
    GIT_URL https://github.com/foo/foo
    GIT_TAG 1.2.3
    OPTIONS
      BUILD_TESTING=OFF
      BUILD_DOCS=OFF
  )

  assert(DEFINED ARG_NAME)
  assert(ARG_NAME STREQUAL Foo)

  assert(DEFINED ARG_GIT_URL)
  assert(ARG_GIT_URL STREQUAL https://github.com/foo/foo)

  assert(DEFINED ARG_GIT_TAG)
  assert(ARG_GIT_TAG STREQUAL 1.2.3)

  assert(DEFINED ARG_OPTIONS)
  assert(ARG_OPTIONS MATCHES "^BUILD_TESTING=OFF.BUILD_DOCS=OFF$")
endfunction()

function("Parse empty arguments")
  _cdeps_parse_arguments()

  assert(NOT DEFINED ARG_NAME)
  assert(NOT DEFINED ARG_GIT_URL)
  assert(NOT DEFINED ARG_GIT_TAG)
  assert(NOT DEFINED ARG_OPTIONS)
endfunction()

cmake_language(CALL "${TEST_COMMAND}")
