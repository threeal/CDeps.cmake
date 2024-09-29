find_package(CDeps REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)

set(CDEPS_ROOT ${CMAKE_CURRENT_BINARY_DIR}/.cdeps)
file(REMOVE_RECURSE "${CDEPS_ROOT}")

function(test_download_external_package)
  section("it should download an external package")
    cdeps_download_package(
      ProjectStarter github.com/threeal/project-starter v1.0.0)

    section("it should download to the correct path")
      assert(DEFINED ProjectStarter_SOURCE_DIR)
      assert(EXISTS "${ProjectStarter_SOURCE_DIR}")

      cdeps_get_package_dir(ProjectStarter PACKAGE_DIR)
      assert(ProjectStarter_SOURCE_DIR STREQUAL "${PACKAGE_DIR}/src")
    endsection()

    section("it should download the correct version")
      find_package(Git REQUIRED)
      assert_execute_process(
        COMMAND ${GIT_EXECUTABLE} -C "${PACKAGE_DIR}/src" rev-parse HEAD
        OUTPUT "5a80d2080c808f588856c3191512ea677eede6ee")
    endsection()

    section("it should download only the latest change")
      find_package(Git REQUIRED)
      assert_execute_process(
        COMMAND ${GIT_EXECUTABLE} -C "${PACKAGE_DIR}/src" rev-list --count HEAD
        OUTPUT "1")
    endsection()
  endsection()
endfunction()

test_download_external_package()

section("it should redownload an external package with a different version")
  cdeps_download_package(
    ProjectStarter github.com/threeal/project-starter v1.1.0)

  section("it should redownload to the correct path")
    assert(DEFINED ProjectStarter_SOURCE_DIR)
    assert(EXISTS "${ProjectStarter_SOURCE_DIR}")

    cdeps_get_package_dir(ProjectStarter PACKAGE_DIR)
    assert(ProjectStarter_SOURCE_DIR STREQUAL "${PACKAGE_DIR}/src")
  endsection()

  section("it should redownload the correct version")
    find_package(Git REQUIRED)
    assert_execute_process(
      COMMAND ${GIT_EXECUTABLE} -C "${PACKAGE_DIR}/src" rev-parse HEAD
      OUTPUT "316dec51ce6bfd7647d3e68d4cb2512a59a49682")
  endsection()

  section("it should download only the latest change")
    find_package(Git REQUIRED)
    assert_execute_process(
      COMMAND ${GIT_EXECUTABLE} -C "${PACKAGE_DIR}/src" rev-list --count HEAD
      OUTPUT "1")
  endsection()
endsection()

section(
  "it should fail to download an external package with an invalid version")
  assert_fatal_error(
    CALL cdeps_download_package ProjectStarter
      github.com/threeal/project-starter invalid
    MESSAGE "CDeps: Failed to download ProjectStarter:")
endsection()

test_download_external_package()

section("it should not redownload an external package")
  set(PREV_GIT_EXECUTABLE "${GIT_EXECUTABLE}")
  set(GIT_EXECUTABLE invalid)

  cdeps_download_package(
    ProjectStarter github.com/threeal/project-starter v1.0.0)

  set(GIT_EXECUTABLE "${PREV_GIT_EXECUTABLE}")

  section("it should maintain the correct path")
    assert(DEFINED ProjectStarter_SOURCE_DIR)
    assert(EXISTS "${ProjectStarter_SOURCE_DIR}")

    cdeps_get_package_dir(ProjectStarter PACKAGE_DIR)
    assert(ProjectStarter_SOURCE_DIR STREQUAL "${PACKAGE_DIR}/src")
  endsection()

  section("it should maintain the correct version")
    find_package(Git REQUIRED)
    assert_execute_process(
      COMMAND ${GIT_EXECUTABLE} -C "${PACKAGE_DIR}/src" rev-parse HEAD
      OUTPUT "5a80d2080c808f588856c3191512ea677eede6ee")
  endsection()

  section("it should maintain only the latest change")
    find_package(Git REQUIRED)
    assert_execute_process(
      COMMAND ${GIT_EXECUTABLE} -C "${PACKAGE_DIR}/src" rev-list --count HEAD
      OUTPUT "1")
  endsection()
endsection()
