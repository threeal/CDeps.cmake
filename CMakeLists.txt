cmake_minimum_required(VERSION 3.12)

project(
  CDeps
  VERSION 0.0.0
  DESCRIPTION "Build and install missing dependencies in your CMake project"
  HOMEPAGE_URL https://github.com/threeal/CDeps.cmake
  LANGUAGES NONE
)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(MkdirRecursive)

if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR AND BUILD_TESTING)
  enable_testing()

  add_test(
    NAME BuildProjectTest
    COMMAND cmake -P ${CMAKE_CURRENT_SOURCE_DIR}/test/BuildProjectTest.cmake
  )
endif()

install(
  FILES cmake/MkdirRecursive.cmake
  DESTINATION lib/cmake
)
