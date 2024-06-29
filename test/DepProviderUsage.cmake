cmake_minimum_required(VERSION 3.5)

find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)
include(Assertion.cmake)

set(CDEPS_ROOT ${CMAKE_CURRENT_BINARY_DIR}/.cdeps)
file(REMOVE_RECURSE "${CDEPS_ROOT}")

section("it should generate the source code of the test project")
  file(REMOVE_RECURSE project)
  file(MAKE_DIRECTORY project)

  file(
    WRITE project/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "project(Poject LANGUAGES CXX)\n"
    "\n"
    "find_package(MyFibonacci REQUIRED)\n"
    "\n"
    "add_executable(main main.cpp)\n"
    "target_link_libraries(main my_fibonacci::sequence)\n"
    "\n"
    "add_custom_target(run COMMAND \"$<TARGET_FILE:main>\")\n"
    "add_dependencies(run main)\n")

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
endsection()

section("it should fail to configure the build because of missing dependencies")
  assert_execute_process(
    COMMAND "${CMAKE_COMMAND}" -B project/build project
    ERROR "Could not find a package configuration file provided by \"MyFibonacci\"")
endsection()

section("it should generate the dependency provider module")
  file(
    WRITE project/CDeps.cmake
    "find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)\n"
    "\n"
    "cdeps_declare_package(\n"
    "  MyFibonacci github.com/threeal/cpp-starter GIT_TAG main)\n")
endsection()

section("it should configure the build of the test project")
  assert_execute_process(
    "${CMAKE_COMMAND}" -B project/build project
      -D CMAKE_PROJECT_TOP_LEVEL_INCLUDES=CDeps.cmake)
endsection()
