function(reconfigure_project)
  message(STATUS "Reconfiguring project")
  execute_process(
    COMMAND "${CMAKE_COMMAND}"
      -B ${CMAKE_CURRENT_LIST_DIR}/project/build
      -D CMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
      --fresh
      ${CMAKE_CURRENT_LIST_DIR}/project
    RESULT_VARIABLE RES
  )
  if(NOT RES EQUAL 0)
    message(FATAL_ERROR "Failed to reconfigure project")
  endif()
endfunction()

function(build_project)
  message(STATUS "Building project")
  execute_process(
    COMMAND "${CMAKE_COMMAND}" --build ${CMAKE_CURRENT_LIST_DIR}/project/build
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

function("Install missing dependencies")
  reconfigure_project()
  build_project()
  run_project()
endfunction()

cmake_language(CALL "${TEST_COMMAND}")
