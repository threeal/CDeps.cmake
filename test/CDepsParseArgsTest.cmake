include(CDeps)

function(expect VAR EXPECTED)
  if(NOT ${VAR} STREQUAL "${EXPECTED}")
    message(FATAL_ERROR "${VAR} expected to be equal to ${EXPECTED} but got ${${VAR}} instead")
  endif()
endfunction()

function(expect_undefined VAR)
  if(${VAR})
    message(FATAL_ERROR "${VAR} should not be defined")
  endif()
endfunction()

function("Parse arguments")
  _cdeps_parse_arguments(
    NAME Foo
    GIT_URL https://github.com/foo/foo
    GIT_TAG 1.2.3
    OPTIONS
      BUILD_TESTING=OFF
      BUILD_DOCS=OFF
  )

  expect(ARG_NAME Foo)
  expect(ARG_GIT_URL https://github.com/foo/foo)
  expect(ARG_GIT_TAG 1.2.3)
  expect(ARG_OPTIONS "BUILD_TESTING=OFF;BUILD_DOCS=OFF")
endfunction()

function("Parse empty arguments")
  _cdeps_parse_arguments()

  expect_undefined(ARG_NAME)
  expect_undefined(ARG_GIT_URL)
  expect_undefined(ARG_GIT_TAG)
  expect_undefined(ARG_OPTIONS)
endfunction()

if(NOT DEFINED TEST_COMMAND)
  message(FATAL_ERROR "The 'TEST_COMMAND' variable should be defined")
elseif(NOT COMMAND "${TEST_COMMAND}")
  message(FATAL_ERROR "Unable to find a command named '${TEST_COMMAND}'")
endif()

cmake_language(CALL "${TEST_COMMAND}")
