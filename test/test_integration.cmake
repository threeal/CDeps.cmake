cmake_minimum_required(VERSION 3.21)

include(Assertion)
include(CDeps RESULT_VARIABLE CDEPS_LIST_FILE)

file(REMOVE_RECURSE project)

section("it should generate the source code of the test project")
  file(WRITE project/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "project(Poject LANGUAGES CXX)\n"
    "\n"
    "find_package(MyFibonacci REQUIRED)\n")
endsection()

section("it should fail to configure the build due to missing dependencies")
  assert_execute_process(
    COMMAND "${CMAKE_COMMAND}" -G "Unix Makefiles" -S project -B project/build
    EXPECT_ERROR "Could not find a package configuration file")
endsection()

section("it should regenerate the source code of the test project")
  file(WRITE project/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "project(Poject LANGUAGES CXX)\n"
    "\n"
    "include(${CDEPS_LIST_FILE})\n"
    "\n"
    "cdeps_download_package(CppStarter github.com/threeal/cpp-starter v1.0.0)\n"
    "cdeps_build_package(CppStarter GENERATOR \"\${CMAKE_GENERATOR}\")\n"
    "cdeps_install_package(CppStarter)\n"
    "\n"
    "find_package(MyFibonacci REQUIRED CONFIG\n"
    "  PATHS \"\${CppStarter_INSTALL_DIR}\" NO_DEFAULT_PATH)\n"
    "\n"
    "add_executable(main main.cpp)\n"
    "target_link_libraries(main my_fibonacci::sequence)\n"
    "\n"
    "add_custom_target(run COMMAND \"$<TARGET_FILE:main>\")\n"
    "add_dependencies(run main)\n")

  file(WRITE project/main.cpp
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
  assert_execute_process(
    "${CMAKE_COMMAND}" -G "Unix Makefiles" -S project -B project/build)
endsection()

section("it should build the test project")
  assert_execute_process("${CMAKE_COMMAND}" --build project/build)
endsection()

section("it should run the test project")
  assert_execute_process(
    COMMAND "${CMAKE_COMMAND}" --build project/build --target run
    EXPECT_OUTPUT "1 1 2 3 5")
endsection()

file(REMOVE_RECURSE project)
