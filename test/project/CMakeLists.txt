cmake_minimum_required(VERSION 3.5)

project(Poject LANGUAGES CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

find_package(FMT REQUIRED)

add_executable(main src/main.cpp)
target_link_libraries(main fmt::fmt)
