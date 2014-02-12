# Autogenerated file, run tools/build/setup_cmake.py to regenerate
if(NOT DEFINED IMP_TIMEOUT_FACTOR)
    if(${CMAKE_BUILD_TYPE} MATCHES "Debug")
      set(IMP_TIMEOUT_FACTOR 3 CACHE INT "A scaling factor for test timeouts")
    else()
      set(IMP_TIMEOUT_FACTOR 1 CACHE INT "A scaling factor for test timeouts")
    endif()
endif()

set(IMP_CHEAP_TIMEOUT 2 CACHE INT "Timeout for cheap tests")
set(IMP_MEDIUM_TIMEOUT 15 CACHE INT "Timeout for medium tests")
set(IMP_EXPENSIVE_TIMEOUT 120 CACHE INT "Timeout for expensive tests")
set(IMP_CHEAP_COST 1 CACHE INTERNAL "")
set(IMP_MEDIUM_COST 2 CACHE INTERNAL "")
set(IMP_EXPENSIVE_COST 3 CACHE INTERNAL "")

function(imp_add_python_tests modulename length type)
  set(modulename ${ARGV0})
  set(length ${ARGV1})
  set(ttype ${ARGV2})
  list(REMOVE_AT ARGV 0)
  list(REMOVE_AT ARGV 0)
  list(REMOVE_AT ARGV 0)
  math(EXPR timeout "${IMP_TIMEOUT_FACTOR} * ${IMP_${length}_TIMEOUT}")

  foreach (test ${ARGV})
      get_filename_component(path ${test} ABSOLUTE)
      GET_FILENAME_COMPONENT(name ${test} NAME)
      add_test("${modulename}-${name}" ${IMP_TEST_SETUP} python ${path} ${IMP_TEST_ARGUMENTS})
      set_tests_properties("${modulename}-${name}" PROPERTIES LABELS "${modulename}-${ttype}-python-${length}")
      set_tests_properties("${modulename}-${name}" PROPERTIES TIMEOUT ${timeout})
      set_tests_properties("${modulename}-${name}" PROPERTIES COST ${IMP_${length}_COST})
      if(DEFINED IMP_TESTS_PROPERTIES)
        set_tests_properties("${modulename}-${name}" PROPERTIES ${IMP_TESTS_PROPERTIES})
      endif()
  endforeach(test)
endfunction(imp_add_python_tests)

function(imp_add_cpp_tests modulename length output target_list type)
  set(modulename ${ARGV0})
  set(length ${ARGV1})
  set(output ${ARGV2})
  set(target_list ${ARGV3})
  set(ttype ${ARGV4})
  list(REMOVE_AT ARGV 0)
  list(REMOVE_AT ARGV 0)
  list(REMOVE_AT ARGV 0)
  list(REMOVE_AT ARGV 0)
  list(REMOVE_AT ARGV 0)
  math(EXPR timeout "${IMP_TIMEOUT_FACTOR} * ${IMP_${length}_TIMEOUT}")

  foreach (test ${ARGV})
     GET_FILENAME_COMPONENT(name ${test} NAME)
     GET_FILENAME_COMPONENT(name_we ${test} NAME_WE)
     add_executable("${modulename}-${name}" ${test})
     target_link_libraries("${modulename}-${name}"     ${IMP_LINK_LIBRARIES})
     set_target_properties("${modulename}-${name}" PROPERTIES
                           RUNTIME_OUTPUT_DIRECTORY "${output}"
                           OUTPUT_NAME ${name_we})
     set_property(TARGET "${modulename}-${name}" PROPERTY FOLDER "${modulename}")

     add_test("${modulename}-${name}" ${IMP_TEST_SETUP}
              ${output}/${name_we}${CMAKE_EXECUTABLE_SUFFIX} ${IMP_TEST_ARGUMENTS})
     set_tests_properties("${modulename}-${name}" PROPERTIES LABELS "${modulename}-${ttype}-cpp-${length}")
     if(DEFINED IMP_TESTS_PROPERTIES)
        set_tests_properties("${modulename}-${name}" PROPERTIES ${IMP_TESTS_PROPERTIES})
     endif()
     set_tests_properties("${modulename}-${name}" PROPERTIES TIMEOUT ${timeout})
     set_tests_properties("${modulename}-${name}" PROPERTIES COST ${IMP_${length}_COST})
     set(${target_list} ${${target_list}} "${modulename}-${name}" CACHE INTERNAL "" FORCE)
  endforeach(test)
endfunction(imp_add_cpp_tests)


function(imp_add_tests modulename output target_list ttype)
  set(modulename ${ARGV0})
  set(output ${ARGV1})
  set(target_list ${ARGV2})
  set(ttype ${ARGV3})
  list(REMOVE_AT ARGV 0)
  list(REMOVE_AT ARGV 0)
  list(REMOVE_AT ARGV 0)
  list(REMOVE_AT ARGV 0)

  foreach (test ${ARGV})
     GET_FILENAME_COMPONENT(name ${test} NAME)
     GET_FILENAME_COMPONENT(extension ${test} EXT)
     if("${extension}" MATCHES ".*py")
        set(type "py")
     else()
        set(type "cpp")
     endif()
     if(${name} MATCHES "^test_.*")
        set(cost "cheap")
     elseif(${name} MATCHES "^medium_test_.*")
        set(cost "medium")
     else()
        set(cost "expensive")
     endif()
     set(${type}_${cost} ${${type}_${cost}} ${test})
  endforeach(test)
  imp_add_python_tests(${modulename} "CHEAP" ${ttype} "${py_cheap}")
  imp_add_python_tests(${modulename} "MEDIUM" ${ttype} "${py_medium}")
  imp_add_python_tests(${modulename} "EXPENSIVE" ${ttype} "${py_expensive}")
  imp_add_cpp_tests(${modulename} "CHEAP" ${output} ${target_list} ${ttype} "${cpp_cheap}")
  imp_add_cpp_tests(${modulename} "MEDIUM" ${output} ${target_list} ${ttype} "${cpp_medium}")
  imp_add_cpp_tests(${modulename} "EXPENSIVE" ${output} ${target_list} ${ttype} "${cpp_expensive}")
endfunction(imp_add_tests)