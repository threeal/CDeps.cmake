cmake_minimum_required(VERSION 3.5)

project(Poject LANGUAGES CXX)

find_package(FMT REQUIRED)

add_executable(main src/main.cpp)
target_link_libraries(main fmt::fmt)
