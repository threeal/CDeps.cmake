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

section("resolve package URLs")
  section("it should resolve a package URL that contains an HTTP protocol")
    cdeps_resolve_package_url(http://github.com/threeal/cpp-starter OUTPUT)
    assert(OUTPUT STREQUAL http://github.com/threeal/cpp-starter)
  endsection()

  section("it should resolve a package URL that contains an HTTPS protocol")
    cdeps_resolve_package_url(https://github.com/threeal/cpp-starter OUTPUT)
    assert(OUTPUT STREQUAL https://github.com/threeal/cpp-starter)
  endsection()

  section("it should resolve a package URL that contains no protocol")
    cdeps_resolve_package_url(github.com/threeal/cpp-starter OUTPUT)
    assert(OUTPUT STREQUAL https://github.com/threeal/cpp-starter)
  endsection()
endsection()
