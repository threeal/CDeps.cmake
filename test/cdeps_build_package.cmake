find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)

set(CDEPS_ROOT ${CMAKE_CURRENT_BINARY_DIR}/.cdeps)
file(REMOVE_RECURSE "${CDEPS_ROOT}")

cdeps_get_package_dir(Sample SAMPLE_PACKAGE_DIR)

section(
  "it should fail to build an external package that has not been downloaded")
  assert_fatal_error(
    CALL cdeps_build_package Sample
    MESSAGE "CDeps: Sample must be downloaded before building")
endsection()

function(test_generate_and_build_external_package)
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
  endsection()

  section("it should build an external package")
    cdeps_build_package(Sample)

    section("it should build in the correct path")
      assert(DEFINED Sample_BUILD_DIR)
      assert(EXISTS "${Sample_BUILD_DIR}")

      assert(Sample_BUILD_DIR STREQUAL ${SAMPLE_PACKAGE_DIR}/build)
    endsection()

    section("it should use the correct build system generator")
      assert(NOT EXISTS ${Sample_BUILD_DIR}/build.ninja)
    endsection()

    section("it should build the correct targets")
      assert(EXISTS ${SAMPLE_PACKAGE_DIR}/build/earth)
      assert_execute_process(COMMAND ${SAMPLE_PACKAGE_DIR}/build/earth)

      assert(NOT EXISTS ${SAMPLE_PACKAGE_DIR}/build/mars)
    endsection()
  endsection()
endfunction()

test_generate_and_build_external_package()

section("it should rebuild an external package with a different options")
  cdeps_build_package(Sample GENERATOR Ninja OPTIONS BUILD_MARS=ON)

  section("it should rebuild in the correct path")
    assert(DEFINED Sample_BUILD_DIR)
    assert(EXISTS "${Sample_BUILD_DIR}")

    assert(Sample_BUILD_DIR STREQUAL ${SAMPLE_PACKAGE_DIR}/build)
  endsection()

  section("it should use the correct build system generator")
    assert(EXISTS ${Sample_BUILD_DIR}/build.ninja)
  endsection()

  section("it should rebuild the correct targets")
    assert(EXISTS ${SAMPLE_PACKAGE_DIR}/build/earth)
    assert_execute_process(COMMAND ${SAMPLE_PACKAGE_DIR}/build/earth)

    assert(EXISTS ${SAMPLE_PACKAGE_DIR}/build/mars)
    assert_execute_process(COMMAND ${SAMPLE_PACKAGE_DIR}/build/mars)
  endsection()
endsection()

section("it should fail to build a corrupted external package")
  file(WRITE ${SAMPLE_PACKAGE_DIR}/src/earth.cpp corrupted)
  file(WRITE ${SAMPLE_PACKAGE_DIR}/src.lock corrupted)

  assert_fatal_error(
    CALL cdeps_build_package Sample
    MESSAGE "CDeps: Failed to build Sample:")
endsection()

section("it should fail to configure a corrupted external package")
  file(WRITE ${SAMPLE_PACKAGE_DIR}/src/CMakeLists.txt corrupted)
  file(WRITE ${SAMPLE_PACKAGE_DIR}/src.lock corrupted)

  assert_fatal_error(
    CALL cdeps_build_package Sample
    MESSAGE "CDeps: Failed to configure Sample:")
endsection()

test_generate_and_build_external_package()

section("it should not rebuild an external package")
  set(PREV_CMAKE_COMMAND "${CMAKE_COMMAND}")
  set(CMAKE_COMMAND invalid)

  cdeps_build_package(Sample)

  set(CMAKE_COMMAND "${PREV_CMAKE_COMMAND}")

  section("it should maintain the correct path")
    assert(DEFINED Sample_BUILD_DIR)
    assert(EXISTS "${Sample_BUILD_DIR}")

    assert(Sample_BUILD_DIR STREQUAL ${SAMPLE_PACKAGE_DIR}/build)
  endsection()

  section("it should maintain the correct build system generator")
    assert(NOT EXISTS ${Sample_BUILD_DIR}/build.ninja)
  endsection()

  section("it should maintain the build targets")
    assert(EXISTS ${SAMPLE_PACKAGE_DIR}/build/earth)
    assert_execute_process(COMMAND ${SAMPLE_PACKAGE_DIR}/build/earth)

    assert(NOT EXISTS ${SAMPLE_PACKAGE_DIR}/build/mars)
  endsection()
endsection()
