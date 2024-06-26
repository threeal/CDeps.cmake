cmake_minimum_required(VERSION 3.5)

include(Assertion.cmake)

section("it should fail to configure an external package build")
  file(REMOVE_RECURSE project)
  file(MAKE_DIRECTORY project)

  # TODO: Currently, a Git tag is always required.
  file(
    WRITE project/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "project(Poject LANGUAGES CXX)\n"
    "\n"
    "find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)\n"
    "cdeps_build_package(\n"
    "  https://github.com/threeal/project-starter\n"
    "  NAME project-starter\n"
    "  GIT_TAG main)\n")

  assert_execute_process(
    COMMAND "${CMAKE_COMMAND}" -B project/build project
    ERROR "CDeps: Failed to configure project-starter:")
endsection()

section("it should fail to build an external package")
  file(REMOVE_RECURSE project)
  file(MAKE_DIRECTORY project)

  # TODO: Currently, a Git tag is always required.
  file(
    WRITE project/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "project(Poject LANGUAGES CXX)\n"
    "\n"
    "find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)\n"
    "cdeps_build_package(\n"
    "  https://github.com/threeal/cpp-starter\n"
    "  NAME cpp-starter\n"
    "  GIT_TAG main\n"
    "  OPTIONS CMAKE_CXX_FLAGS=invalid CMAKE_CXX_COMPILER_WORKS=ON)\n")

  assert_execute_process(
    COMMAND "${CMAKE_COMMAND}" -B project/build project
    ERROR "CDeps: Failed to build cpp-starter:")
endsection()

section("it should build an external package")
  file(REMOVE_RECURSE project)
  file(MAKE_DIRECTORY project)

  # TODO: Currently, a Git tag is always required.
  file(
    WRITE project/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "project(Poject LANGUAGES CXX)\n"
    "\n"
    "find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)\n"
    "cdeps_build_package(\n"
    "  https://github.com/threeal/cpp-starter\n"
    "  NAME cpp-starter\n"
    "  GIT_TAG main)\n"
    "\n"
    "include(../Assertion.cmake)\n"
    "assert(DEFINED cpp-starter_BUILD_DIR)\n"
    "assert(EXISTS \"\${cpp-starter_BUILD_DIR}\")\n")

  assert_execute_process("${CMAKE_COMMAND}" -B project/build project)
endsection()
