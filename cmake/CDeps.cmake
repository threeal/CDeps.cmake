# This code is licensed under the terms of the MIT License.
# Copyright (c) 2024 Alfi Maulana

include_guard(GLOBAL)

# Downloads the source code of an external package.
#
# cdeps_download_package(<git_url> [NAME <name>] [GIT_TAG <tag>])
#
# This function downloads the source code of an external package using Git.
# It downloads the source code from the given `<git_url>` with a specific
# `<tag>` and saves it as the `<name>` package.
#
# This function outputs the `<name>_SOURCE_DIR` variable, which contains the
# path of the downloaded source code of the external package.
function(cdeps_download_package GIT_URL)
  cmake_parse_arguments(PARSE_ARGV 1 ARG "" "NAME;GIT_TAG" "")

  # Set the default CDEPS_ROOT directory if not provided.
  if(NOT CDEPS_ROOT)
    set(CDEPS_ROOT ${CMAKE_SOURCE_DIR}/.cdeps)
  endif()

  # Check if the source directory exists; if not, download the package using Git.
  set(SOURCE_DIR ${CDEPS_ROOT}/${ARG_NAME}-src)
  if(NOT EXISTS "${SOURCE_DIR}")
    find_program(GIT_PROGRAM git)
    if("${GIT_PROGRAM}" STREQUAL GIT_PROGRAM-NOTFOUND)
      message(FATAL_ERROR "CDeps: Git is required to download packages")
    endif()

    message(STATUS "CDeps: Downloading ${ARG_NAME} from ${GIT_URL}#${ARG_GIT_TAG}")
    execute_process(
      COMMAND git clone -b "${ARG_GIT_TAG}" "${GIT_URL}" "${SOURCE_DIR}"
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
    )
    if(NOT "${RES}" EQUAL 0)
      message(FATAL_ERROR "CDeps: Failed to download ${ARG_NAME}: ${ERR}")
    endif()
  endif()

  set(${ARG_NAME}_SOURCE_DIR "${SOURCE_DIR}" PARENT_SCOPE)
endfunction()

# Builds an external package from downloaded source code.
#
# cdeps_build_package(
#   <git_url> [NAME <name>] [GIT_TAG <tag>] [OPTIONS <options>...])
#
# This function builds an external package named `<name>` with `<options>` from
# source code downloaded from the given `<git_url>` with a specific `<tag>`.
#
# This function outputs the `<name>_BUILD_DIR` variable, which contains the
# path of the built external package.
#
# See also the documentation of the `cdeps_download_package` function.
function(cdeps_build_package GIT_URL)
  cmake_parse_arguments(PARSE_ARGV 1 ARG "" "NAME" OPTIONS)

  cdeps_download_package(
    "${GIT_URL}" NAME "${ARG_NAME}" ${ARG_UNPARSED_ARGUMENTS})

  # Set the default CDEPS_ROOT directory if not provided.
  if(NOT CDEPS_ROOT)
    set(CDEPS_ROOT ${CMAKE_SOURCE_DIR}/.cdeps)
  endif()

  # Check if the build directory exists; if not, configure and build the package.
  set(BUILD_DIR ${CDEPS_ROOT}/${ARG_NAME}-build)
  if(NOT EXISTS "${BUILD_DIR}")
    message(STATUS "CDeps: Configuring ${ARG_NAME}")
    foreach(OPTION ${ARG_OPTIONS})
      list(APPEND CONFIGURE_ARGS -D "${OPTION}")
    endforeach()
    execute_process(
      COMMAND "${CMAKE_COMMAND}" -B "${BUILD_DIR}" ${CONFIGURE_ARGS}
        "${${ARG_NAME}_SOURCE_DIR}"
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
    )
    if(NOT "${RES}" EQUAL 0)
      message(FATAL_ERROR "CDeps: Failed to configure ${ARG_NAME}: ${ERR}")
    endif()

    message(STATUS "CDeps: Building ${ARG_NAME}")
    execute_process(
      COMMAND "${CMAKE_COMMAND}" --build "${BUILD_DIR}"
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
    )
    if(NOT "${RES}" EQUAL 0)
      message(FATAL_ERROR "CDeps: Failed to build ${ARG_NAME}: ${ERR}")
    endif()
  endif()

  set(${ARG_NAME}_BUILD_DIR "${BUILD_DIR}" PARENT_SCOPE)
endfunction()

# Installs an external package after building it from downloaded source code.
#
# cdeps_install_package(
#   <git_url> [NAME <name>] [GIT_TAG <tag>] [OPTIONS <options>...])
#
# This function installs an external package named `<name>` after building it
# with `<options>` from source code downloaded from the given `<git_url>` with
# a specific `<tag>`.
#
# See also the documentation of the `cdeps_download_package` and
# `cdeps_build_package` functions.
function(cdeps_install_package GIT_URL)
  cmake_parse_arguments(PARSE_ARGV 1 ARG "" "NAME" "")

  cdeps_build_package("${GIT_URL}" NAME "${ARG_NAME}" ${ARG_UNPARSED_ARGUMENTS})

  # Set the default CDEPS_ROOT directory if not provided.
  if(NOT CDEPS_ROOT)
    set(CDEPS_ROOT ${CMAKE_SOURCE_DIR}/.cdeps)
  endif()

  # Check if the installation directory exists; if not, install the package.
  set(INSTALL_DIR ${CDEPS_ROOT}/${ARG_NAME}-install)
  if(NOT EXISTS "${INSTALL_DIR}")
    message(STATUS "CDeps: Installing ${ARG_NAME}")
    execute_process(
      COMMAND "${CMAKE_COMMAND}" --install "${${ARG_NAME}_BUILD_DIR}"
        --prefix "${INSTALL_DIR}"
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
    )
    if(NOT "${RES}" EQUAL 0)
      message(FATAL_ERROR "CDeps: Failed to install ${ARG_NAME}: ${ERR}")
    endif()
  endif()

  # Update CMAKE_PREFIX_PATH if the installed package provides CMake configuration files.
  if(IS_DIRECTORY ${INSTALL_DIR}/lib/cmake)
    set(CMAKE_PREFIX_PATH "${INSTALL_DIR}/lib/cmake;${CMAKE_PREFIX_PATH}" PARENT_SCOPE)
  endif()
endfunction()
