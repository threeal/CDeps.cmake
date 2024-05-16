cmake_minimum_required(VERSION 3.5)

project(Poject LANGUAGES CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

find_package(FMT QUIET NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH)
if(FMT_FOUND)
  message(FATAL_ERROR "should not use the FMT library from the system")
endif()

include(CDeps)
cdeps_install_package(
  NAME FMT
  GIT_URL https://github.com/fmtlib/fmt
  GIT_TAG 10.2.1
  OPTIONS FMT_MASTER_PROJECT=OFF
)

find_package(FMT REQUIRED NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH)

add_executable(main src/main.cpp)
target_link_libraries(main fmt::fmt)

add_custom_target(run_main ALL COMMAND "$<TARGET_FILE:main>")
add_dependencies(run_main main)
