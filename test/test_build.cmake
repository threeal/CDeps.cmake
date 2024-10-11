cmake_minimum_required(VERSION 3.21)

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CDeps.cmake)

set(CMAKE_GENERATOR "Unix Makefiles")

set(CDEPS_DIR .cdeps)
file(REMOVE_RECURSE .cdeps)

section("it should fail to build a package "
  "because it has not been downloaded")
  assert_fatal_error(
    CALL cdeps_build_package pkg
    MESSAGE "CDeps: pkg must be downloaded before building")
endsection()

file(WRITE .cdeps/pkg/src/CMakeLists.txt
  "cmake_minimum_required(VERSION 3.5)\n"
  "project(pkg LANGUAGES CXX)\n"
  "add_executable(main main.cpp)\n")

file(WRITE .cdeps/pkg/src/main.cpp
  "#include <iostream>\n"
  "\n"
  "int main() {\n"
  "  std::cout << \"Hello World!\\n\";\n"
  "}\n")

file(WRITE .cdeps/pkg/src.lock "pkg github.com/user/pkg main")

section("it should build a package")
  cdeps_build_package(pkg)

  section("it should output the build directory variable")
    assert(DEFINED pkg_BUILD_DIR)
    assert(pkg_BUILD_DIR STREQUAL .cdeps/pkg/build)
  endsection()

  section("it should generate the lock file")
    file(READ .cdeps/pkg/build.lock CONTENT)
    assert(CONTENT MATCHES "^pkg github.com.user.pkg main")
  endsection()

  section("it should build to the build directory")
    assert(EXISTS .cdeps/pkg/build/CMakeCache.txt)
  endsection()

  section("it should build the correct targets")
    if(EXISTS .cdeps/pkg/build/main)
      assert_execute_process(.cdeps/pkg/build/main OUTPUT "Hello World!")
    elseif(EXISTS .cdeps/pkg/build/main.exe)
      assert_execute_process(.cdeps/pkg/build/main.exe OUTPUT "Hello World!")
    else()
      fail("expected path" .cdeps/pkg/build/main "to exist")
    endif()
  endsection()
endsection()

section("it should not rebuild the package")
  block()
    set(CMAKE_COMMAND invalid)
    cdeps_build_package(pkg)
  endblock()

  section("it should maintain the lock file")
    file(READ .cdeps/pkg/src.lock CONTENT)
    assert(CONTENT MATCHES "^pkg github.com.user.pkg main")
  endsection()

  section("it should maintain the build directory")
    assert(EXISTS .cdeps/pkg/build/CMakeCache.txt)
  endsection()
endsection()

section("it should rebuild the package because of an invalidated lock file")
  file(REMOVE_RECURSE .cdeps/pkg/build)
  file(APPEND .cdeps/pkg/build.lock " invalidated")

  cdeps_build_package(pkg)

  section("it should regenerate the lock file")
    file(READ .cdeps/pkg/build.lock CONTENT)
    assert(CONTENT MATCHES "^pkg github.com.user.pkg main")
  endsection()

  section("it should rebuild to the build directory")
    assert(EXISTS .cdeps/pkg/build/CMakeCache.txt)
  endsection()
endsection()

section("it should fail to rebuild the package "
  "because of a corrupted source file")
  file(READ .cdeps/pkg/src/main.cpp ORIGINAL_MAIN_CPP)
  file(WRITE .cdeps/pkg/src/main.cpp corrupted)
  file(APPEND .cdeps/pkg/build.lock " invalidated")

  assert_fatal_error(
    CALL cdeps_build_package pkg
    MESSAGE "CDeps: Failed to execute process:")

  section("it should remove the lock file")
    assert(NOT EXISTS .cdeps/pkg/build.lock)
  endsection()

  section("it should remove the build directory")
    assert(NOT EXISTS .cdeps/pkg/build)
  endsection()

  file(WRITE .cdeps/pkg/src/main.cpp "${ORIGINAL_MAIN_CPP}")
endsection()

section("it should rebuild the package after a failure")
  cdeps_build_package(pkg)

  section("it should regenerate the lock file")
    file(READ .cdeps/pkg/build.lock CONTENT)
    assert(CONTENT MATCHES "^pkg github.com.user.pkg main")
  endsection()

  section("it should rebuild to the build directory")
    assert(EXISTS .cdeps/pkg/build/CMakeCache.txt)
  endsection()
endsection()

file(REMOVE_RECURSE .cdeps)
