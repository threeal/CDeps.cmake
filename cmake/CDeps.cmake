# MIT License
#
# Copyright (c) 2024 Alfi Maulana
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# This variable specifies the version of the included `CDeps.cmake` module.
set(CDEPS_VERSION 0.1.0)

# This variable specifies the directory used by CDeps to store packages.
# Modify this variable to specify a different directory for storing packages.
if(NOT DEFINED CDEPS_DIR)
  set(CDEPS_DIR ${CMAKE_SOURCE_DIR}/.cdeps)
endif()

# Downloads the source files of an external package.
#
# cdeps_download_package(<name> <url> <ref> [RECURSE_SUBMODULES])
#
# This function downloads the source files of an external package named `<name>`
# using Git. It retrieves the source files from the specified `<url>` with a
# particular `<ref>`. The `<url>` must be specified without a protocol (e.g.,
# `github.com/user/repo`), while the `<ref>` can be a branch, tag, or commit
# hash.
#
# If the `RECURSE_SUBMODULES` option is specified, the external package will be
# downloaded along with its submodules recursively.
#
# This function outputs the `<name>_SOURCE_DIR` variable, which contains the
# path to the downloaded source files of the external package.
function(cdeps_download_package NAME URL REF)
  cmake_parse_arguments(PARSE_ARGV 3 ARG RECURSE_SUBMODULES "" "")

  set(SOURCE_LOCK "${NAME} ${URL} ${REF}")
  if(ARG_RECURSE_SUBMODULES)
    string(APPEND SOURCE_LOCK " RECURSE_SUBMODULES")
  endif()

  # Check if the lock file is valid; redownload the source files if it isn't.
  if(EXISTS ${CDEPS_DIR}/${NAME}/src.lock)
    file(READ ${CDEPS_DIR}/${NAME}/src.lock LOCK)
    if(LOCK STREQUAL SOURCE_LOCK)
      message(STATUS "CDeps: Using existing ${NAME} download")
      set(${NAME}_SOURCE_DIR ${CDEPS_DIR}/${NAME}/src PARENT_SCOPE)
      return()
    else()
      file(REMOVE ${CDEPS_DIR}/${NAME}/src.lock)
    endif()
  endif()

  message(STATUS "CDeps: Downloading ${NAME}")
  file(REMOVE_RECURSE ${CDEPS_DIR}/${NAME}/src)
  file(MAKE_DIRECTORY ${CDEPS_DIR}/${NAME}/src)

  if(NOT DEFINED GIT_EXECUTABLE)
    find_package(Git)
    if(NOT Git_FOUND OR NOT DEFINED GIT_EXECUTABLE)
      message(FATAL_ERROR "CDeps: Git is required to download packages")
      return()
    endif()
  endif()

  set(INIT_COMMAND "${GIT_EXECUTABLE}" -C ${CDEPS_DIR}/${NAME}/src init)

  set(ADD_REMOTE_COMMAND "${GIT_EXECUTABLE}" -C ${CDEPS_DIR}/${NAME}/src
    remote add origin https://${URL}.git)

  set(FETCH_COMMAND "${GIT_EXECUTABLE}" -C ${CDEPS_DIR}/${NAME}/src
    fetch --depth 1 --tags origin "${REF}")

  set(CHECKOUT_COMMAND "${GIT_EXECUTABLE}" -C ${CDEPS_DIR}/${NAME}/src
    checkout "${REF}")

  set(COMMANDS INIT_COMMAND ADD_REMOTE_COMMAND FETCH_COMMAND
    CHECKOUT_COMMAND)

  if(ARG_RECURSE_SUBMODULES)
    set(SUBMODULE_COMMAND "${GIT_EXECUTABLE}" -C ${CDEPS_DIR}/${NAME}/src
      submodule update --init --recursive)
    list(APPEND COMMANDS SUBMODULE_COMMAND)
  endif()

  foreach(COMMAND IN LISTS COMMANDS)
    execute_process(
      COMMAND ${${COMMAND}}
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
      OUTPUT_QUIET)
    if(NOT "${RES}" EQUAL 0)
      string(JOIN " " COMMAND ${${COMMAND}})
      message(FATAL_ERROR
        "CDeps: Failed to execute process:\n  ${COMMAND}\n${ERR}")
      return()
    endif()
  endforeach()

  file(WRITE ${CDEPS_DIR}/${NAME}/src.lock "${SOURCE_LOCK}")
  set(${NAME}_SOURCE_DIR ${CDEPS_DIR}/${NAME}/src PARENT_SCOPE)
endfunction()

# Builds an external package.
#
# cdeps_build_package(<name> [GENERATOR <generator>] [OPTIONS <options>...])
#
# This function builds an external package named `<name>` with the specified
# options. If the package is already built, it does nothing. The `<name>`
# package must be downloaded before calling this function.
#
# If the `CDEPS_BUILD_GENERATOR` variable is defined, the package will be built
# using the build system generator specified in the variable. If the `GENERATOR`
# option is specified, the build system generator provided in `<generator>` will
# be used instead, overriding the variable.
#
# If the `CDEPS_BUILD_OPTIONS` list variable is defined, additional variables in
# each list entry will be used for building the package. Each entry must be in
# the format `NAME=VALUE`, where `NAME` is the variable name and `VALUE` is the
# variable value. If the `OPTIONS` option is specified, additional variables
# provided in `<options>...` will also be used. Any variable defined in
# `<options>...` will override the corresponding variable defined in the
# `CDEPS_BUILD_OPTIONS` variable.
#
# This function outputs the `<name>_BUILD_DIR` variable, which contains the path
# to the built external package.
function(cdeps_build_package NAME)
  if(DEFINED CDEPS_BUILD_GENERATOR)
    set(GENERATOR "${CDEPS_BUILD_GENERATOR}")
  endif()

  if(DEFINED CDEPS_BUILD_OPTIONS)
    list(APPEND OPTIONS ${CDEPS_BUILD_OPTIONS})
  endif()

  cmake_parse_arguments(PARSE_ARGV 1 ARG "" GENERATOR OPTIONS)

  if(DEFINED ARG_GENERATOR)
    set(GENERATOR "${ARG_GENERATOR}")
  endif()

  if(DEFINED ARG_OPTIONS)
    list(APPEND OPTIONS ${ARG_OPTIONS})
  endif()

  if(NOT EXISTS ${CDEPS_DIR}/${NAME}/src.lock)
    message(FATAL_ERROR "CDeps: ${NAME} must be downloaded before building")
    return()
  endif()

  file(READ ${CDEPS_DIR}/${NAME}/src.lock SOURCE_LOCK)
  set(BUILD_LOCK "${SOURCE_LOCK}")
  if(DEFINED GENERATOR)
    string(APPEND BUILD_LOCK " GENERATOR ${GENERATOR}")
  endif()
  if(DEFINED OPTIONS)
    string(JOIN " " OPTIONS_STR ${OPTIONS})
    string(APPEND BUILD_LOCK " OPTIONS ${OPTIONS_STR}")
  endif()

  # Check if the lock file is valid; rebuild the package if it isn't.
  if(EXISTS ${CDEPS_DIR}/${NAME}/build.lock)
    file(READ ${CDEPS_DIR}/${NAME}/build.lock LOCK)
    if(LOCK STREQUAL BUILD_LOCK)
      message(STATUS "CDeps: Using existing ${NAME} build")
      set(${NAME}_BUILD_DIR ${CDEPS_DIR}/${NAME}/build PARENT_SCOPE)
      return()
    else()
      file(REMOVE ${CDEPS_DIR}/${NAME}/build.lock)
    endif()
  endif()

  message(STATUS "CDeps: Building ${NAME}")
  file(REMOVE_RECURSE ${CDEPS_DIR}/${NAME}/build)

  set(CONFIGURE_COMMAND "${CMAKE_COMMAND}")
  if(DEFINED GENERATOR)
    list(APPEND CONFIGURE_COMMAND -G "${GENERATOR}")
  endif()
  foreach(OPTION ${OPTIONS})
    list(APPEND CONFIGURE_COMMAND -D "${OPTION}")
  endforeach()
  list(APPEND CONFIGURE_COMMAND -S ${CDEPS_DIR}/${NAME}/src
    -B ${CDEPS_DIR}/${NAME}/build)

  set(BUILD_COMMAND "${CMAKE_COMMAND}" --build ${CDEPS_DIR}/${NAME}/build)

  foreach(COMMAND IN ITEMS CONFIGURE_COMMAND BUILD_COMMAND)
    execute_process(
      COMMAND ${${COMMAND}}
      ERROR_VARIABLE ERR
      RESULT_VARIABLE RES
      OUTPUT_QUIET)
    if(NOT "${RES}" EQUAL 0)
      string(JOIN " " COMMAND ${${COMMAND}})
      message(FATAL_ERROR
        "CDeps: Failed to execute process:\n  ${COMMAND}\n${ERR}")
      return()
    endif()
  endforeach()

  file(WRITE ${CDEPS_DIR}/${NAME}/build.lock "${BUILD_LOCK}")
  set(${NAME}_BUILD_DIR ${CDEPS_DIR}/${NAME}/build PARENT_SCOPE)
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
  if(NOT EXISTS ${CDEPS_DIR}/${NAME}/build.lock)
    message(FATAL_ERROR "CDeps: ${NAME} must be built before installation")
    return()
  endif()

  file(READ ${CDEPS_DIR}/${NAME}/build.lock BUILD_LOCK)
  set(INSTALL_LOCK "${BUILD_LOCK}")

  # Check if the lock file is valid; reinstall the package if it isn't.
  if(EXISTS ${CDEPS_DIR}/${NAME}/install.lock)
    file(READ ${CDEPS_DIR}/${NAME}/install.lock LOCK)
    if(LOCK STREQUAL INSTALL_LOCK)
      message(STATUS "CDeps: Using existing ${NAME} installation")
      set(${NAME}_INSTALL_DIR ${CDEPS_DIR}/${NAME}/install PARENT_SCOPE)
      return()
    else()
      file(REMOVE ${CDEPS_DIR}/${NAME}/install.lock)
    endif()
  endif()

  message(STATUS "CDeps: Installing ${NAME}")
  file(REMOVE_RECURSE ${CDEPS_DIR}/${NAME}/install)

  set(INSTALL_COMMAND "${CMAKE_COMMAND}" --install ${CDEPS_DIR}/${NAME}/build
      --prefix ${CDEPS_DIR}/${NAME}/install)

  execute_process(
    COMMAND ${INSTALL_COMMAND}
    ERROR_VARIABLE ERR
    RESULT_VARIABLE RES
    OUTPUT_QUIET)
  if(NOT "${RES}" EQUAL 0)
    string(JOIN " " COMMAND ${INSTALL_COMMAND})
    message(FATAL_ERROR
      "CDeps: Failed to execute process:\n  ${COMMAND}\n${ERR}")
    return()
  endif()

  file(WRITE ${CDEPS_DIR}/${NAME}/install.lock "${INSTALL_LOCK}")
  set(${NAME}_INSTALL_DIR ${CDEPS_DIR}/${NAME}/install PARENT_SCOPE)
endfunction()
