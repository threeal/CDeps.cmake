include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CDeps.cmake)

find_package(Git REQUIRED QUIET)

set(CDEPS_DIR .cdeps)
file(REMOVE_RECURSE .cdeps)

section("it should download a package")
  cdeps_download_package(pkg github.com/threeal/project-starter v1.0.0)

  section("it should output the source directory variable")
    assert(DEFINED pkg_SOURCE_DIR)
    assert(pkg_SOURCE_DIR STREQUAL .cdeps/pkg/src)
  endsection()

  section("it should generate the lock file")
    file(READ .cdeps/pkg/src.lock CONTENT)
    assert(CONTENT STREQUAL "pkg github.com/threeal/project-starter v1.0.0")
  endsection()

  section("it should download to the source directory")
    assert_execute_process(
      COMMAND ${GIT_EXECUTABLE} -C .cdeps/pkg/src status)
  endsection()

  section("it should download only the latest change")
    assert_execute_process(
      COMMAND ${GIT_EXECUTABLE} -C .cdeps/pkg/src rev-list --count HEAD
      OUTPUT 1)
  endsection()
endsection()

section("it should not redownload the package")
  block()
    set(GIT_EXECUTABLE invalid)
    cdeps_download_package(pkg github.com/threeal/project-starter v1.0.0)
  endblock()

  section("it should maintain the lock file")
    file(READ .cdeps/pkg/src.lock CONTENT)
    assert(CONTENT STREQUAL "pkg github.com/threeal/project-starter v1.0.0")
  endsection()

  section("it should maintain the source directory")
    assert_execute_process(COMMAND ${GIT_EXECUTABLE} -C .cdeps/pkg/src status)
  endsection()
endsection()

section("it should redownload the package because of an invalidated lock file")
  file(REMOVE_RECURSE .cdeps/pkg/src)
  file(APPEND .cdeps/pkg/src.lock " invalidated")

  cdeps_download_package(pkg github.com/threeal/project-starter v1.0.0)

  section("it should regenerate the lock file")
    file(READ .cdeps/pkg/src.lock CONTENT)
    assert(CONTENT STREQUAL "pkg github.com/threeal/project-starter v1.0.0")
  endsection()

  section("it should redownload to the source directory")
    assert_execute_process(COMMAND ${GIT_EXECUTABLE} -C .cdeps/pkg/src status)
  endsection()
endsection()

section("it should fail to redownload the package because of an invalid URL")
  assert_fatal_error(
    CALL cdeps_download_package pkg invalid.com invalid
    MESSAGE "CDeps: Failed to execute process:")

  section("it should remove the lock file")
    assert(NOT EXISTS .cdeps/pkg/src.lock)
  endsection()

  section("it should remove the source directory")
    assert(NOT EXISTS .cdeps/pkg/src)
  endsection()
endsection()

section("it should redownload the package after a failure")
  cdeps_download_package(pkg github.com/threeal/project-starter v1.0.0)

  section("it should regenerate the lock file")
    file(READ .cdeps/pkg/src.lock CONTENT)
    assert(CONTENT STREQUAL "pkg github.com/threeal/project-starter v1.0.0")
  endsection()

  section("it should redownload to the source directory")
    assert_execute_process(COMMAND ${GIT_EXECUTABLE} -C .cdeps/pkg/src status)
  endsection()
endsection()

file(REMOVE_RECURSE .cdeps)
