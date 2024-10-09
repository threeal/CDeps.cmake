include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CDeps.cmake)

section("retrieve the path of package directories")
  set(CMAKE_SOURCE_DIR source-dir)

  section("it should retrieve the path of a package directory")
    cdeps_get_package_dir(CppStarter OUTPUT)
    assert(OUTPUT STREQUAL source-dir/.cdeps/CppStarter)
  endsection()

  section("it should retrieve the path of a package directory if the root is specified")
    set(CDEPS_ROOT some-root)
    cdeps_get_package_dir(CppStarter OUTPUT)
    assert(OUTPUT STREQUAL some-root/CppStarter)
  endsection()
endsection()
