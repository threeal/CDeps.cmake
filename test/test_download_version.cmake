cmake_minimum_required(VERSION 3.21)

find_package(Git REQUIRED QUIET)

include(Assertion)
include(CDeps)

set(CDEPS_DIR .cdeps)
file(REMOVE_RECURSE .cdeps)

section("it should download a package with a specific branch name")
  cdeps_download_package(pkg github.com/threeal/project-starter main)

  section("it should generate the lock file")
    file(READ .cdeps/pkg/src.lock CONTENT)
    assert(CONTENT MATCHES main$)
  endsection()

  section("it should download with the correct branch name")
    assert_execute_process(
      COMMAND ${GIT_EXECUTABLE} -C .cdeps/pkg/src rev-parse --abbrev-ref HEAD
      EXPECT_OUTPUT main)
  endsection()
endsection()

section("it should redownload the package with a specific tag name")
  cdeps_download_package(pkg github.com/threeal/project-starter v1.0.0)

  section("it should regenerate the lock file")
    file(READ .cdeps/pkg/src.lock CONTENT)
    assert(CONTENT MATCHES v1.0.0$)
  endsection()

  section("it should redownload with the correct tag name")
    assert_execute_process(
      COMMAND ${GIT_EXECUTABLE} -C .cdeps/pkg/src
        describe --exact-match --tags v1.0.0
      EXPECT_OUTPUT STREQUAL v1.0.0)
  endsection()
endsection()

section("it should redownload the package with a specific commit hash")
  cdeps_download_package(pkg github.com/threeal/project-starter
    ad2c03959cb67fffc7cce7266bc244c73a2af8ec)

  section("it should regenerate the lock file")
    file(READ .cdeps/pkg/src.lock CONTENT)
    assert(CONTENT MATCHES ad2c03959cb67fffc7cce7266bc244c73a2af8ec$)
  endsection()

  section("it should redownload with the correct commit hash")
    assert_execute_process(
      COMMAND ${GIT_EXECUTABLE} -C .cdeps/pkg/src rev-parse HEAD
      EXPECT_OUTPUT STREQUAL ad2c03959cb67fffc7cce7266bc244c73a2af8ec)
  endsection()
endsection()

file(REMOVE_RECURSE .cdeps)
