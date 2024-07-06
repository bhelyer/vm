cmake_minimum_required(VERSION 3.21)
project(pinot)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_OSX_DEPLOYMENT_TARGET 13.3)

add_library(
    pinot
    lib/Pinot/Exceptions.h
    lib/Pinot/Memory.cpp lib/Pinot/Memory.h
    lib/Pinot/VM.cpp lib/Pinot/VM.h
)

target_include_directories(pinot PUBLIC lib)

add_executable(
    vm
    src/main.cpp
)

target_link_libraries(vm PRIVATE pinot)