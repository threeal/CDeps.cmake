include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CDeps.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/assert_helper.cmake)

set(CMAKE_GENERATOR "Unix Makefiles")

set(CDEPS_ROOT ${CMAKE_CURRENT_BINARY_DIR}/.cdeps)
file(REMOVE_RECURSE "${CDEPS_ROOT}")

cdeps_get_package_dir(Sample PACKAGE_DIR)
set(Sample_SOURCE_DIR ${PACKAGE_DIR}/src)

section("it should fail to install an external package that has not been built")
  assert_fatal_error(
    CALL cdeps_install_package Sample
    MESSAGE "CDeps: Sample must be built before installation")
endsection()

section("it should generate external package source files")
  file(
    WRITE ${Sample_SOURCE_DIR}/CMakeLists.txt
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

  file(
    WRITE ${Sample_SOURCE_DIR}/earth.cpp
    "#include <iostream>\n"
    "\n"
    "int main() {\n"
    "  std::cout << \"Hello Earth!\\n\";\n"
    "}\n")

  file(
    WRITE ${Sample_SOURCE_DIR}/mars.cpp
    "#include <iostream>\n"
    "\n"
    "int main() {\n"
    "  std::cout << \"Hello Mars!\\n\";\n"
    "}\n")

  file(
    WRITE ${Sample_SOURCE_DIR}.lock
    "Sample github.com/user/sample main")
endsection()

section("it should build an external package")
  cdeps_build_package(Sample)
endsection()

section("it should fail to install a corrupted external package")
  file(READ ${Sample_BUILD_DIR}/cmake_install.cmake
    ORIGINAL_CMAKE_INSTALL_CMAKE)

  file(WRITE ${Sample_BUILD_DIR}/cmake_install.cmake corrupted)

  assert_fatal_error(
    CALL cdeps_install_package Sample
    MESSAGE "CDeps: Failed to install Sample:")

  file(WRITE ${Sample_BUILD_DIR}/cmake_install.cmake
    "${ORIGINAL_CMAKE_INSTALL_CMAKE}")
endsection()

section("it should install an external package")
  cdeps_install_package(Sample)

  section("it should install to the correct path")
    assert_cdeps_package_install_dir(Sample)
  endsection()

  section("it should install the correct targets")
    assert(EXISTS ${Sample_INSTALL_DIR}/bin/earth)
    assert_execute_process(
      COMMAND ${Sample_INSTALL_DIR}/bin/earth
      OUTPUT "Hello Earth!")

    assert(NOT EXISTS ${Sample_INSTALL_DIR}/bin/mars)
  endsection()

  unset(Sample_INSTALL_DIR)
endsection()

section("it should not reinstall an external package")
  set(PREV_CMAKE_COMMAND "${CMAKE_COMMAND}")
  set(CMAKE_COMMAND invalid)

  cdeps_install_package(Sample)

  set(CMAKE_COMMAND "${PREV_CMAKE_COMMAND}")

  section("it should maintain the correct path")
    assert_cdeps_package_install_dir(Sample)
  endsection()

  unset(Sample_INSTALL_DIR)
endsection()

section("it should rebuild an external package with different options")
  cdeps_build_package(Sample OPTIONS BUILD_MARS=ON)
endsection()

section("it should reinstall an external package")
  cdeps_install_package(Sample)

  section("it should reinstall to the correct path")
    assert_cdeps_package_install_dir(Sample)
  endsection()

  section("it should reinstall the correct targets")
    assert(EXISTS ${Sample_INSTALL_DIR}/bin/earth)
    assert_execute_process(
      COMMAND ${Sample_INSTALL_DIR}/bin/earth
      OUTPUT "Hello Earth!")

    assert(EXISTS ${Sample_INSTALL_DIR}/bin/mars)
    assert_execute_process(
      COMMAND ${Sample_INSTALL_DIR}/bin/mars
      OUTPUT "Hello Mars!")
  endsection()

  unset(Sample_INSTALL_DIR)
endsection()

file(REMOVE_RECURSE "${CDEPS_ROOT}")
