find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)

set(CDEPS_ROOT ${CMAKE_CURRENT_BINARY_DIR}/.cdeps)
file(REMOVE_RECURSE "${CDEPS_ROOT}")

cdeps_get_package_dir(Sample SAMPLE_PACKAGE_DIR)

section("it should generate external package source files")
  file(
    WRITE ${SAMPLE_PACKAGE_DIR}/src/CMakeLists.txt
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
    WRITE ${SAMPLE_PACKAGE_DIR}/src/earth.cpp
    "#include <iostream>\n"
    "\n"
    "int main() {\n"
    "  std::cout << \"Hello Earth!\\n\";\n"
    "}\n")

  file(
    WRITE ${SAMPLE_PACKAGE_DIR}/src/mars.cpp
    "#include <iostream>\n"
    "\n"
    "int main() {\n"
    "  std::cout << \"Hello Mars!\\n\";\n"
    "}\n")

  file(
    WRITE ${SAMPLE_PACKAGE_DIR}/src.lock
    "Sample github.com/user/sample main")

  set(Sample_SOURCE_DIR ${SAMPLE_PACKAGE_DIR}/src)
endsection()

section("it should fail to install an external package that has not been built")
  assert_fatal_error(
    CALL cdeps_install_package Sample
    MESSAGE "CDeps: Sample must be built before installation")
endsection()

macro(test_build_and_install_external_package)
  section("it should build an external package")
    execute_process(
      COMMAND "${CMAKE_COMMAND}" -B ${SAMPLE_PACKAGE_DIR}/build
        ${SAMPLE_PACKAGE_DIR}/src --fresh
      RESULT_VARIABLE RES
      OUTPUT_QUIET)
    assert(RES EQUAL 0)

    execute_process(
      COMMAND "${CMAKE_COMMAND}" --build ${SAMPLE_PACKAGE_DIR}/build
      RESULT_VARIABLE RES
      OUTPUT_QUIET)
    assert(RES EQUAL 0)

    file(
      WRITE ${SAMPLE_PACKAGE_DIR}/build.lock
      "Sample github.com/user/sample main")

    set(Sample_BUILD_DIR ${SAMPLE_PACKAGE_DIR}/build)
  endsection()

  section("it should install an external package")
    unset(Sample_INSTALL_DIR)
    cdeps_install_package(Sample)

    section("it should install to the correct path")
      assert(DEFINED Sample_INSTALL_DIR)
      assert(EXISTS "${Sample_INSTALL_DIR}")

      assert(Sample_INSTALL_DIR STREQUAL ${SAMPLE_PACKAGE_DIR}/install)
    endsection()

    section("it should install the correct targets")
      assert(EXISTS ${Sample_INSTALL_DIR}/bin/earth)
      assert_execute_process(
        COMMAND ${Sample_INSTALL_DIR}/bin/earth
        OUTPUT "Hello Earth!")

      assert(NOT EXISTS ${Sample_INSTALL_DIR}/bin/mars)
    endsection()
  endsection()
endmacro()

test_build_and_install_external_package()

section("it should rebuild an external package with different options")
  execute_process(
    COMMAND "${CMAKE_COMMAND}" -B ${SAMPLE_PACKAGE_DIR}/build
      ${SAMPLE_PACKAGE_DIR}/src -D BUILD_MARS=ON --fresh
    RESULT_VARIABLE RES
    OUTPUT_QUIET)
  assert(RES EQUAL 0)

  execute_process(
    COMMAND "${CMAKE_COMMAND}" --build ${SAMPLE_PACKAGE_DIR}/build
    RESULT_VARIABLE RES
    OUTPUT_QUIET)
  assert(RES EQUAL 0)

  file(
    WRITE ${SAMPLE_PACKAGE_DIR}/build.lock
    "Sample github.com/user/sample main OPTIONS BUILD_MARS=ON")

  set(Sample_BUILD_DIR ${SAMPLE_PACKAGE_DIR}/build)
endsection()

section("it should reinstall an external package")
  unset(Sample_INSTALL_DIR)

  cdeps_install_package(Sample)

  section("it should reinstall to the correct path")
    assert(DEFINED Sample_INSTALL_DIR)
    assert(EXISTS "${Sample_INSTALL_DIR}")

    assert(Sample_INSTALL_DIR STREQUAL ${SAMPLE_PACKAGE_DIR}/install)
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
endsection()

section("it should fail to install a corrupted external package")
  file(REMOVE ${SAMPLE_PACKAGE_DIR}/build/cmake_install.cmake)
  file(WRITE ${SAMPLE_PACKAGE_DIR}/build.lock corrupted)

  assert_fatal_error(
    CALL cdeps_install_package Sample
    MESSAGE "CDeps: Failed to install Sample:")
endsection()

test_build_and_install_external_package()

section("it should not reinstall an external package")
  set(PREV_CMAKE_COMMAND "${CMAKE_COMMAND}")
  set(CMAKE_COMMAND invalid)

  cdeps_install_package(Sample)

  set(CMAKE_COMMAND "${PREV_CMAKE_COMMAND}")

  section("it should maintain to the correct path")
    assert(DEFINED Sample_INSTALL_DIR)
    assert(EXISTS "${Sample_INSTALL_DIR}")

    assert(Sample_INSTALL_DIR STREQUAL ${SAMPLE_PACKAGE_DIR}/install)
  endsection()

  section("it should maintain the correct targets")
    assert(EXISTS ${Sample_INSTALL_DIR}/bin/earth)
    assert_execute_process(
      COMMAND ${Sample_INSTALL_DIR}/bin/earth
      OUTPUT "Hello Earth!")

    assert(NOT EXISTS ${Sample_INSTALL_DIR}/bin/mars)
  endsection()
endsection()
