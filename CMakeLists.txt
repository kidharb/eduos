include(FetchContent)
cmake_minimum_required(VERSION 3.20)
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
project("eduos" NONE)

set(IMAGE_NAME            "template")
set(CMAKE_C_FLAGS         "-Wno-gnu-folding-constant")
set(CMAKE_C_FLAGS_DEBUG   "-g -O0 -DDEBUG")
set(CMAKE_CXX_FLAGS       "-Wno-gnu-folding-constant")
set(CMAKE_CXX_FLAGS_DEBUG "-g -O0 -DDEBUG")

FetchContent_Declare(
    limine
	GIT_REPOSITORY https://github.com/limine-bootloader/limine.git
    GIT_TAG        origin/v7.x-binary
  )
FetchContent_MakeAvailable(limine)

set(CMAKE_C_COMPILER x86_64-elf-gcc)
set(CMAKE_FIND_ROOT_PATH  /home/kidharb/opt/cross/bin)

#set(subproject "limine" CACHE STRING "Sub-project to build, valid are limine")
include_directories(${limine_SOURCE_DIR}/)
add_subdirectory("src/kernel")