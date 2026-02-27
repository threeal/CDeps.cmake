# CDeps.cmake

Download, build, and install missing dependencies in [CMake](https://cmake.org/) projects.

The [`CDeps.cmake`](./cmake/CDeps.cmake) module allows CMake projects to make their external dependencies available during the build process, preventing the user from manually building and installing dependencies, and ensuring that the project uses the correct version of the specified dependencies.

This module provides the following commands to manage dependencies in CMake projects:

- [`cdeps_download_package`](#cdeps_download_package): Downloads the source files of a dependency using [Git](https://git-scm.com/).
- [`cdeps_build_package`](#cdeps_build_package): Builds a dependency using CMake.
- [`cdeps_install_package`](#cdeps_install_package): Installs the targets of a dependency using CMake.

These commands enable a dependency to be downloaded, built, and installed as necessary. When combined with a [find package module](https://cmake.org/cmake/help/book/mastering-cmake/chapter/Finding%20Packages.html), they can serve as a fallback if the dependency is not already available in the system.

## Key Features

* Download dependencies using [Git](https://git-scm.com/).
* Build and install dependencies using CMake.
* Simple syntax and easy integration.

## Usage Guide

### Module Integration

The recommended way to integrate this module into a CMake project is by downloading it using the [`file(DOWNLOAD)`](https://cmake.org/cmake/help/latest/command/file.html#download) command:

```cmake
file(
  DOWNLOAD https://github.com/threeal/CDeps.cmake/releases/download/v0.1.0/CDeps.cmake
    ${CMAKE_BINARY_DIR}/cmake/CDeps.cmake
  EXPECTED_MD5 a9d1c7002227a12f9614dddf9336e3dd)

include(${CMAKE_BINARY_DIR}/cmake/CDeps.cmake)
```

Alternatively, for offline use, this module can be vendored directly into a project and included normally using the [`include`](https://cmake.org/cmake/help/latest/command/include.html) command.

### Download, Build, and Install Dependencies

The following commands provide the basic functionality for downloading, building, and installing dependencies in a CMake project:

```cmake
cdeps_download_package(<name> <url> <ref>)
cdeps_build_package(<name>)
cdeps_install_package(<name>)
```

For example, the following commands will download, build, and install the [{fmt}](https://github.com/fmtlib/fmt) library, making it available in the project and accessible via the [`find_package`](https://cmake.org/cmake/help/latest/command/find_package.html) command:

```cmake
cdeps_download_package(FMT github.com/fmtlib/fmt 11.0.2)
cdeps_build_package(FMT)
cdeps_install_package(FMT)

find_package(FMT 11.0.2 CONFIG PATHS ${FMT_INSTALL_DIR}/lib/cmake)
```

### Find Module Integration

If used within a find package module, this module can provide dependencies as a fallback if they are not already available on the system. This allows the project to support offline use (if the package is already installed), while also enabling it to fetch missing dependencies from the internet.

For example, the following commands allow the {fmt} library to be fetched only if it is not already available in the system:

```cmake
# FindFMT.cmake

include(CDeps)
cdeps_download_package(FMT github.com/fmtlib/fmt ${FMT_FIND_VERSION})
cdeps_build_package(FMT)
cdeps_install_package(FMT)

include(CMakeFindDependencyMacro)
find_dependency(FMT CONFIG PATHS ${FMT_INSTALL_DIR}/lib/cmake NO_DEFAULT_PATH)
```

In the `CMakeLists.txt` file, you can use the `find_package` command as usual. This will attempt to locate the package on the system first, and if it is not available, it will fetch and make it available for the project:

```cmake
# CMakeLists.txt

cmake_minimum_required(VERSION 3.15)

# Required to prioritize package config files in `find_package` searches.
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG ON)

find_package(FMT 11.0.2 REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE fmt::fmt)
```

## API Reference

### `CDEPS_VERSION`

This variable specifies the version of the included `CDeps.cmake` module.

### `CDEPS_DIR`

This variable specifies the directory used by CDeps to store packages. Modify this variable to specify a different directory for storing packages.

### `cdeps_download_package`

Downloads the source files of an external package.

```cmake
cdeps_download_package(<name> <url> <ref> [RECURSE_SUBMODULES])
```

This function downloads the source files of an external package named `<name>` using Git. It retrieves the source files from the specified `<url>` with a particular `<ref>`. The `<url>` must be specified without a protocol (e.g., `github.com/user/repo`), while the `<ref>` can be a branch, tag, or commit hash.

If the `RECURSE_SUBMODULES` option is specified, the external package will be downloaded along with its submodules recursively.

This function outputs the `<name>_SOURCE_DIR` variable, which contains the path to the downloaded source files of the external package.

### `cdeps_build_package`

Builds an external package.

```cmake
cdeps_build_package(
  <name>
  [SOURCE_SUBDIR <subdir>]
  [GENERATOR <generator>]
  [OPTIONS <options>...])
```

This function builds an external package named `<name>` with the specified options. If the package is already built, it does nothing. The `<name>` package must be downloaded before calling this function.

If the `SOURCE_SUBDIR` option is specified, the package will be built from the CMake project located in the `<subdir>` directory, relative to the downloaded package source directory.

If the `CDEPS_BUILD_GENERATOR` variable is defined, the package will be built using the build system generator specified in the variable. If the `GENERATOR` option is specified, the build system generator provided in `<generator>` will be used instead, overriding the variable.

If the `CDEPS_BUILD_OPTIONS` list variable is defined, additional variables in each list entry will be used for building the package. Each entry must be in the format `NAME=VALUE`, where `NAME` is the variable name and `VALUE` is the variable value. If the `OPTIONS` option is specified, additional variables provided in `<options>...` will also be used. Any variable defined in `<options>...` will override the corresponding variable defined in the `CDEPS_BUILD_OPTIONS` variable.

This function outputs the `<name>_BUILD_DIR` variable, which contains the path to the built external package.

### `cdeps_install_package`

Installs an external package.

```cmake
cdeps_install_package(<name>)
```

This function installs an external package named `<name>`. If the package is already installed, it does nothing. The `<name>` package must already be built before calling this function.

This function outputs the `<name>_INSTALL_DIR` variable, which contains the path to the installed external package.

## License

This project is licensed under the terms of the [MIT License](./LICENSE).

Copyright © 2024-2026 [Alfi Maulana](https://github.com/threeal)
