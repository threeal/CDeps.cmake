# Asserts that the source directory of the specified package is valid.
#
# assert_cdeps_package_source_dir(<name>)
#
# This function checks whether the `<name>_SOURCE_DIR` variable is defined and
# points to an existing and valid source directory.
function(assert_cdeps_package_source_dir NAME)
  assert(DEFINED ${NAME}_SOURCE_DIR)
  assert(EXISTS "${${NAME}_SOURCE_DIR}")

  cdeps_get_package_dir("${NAME}" PACKAGE_DIR)
  assert(${NAME}_SOURCE_DIR STREQUAL "${PACKAGE_DIR}/src")
endfunction()

# Asserts that the given directory contains a Git repository with the expected
# commit hash.
#
# assert_git_commit_hash(<dir> <expected_hash>)
#
# This function checks whether the given <dir> contains a Git repository with
# a commit hash matching `<expected_hash>`.
function(assert_git_commit_hash DIR EXPECTED_HASH)
  find_package(Git REQUIRED)
  assert_execute_process(
    COMMAND ${GIT_EXECUTABLE} -C "${DIR}" rev-parse HEAD
    OUTPUT "${EXPECTED_HASH}")
endfunction()

# Asserts that the given directory contains a Git repository with the expected
# number of commits.
#
# assert_git_commits_count(<dir> <expected_count>)
#
# This function checks whether the given <dir> contains a Git repository with
# the number of commits equals to `<expected_count>`.
function(assert_git_commits_count DIR EXPECTED_COUNT)
  find_package(Git REQUIRED)
  assert_execute_process(
    COMMAND ${GIT_EXECUTABLE} -C "${DIR}" rev-list --count HEAD
    OUTPUT "${EXPECTED_COUNT}")
endfunction()

# Asserts that the given directory contains a Git repository with the expected
# submodule status.
#
# assert_git_submodule_status(<dir> <expected_status>)
#
# This function checks whether the given <dir> contains a Git repository where
# the submodule status matches `<expected_status>`.
function(assert_git_submodule_status DIR EXPECTED_STATUS)
  find_package(Git REQUIRED)
  assert_execute_process(
    COMMAND ${GIT_EXECUTABLE} -C "${DIR}" submodule status --recursive
    OUTPUT "${EXPECTED_STATUS}")
endfunction()
