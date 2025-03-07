cmake_minimum_required(VERSION 3.21)

project(
  CDeps
  VERSION 0.1.0
  DESCRIPTION "Download, build, and install missing dependencies in CMake projects"
  HOMEPAGE_URL https://github.com/threeal/CDeps.cmake
  LANGUAGES NONE)

option(CDEPS_ENABLE_TESTS "Enable test targets.")
option(CDEPS_ENABLE_INSTALL "Enable install targets." ${PROJECT_IS_TOP_LEVEL})

list(PREPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Prefer system packages over the find modules provided by this project.
if(NOT DEFINED CMAKE_FIND_PACKAGE_PREFER_CONFIG)
  set(CMAKE_FIND_PACKAGE_PREFER_CONFIG TRUE)
endif()

include(CDeps)

if(CDEPS_ENABLE_TESTS)
  enable_testing()

  find_package(Assertion 2.0.0 REQUIRED)
  list(APPEND CMAKE_SCRIPT_TEST_DEFINITIONS CMAKE_MODULE_PATH)

  add_cmake_script_test(test/test_build_generator.cmake)
  add_cmake_script_test(test/test_build_options.cmake)
  add_cmake_script_test(test/test_build_subdir.cmake)
  add_cmake_script_test(test/test_build.cmake)
  add_cmake_script_test(test/test_download_submodule.cmake)
  add_cmake_script_test(test/test_download_version.cmake)
  add_cmake_script_test(test/test_download.cmake)
  add_cmake_script_test(test/test_install.cmake)
  add_cmake_script_test(test/test_integration.cmake)
endif()

if(CDEPS_ENABLE_INSTALL)
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/cmake/CDepsConfig.cmake
    "list(PREPEND CMAKE_MODULE_PATH \${CMAKE_CURRENT_LIST_DIR})\n"
    "include(CDeps)\n")

  include(CMakePackageConfigHelpers)
  write_basic_package_version_file(cmake/CDepsConfigVersion.cmake
    COMPATIBILITY SameMajorVersion ARCH_INDEPENDENT)

  install(
    FILES cmake/CDeps.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/cmake/CDepsConfig.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/cmake/CDepsConfigVersion.cmake
    DESTINATION lib/cmake/CDeps)

  set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}")
  include(CPack)
endif()
