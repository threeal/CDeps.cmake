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
    DOWNLOAD https://github.com/threeal/assertion-cmake/releases/download/v1.0.0/Assertion.cmake
      ${CMAKE_BINARY_DIR}/Assertion.cmake
    EXPECTED_MD5 1d8ec589d6cc15772581bf77eb3873ff)
  include(${CMAKE_BINARY_DIR}/Assertion.cmake)

  assertion_add_test(test/cdeps_build_package.cmake)
  assertion_add_test(test/cdeps_download_package.cmake)
  assertion_add_test(test/cdeps_get_package_dir.cmake)
  assertion_add_test(test/cdeps_install_package.cmake)
  assertion_add_test(test/cdeps_resolve_package_url.cmake)
  assertion_add_test(test/integration.cmake)
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
