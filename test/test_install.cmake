include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CDeps.cmake)

set(CMAKE_GENERATOR "Unix Makefiles")

set(CDEPS_ROOT .cdeps)
file(REMOVE_RECURSE .cdeps)

section("it should fail to install a package "
  "because it has not been built")
  assert_fatal_error(
    CALL cdeps_install_package pkg
    MESSAGE "CDeps: pkg must be built before installation")
endsection()

file(WRITE .cdeps/pkg/src/CMakeLists.txt
  "cmake_minimum_required(VERSION 3.5)\n"
  "project(pkg LANGUAGES CXX)\n"
  "\n"
  "add_executable(main main.cpp)\n"
  "install(TARGETS main EXPORT main_targets)\n")

file(WRITE .cdeps/pkg/src/main.cpp
  "#include <iostream>\n"
  "\n"
  "int main() {\n"
  "  std::cout << \"Hello World!\\n\";\n"
  "}\n")

file(WRITE .cdeps/pkg/src.lock "pkg github.com/user/pkg main")

cdeps_build_package(pkg)

section("it should install a package")
  cdeps_install_package(pkg)

  section("it should output the install directory variable")
    assert(DEFINED pkg_INSTALL_DIR)
    assert(pkg_INSTALL_DIR STREQUAL .cdeps/pkg/install)
  endsection()

  section("it should generate the lock file")
    file(READ .cdeps/pkg/install.lock CONTENT)
    assert(CONTENT MATCHES "^pkg github.com.user.pkg main")
  endsection()

  section("it should install to the install directory")
    assert(EXISTS .cdeps/pkg/install/bin)
  endsection()

  section("it should install the correct targets")
    assert_execute_process(.cdeps/pkg/install/bin/main OUTPUT "Hello World!")
  endsection()
endsection()

section("it should not reinstall the package")
  block()
    set(CMAKE_COMMAND invalid)
    cdeps_install_package(pkg)
  endblock()

  section("it should maintain the lock file")
    file(READ .cdeps/pkg/install.lock CONTENT)
    assert(CONTENT MATCHES "^pkg github.com.user.pkg main")
  endsection()

  section("it should maintain the install directory")
    assert(EXISTS .cdeps/pkg/install/bin)
  endsection()
endsection()

section("it should reinstall the package because of an invalidated lock file")
  file(REMOVE_RECURSE .cdeps/pkg/install)
  file(APPEND .cdeps/pkg/install.lock " invalidated")

  cdeps_install_package(pkg)

  section("it should regenerate the lock file")
    file(READ .cdeps/pkg/install.lock CONTENT)
    assert(CONTENT MATCHES "^pkg github.com.user.pkg main")
  endsection()

  section("it should reinstall to the install directory")
    assert(EXISTS .cdeps/pkg/install/bin)
  endsection()
endsection()

section("it should fail to reinstall the package "
  "because of a corrupted install rule file")
  file(READ .cdeps/pkg/build/cmake_install.cmake ORIGINAL_INSTALL_RULE)
  file(WRITE .cdeps/pkg/build/cmake_install.cmake corrupted)
  file(APPEND .cdeps/pkg/install.lock " invalidated")

  assert_fatal_error(
    CALL cdeps_install_package pkg
    MESSAGE "CDeps: Failed to install pkg:")

  section("it should remove the lock file")
    assert(NOT EXISTS .cdeps/pkg/install.lock)
  endsection()

  section("it should remove the install directory")
    assert(NOT EXISTS .cdeps/pkg/install)
  endsection()

  file(WRITE .cdeps/pkg/build/cmake_install.cmake "${ORIGINAL_INSTALL_RULE}")
endsection()

section("it should reinstall the package after a failure")
  cdeps_install_package(pkg)

  section("it should regenerate the lock file")
    file(READ .cdeps/pkg/install.lock CONTENT)
    assert(CONTENT MATCHES "^pkg github.com.user.pkg main")
  endsection()

  section("it should reinstall to the install directory")
    assert(EXISTS .cdeps/pkg/install/bin)
  endsection()
endsection()

file(REMOVE_RECURSE .cdeps)
