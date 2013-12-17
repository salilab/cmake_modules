if (APPLE)
  execute_process(COMMAND uname -v OUTPUT_VARIABLE DARWIN_VERSION)
  string(REGEX MATCH "[0-9]+" DARWIN_VERSION ${DARWIN_VERSION})
endif()

if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU")
execute_process(COMMAND ${CMAKE_CXX_COMPILER} -dumpversion OUTPUT_VARIABLE
		        GCC_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
message(STATUS "GCC version: ${GCC_VERSION}")
if (GCC_VERSION VERSION_GREATER 4.7 OR GCC_VERSION VERSION_EQUAL 4.7)
message(STATUS "Enabling g++ C++11 support")
add_definitions("--std=c++11")
elseif (GCC_VERSION VERSION_GREATER 4.3 OR GCC_VERSION VERSION_EQUAL 4.3)
message(STATUS "Enabling g++ C++0x support")
add_definitions("--std=c++0x")
endif()
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
  # c++11's std::move (which boost/CGAL use) doesn't work until
  # OS X 10.9 (Darwin version 13)
  if (NOT APPLE OR DARWIN_VERSION GREATER 12)
    message(STATUS "Enabling clang C++11 support")
    add_definitions("--std=c++11")
  else()
    message(STATUS "Disabling C++11 for mac os < 10.9")
  endif()
else()
  message(STATUS "Unknown compiler, not sure what to do about C++11")
endif()
