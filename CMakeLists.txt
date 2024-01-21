cmake_minimum_required(VERSION 3.19)

project(
  CDeps
  VERSION 0.0.0
  DESCRIPTION "Build and install missing dependencies in your CMake project"
  HOMEPAGE_URL https://github.com/threeal/CDeps.cmake
  LANGUAGES NONE
)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
  if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(test)
  endif()

  install(
    FILES cmake/CDeps.cmake
    DESTINATION lib/cmake/CDeps
  )
endif()
