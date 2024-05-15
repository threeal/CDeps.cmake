cmake_minimum_required(VERSION 3.5)

file(
  DOWNLOAD https://threeal.github.io/assertion-cmake/v0.1.0 ${CMAKE_BINARY_DIR}/Assertion.cmake
  EXPECTED_MD5 3c9c0dd5e971bde719d7151c673e08b4
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

  assert_defined(ARG_NAME)
  assert_strequal("${ARG_NAME}" Foo)

  assert_defined(ARG_GIT_URL)
  assert_strequal("${ARG_GIT_URL}" https://github.com/foo/foo)

  assert_defined(ARG_GIT_TAG)
  assert_strequal("${ARG_GIT_TAG}" 1.2.3)

  assert_defined(ARG_OPTIONS)
  assert_strequal("${ARG_OPTIONS}" "BUILD_TESTING=OFF;BUILD_DOCS=OFF")
endfunction()

function("Parse empty arguments")
  _cdeps_parse_arguments()

  assert_not_defined(ARG_NAME)
  assert_not_defined(ARG_GIT_URL)
  assert_not_defined(ARG_GIT_TAG)
  assert_not_defined(ARG_OPTIONS)
endfunction()

cmake_language(CALL "${TEST_COMMAND}")
