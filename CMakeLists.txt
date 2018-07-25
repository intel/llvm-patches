#===================== begin_copyright_notice ==================================
# 
# Copyright (c) 2017-2018 Intel Corporation.
# 
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
# 
# ======================= end_copyright_notice ==================================

#
# LLVM module
#

cmake_minimum_required(VERSION 3.4.3)

if(BS_USE_OSDM_BUILD_SYSTEM)
    include(${BUILD_SYS_INC}/utils.cmake)
    bs_find_patch()
    bs_find_python2()
else()
    if (NOT PATCH)
        find_program(PATCH NAMES patch patch.exe)
    endif()
    if (NOT PYTHON)
        find_program(PYTHON NAMES python2 python python2.exe python.exe)
    endif()
endif()

include(llvm_utils.cmake)

set(LLVM_TARGETS_TO_BUILD "" CACHE STRING "desc" FORCE)
set(LLVM_BUILD_TOOLS true CACHE BOOL "desc" FORCE)
set(LLVM_INCLUDE_TOOLS true CACHE BOOL "desc" FORCE)
set(LLVM_INSTALL_UTILS false CACHE BOOL "desc" FORCE)
set(LLVM_INCLUDE_UTILS false CACHE BOOL "desc" FORCE)
set(LLVM_BUILD_EXAMPLES false CACHE BOOL "desc" FORCE)
set(LLVM_INCLUDE_EXAMPLES false CACHE BOOL "desc" FORCE)
set(LLVM_BUILD_TESTS false CACHE BOOL "desc" FORCE)
set(LLVM_INCLUDE_TESTS false CACHE BOOL "desc" FORCE)
set(LLVM_APPEND_VC_REV false CACHE BOOL "desc" FORCE)
set(LLVM_ENABLE_THREADS true CACHE BOOL "desc" FORCE)
set(LLVM_ENABLE_CXX1Y false CACHE BOOL "desc" FORCE)
set(LLVM_ENABLE_PIC true CACHE BOOL "desc" FORCE)
set(LLVM_ENABLE_WARNINGS true CACHE BOOL "desc" FORCE)
set(LLVM_ENABLE_PEDANTIC true CACHE BOOL "desc" FORCE)
set(LLVM_ENABLE_WERROR false CACHE BOOL "desc" FORCE)
set(LLVM_ABI_BREAKING_CHECKS FORCE_OFF CACHE BOOL "desc" FORCE)
set(LLVM_BUILD_RUNTIME true CACHE BOOL "desc" FORCE)
set(LLVM_ENABLE_TERMINFO false CACHE BOOL "desc" FORCE)


set(LLVM_OPTIONS
    "-DLLVM_TARGETS_TO_BUILD=${LLVM_TARGETS_TO_BUILD}"
    "-DLLVM_BUILD_TOOLS=${LLVM_BUILD_TOOLS}"
    "-DLLVM_INCLUDE_TOOLS=${LLVM_INCLUDE_TOOLS}"
    "-DLLVM_INSTALL_UTILS=${LLVM_INSTALL_UTILS}"
    "-DLLVM_INCLUDE_UTILS=${LLVM_INCLUDE_UTILS}"
    "-DLLVM_BUILD_EXAMPLES=${LLVM_BUILD_EXAMPLES}"
    "-DLLVM_INCLUDE_EXAMPLES=${LLVM_INCLUDE_EXAMPLES}"
    "-DLLVM_BUILD_TESTS=${LLVM_BUILD_TESTS}"
    "-DLLVM_INCLUDE_TESTS=${LLVM_INCLUDE_TESTS}"
    "-DLLVM_APPEND_VC_REV=${LLVM_APPEND_VC_REV}"
    "-DLLVM_ENABLE_THREADS=${LLVM_ENABLE_THREADS}"
    "-DLLVM_ENABLE_CXX1Y=${LLVM_ENABLE_CXX1Y}"
    "-DLLVM_ENABLE_PIC=${LLVM_ENABLE_PIC}"
    "-DLLVM_ENABLE_WARNINGS=${LLVM_ENABLE_WARNINGS}"
    "-DLLVM_ENABLE_PEDANTIC=${LLVM_ENABLE_PEDANTIC}"
    "-DLLVM_ENABLE_WERROR=${LLVM_ENABLE_WERROR}"
    "-DLLVM_ABI_BREAKING_CHECKS=${LLVM_ABI_BREAKING_CHECKS}"
    "-DLLVM_BUILD_RUNTIME=${LLVM_BUILD_RUNTIME}"
    "-DLLVM_ENABLE_TERMINFO=${LLVM_ENABLE_TERMINFO}"
)


if(_ASSERTBUILD)
    set(LLVM_ENABLE_ASSERTIONS true CACHE STRING "desc" FORCE)
    set(LLVM_OPTIONS
        "${LLVM_OPTIONS}"
        "-DLLVM_ENABLE_ASSERTIONS=${LLVM_ENABLE_ASSERTIONS}"
    )
endif()

if(WIN32)
    set(LLVM_USE_CRT_DEBUG MTd CACHE STRING "desc" FORCE)
    set(LLVM_USE_CRT_RELEASE MT CACHE STRING "desc" FORCE)
    set(LLVM_USE_CRT_RELEASEINTERNAL MT CACHE STRING "desc" FORCE)
    set(LLVM_OPTIONS
        "${LLVM_OPTIONS}"
        "-DLLVM_USE_CRT_DEBUG=${LLVM_USE_CRT_DEBUG}"
        "-DLLVM_USE_CRT_RELEASE=${LLVM_USE_CRT_RELEASE}"
        "-DLLVM_USE_CRT_RELEASEINTERNAL=${LLVM_USE_CRT_RELEASEINTERNAL}"
    )
else()
    set(LLVM_ENABLE_EH true CACHE BOOL "desc" FORCE)
    set(LLVM_ENABLE_RTTI true CACHE BOOL "desc" FORCE)
    if ("${ARCH}" STREQUAL "32")
       set(LLVM_BUILD_32_BITS true CACHE BOOL "desc" FORCE)
    else()
       set(LLVM_BUILD_32_BITS false CACHE BOOL "desc" FORCE)
    endif()
    set(LLVM_OPTIONS
        "${LLVM_OPTIONS}"
        "-DLLVM_ENABLE_EH=${LLVM_ENABLE_EH}"
        "-DLLVM_ENABLE_RTTI=${LLVM_ENABLE_RTTI}"
        "-DLLVM_BUILD_32_BITS=${LLVM_BUILD_32_BITS}"
    )
endif()

if(NOT EXISTS ${LLVM_SOURCE_URL})
    # Use LLVM sources stored at fixed location
    set(LLVM_SOURCE_URL ${CMAKE_CURRENT_SOURCE_DIR}/../llvm_source)
endif()
if(NOT EXISTS ${LLVM_SOURCE_URL})
    # Use LLVM sources stored at fixed location
    set(LLVM_SOURCE_URL ${CMAKE_CURRENT_SOURCE_DIR}/../../../../llvm_source)
endif()
if(NOT EXISTS ${LLVM_SOURCE_URL})
    # Use tar archive with stock LLVM sources.
    set(LLVM_SOURCE_USE_TARBALL true)
    set(LLVM_SOURCE_URL "${BS_DIR_MIGRATION_BINARIES}/igc/llvm/llvm-4.0.0.src.tar.xz")
endif()

# Use LLVM stock sources or patched stock sources
if(LLVM_STOCK_SOURCES)
    set(LLVM_APPLY_PATCHES false)
else()
    set(LLVM_APPLY_PATCHES true)
endif()

if(LLVM_APPLY_PATCHES)
    # Customization patches will be applied if present.
    file(GLOB LLVM_EXTERNAL_PATCH_FILES "${CMAKE_CURRENT_SOURCE_DIR}/releases/4.0.0/patches_external/*.patch")
    list(APPEND LLVM_PATCH_FILES ${LLVM_EXTERNAL_PATCH_FILES})
    # Sort list of patch files.
    list(SORT LLVM_PATCH_FILES)
endif()

message(STATUS "LLVM_SOURCE_URL   = ${LLVM_SOURCE_URL}")
message(STATUS "LLVM_OPTIONS      = ${LLVM_OPTIONS}")

if(NOT LLVM_SOURCE_DIR)
    set(LLVM_SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/../src")
endif()
if(NOT EXISTS ${LLVM_SOURCE_DIR})
    if(LLVM_SOURCE_USE_TARBALL)
        # Unpack stock LLVM tarball to LLVM_SOURCE_DIR
        set(LLVM_UNZIPED_SOURCE_TEMP_DIR "${CMAKE_CURRENT_BINARY_DIR}/tmp")
        file(MAKE_DIRECTORY ${LLVM_UNZIPED_SOURCE_TEMP_DIR})
    
        message(STATUS "Extracting stock LLVM tarball to ${LLVM_SOURCE_DIR}")
        execute_process(COMMAND ${CMAKE_COMMAND} -E tar xfz ${LLVM_SOURCE_URL} WORKING_DIRECTORY ${LLVM_UNZIPED_SOURCE_TEMP_DIR} RESULT_VARIABLE rv)
     
        if(NOT rv EQUAL 0)
            message(STATUS "extracting... [error clean up]")
            file(REMOVE_RECURSE "${LLVM_UNZIPED_SOURCE_TEMP_DIR}")
            message(FATAL_ERROR "error: extract of '${LLVM_SOURCE_URL}' failed")
        endif()
      
        file(GLOB contents "${LLVM_UNZIPED_SOURCE_TEMP_DIR}/*")
        file(RENAME ${contents} "${LLVM_SOURCE_DIR}")
        file(REMOVE_RECURSE ${LLVM_UNZIPED_SOURCE_TEMP_DIR})
    else()
        # Copy stock LLVM sources to LLVM_SOURCE_DIR
        message(STATUS "Copying stock LLVM sources to ${LLVM_SOURCE_DIR}")
        execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${LLVM_SOURCE_URL} ${LLVM_SOURCE_DIR})
    endif()
    # Apply customization patches if any.
    foreach(patch_file ${LLVM_PATCH_FILES})
        message("Apply ${patch_file} file")
        execute_process(COMMAND ${PATCH} -d ${LLVM_SOURCE_DIR} -p1 -i ${patch_file} RESULT_VARIABLE rv)
        if(NOT rv EQUAL 0)
            message(FATAL_ERROR "error: appling aptch '${patch_file}' failed")
        endif()
    endforeach()
endif()

if(CMAKE_CONFIGURATION_TYPES)
    # Multi-configuration generator.
    set (CMAKE_CONFIGURATION_TYPES "Debug" "Release" "ReleaseInternal")
    message(STATUS "LLVM_CONFIGURATION_TYPES = ${CMAKE_CONFIGURATION_TYPES}")
else()
    # Single-configuration generator.
    message(STATUS "LLVM_BUILD_TYPE   = ${CMAKE_BUILD_TYPE}")
endif()

# Set python interpreter for LLVM 
llvm_utils_python_set()
# Do not alter LLVM compilation flags
llvm_utils_push_build_flags()
add_subdirectory(${LLVM_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/src EXCLUDE_FROM_ALL)
llvm_utils_pop_build_flags()
llvm_utils_python_restore()

set(LLVM_INCLUDE_DIRS "${LLVM_SOURCE_DIR}/include;${CMAKE_CURRENT_BINARY_DIR}/src/include")
set(LLVM_INCLUDE_DIRS ${LLVM_INCLUDE_DIRS} PARENT_SCOPE)

