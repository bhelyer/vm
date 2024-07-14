cmake_minimum_required(VERSION 3.21)
project(pinot)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_OSX_DEPLOYMENT_TARGET 13.3)

find_package(GTest)

# Enable all warnings and treat warnings as errors for the given target.
function(target_enable_warnings target)
    if(MSVC)
        target_compile_options(${target} PRIVATE /W4 /WX)
    else()
        target_compile_options(${target} PRIVATE -Wall -Wextra -pedantic -Werror)
    endif()
endfunction()

add_library(
    pinot
    lib/Pinot/Exceptions.h
    lib/Pinot/Memory.cpp lib/Pinot/Memory.h
    lib/Pinot/VM.cpp lib/Pinot/VM.h
)
target_enable_warnings(pinot)
target_include_directories(pinot PUBLIC lib)

add_executable(
    vm
    src/main.cpp
)
target_enable_warnings(vm)
target_link_libraries(vm PRIVATE pinot)

if(GTest_FOUND)
    message("Found GTest, creating tests.")
    enable_testing()
    add_executable(
        vm.test
        test/VM.Test.cpp
    )
    target_link_libraries(
        vm.test
        PRIVATE
        GTest::gtest GTest::gtest_main GTest::gmock GTest::gmock_main
        pinot
    )
    add_test(vm.test vm.test)
else()
    message("Didn't find GTest, not creating tests.")
endif()
