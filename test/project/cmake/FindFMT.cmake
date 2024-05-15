find_package(FMT QUIET CONFIG NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH)
if(FMT_FOUND)
  message(FATAL_ERROR "should not use the FMT library from the system")
endif()

include(CDeps)
cdeps_install_package(
  NAME FMT
  GIT_URL https://github.com/fmtlib/fmt
  GIT_TAG 10.2.1
  OPTIONS FMT_MASTER_PROJECT=OFF
)

find_package(FMT REQUIRED CONFIG NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH)
