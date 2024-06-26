cmake_minimum_required(VERSION 3.5)

include(Assertion.cmake)

section("it should fail to download the source code of an external package")
  file(REMOVE_RECURSE project)
  file(MAKE_DIRECTORY project)

  file(
    WRITE project/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "project(Poject LANGUAGES CXX)\n"
    "\n"
    "find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)\n"
    "cdeps_download_package(google.com NAME google)\n")

  assert_execute_process(
    COMMAND "${CMAKE_COMMAND}" -B project/build project
    ERROR "CDeps: Failed to download google:")
endsection()

section("it should download the source code of an external package")
  file(REMOVE_RECURSE project)
  file(MAKE_DIRECTORY project)

  # TODO: Currently, a Git tag is always required.
  file(
    WRITE project/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "project(Poject LANGUAGES CXX)\n"
    "\n"
    "find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)\n"
    "cdeps_download_package(\n"
    "  github.com/threeal/project-starter\n"
    "  NAME project-starter\n"
    "  GIT_TAG main)\n"
    "\n"
    "include(../Assertion.cmake)\n"
    "assert(DEFINED project-starter_SOURCE_DIR)\n"
    "assert(EXISTS \"\${project-starter_SOURCE_DIR}\")\n")

  assert_execute_process(COMMAND "${CMAKE_COMMAND}" -B project/build project)
endsection()
