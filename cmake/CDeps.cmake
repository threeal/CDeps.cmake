# This code is licensed under the terms of the MIT License.
# Copyright (c) 2024 Alfi Maulana

include_guard(GLOBAL)

# Retrieves the path of a package directory.
#
# cdeps_get_package_dir(<url> <output_dir>)
#
# This function retrieves the directory path of a package with `<url>` and
# stores it in the `<output_dir>` variable.
#
# If the `CDEPS_ROOT` variable is defined, it will locate the package directory
# under that variable. Otherwise, it will locate the package directory under the
# `.cdeps` directory of the project's source directory.
function(cdeps_get_package_dir URL OUTPUT_DIR)
  string(REGEX REPLACE .*:// "" DIR "${URL}")
  if(DEFINED CDEPS_ROOT)
    set("${OUTPUT_DIR}" ${CDEPS_ROOT}/${DIR} PARENT_SCOPE)
  else()
    set("${OUTPUT_DIR}" ${CMAKE_SOURCE_DIR}/.cdeps/${DIR} PARENT_SCOPE)
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
# cdeps_download_package(<url> [GIT_TAG <tag>])
#
# This function downloads the source code of an external package using Git.
# It downloads the source code from the given `<url>` with a specific `<tag>`.
#
# This function outputs the `<url>_SOURCE_DIR` variable, which contains the
# path of the downloaded source code of the external package.
function(cdeps_download_package URL)
  cmake_parse_arguments(PARSE_ARGV 1 ARG "" "GIT_TAG" "")
  cdeps_get_package_dir("${URL}" PACKAGE_DIR)

  # Check if the source directory exists; if not, download the package using Git.
  if(NOT EXISTS ${PACKAGE_DIR}-src)
    if(NOT DEFINED GIT_EXECUTABLE)
      find_package(Git)
      if(NOT Git_FOUND OR NOT DEFINED GIT_EXECUTABLE)
        message(FATAL_ERROR "CDeps: Git is required to download packages")
        return()
      endif()
    endif()

    cdeps_resolve_package_url("${URL}" GIT_URL)

    message(STATUS "CDeps: Downloading ${URL} from ${GIT_URL}#${ARG_GIT_TAG}")
    execute_process(
      COMMAND "${GIT_EXECUTABLE}" clone -b "${ARG_GIT_TAG}" "${GIT_URL}"
        ${PACKAGE_DIR}-src
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
    )
    if(NOT "${RES}" EQUAL 0)
      file(REMOVE_RECURSE ${PACKAGE_DIR}-src)
      message(FATAL_ERROR "CDeps: Failed to download ${URL}: ${ERR}")
      return()
    endif()
  endif()

  set(${URL}_SOURCE_DIR ${PACKAGE_DIR}-src PARENT_SCOPE)
endfunction()

# Builds an external package from downloaded source code.
#
# cdeps_build_package(<url> [GIT_TAG <tag>] [OPTIONS <options>...])
#
# This function builds an external package with `<options>` from source code
# downloaded from the given `<url>` with a specific `<tag>`.
#
# This function outputs the `<url>_BUILD_DIR` variable, which contains the
# path of the built external package.
#
# See also the documentation of the `cdeps_download_package` function.
function(cdeps_build_package URL)
  cmake_parse_arguments(PARSE_ARGV 1 ARG "" "" OPTIONS)
  cdeps_get_package_dir("${URL}" PACKAGE_DIR)

  cdeps_download_package("${URL}" ${ARG_UNPARSED_ARGUMENTS})

  # Check if the build directory exists; if not, configure and build the package.
  if(NOT EXISTS ${PACKAGE_DIR}-build)
    message(STATUS "CDeps: Configuring ${URL}")
    foreach(OPTION ${ARG_OPTIONS})
      list(APPEND CONFIGURE_ARGS -D "${OPTION}")
    endforeach()
    execute_process(
      COMMAND "${CMAKE_COMMAND}" -B ${PACKAGE_DIR}-build ${CONFIGURE_ARGS}
        "${${URL}_SOURCE_DIR}"
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
    )
    if(NOT "${RES}" EQUAL 0)
      file(REMOVE_RECURSE ${PACKAGE_DIR}-build)
      message(FATAL_ERROR "CDeps: Failed to configure ${URL}: ${ERR}")
      return()
    endif()

    message(STATUS "CDeps: Building ${URL}")
    execute_process(
      COMMAND "${CMAKE_COMMAND}" --build ${PACKAGE_DIR}-build
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
    )
    if(NOT "${RES}" EQUAL 0)
      file(REMOVE_RECURSE ${PACKAGE_DIR}-build)
      message(FATAL_ERROR "CDeps: Failed to build ${URL}: ${ERR}")
      return()
    endif()
  endif()

  set(${URL}_BUILD_DIR ${PACKAGE_DIR}-build PARENT_SCOPE)
endfunction()

# Installs an external package after building it from downloaded source code.
#
# cdeps_install_package(<url> [GIT_TAG <tag>] [OPTIONS <options>...])
#
# This function installs an external package after building it with `<options>`
# from source code downloaded from the given `<url>` with a specific `<tag>`.
#
# See also the documentation of the `cdeps_download_package` and
# `cdeps_build_package` functions.
function(cdeps_install_package URL)
  cmake_parse_arguments(PARSE_ARGV 1 ARG "" "" "")
  cdeps_get_package_dir("${URL}" PACKAGE_DIR)

  cdeps_build_package("${URL}" ${ARG_UNPARSED_ARGUMENTS})

  # Check if the installation directory exists; if not, install the package.
  if(NOT EXISTS ${PACKAGE_DIR}-install)
    message(STATUS "CDeps: Installing ${URL}")
    execute_process(
      COMMAND "${CMAKE_COMMAND}" --install "${${URL}_BUILD_DIR}"
        --prefix ${PACKAGE_DIR}-install
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
    )
    if(NOT "${RES}" EQUAL 0)
      file(REMOVE_RECURSE ${PACKAGE_DIR}-install)
      message(FATAL_ERROR "CDeps: Failed to install ${URL}: ${ERR}")
      return()
    endif()
  endif()

  # Update the prefix path if the installed package provides a CMake directory.
  if(IS_DIRECTORY ${PACKAGE_DIR}-install/lib/cmake)
    list(PREPEND CMAKE_PREFIX_PATH "${PACKAGE_DIR}-install/lib/cmake")
    set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} PARENT_SCOPE)
  endif()
endfunction()

function(cdeps_declare_package NAME)
  function(cdeps_provide_dependency METHOD NAME)
    if(DEFINED CDEPS_${NAME}_DECLARED_OPTIONS)
      cmake_parse_arguments(PARSE_ARGV 2 ARG "" "" "")
      cdeps_install_package(${CDEPS_${NAME}_DECLARED_OPTIONS})
      find_package("${NAME}" ${ARG_UNPARSED_ARGUMENTS} BYPASS_PROVIDER)
    endif()
  endfunction()

  cmake_language(
    SET_DEPENDENCY_PROVIDER cdeps_provide_dependency
    SUPPORTED_METHODS FIND_PACKAGE)

  cmake_parse_arguments(PARSE_ARGV 1 ARG "" "" "")
  set(CDEPS_${NAME}_DECLARED_OPTIONS ${ARG_UNPARSED_ARGUMENTS} PARENT_SCOPE)
endfunction()
