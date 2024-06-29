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

include(cmake/CDeps.cmake)

if(CDEPS_ENABLE_TESTS)
  enable_testing()

  file(
    DOWNLOAD https://raw.githubusercontent.com/threeal/assertion-cmake/511d7351ebedf65878b20acb1263095ba1c19b0a/cmake/Assertion.cmake
      ${CMAKE_BINARY_DIR}/Assertion.cmake
    EXPECTED_MD5 3abb541f0d6d50d350a3591ff3cc0c27)

  add_test(
    NAME "package directory retrieval"
    COMMAND "${CMAKE_COMMAND}"
      -P ${CMAKE_CURRENT_SOURCE_DIR}/test/PackageDirRetrieval.cmake)

  add_test(
    NAME "package URL resolve"
    COMMAND "${CMAKE_COMMAND}"
      -P ${CMAKE_CURRENT_SOURCE_DIR}/test/PackageUrlResolve.cmake)

  add_test(
    NAME "package download"
    COMMAND "${CMAKE_COMMAND}"
      -P ${CMAKE_CURRENT_SOURCE_DIR}/test/PackageDownload.cmake)

  add_test(
    NAME "package build"
    COMMAND "${CMAKE_COMMAND}"
      -P ${CMAKE_CURRENT_SOURCE_DIR}/test/PackageBuild.cmake)

  add_test(
    NAME "package installation"
    COMMAND "${CMAKE_COMMAND}"
      -P ${CMAKE_CURRENT_SOURCE_DIR}/test/PackageInstallation.cmake)

  add_test(
    NAME "package integration"
    COMMAND "${CMAKE_COMMAND}"
      -P ${CMAKE_CURRENT_SOURCE_DIR}/test/PackageInstegration.cmake)
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
