include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CDeps.cmake)

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
