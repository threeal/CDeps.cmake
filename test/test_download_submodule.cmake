include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CDeps.cmake)

find_package(Git REQUIRED QUIET)

set(CDEPS_DIR .cdeps)
file(REMOVE_RECURSE .cdeps)

section("it should download a package without submodules")
  cdeps_download_package(pkg github.com/threeal/git-submodule-example v1.0.0)

  section("it should generate the lock file")
    file(READ .cdeps/pkg/src.lock CONTENT)
    assert(CONTENT MATCHES [^RECURSE_SUBMODULES]$)
  endsection()

  section("it should not download the submodules")
    assert_execute_process(
      COMMAND ${GIT_EXECUTABLE} -C .cdeps/pkg/src submodule status --recursive
      OUTPUT "^-.+ project-starter")
  endsection()
endsection()

section("it should redownload the package with submodules")
  cdeps_download_package(
    pkg github.com/threeal/git-submodule-example v1.0.0 RECURSE_SUBMODULES)

  section("it should regenerate the lock file")
    file(READ .cdeps/pkg/src.lock CONTENT)
    assert(CONTENT MATCHES RECURSE_SUBMODULES$)
  endsection()

  section("it should download the submodules")
    assert_execute_process(
      COMMAND ${GIT_EXECUTABLE} -C .cdeps/pkg/src submodule status --recursive
      OUTPUT "^ .+ project-starter")
  endsection()
endsection()

file(REMOVE_RECURSE .cdeps)
