cmake_minimum_required(VERSION 3.21)

project(
  CDeps
  VERSION 0.0.0
  DESCRIPTION "Build and install missing dependencies in your CMake project"
  HOMEPAGE_URL https://github.com/threeal/CDeps.cmake
  LANGUAGES NONE
)

option(CDEPS_ENABLE_TESTS "Enable test targets.")
option(CDEPS_ENABLE_INSTALL "Enable install targets." ${PROJECT_IS_TOP_LEVEL})

list(PREPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

if(CDEPS_ENABLE_TESTS)
  enable_testing()
  add_subdirectory(test)
endif()

if(CDEPS_ENABLE_INSTALL)
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
