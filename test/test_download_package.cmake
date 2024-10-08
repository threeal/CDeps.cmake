include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CDeps.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/assert_helper.cmake)

set(CDEPS_ROOT ${CMAKE_CURRENT_BINARY_DIR}/.cdeps)
file(REMOVE_RECURSE "${CDEPS_ROOT}")

section(
  "it should fail to download an external package with an invalid URL")
  assert_fatal_error(
    CALL cdeps_download_package github github.com invalid
    MESSAGE "CDeps: Failed to download github:")
endsection()

section("it should download an external package with a valid URL")
  cdeps_download_package(
    ProjectStarter github.com/threeal/project-starter v1.0.0)

  section("it should download to the correct path")
    assert_cdeps_package_source_dir(ProjectStarter)
  endsection()

  section("it should download the correct version")
    assert_git_commit_hash(
      "${ProjectStarter_SOURCE_DIR}" 5a80d2080c808f588856c3191512ea677eede6ee)
  endsection()

  section("it should download only the latest change")
    assert_git_commits_count("${ProjectStarter_SOURCE_DIR}" 1)
  endsection()

  unset(ProjectStarter_SOURCE_DIR)
endsection()

section("it should not redownload an external package")
  set(PREV_GIT_EXECUTABLE "${GIT_EXECUTABLE}")
  set(GIT_EXECUTABLE invalid)

  cdeps_download_package(
    ProjectStarter github.com/threeal/project-starter v1.0.0)

  set(GIT_EXECUTABLE "${PREV_GIT_EXECUTABLE}")

  section("it should maintain the correct path")
    assert_cdeps_package_source_dir(ProjectStarter)
  endsection()

  unset(ProjectStarter_SOURCE_DIR)
endsection()

section("it should redownload an external package with a different version")
  cdeps_download_package(
    ProjectStarter github.com/threeal/project-starter v1.1.0)

  section("it should redownload to the correct path")
    assert_cdeps_package_source_dir(ProjectStarter)
  endsection()

  section("it should redownload the correct version")
    assert_git_commit_hash(
      "${ProjectStarter_SOURCE_DIR}" 316dec51ce6bfd7647d3e68d4cb2512a59a49682)
  endsection()

  section("it should download only the latest change")
    assert_git_commits_count("${ProjectStarter_SOURCE_DIR}" 1)
  endsection()

  unset(ProjectStarter_SOURCE_DIR)
endsection()

section("it should download an external package without submodules")
  cdeps_download_package(
    GitSubmoduleExample github.com/threeal/git-submodule-example v1.0.0)

  section("it should download to the correct path")
    assert_cdeps_package_source_dir(GitSubmoduleExample)
  endsection()

  section("it should download the correct version")
    assert_git_commit_hash("${GitSubmoduleExample_SOURCE_DIR}"
      9264df25ee6d43751d8948b746e808cf6069f834)
  endsection()

  section("it should download only the latest change")
    assert_git_commits_count("${GitSubmoduleExample_SOURCE_DIR}" 1)
  endsection()

  section("it should not download the submodules")
    assert_git_submodule_status("${GitSubmoduleExample_SOURCE_DIR}"
      "-bea29a84b6c55a49fef34be3e7a17498c633b6d9 project-starter")
  endsection()

  unset(GitSubmoduleExample_SOURCE_DIR)
endsection()

section("it should redownload an external package with submodules")
  cdeps_download_package(
    GitSubmoduleExample github.com/threeal/git-submodule-example v1.0.0
    RECURSE_SUBMODULES)

  section("it should redownload to the correct path")
    assert_cdeps_package_source_dir(GitSubmoduleExample)
  endsection()

  section("it should redownload the correct version")
    assert_git_commit_hash("${GitSubmoduleExample_SOURCE_DIR}"
      9264df25ee6d43751d8948b746e808cf6069f834)
  endsection()

  section("it should redownload only the latest change")
    assert_git_commits_count("${GitSubmoduleExample_SOURCE_DIR}" 1)
  endsection()

  section("it should redownload the submodules")
    assert_git_submodule_status("${GitSubmoduleExample_SOURCE_DIR}"
      "bea29a84b6c55a49fef34be3e7a17498c633b6d9 project-starter \\(v1\\.2\\.0\\)")
  endsection()

  unset(GitSubmoduleExample_SOURCE_DIR)
endsection()

file(REMOVE_RECURSE "${CDEPS_ROOT}")
