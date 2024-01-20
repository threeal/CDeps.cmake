# Matches everything if not defined
if(NOT TEST_MATCHES)
  set(TEST_MATCHES ".*")
endif()

set(TEST_COUNT 0)

function(reconfigure_project)
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
  if(NOT RES EQUAL 0)
    message(FATAL_ERROR "Failed to configure project")
  endif()
endfunction()

function(build_project)
  message(STATUS "Building project")
  execute_process(
    COMMAND cmake --build ${CMAKE_CURRENT_LIST_DIR}/project/build
    RESULT_VARIABLE RES
  )
  if(NOT RES EQUAL 0)
    message(FATAL_ERROR "Failed to build project")
  endif()
endfunction()

function(run_project)
  message(STATUS "Running project")
  execute_process(
    COMMAND ${CMAKE_CURRENT_LIST_DIR}/project/build/main
    RESULT_VARIABLE RES
  )
  if(NOT RES EQUAL 0)
    message(FATAL_ERROR "Failed to run project")
  endif()
endfunction()

if("Install missing dependencies" MATCHES ${TEST_MATCHES})
  math(EXPR TEST_COUNT "${TEST_COUNT} + 1")
  reconfigure_project()
  build_project()
  run_project()
endif()

if(TEST_COUNT LESS_EQUAL 0)
  message(FATAL_ERROR "Nothing to test with: ${TEST_MATCHES}")
endif()
