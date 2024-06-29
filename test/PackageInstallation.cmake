cmake_minimum_required(VERSION 3.5)

find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)
include(Assertion.cmake)

set(CDEPS_ROOT ${CMAKE_CURRENT_BINARY_DIR}/.cdeps)
file(REMOVE_RECURSE "${CDEPS_ROOT}")

section("it should fail to install an external package")
  assert_fatal_error(
    CALL cdeps_install_package github.com/threeal/cpp-starter main
      OPTIONS CMAKE_SKIP_INSTALL_RULES=ON
    MESSAGE "CDeps: Failed to install github.com/threeal/cpp-starter:")
endsection()

section("it should install an external package")
  file(REMOVE_RECURSE project)
  file(MAKE_DIRECTORY project)

  file(
    WRITE project/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "project(Poject LANGUAGES CXX)\n"
    "\n"
    "include(../Assertion.cmake)\n"
    "\n"
    "find_package(MyFibonacci QUIET)\n"
    "assert(NOT MyFibonacci_FOUND)\n"
    "\n"
    "find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)\n"
    "\n"
    "cdeps_install_package(github.com/threeal/cpp-starter main)\n"
    "\n"
    "assert(DEFINED github.com/threeal/cpp-starter_INSTALL_DIR)\n"
    "assert(EXISTS \"\${github.com/threeal/cpp-starter_INSTALL_DIR}\")\n"
    "\n"
    "find_package(\n"
    "  MyFibonacci REQUIRED\n"
    "  HINTS \"\${github.com/threeal/cpp-starter_INSTALL_DIR}\")\n"
    "\n"
    "add_executable(main main.cpp)\n"
    "target_link_libraries(main my_fibonacci::sequence)\n"
    "\n"
    "add_custom_target(run_main ALL COMMAND \"$<TARGET_FILE:main>\")\n"
    "add_dependencies(run_main main)\n")

  file(
    WRITE project/main.cpp
    "#include <my_fibonacci/sequence.hpp>\n"
    "#include <iostream>\n"
    "\n"
    "int main() {\n"
    "  const auto sequence = my_fibonacci::fibonacci_sequence(5);\n"
    "  for (auto val : sequence) {\n"
    "    std::cout << val << \" \";\n"
    "  }\n"
    "  std::cout << std::endl;\n"
    "  return 0;\n"
    "}\n")

  assert_execute_process("${CMAKE_COMMAND}" -B project/build project)
  assert_execute_process("${CMAKE_COMMAND}" --build project/build)
endsection()
