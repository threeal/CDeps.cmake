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

# Downloads the source files of an external package.
#
# cdeps_download_package(<name> <url> <ref>)
#
# This function downloads the source files of an external package named `<name>`
# using Git. It downloads the source files from the specified `<url>` with a
# particular `<ref>`. The `<ref>` can be a branch, tag, or commit hash.
#
# This function outputs the `<name>_SOURCE_DIR` variable, which contains the
# path to the downloaded source files of the external package.
function(cdeps_download_package NAME URL REF)
  cdeps_get_package_dir("${NAME}" PACKAGE_DIR)

  set(SOURCE_LOCK "${NAME} ${URL} ${REF}")

  # Check if the lock file is valid; redownload the source files if it isn't.
  if(EXISTS ${PACKAGE_DIR}/src.lock)
    file(READ ${PACKAGE_DIR}/src.lock LOCK)
    if(LOCK STREQUAL SOURCE_LOCK)
      message(STATUS "CDeps: Using existing ${NAME} source files")
      set(${NAME}_SOURCE_DIR ${PACKAGE_DIR}/src PARENT_SCOPE)
      return()
    else()
      file(REMOVE ${PACKAGE_DIR}/src.lock)
      file(REMOVE_RECURSE ${PACKAGE_DIR}/src)
    endif()
  endif()

  if(NOT DEFINED GIT_EXECUTABLE)
    find_package(Git)
    if(NOT Git_FOUND OR NOT DEFINED GIT_EXECUTABLE)
      message(FATAL_ERROR "CDeps: Git is required to download packages")
      return()
    endif()
  endif()

  cdeps_resolve_package_url("${URL}" GIT_URL)

  message(STATUS "CDeps: Downloading ${NAME} from ${GIT_URL} at ${REF}")
  execute_process(
    COMMAND "${GIT_EXECUTABLE}" clone -b "${REF}" "${GIT_URL}"
      ${PACKAGE_DIR}/src
    ERROR_VARIABLE ERR
    RESULT_VARIABLE RES
    OUTPUT_QUIET
  )
  if(NOT "${RES}" EQUAL 0)
    file(REMOVE_RECURSE ${PACKAGE_DIR}/src)
    message(FATAL_ERROR "CDeps: Failed to download ${NAME}: ${ERR}")
    return()
  endif()

  file(WRITE ${PACKAGE_DIR}/src.lock "${SOURCE_LOCK}")
  set(${NAME}_SOURCE_DIR ${PACKAGE_DIR}/src PARENT_SCOPE)
endfunction()

# Builds an external package.
#
# cdeps_build_package(<name> [OPTIONS <options>...])
#
# This function builds an external package named `<name>` with `<options>`. If
# the package is already built, it does nothing. The `<name>` package must
# already be downloaded before calling this function.
#
# This function outputs the `<name>_BUILD_DIR` variable, which contains the path
# to the built external package.
function(cdeps_build_package NAME)
  cmake_parse_arguments(PARSE_ARGV 1 ARG "" "" OPTIONS)

  cdeps_get_package_dir("${NAME}" PACKAGE_DIR)
  if(NOT EXISTS ${PACKAGE_DIR}/src.lock)
    message(FATAL_ERROR "CDeps: ${NAME} must be downloaded before building")
    return()
  endif()

  file(READ ${PACKAGE_DIR}/src.lock SOURCE_LOCK)
  set(BUILD_LOCK "${SOURCE_LOCK}")
  if(DEFINED ARG_OPTIONS)
    string(APPEND BUILD_LOCK " OPTIONS ${ARG_OPTIONS}")
  endif()

  # Check if the lock file is valid; rebuild the package if it isn't.
  if(EXISTS ${PACKAGE_DIR}/build.lock)
    file(READ ${PACKAGE_DIR}/build.lock LOCK)
    if(LOCK STREQUAL BUILD_LOCK)
      message(STATUS "CDeps: Using existing ${NAME} build")
      set(${NAME}_BUILD_DIR ${PACKAGE_DIR}/build PARENT_SCOPE)
      return()
    else()
      file(REMOVE ${PACKAGE_DIR}/build.lock)
      file(REMOVE_RECURSE ${PACKAGE_DIR}/build)
    endif()
  endif()

  message(STATUS "CDeps: Configuring ${NAME}")
  foreach(OPTION ${ARG_OPTIONS})
    list(APPEND CONFIGURE_ARGS -D "${OPTION}")
  endforeach()
  execute_process(
    COMMAND "${CMAKE_COMMAND}" -B ${PACKAGE_DIR}/build ${CONFIGURE_ARGS}
      "${${NAME}_SOURCE_DIR}"
    ERROR_VARIABLE ERR
    RESULT_VARIABLE RES
    OUTPUT_QUIET
  )
  if(NOT "${RES}" EQUAL 0)
    file(REMOVE_RECURSE ${PACKAGE_DIR}/build)
    message(FATAL_ERROR "CDeps: Failed to configure ${NAME}: ${ERR}")
    return()
  endif()

  message(STATUS "CDeps: Building ${NAME}")
  execute_process(
    COMMAND "${CMAKE_COMMAND}" --build ${PACKAGE_DIR}/build
    ERROR_VARIABLE ERR
    RESULT_VARIABLE RES
    OUTPUT_QUIET
  )
  if(NOT "${RES}" EQUAL 0)
    file(REMOVE_RECURSE ${PACKAGE_DIR}/build)
    message(FATAL_ERROR "CDeps: Failed to build ${NAME}: ${ERR}")
    return()
  endif()

  file(WRITE ${PACKAGE_DIR}/build.lock "${BUILD_LOCK}")
  set(${NAME}_BUILD_DIR ${PACKAGE_DIR}/build PARENT_SCOPE)
endfunction()

# Installs an external package.
#
# cdeps_install_package(<name>)
#
# This function installs an external package named `<name>`. If the package is
# already installed, it does nothing. The `<name>` package must already be built
# before calling this function.
#
# This function outputs the `<name>_INSTALL_DIR` variable, which contains the
# path to the installed external package.
function(cdeps_install_package NAME)
  cdeps_get_package_dir("${NAME}" PACKAGE_DIR)
  if(NOT EXISTS ${PACKAGE_DIR}/build.lock)
    message(FATAL_ERROR "CDeps: ${NAME} must be built before installation")
    return()
  endif()

  file(READ ${PACKAGE_DIR}/build.lock BUILD_LOCK)
  set(INSTALL_LOCK "${BUILD_LOCK}")

  # Check if the lock file is valid; reinstall the package if it isn't.
  if(EXISTS ${PACKAGE_DIR}/install.lock)
    file(READ ${PACKAGE_DIR}/install.lock LOCK)
    if(LOCK STREQUAL INSTALL_LOCK)
      message(STATUS "CDeps: Using existing ${NAME} installation")
      set(${NAME}_INSTALL_DIR ${PACKAGE_DIR}/install PARENT_SCOPE)
      return()
    else()
      file(REMOVE ${PACKAGE_DIR}/install.lock)
      file(REMOVE_RECURSE ${PACKAGE_DIR}/install)
    endif()
  endif()

  message(STATUS "CDeps: Installing ${NAME}")
  execute_process(
    COMMAND "${CMAKE_COMMAND}" --install "${${NAME}_BUILD_DIR}"
      --prefix ${PACKAGE_DIR}/install
    ERROR_VARIABLE ERR
    RESULT_VARIABLE RES
    OUTPUT_QUIET
  )
  if(NOT "${RES}" EQUAL 0)
    file(REMOVE_RECURSE ${PACKAGE_DIR}/install)
    message(FATAL_ERROR "CDeps: Failed to install ${NAME}: ${ERR}")
    return()
  endif()

  file(WRITE ${PACKAGE_DIR}/install.lock "${INSTALL_LOCK}")
  set(${NAME}_INSTALL_DIR ${PACKAGE_DIR}/install PARENT_SCOPE)
endfunction()
