cmake_minimum_required(VERSION 3.5)

include(Assertion.cmake)

section("it should fail to configure an external package")
  file(REMOVE_RECURSE project)
  file(MAKE_DIRECTORY project)

  # TODO: Currently, a Git tag is always required.
  file(
    WRITE project/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "project(Poject LANGUAGES CXX)\n"
    "\n"
    "find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)\n"
    "cdeps_install_package(\n"
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
    "cdeps_install_package(\n"
    "  https://github.com/threeal/cpp-starter\n"
    "  NAME cpp-starter\n"
    "  GIT_TAG main\n"
    "  OPTIONS CMAKE_CXX_FLAGS=invalid CMAKE_CXX_COMPILER_WORKS=ON)\n")

  assert_execute_process(
    COMMAND "${CMAKE_COMMAND}" -B project/build project
    ERROR "CDeps: Failed to build cpp-starter:")
endsection()

section("it should fail to install an external package")
  file(REMOVE_RECURSE project)
  file(MAKE_DIRECTORY project)

  # TODO: Currently, a Git tag is always required.
  file(
    WRITE project/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "project(Poject LANGUAGES CXX)\n"
    "\n"
    "find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)\n"
    "cdeps_install_package(\n"
    "  https://github.com/threeal/cmake-starter\n"
    "  NAME cmake-starter\n"
    "  GIT_TAG main\n"
    "  OPTIONS CMAKE_SKIP_INSTALL_RULES=ON)\n")

  assert_execute_process(
    COMMAND "${CMAKE_COMMAND}" -B project/build project
    ERROR "CDeps: Failed to install cmake-starter:")
endsection()

section("it should install an external package")
  file(REMOVE_RECURSE project)
  file(MAKE_DIRECTORY project)

  file(
    WRITE project/CMakeLists.txt
    "cmake_minimum_required(VERSION 3.5)\n"
    "project(Poject LANGUAGES CXX)\n"
    "\n"
    "find_package(FMT QUIET NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH)\n"
    "if(FMT_FOUND)\n"
    "  message(FATAL_ERROR \"should not use the FMT library from the system\")\n"
    "endif()\n"
    "\n"
    "find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)\n"
    "\n"
    "cdeps_install_package(\n"
    "  https://github.com/fmtlib/fmt\n"
    "  NAME FMT\n"
    "  GIT_TAG 10.2.1\n"
    "  OPTIONS FMT_MASTER_PROJECT=OFF)\n"
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

  assert_execute_process("${CMAKE_COMMAND}" -B project/build project)
  assert_execute_process("${CMAKE_COMMAND}" --build project/build)
endsection()
