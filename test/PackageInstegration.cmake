cmake_minimum_required(VERSION 3.5)

include(Assertion.cmake)

section("it should generate the source code of the test project")
  file(REMOVE_RECURSE project)
  file(MAKE_DIRECTORY project)

  file(
    WRITE project/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "project(Poject LANGUAGES CXX)\n"
    "\n"
    "find_package(MyFibonacci REQUIRED)\n")
endsection()

section("it should fail to configure the build due to missing dependencies")
  assert_execute_process(
    COMMAND "${CMAKE_COMMAND}" -B project/build project
    ERROR "Could not find a package configuration file provided by \"MyFibonacci\"")
endsection()

section("it should regenerate the source code of the test project")
  file(
    WRITE project/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "project(Poject LANGUAGES CXX)\n"
    "\n"
    "find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)\n"
    "\n"
    "cdeps_install_package(CppStarter github.com/threeal/cpp-starter main)\n"
    "find_package(MyFibonacci REQUIRED HINTS \"\${CppStarter_INSTALL_DIR}\")\n"
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

section("it should configure the build of the test project")
  assert_execute_process("${CMAKE_COMMAND}" -B project/build project)
endsection()

section("it should build the test project")
  assert_execute_process("${CMAKE_COMMAND}" --build project/build)
endsection()

section("it should run the test project")
  assert_execute_process(
    COMMAND "${CMAKE_COMMAND}" --build project/build --target run
    OUTPUT "1 1 2 3 5")
endsection()
