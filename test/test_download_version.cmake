include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CDeps.cmake)

find_package(Git REQUIRED QUIET)

set(CDEPS_ROOT .cdeps)
file(REMOVE_RECURSE .cdeps)

section("it should download a package with a specific version")
  cdeps_download_package(pkg github.com/threeal/project-starter v1.0.0)

  section("it should generate the lock file")
    file(READ .cdeps/pkg/src.lock CONTENT)
    assert(CONTENT MATCHES v1.0.0$)
  endsection()

  section("it should download with the correct version")
    assert_execute_process(
      COMMAND ${GIT_EXECUTABLE} -C .cdeps/pkg/src
        describe --exact-match --tags v1.0.0
      OUTPUT v1.0.0)
  endsection()
endsection()

section("it should redownload the package with a different version")
  cdeps_download_package(pkg github.com/threeal/project-starter v1.1.0)

  section("it should regenerate the lock file")
    file(READ .cdeps/pkg/src.lock CONTENT)
    assert(CONTENT MATCHES v1.1.0$)
  endsection()

  section("it should redownload with the correct version")
    assert_execute_process(
      COMMAND ${GIT_EXECUTABLE} -C .cdeps/pkg/src
        describe --exact-match --tags v1.1.0
      OUTPUT v1.1.0)
  endsection()
endsection()

file(REMOVE_RECURSE .cdeps)
