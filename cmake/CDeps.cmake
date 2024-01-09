function(cdeps_install_package)
  cmake_parse_arguments(ARG "" "NAME;GIT_URL;GIT_TAG" "" ${ARGN})

  if(NOT CDEPS_ROOT)
    set(CDEPS_ROOT ${CMAKE_SOURCE_DIR}/.cdeps)
  endif()

  set(SOURCE_DIR ${CDEPS_ROOT}/${ARG_NAME}-src)
  if(NOT EXISTS ${SOURCE_DIR})
    find_program(GIT_PROGRAM git)
    if(${GIT_PROGRAM} STREQUAL GIT_PROGRAM-NOTFOUND)
      message(FATAL_ERROR "CDeps: Git is required to download packages")
    endif()

    message(STATUS "CDeps: Downloading ${ARG_NAME} from ${ARG_GIT_URL}#${ARG_GIT_TAG}")
    execute_process(
      COMMAND git clone -b ${ARG_GIT_TAG} ${ARG_GIT_URL} ${SOURCE_DIR}
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
    )
    if(NOT ${RES} EQUAL 0)
      message(FATAL_ERROR "CDeps: Failed to download ${ARG_NAME}: ${ERR}")
    endif()
  endif()


  set(BUILD_DIR ${CDEPS_ROOT}/${ARG_NAME}-build)
  if(NOT EXISTS ${BUILD_DIR})
    message(STATUS "CDeps: Configuring ${ARG_NAME}")
    execute_process(
      COMMAND ${CMAKE_COMMAND} ${SOURCE_DIR} -B ${BUILD_DIR} -D FMT_MASTER_PROJECT=OFF
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
    )
    if(NOT ${RES} EQUAL 0)
      message(FATAL_ERROR "CDeps: Failed to configure ${ARG_NAME}: ${ERR}")
    endif()

    message(STATUS "CDeps: Building ${ARG_NAME}")
    execute_process(
      COMMAND ${CMAKE_COMMAND} --build ${BUILD_DIR}
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
    )
    if(NOT ${RES} EQUAL 0)
      message(FATAL_ERROR "CDeps: Failed to build ${ARG_NAME}: ${ERR}")
    endif()
  endif()

  set(INSTALL_DIR ${CDEPS_ROOT}/${ARG_NAME}-install)
  if(NOT EXISTS ${INSTALL_DIR})
    message(STATUS "CDeps: Installing ${ARG_NAME}")
    execute_process(
      COMMAND ${CMAKE_COMMAND} --install ${BUILD_DIR} --prefix ${INSTALL_DIR}
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
    )
    if(NOT ${RES} EQUAL 0)
      message(FATAL_ERROR "CDeps: Failed to install ${ARG_NAME}: ${ERR}")
    endif()
  endif()

  if(IS_DIRECTORY ${INSTALL_DIR}/lib/cmake)
    set(CMAKE_PREFIX_PATH "${INSTALL_DIR}/lib/cmake;${CMAKE_PREFIX_PATH}" PARENT_SCOPE)
  endif()
endfunction()
