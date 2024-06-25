cmake_minimum_required(VERSION 3.5)

file(
  DOWNLOAD https://github.com/threeal/assertion-cmake/releases/download/v0.3.0/Assertion.cmake
    ${CMAKE_BINARY_DIR}/Assertion.cmake
  EXPECTED_MD5 851f49c10934d715df5d0b59c8b8c72a
)
include(${CMAKE_BINARY_DIR}/Assertion.cmake)

section("generate sample project")
  file(MAKE_DIRECTORY project)

  file(
    WRITE project/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "\n"
    "project(Poject LANGUAGES CXX)\n"
    "\n"
    "list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)\n"
    "\n"
    "find_package(FMT QUIET NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH)\n"
    "if(FMT_FOUND)\n"
    "  message(FATAL_ERROR \"should not use the FMT library from the system\")\n"
    "endif()\n"
    "\n"
    "include(CDeps)\n"
    "cdeps_install_package(\n"
    "  NAME FMT\n"
    "  GIT_URL https://github.com/fmtlib/fmt\n"
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
  assert_execute_process(
    "${CMAKE_COMMAND}"
      -B project/build
      -D CMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
      --fresh
      project)
endsection()

section("build sample project")
  assert_execute_process(
    "${CMAKE_COMMAND}" --build project/build)
endsection()
