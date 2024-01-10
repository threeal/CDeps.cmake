if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/project/build)
  message(STATUS "Removing build directory")
  file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/project/build)
endif()

message(STATUS "Configuring project")
execute_process(
  COMMAND cmake ${CMAKE_CURRENT_LIST_DIR}/project
    -B ${CMAKE_CURRENT_LIST_DIR}/project/build
    -D CMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
  RESULT_VARIABLE RES
)
if(NOT ${RES} EQUAL 0)
  message(FATAL_ERROR "Failed to configure project")
endif()

message(STATUS "Building project")
execute_process(
  COMMAND cmake --build ${CMAKE_CURRENT_LIST_DIR}/project/build
  RESULT_VARIABLE RES
)
if(NOT ${RES} EQUAL 0)
  message(FATAL_ERROR "Failed to build project")
endif()

message(STATUS "Running project")
execute_process(
  COMMAND ${CMAKE_CURRENT_LIST_DIR}/project/build/main
  RESULT_VARIABLE RES
)
if(NOT ${RES} EQUAL 0)
  message(FATAL_ERROR "Failed to run project")
endif()
