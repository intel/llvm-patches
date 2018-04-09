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
# LLVM libraries
#

cmake_minimum_required(VERSION 3.4.3)

function(add_dependencies_for_llvm_lib_target llvm_src_dir)
    get_property(llvm_src_subdirs DIRECTORY "${llvm_src_dir}" PROPERTY SUBDIRECTORIES)
    foreach(llvm_src_subdir IN LISTS llvm_src_subdirs)
        add_dependencies_for_llvm_lib_target("${llvm_src_subdir}")
    endforeach()
    get_property(llvm_sub_targets DIRECTORY "${llvm_src_dir}" PROPERTY BUILDSYSTEM_TARGETS)
    if(llvm_sub_targets)
        foreach(llvm_target IN LISTS llvm_sub_targets)
            add_dependencies(${LLVM_LIB_NAME} ${llvm_target})
            set_target_properties(${llvm_target} PROPERTIES VS_PRE_DEFAULT_PROPS "${CMAKE_CURRENT_SOURCE_DIR}/../../WrkSpace/PropertySheets/igfx_env.props")
        endforeach()
    endif()
endfunction()

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

if(LLVM_CUSTOM_LIB_NAME)
    set (LLVM_LIB_NAME ${LLVM_CUSTOM_LIB_NAME})
else()
    set (LLVM_LIB_NAME llvm)
endif()

if(LLVM_USE_SOURCES_DIRECTLY)
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
    set(PYTHON_EXECUTABLE ${PYTHON} CACHE PATH "desc" FORCE)
else()
set(LLVM_OPTIONS
    "-DLLVM_TARGETS_TO_BUILD=''"
    "-DLLVM_BUILD_TOOLS=true"
    "-DLLVM_INCLUDE_TOOLS=true"
    "-DLLVM_INSTALL_UTILS=false"
    "-DLLVM_INCLUDE_UTILS=false"
    "-DLLVM_BUILD_EXAMPLES=false"
    "-DLLVM_INCLUDE_EXAMPLES=false"
    "-DLLVM_BUILD_TESTS=false"
    "-DLLVM_INCLUDE_TESTS=false"
    "-DLLVM_APPEND_VC_REV=false"
    "-DLLVM_ENABLE_THREADS=true"
    "-DLLVM_ENABLE_CXX1Y=false"
    "-DLLVM_ENABLE_PIC=true"
    "-DLLVM_ENABLE_WARNINGS=true"
    "-DLLVM_ENABLE_PEDANTIC=true"
    "-DLLVM_ENABLE_WERROR=false"
    "-DLLVM_ABI_BREAKING_CHECKS=FORCE_OFF"
    "-DLLVM_BUILD_RUNTIME=true"
    "-DLLVM_ENABLE_TERMINFO=false"
    "-DPYTHON_EXECUTABLE=${PYTHON}"
)
endif()

if (LLVM_USE_SOURCES_DIRECTLY)
    set(LLVM_USE_CRT_DEBUG MTd CACHE STRING "desc" FORCE)
    set(LLVM_USE_CRT_RELEASE MT CACHE STRING "desc" FORCE)
    set(LLVM_USE_CRT_RELEASEINTERNAL MT CACHE STRING "desc" FORCE)
else()
    list(APPEND LLVM_OPTIONS
        "-DLLVM_ENABLE_EH=true"
        "-DLLVM_ENABLE_RTTI=true"
    )
    if ("${ARCH}" STREQUAL "32")
        list(APPEND LLVM_OPTIONS "-DLLVM_BUILD_32_BITS=true")
    else()
        list(APPEND LLVM_OPTIONS "-DLLVM_BUILD_32_BITS=false")
    endif()
    if(CMAKE_MAKE_PROGRAM)
        list(APPEND LLVM_OPTIONS "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}")
    endif()
endif()

if(LLVM_LIMITED_CONFIGURATION)
    if(LLVM_USE_SOURCES_DIRECTLY)
        set(LLVM_LIMITED_CONFIGURATION true)
    else()
        list(APPEND LLVM_OPTIONS "-DLLVM_LIMITED_CONFIGURATION=true")
    endif()
endif()

if(LLVM_SOURCE_DIR)
    # Use LLVM sources stored at LLVM_SOURCE_DIR.
    set(LLVM_SOURCE_URL ${LLVM_SOURCE_DIR})
else()
    # Use LLVM sources stored at fixed location
    set(LLVM_SOURCE_URL ${CMAKE_CURRENT_SOURCE_DIR}/../llvm_source)
    if(NOT EXISTS ${LLVM_SOURCE_URL})
        # Use tar archive with pure LLVM sources.
        set(LLVM_SOURCE_URL "${CMAKE_CURRENT_SOURCE_DIR}/releases/4.0.0/llvm-4.0.0.src.tar.xz")
    endif()
endif()

if(LLVM_DO_NOT_APPLY_PATCHES)
   set(LLVM_APPLY_PATCHES false)
else()
   set(LLVM_APPLY_PATCHES true)
endif()

if(LLVM_APPLY_PATCHES)
    # Customization patches will be applied if present.
    file(GLOB LLVM_EXTERNAL_PATCH_FILES "${CMAKE_CURRENT_SOURCE_DIR}/releases/4.0.0/patches_external/*.patch")
    list(APPEND LLVM_PATCH_FILES ${LLVM_EXTERNAL_PATCH_FILES})
    set(LLVM_APPLY_INTERNAL_PATCHES true)
    if(LLVM_APPLY_INTERNAL_PATCHES)
        file(GLOB LLVM_INTERNAL_PATCH_FILES "${CMAKE_CURRENT_SOURCE_DIR}/releases/4.0.0/patches_internal/*.patch")
        list(APPEND LLVM_PATCH_FILES ${LLVM_INTERNAL_PATCH_FILES})
    endif()
    # Sort list of patch files.
    list(SORT LLVM_PATCH_FILES)
endif()

if(LLVM_INSTALL_DIR)
    set(LLVM_DIR ${LLVM_INSTALL_DIR})
else()
    set(LLVM_DIR "${CMAKE_CURRENT_BINARY_DIR}/install")
endif()
set(LLVM_DIR           ${LLVM_DIR} PARENT_SCOPE)
set(LLVM_LIB_NAME      ${LLVM_LIB_NAME} PARENT_SCOPE)

message(STATUS "LLVM_LIB_NAME     = ${LLVM_LIB_NAME}")
message(STATUS "LLVM_SOURCE_URL   = ${LLVM_SOURCE_URL}")
message(STATUS "LLVM_DIR          = ${LLVM_DIR}")
message(STATUS "LLVM_OPTIONS      = ${LLVM_OPTIONS}")

if(LLVM_USE_SOURCES_DIRECTLY)  
    set(LLVM_SOURCE_DIR "${CMAKE_BINARY_DIR}/llvm/src")
    if(NOT EXISTS ${LLVM_SOURCE_DIR})
        set(LLVM_UNZIPED_SOURCE_TEMP_DIR "${CMAKE_CURRENT_BINARY_DIR}/llvm/tmp")
        file(MAKE_DIRECTORY ${LLVM_UNZIPED_SOURCE_TEMP_DIR})
        
        message(STATUS "extracting... [tar xfz]")
        execute_process(COMMAND ${CMAKE_COMMAND} -E tar xfz ${LLVM_SOURCE_URL} WORKING_DIRECTORY ${LLVM_UNZIPED_SOURCE_TEMP_DIR} RESULT_VARIABLE rv)
        
        if(NOT rv EQUAL 0)
            message(STATUS "extracting... [error clean up]")
            file(REMOVE_RECURSE "${LLVM_UNZIPED_SOURCE_TEMP_DIR}")
            message(FATAL_ERROR "error: extract of '${LLVM_SOURCE_URL}' failed")
        endif()
        
        file(GLOB contents "${LLVM_UNZIPED_SOURCE_TEMP_DIR}/*")
        file(RENAME ${contents} "${LLVM_SOURCE_DIR}")
        file(REMOVE_RECURSE ${LLVM_UNZIPED_SOURCE_TEMP_DIR})
        
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

    add_subdirectory(${LLVM_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/src)
    add_custom_target(${LLVM_LIB_NAME} ALL)
    set_target_properties(${LLVM_LIB_NAME} PROPERTIES VS_PRE_DEFAULT_PROPS "${CMAKE_CURRENT_SOURCE_DIR}/../../WrkSpace/PropertySheets/igfx_env.props")
    add_custom_command(TARGET ${LLVM_LIB_NAME}
                       COMMAND ${CMAKE_COMMAND}
                       -DCMAKE_INSTALL_CONFIG_NAME=$<CONFIG>
                       -DCMAKE_INSTALL_PREFIX=${LLVM_DIR}
                       -P cmake_install.cmake
                       WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/src)
   add_dependencies_for_llvm_lib_target(${LLVM_SOURCE_DIR})
else()

    message(STATUS "LLVM_BUILD_TYPE   = ${CMAKE_BUILD_TYPE}")

    include(${CMAKE_ROOT}/Modules/ExternalProject.cmake)

    ExternalProject_Add(${LLVM_LIB_NAME}
        URL ${LLVM_SOURCE_URL}
        PREFIX src
        BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/src
        CMAKE_ARGS -G ${CMAKE_GENERATOR}
                   -DCMAKE_BUILD_TYPE=$<$<CONFIG:Debug>:Debug>$<$<CONFIG:Release>:Release>$<$<CONFIG:ReleaseInternal>:Release>
                   -DCMAKE_INSTALL_PREFIX=${LLVM_DIR}
                   ${LLVM_OPTIONS}
        INSTALL_COMMAND DESTDIR= ${CMAKE_COMMAND} --build . --target install
    )
    # Apply customization patches if any.
    set(i 1)
    set(patch_dependee "patch")
    foreach(patch_file ${LLVM_PATCH_FILES})

        ExternalProject_Add_Step(${LLVM_LIB_NAME} "patch${i}"
                COMMAND ${PATCH} -d "${CMAKE_CURRENT_BINARY_DIR}/src/src/${LLVM_LIB_NAME}" -p1 < ${patch_file}
                DEPENDEES ${patch_dependee}
                DEPENDERS configure
                COMMENT "Apply ${patch_file} file"
                )

        set(patch_dependee "patch${i}")
        math(EXPR i "${i} + 1")

    endforeach()
endif()

