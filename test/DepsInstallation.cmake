cmake_minimum_required(VERSION 3.5)

include(Assertion.cmake)

section("generate sample project")
  file(MAKE_DIRECTORY project)

  file(
    WRITE project/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "\n"
    "project(Poject LANGUAGES CXX)\n"
    "\n"
    "find_package(FMT QUIET NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH)\n"
    "if(FMT_FOUND)\n"
    "  message(FATAL_ERROR \"should not use the FMT library from the system\")\n"
    "endif()\n"
    "\n"
    "find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)\n"
    "include(CDeps)\n"
    "\n"
    "cdeps_install_package(\n"
    "  https://github.com/fmtlib/fmt\n"
    "  NAME FMT\n"
    "  GIT_TAG 10.2.1\n"
    "  OPTIONS FMT_MASTER_PROJECT=OFF\n"
    ")\n"
    "\n"
    "find_package(FMT REQUIRED NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH)\n"
    "\n"
    "add_executable(main main.cpp)\n"
    "target_link_libraries(main fmt::fmt)\n"
    "\n"
    "add_custom_target(run_main ALL COMMAND \"$<TARGET_FILE:main>\")\n"
    "add_dependencies(run_main main)\n")

  file(
    WRITE project/main.cpp
    "#include <fmt/core.h>\n"
    "\n"
    "int main() {\n"
    "  fmt::print(\"Hello world!\\n\");\n"
    "  return 0;\n"
    "}\n")
endsection()

section("reconfigure sample project")
  assert_execute_process("${CMAKE_COMMAND}" -B project/build --fresh project)
endsection()

section("build sample project")
  assert_execute_process("${CMAKE_COMMAND}" --build project/build)
endsection()
