# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file LICENSE.rst or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION ${CMAKE_VERSION}) # this file comes with cmake

# If CMAKE_DISABLE_SOURCE_CHANGES is set to true and the source directory is an
# existing directory in our source tree, calling file(MAKE_DIRECTORY) on it
# would cause a fatal error, even though it would be a no-op.
if(NOT EXISTS "/Users/carlosrienzi/Downloads/IECAnalyzer/build/_deps/analyzersdk-src")
  file(MAKE_DIRECTORY "/Users/carlosrienzi/Downloads/IECAnalyzer/build/_deps/analyzersdk-src")
endif()
file(MAKE_DIRECTORY
  "/Users/carlosrienzi/Downloads/IECAnalyzer/build/_deps/analyzersdk-build"
  "/Users/carlosrienzi/Downloads/IECAnalyzer/build/_deps/analyzersdk-subbuild/analyzersdk-populate-prefix"
  "/Users/carlosrienzi/Downloads/IECAnalyzer/build/_deps/analyzersdk-subbuild/analyzersdk-populate-prefix/tmp"
  "/Users/carlosrienzi/Downloads/IECAnalyzer/build/_deps/analyzersdk-subbuild/analyzersdk-populate-prefix/src/analyzersdk-populate-stamp"
  "/Users/carlosrienzi/Downloads/IECAnalyzer/build/_deps/analyzersdk-subbuild/analyzersdk-populate-prefix/src"
  "/Users/carlosrienzi/Downloads/IECAnalyzer/build/_deps/analyzersdk-subbuild/analyzersdk-populate-prefix/src/analyzersdk-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/Users/carlosrienzi/Downloads/IECAnalyzer/build/_deps/analyzersdk-subbuild/analyzersdk-populate-prefix/src/analyzersdk-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/Users/carlosrienzi/Downloads/IECAnalyzer/build/_deps/analyzersdk-subbuild/analyzersdk-populate-prefix/src/analyzersdk-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
