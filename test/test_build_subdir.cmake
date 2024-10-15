cmake_minimum_required(VERSION 3.21)

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CDeps.cmake)

set(CDEPS_DIR .cdeps)
file(REMOVE_RECURSE .cdeps)

file(WRITE .cdeps/pkg/src/CMakeLists.txt
  "cmake_minimum_required(VERSION 3.5)\n"
  "project(pkg LANGUAGES NONE)\n"
  "set(PROJECT_NAME \"root\" CACHE STRING \"\")\n")

file(WRITE .cdeps/pkg/src/subdir/CMakeLists.txt
  "cmake_minimum_required(VERSION 3.5)\n"
  "project(pkg LANGUAGES NONE)\n"
  "set(PROJECT_NAME \"subdir\" CACHE STRING \"\")\n")

file(WRITE .cdeps/pkg/src.lock "pkg github.com/user/pkg main")

section("it should build a package located in the root directory")
  cdeps_build_package(pkg)

  section("it should generate the lock file")
    file(READ .cdeps/pkg/build.lock CONTENT)
    assert(CONTENT MATCHES [^SOURCE_SUBDIR])
  endsection()

  section("it should build the correct project")
    assert_execute_process(
      COMMAND ${CMAKE_COMMAND} -L -N .cdeps/pkg/build
      OUTPUT "PROJECT_NAME:STRING=root")
  endsection()
endsection()

section("it should build a package located in a subdirectory")
  cdeps_build_package(pkg SOURCE_SUBDIR subdir)

  section("it should regenerate the lock file")
    file(READ .cdeps/pkg/build.lock CONTENT)
    assert(CONTENT MATCHES "SOURCE_SUBDIR subdir$")
  endsection()

  section("it should rebuild the correct project")
    assert_execute_process(
      COMMAND ${CMAKE_COMMAND} -L -N .cdeps/pkg/build
      OUTPUT "PROJECT_NAME:STRING=subdir")
  endsection()
endsection()

file(REMOVE_RECURSE .cdeps)
