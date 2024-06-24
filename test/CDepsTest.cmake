cmake_minimum_required(VERSION 3.5)

file(
  DOWNLOAD https://github.com/threeal/assertion-cmake/releases/download/v0.3.0/Assertion.cmake
    ${CMAKE_BINARY_DIR}/Assertion.cmake
  EXPECTED_MD5 851f49c10934d715df5d0b59c8b8c72a
)
include(${CMAKE_BINARY_DIR}/Assertion.cmake)

function("Install missing dependencies")
  assert_execute_process(
    "${CMAKE_COMMAND}"
      -B ${CMAKE_CURRENT_LIST_DIR}/project/build
      -D CMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
      --fresh
      ${CMAKE_CURRENT_LIST_DIR}/project)

  assert_execute_process(
    "${CMAKE_COMMAND}" --build ${CMAKE_CURRENT_LIST_DIR}/project/build)
endfunction()

cmake_language(CALL "${TEST_COMMAND}")
