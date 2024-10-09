cmake_minimum_required(VERSION 3.21)

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CDeps.cmake)

set(CDEPS_ROOT .cdeps)
file(REMOVE_RECURSE .cdeps)

file(WRITE .cdeps/pkg/src/CMakeLists.txt
  "cmake_minimum_required(VERSION 3.5)\n"
  "project(pkg LANGUAGES NONE)\n"
  "set(BUILD_TYPE \"\${CMAKE_BUILD_TYPE}\" CACHE STRING \"\" FORCE)\n")

file(WRITE .cdeps/pkg/src.lock "pkg github.com/user/pkg main")

section("it should build a package without a build type specified")
  cdeps_build_package(pkg)

  section("it should generate the lock file")
    file(READ .cdeps/pkg/build.lock CONTENT)
    assert(CONTENT MATCHES [^OPTIONS])
  endsection()
endsection()

section("it should rebuild the package with the main project build type")
  block()
    set(CMAKE_BUILD_TYPE Release)
    cdeps_build_package(pkg)
  endblock()

  section("it should regenerate the lock file")
    file(READ .cdeps/pkg/build.lock CONTENT)
    assert(CONTENT MATCHES "OPTIONS CMAKE_BUILD_TYPE=Release$")
  endsection()

  section("it should rebuild with the correct build type")
    assert_execute_process(
      COMMAND ${CMAKE_COMMAND} -L -N .cdeps/pkg/build
      OUTPUT "BUILD_TYPE:STRING=Release")
  endsection()
endsection()

section("it should rebuild the package with the specified build type")
  block()
    set(CMAKE_BUILD_TYPE Release)
    cdeps_build_package(pkg OPTIONS CMAKE_BUILD_TYPE=RelWithDebInfo)
  endblock()

  section("it should regenerate the lock file")
    file(READ .cdeps/pkg/build.lock CONTENT)
    assert(CONTENT MATCHES "OPTIONS CMAKE_BUILD_TYPE=RelWithDebInfo$")
  endsection()

  section("it should rebuild with the correct build type")
    assert_execute_process(
      COMMAND ${CMAKE_COMMAND} -L -N .cdeps/pkg/build
      OUTPUT "BUILD_TYPE:STRING=RelWithDebInfo")
  endsection()
endsection()
