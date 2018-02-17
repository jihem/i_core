cmake_minimum_required(VERSION 3.6)
project(i_core)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES main.cpp i_core.cpp i_core.h i_var.cpp i_var.h i_ret.cpp i_ret.h)
add_executable(i_core ${SOURCE_FILES})

