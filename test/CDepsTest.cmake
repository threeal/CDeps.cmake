cmake_minimum_required(VERSION 3.5)

file(
  DOWNLOAD https://threeal.github.io/assertion-cmake/v0.2.0
    ${CMAKE_BINARY_DIR}/Assertion.cmake
  EXPECTED_MD5 4ee0e5217b07442d1a31c46e78bb5fac
)
include(${CMAKE_BINARY_DIR}/Assertion.cmake)

function("Install missing dependencies")
  assert_execute_process(
    COMMAND "${CMAKE_COMMAND}"
      -B ${CMAKE_CURRENT_LIST_DIR}/project/build
      -D CMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
      --fresh
      ${CMAKE_CURRENT_LIST_DIR}/project
  )

  assert_execute_process(
    COMMAND "${CMAKE_COMMAND}" --build ${CMAKE_CURRENT_LIST_DIR}/project/build
  )
endfunction()

cmake_language(CALL "${TEST_COMMAND}")
