include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CDeps.cmake)

set(CDEPS_ROOT .cdeps)
file(REMOVE_RECURSE .cdeps)

file(WRITE .cdeps/pkg/src/CMakeLists.txt
  "cmake_minimum_required(VERSION 3.5)\n"
  "project(pkg LANGUAGES NONE)\n"
  "set(GENERATOR \"\${CMAKE_GENERATOR}\" CACHE STRING \"\" FORCE)\n")

file(WRITE .cdeps/pkg/src.lock "pkg github.com/user/pkg main")

section("it should build a package with the default generator")
  cdeps_build_package(pkg)

  section("it should generate the lock file")
    file(READ .cdeps/pkg/build.lock CONTENT)
    assert(CONTENT MATCHES [^GENERATOR])
  endsection()
endsection()

section("it should fail to rebuild the package "
  "because of an invalid parent generator")
  block()
    set(CMAKE_GENERATOR invalid)
    assert_fatal_error(
      CALL cdeps_build_package pkg
      MESSAGE "CDeps: Failed to configure pkg:")
  endblock()

  section("it should remove the lock file")
    assert(NOT EXISTS .cdeps/pkg/build.lock)
  endsection()
endsection()

section("it should rebuild the package with the parent generator")
  block()
    set(CMAKE_GENERATOR "Unix Makefiles")
    cdeps_build_package(pkg)
  endblock()

  section("it should regenerate the lock file")
    file(READ .cdeps/pkg/build.lock CONTENT)
    assert(CONTENT MATCHES "GENERATOR Unix Makefiles$")
  endsection()

  section("it should rebuild with the correct generator")
    assert_execute_process(
      COMMAND ${CMAKE_COMMAND} -L -N .cdeps/pkg/build
      OUTPUT "GENERATOR:STRING=Unix Makefiles")
  endsection()
endsection()

section("it should fail to rebuild the package "
  "because of an invalid specified generator")
  block()
    assert_fatal_error(
      CALL cdeps_build_package pkg GENERATOR invalid
      MESSAGE "CDeps: Failed to configure pkg:")
  endblock()

  section("it should remove the lock file")
    assert(NOT EXISTS .cdeps/pkg/build.lock)
  endsection()
endsection()

section("it should rebuild the package with the specified generator")
  cdeps_build_package(pkg GENERATOR "Unix Makefiles")

  section("it should regenerate the lock file")
    file(READ .cdeps/pkg/build.lock CONTENT)
    assert(CONTENT MATCHES "GENERATOR Unix Makefiles$")
  endsection()

  section("it should rebuild with the correct generator")
    assert_execute_process(
      COMMAND ${CMAKE_COMMAND} -L -N .cdeps/pkg/build
      OUTPUT "GENERATOR:STRING=Unix Makefiles")
  endsection()
endsection()

file(REMOVE_RECURSE .cdeps)
