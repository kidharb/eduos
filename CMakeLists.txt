cmake_minimum_required(VERSION 3.20)
project("kid_uefi" NONE)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_C_FLAGS         "-Wno-gnu-folding-constant")
set(CMAKE_C_FLAGS_DEBUG   "-g -O0 -DDEBUG")
set(CMAKE_CXX_FLAGS       "-Wno-gnu-folding-constant")
set(CMAKE_CXX_FLAGS_DEBUG "-g -O0 -DDEBUG")

set(subproject "uefi" CACHE STRING "Sub-project to build, valid are toolchain, sysroot and lf_os")
include(${subproject})
