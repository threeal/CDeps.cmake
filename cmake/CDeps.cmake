# This code is licensed under the terms of the MIT License.
# Copyright (c) 2024 Alfi Maulana

include_guard(GLOBAL)

# Retrieves the path of a package directory.
#
# cdeps_get_package_dir(<name> <output_dir>)
#
# This function retrieves the directory path of a package named `<name>` and
# stores it in the `<output_dir>` variable.
#
# If the `CDEPS_ROOT` variable is defined, it will locate the package directory
# under that variable. Otherwise, it will locate the package directory under the
# `.cdeps` directory of the project's source directory.
function(cdeps_get_package_dir NAME OUTPUT_DIR)
  if(DEFINED CDEPS_ROOT)
    set("${OUTPUT_DIR}" ${CDEPS_ROOT}/${NAME} PARENT_SCOPE)
  else()
    set("${OUTPUT_DIR}" ${CMAKE_SOURCE_DIR}/.cdeps/${NAME} PARENT_SCOPE)
  endif()
endfunction()

# Resolves the given package URL to a valid URL.
#
# cdeps_resolve_package_url(<url> <output_url>)
#
# This function resolves the given `<url>` to a valid URL and outputs it to the
# `<output_url>` variable.
function(cdeps_resolve_package_url URL OUTPUT_URL)
  if(URL MATCHES ".*://")
    set("${OUTPUT_URL}" "${URL}" PARENT_SCOPE)
  else()
    set("${OUTPUT_URL}" https://${URL} PARENT_SCOPE)
  endif()
endfunction()

# Downloads the source code of an external package.
#
# cdeps_download_package(<url> [NAME <name>] [GIT_TAG <tag>])
#
# This function downloads the source code of an external package using Git.
# It downloads the source code from the given `<url>` with a specific `<tag>`
# and saves it as the `<name>` package.
#
# This function outputs the `<name>_SOURCE_DIR` variable, which contains the
# path of the downloaded source code of the external package.
function(cdeps_download_package URL)
  cmake_parse_arguments(PARSE_ARGV 1 ARG "" "NAME;GIT_TAG" "")
  cdeps_get_package_dir("${ARG_NAME}" PACKAGE_DIR)

  # Check if the source directory exists; if not, download the package using Git.
  if(NOT EXISTS ${PACKAGE_DIR}-src)
    find_program(GIT_PROGRAM git)
    if("${GIT_PROGRAM}" STREQUAL GIT_PROGRAM-NOTFOUND)
      message(FATAL_ERROR "CDeps: Git is required to download packages")
    endif()

    cdeps_resolve_package_url("${URL}" GIT_URL)

    message(STATUS "CDeps: Downloading ${ARG_NAME} from ${GIT_URL}#${ARG_GIT_TAG}")
    execute_process(
      COMMAND git clone -b "${ARG_GIT_TAG}" "${GIT_URL}" ${PACKAGE_DIR}-src
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
    )
    if(NOT "${RES}" EQUAL 0)
      message(FATAL_ERROR "CDeps: Failed to download ${ARG_NAME}: ${ERR}")
    endif()
  endif()

  set(${ARG_NAME}_SOURCE_DIR ${PACKAGE_DIR}-src PARENT_SCOPE)
endfunction()

# Builds an external package from downloaded source code.
#
# cdeps_build_package(
#   <url> [NAME <name>] [GIT_TAG <tag>] [OPTIONS <options>...])
#
# This function builds an external package named `<name>` with `<options>` from
# source code downloaded from the given `<url>` with a specific `<tag>`.
#
# This function outputs the `<name>_BUILD_DIR` variable, which contains the
# path of the built external package.
#
# See also the documentation of the `cdeps_download_package` function.
function(cdeps_build_package URL)
  cmake_parse_arguments(PARSE_ARGV 1 ARG "" "NAME" OPTIONS)
  cdeps_get_package_dir("${ARG_NAME}" PACKAGE_DIR)

  cdeps_download_package(
    "${URL}" NAME "${ARG_NAME}" ${ARG_UNPARSED_ARGUMENTS})

  # Check if the build directory exists; if not, configure and build the package.
  if(NOT EXISTS ${PACKAGE_DIR}-build)
    message(STATUS "CDeps: Configuring ${ARG_NAME}")
    foreach(OPTION ${ARG_OPTIONS})
      list(APPEND CONFIGURE_ARGS -D "${OPTION}")
    endforeach()
    execute_process(
      COMMAND "${CMAKE_COMMAND}" -B ${PACKAGE_DIR}-build ${CONFIGURE_ARGS}
        "${${ARG_NAME}_SOURCE_DIR}"
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
    )
    if(NOT "${RES}" EQUAL 0)
      message(FATAL_ERROR "CDeps: Failed to configure ${ARG_NAME}: ${ERR}")
    endif()

    message(STATUS "CDeps: Building ${ARG_NAME}")
    execute_process(
      COMMAND "${CMAKE_COMMAND}" --build ${PACKAGE_DIR}-build
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
    )
    if(NOT "${RES}" EQUAL 0)
      message(FATAL_ERROR "CDeps: Failed to build ${ARG_NAME}: ${ERR}")
    endif()
  endif()

  set(${ARG_NAME}_BUILD_DIR ${PACKAGE_DIR}-build PARENT_SCOPE)
endfunction()

# Installs an external package after building it from downloaded source code.
#
# cdeps_install_package(
#   <url> [NAME <name>] [GIT_TAG <tag>] [OPTIONS <options>...])
#
# This function installs an external package named `<name>` after building it
# with `<options>` from source code downloaded from the given `<url>` with
# a specific `<tag>`.
#
# See also the documentation of the `cdeps_download_package` and
# `cdeps_build_package` functions.
function(cdeps_install_package URL)
  cmake_parse_arguments(PARSE_ARGV 1 ARG "" "NAME" "")
  cdeps_get_package_dir("${ARG_NAME}" PACKAGE_DIR)

  cdeps_build_package("${URL}" NAME "${ARG_NAME}" ${ARG_UNPARSED_ARGUMENTS})

  # Check if the installation directory exists; if not, install the package.
  if(NOT EXISTS ${PACKAGE_DIR}-install)
    message(STATUS "CDeps: Installing ${ARG_NAME}")
    execute_process(
      COMMAND "${CMAKE_COMMAND}" --install "${${ARG_NAME}_BUILD_DIR}"
        --prefix ${PACKAGE_DIR}-install
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
    )
    if(NOT "${RES}" EQUAL 0)
      message(FATAL_ERROR "CDeps: Failed to install ${ARG_NAME}: ${ERR}")
    endif()
  endif()

  # Update the prefix path if the installed package provides a CMake directory.
  if(IS_DIRECTORY ${PACKAGE_DIR}-install/lib/cmake)
    list(PREPEND CMAKE_PREFIX_PATH "${PACKAGE_DIR}-install/lib/cmake")
    set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} PARENT_SCOPE)
  endif()
endfunction()
