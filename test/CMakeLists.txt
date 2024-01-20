add_test(
  NAME BuildProjectTest
  COMMAND ${CMAKE_COMMAND}
    -D CMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/BuildProjectTest.cmake
)
