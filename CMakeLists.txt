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

  include(CMakePackageConfigHelpers)
  write_basic_package_version_file(
    CDepsConfigVersion.cmake
    COMPATIBILITY SameMajorVersion
  )

  install(
    FILES
      cmake/CDeps.cmake
      cmake/CDepsConfig.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/CDepsConfigVersion.cmake
    DESTINATION lib/cmake/CDeps
  )
endif()
