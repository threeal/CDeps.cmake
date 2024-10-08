include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CDeps.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/assert_helper.cmake)

set(CMAKE_GENERATOR "Unix Makefiles")

set(CDEPS_ROOT ${CMAKE_CURRENT_BINARY_DIR}/.cdeps)
file(REMOVE_RECURSE "${CDEPS_ROOT}")

cdeps_get_package_dir(Sample PACKAGE_DIR)
set(Sample_SOURCE_DIR ${PACKAGE_DIR}/src)

section("it should fail to build an external package "
  "that has not been downloaded")
  assert_fatal_error(
    CALL cdeps_build_package Sample
    MESSAGE "CDeps: Sample must be downloaded before building")
endsection()

section("it should generate external package source files")
  file(WRITE ${Sample_SOURCE_DIR}/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "project(Sample LANGUAGES CXX)\n"
    "\n"
    "option(BUILD_MARS \"\" OFF)\n"
    "\n"
    "add_executable(earth earth.cpp)\n"
    "install(TARGETS earth EXPORT earth_targets)\n"
    "\n"
    "if(BUILD_MARS)\n"
    "  add_executable(mars mars.cpp)\n"
    "  install(TARGETS mars EXPORT mars_targets)\n"
    "endif()\n")

  file(WRITE ${Sample_SOURCE_DIR}/earth.cpp
    "#include <iostream>\n"
    "\n"
    "int main() {\n"
    "  std::cout << \"Hello Earth!\\n\";\n"
    "}\n")

  file(WRITE ${Sample_SOURCE_DIR}/mars.cpp
    "#include <iostream>\n"
    "\n"
    "int main() {\n"
    "  std::cout << \"Hello Mars!\\n\";\n"
    "}\n")

  file(WRITE ${Sample_SOURCE_DIR}.lock
    "Sample github.com/user/sample main")
endsection()

section("it should fail to configure a corrupted external package")
  file(READ ${Sample_SOURCE_DIR}/CMakeLists.txt ORIGINAL_CMAKELISTS_TXT)
  file(WRITE ${Sample_SOURCE_DIR}/CMakeLists.txt corrupted)

  assert_fatal_error(
    CALL cdeps_build_package Sample
    MESSAGE "CDeps: Failed to configure Sample:")

  file(WRITE ${Sample_SOURCE_DIR}/CMakeLists.txt "${ORIGINAL_CMAKELISTS_TXT}")
endsection()

section("it should fail to build a corrupted external package")
  file(READ ${Sample_SOURCE_DIR}/earth.cpp ORIGINAL_EARTH_CPP)
  file(WRITE ${Sample_SOURCE_DIR}/earth.cpp corrupted)

  assert_fatal_error(
    CALL cdeps_build_package Sample
    MESSAGE "CDeps: Failed to build Sample:")

  file(WRITE ${Sample_SOURCE_DIR}/earth.cpp "${ORIGINAL_EARTH_CPP}")
endsection()

section("it should build an external package with a default generator")
  set(PREV_CMAKE_GENERATOR "${CMAKE_GENERATOR}")
  unset(CMAKE_GENERATOR)

  cdeps_build_package(Sample)

  section("it should build in the correct path")
    assert_cdeps_package_build_dir(Sample)
  endsection()

  section("it should build the correct targets")
    assert(EXISTS ${Sample_BUILD_DIR}/earth)
    assert_execute_process(COMMAND ${Sample_BUILD_DIR}/earth)

    assert(NOT EXISTS ${Sample_BUILD_DIR}/mars)
  endsection()

  set(CMAKE_GENERATOR "${PREV_CMAKE_GENERATOR}")
endsection()

section("it should fail to rebuild an external package "
  "with an invalid parent project's generator")
  set(PREV_CMAKE_GENERATOR "${CMAKE_GENERATOR}")
  set(CMAKE_GENERATOR invalid)

  assert_fatal_error(
    CALL cdeps_build_package Sample
    MESSAGE "CDeps: Failed to configure Sample:")

  set(CMAKE_GENERATOR "${PREV_CMAKE_GENERATOR}")
endsection()

section("it should build an external package")
  cdeps_build_package(Sample)

  section("it should build in the correct path")
    assert_cdeps_package_build_dir(Sample)
  endsection()

  section("it should build the correct targets")
    assert(EXISTS ${Sample_BUILD_DIR}/earth)
    assert_execute_process(COMMAND ${Sample_BUILD_DIR}/earth)

    assert(NOT EXISTS ${Sample_BUILD_DIR}/mars)
  endsection()
endsection()

section("it should not rebuild an external package")
  set(PREV_CMAKE_COMMAND "${CMAKE_COMMAND}")
  set(CMAKE_COMMAND invalid)

  cdeps_build_package(Sample)

  set(CMAKE_COMMAND "${PREV_CMAKE_COMMAND}")

  section("it should maintain the correct path")
    assert_cdeps_package_build_dir(Sample)
  endsection()
endsection()

section("it should rebuild an external package with a different options")
  cdeps_build_package(Sample OPTIONS BUILD_MARS=ON)

  section("it should rebuild in the correct path")
    assert_cdeps_package_build_dir(Sample)
  endsection()

  section("it should rebuild the correct targets")
    assert(EXISTS ${Sample_BUILD_DIR}/earth)
    assert_execute_process(COMMAND ${Sample_BUILD_DIR}/earth)

    assert(EXISTS ${Sample_BUILD_DIR}/mars)
    assert_execute_process(COMMAND ${Sample_BUILD_DIR}/mars)
  endsection()
endsection()

section("it should fail to rebuild an external package with an invalid generator")
  assert_fatal_error(
    CALL cdeps_build_package Sample GENERATOR invalid
    MESSAGE "CDeps: Failed to configure Sample:")
endsection()

section("it should build an external package with a valid generator")
  cdeps_build_package(Sample GENERATOR "Unix Makefiles")

  section("it should build in the correct path")
    assert_cdeps_package_build_dir(Sample)
  endsection()

  section("it should use the correct build system generator")
    assert(EXISTS ${Sample_BUILD_DIR}/Makefile)
  endsection()

  section("it should build the correct targets")
    assert(EXISTS ${Sample_BUILD_DIR}/earth)
    assert_execute_process(COMMAND ${Sample_BUILD_DIR}/earth)

    assert(NOT EXISTS ${Sample_BUILD_DIR}/mars)
  endsection()
endsection()

file(REMOVE_RECURSE "${CDEPS_ROOT}")
