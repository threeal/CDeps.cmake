cmake_minimum_required(VERSION 3.21)

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CDeps.cmake)

set(CDEPS_DIR .cdeps)
file(REMOVE_RECURSE .cdeps)

file(WRITE .cdeps/pkg/src/CMakeLists.txt
  "cmake_minimum_required(VERSION 3.5)\n"
  "project(pkg LANGUAGES NONE)\n"
  "set(FIRST_OPTION \"first\" CACHE STRING \"\")\n"
  "set(SECOND_OPTION \"second\" CACHE STRING \"\")\n")

file(WRITE .cdeps/pkg/src.lock "pkg github.com/user/pkg main")

section("it should build a package without options")
  cdeps_build_package(pkg)

  section("it should generate the lock file")
    file(READ .cdeps/pkg/build.lock CONTENT)
    assert(CONTENT MATCHES [^OPTIONS])
  endsection()

  section("it should build with the correct options")
    assert_execute_process(
      COMMAND ${CMAKE_COMMAND} -L -N .cdeps/pkg/build
      OUTPUT "FIRST_OPTION:STRING=first.+SECOND_OPTION:STRING=second")
  endsection()
endsection()

section("it should rebuild the package with the specified options")
  cdeps_build_package(pkg OPTIONS FIRST_OPTION=pertama SECOND_OPTION=kedua)

  section("it should regenerate the lock file")
    file(READ .cdeps/pkg/build.lock CONTENT)
    assert(CONTENT MATCHES "OPTIONS FIRST_OPTION=pertama;SECOND_OPTION=kedua$")
  endsection()

  section("it should rebuild with the correct options")
    assert_execute_process(
      COMMAND ${CMAKE_COMMAND} -L -N .cdeps/pkg/build
      OUTPUT "FIRST_OPTION:STRING=pertama.+SECOND_OPTION:STRING=kedua")
  endsection()
endsection()

file(REMOVE_RECURSE .cdeps)
