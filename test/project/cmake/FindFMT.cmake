find_package(FMT QUIET CONFIG)
if(FMT_FOUND)
  return()
endif()

include(CDeps)
cdeps_install_package(
  NAME FMT
  GIT_URL https://github.com/fmtlib/fmt
  GIT_TAG 10.2.1
)

find_package(FMT REQUIRED CONFIG)
