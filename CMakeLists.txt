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

set(LLVM_TARGETS_TO_BUILD "X86" CACHE STRING "desc" FORCE)
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
set(LLVM_BUILD_LLVM_DYLIB false CACHE BOOL "desc" FORCE)

if(BUILD_PACKAGE)
  set(LLVM_BUILD_LLVM_DYLIB true CACHE BOOL "desc" FORCE)
  set(LLVM_BUILD_TOOLS false CACHE BOOL "desc" FORCE)
endif()


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
    "-DLLVM_BUILD_LLVM_DYLIB=${LLVM_BUILD_LLVM_DYLIB}"
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

if(COMMON_CLANG_LIBRARY_NAME)
    set(LLVM_OPTIONS
        "${LLVM_OPTIONS}"
        "-DCOMMON_CLANG_LIBRARY_NAME=${COMMON_CLANG_LIBRARY_NAME}"
    )
endif()

if(((NOT EXISTS ${LLVM_SOURCE_URL}) AND (NOT EXPECTED_LLVM_VERSION)) OR DEFINED BUILD_PACKAGE)
     # Use LLVM sources stored at fixed location
    if(NOT DEFINED BUILD_PACKAGE)
      set(LLVM_SOURCE_URL ${CMAKE_CURRENT_SOURCE_DIR}/../llvm_source)
    endif()
    if(EXISTS ${LLVM_SOURCE_URL})
        message(STATUS "[LLVM_PATCHER] : Manual read LLVM version from llvm_source/CMakeLists.txt file")
        file(STRINGS ${LLVM_SOURCE_URL}/CMakeLists.txt LLVM_VERSION_MAJOR_MATCH REGEX "set\\(LLVM_VERSION_MAJOR [0-9]+\\)")
        file(STRINGS ${LLVM_SOURCE_URL}/CMakeLists.txt LLVM_VERSION_MINOR_MATCH REGEX "set\\(LLVM_VERSION_MINOR [0-9]+\\)")
        file(STRINGS ${LLVM_SOURCE_URL}/CMakeLists.txt LLVM_VERSION_PATCH_MATCH REGEX "set\\(LLVM_VERSION_PATCH [0-9]+\\)")

        string(REGEX MATCH "[0-9]+" LLVM_VERSION_MAJOR ${LLVM_VERSION_MAJOR_MATCH})
        string(REGEX MATCH "[0-9]+" LLVM_VERSION_MINOR ${LLVM_VERSION_MINOR_MATCH})
        string(REGEX MATCH "[0-9]+" LLVM_VERSION_PATCH ${LLVM_VERSION_PATCH_MATCH})

        set(EXPECTED_LLVM_VERSION "${LLVM_VERSION_MAJOR}.${LLVM_VERSION_MINOR}.${LLVM_VERSION_PATCH}")

        message(STATUS "[LLVM_PATCHER] : In folder ${LLVM_SOURCE_URL} found LLVM version : ${EXPECTED_LLVM_VERSION}")
    endif()
endif()

# Use LLVM stock sources or patched stock sources
if(LLVM_STOCK_SOURCES)
    set(LLVM_APPLY_PATCHES false)
else()
    set(LLVM_APPLY_PATCHES true)
endif()

if(NOT EXPECTED_LLVM_VERSION)
    set(EXPECTED_LLVM_VERSION "7.0.0")
endif()

if(NOT LLVM_SOURCE_DIR)
    set(LLVM_SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/../src")
endif()

if(NOT EXISTS ${LLVM_SOURCE_URL})
    # Use LLVM sources stored at fixed location
    set(LLVM_SOURCE_URL /opt/src/llvm${EXPECTED_LLVM_VERSION}_source)
endif()
if(NOT EXISTS ${LLVM_SOURCE_URL})
    # Use LLVM sources stored at fixed location
    set(LLVM_SOURCE_URL ${CMAKE_CURRENT_SOURCE_DIR}/../llvm${EXPECTED_LLVM_VERSION}_source)
endif()
if(NOT EXISTS ${LLVM_SOURCE_URL})
    # Use LLVM sources stored at fixed location
    set(LLVM_SOURCE_URL ${CMAKE_CURRENT_SOURCE_DIR}/../../../../llvm${EXPECTED_LLVM_VERSION}_source)
endif()

message(STATUS "[LLVM_PATCHER] : LLVM_SOURCE_URL   = ${LLVM_SOURCE_URL}")
message(STATUS "[LLVM_PATCHER] : LLVM_OPTIONS      = ${LLVM_OPTIONS}")

if(NOT EXISTS ${LLVM_SOURCE_DIR})
      # Copy stock LLVM sources to LLVM_SOURCE_DIR
      message(STATUS "[LLVM_PATCHER] : Copying stock LLVM sources to ${LLVM_SOURCE_DIR}")
      execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${LLVM_SOURCE_URL} ${LLVM_SOURCE_DIR})

    FILE(GLOB dirsPatch RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/releases ${CMAKE_CURRENT_SOURCE_DIR}/releases/*)
    list(SORT dirsPatch)
    list(REVERSE dirsPatch)
    
    if(NOT LLVM_VERSION_MAJOR)
        string(REGEX MATCH "[0-9]+" LLVM_VERSION_MAJOR ${EXPECTED_LLVM_VERSION})
    endif()

      if(LLVM_APPLY_PATCHES)
          # Customization patches will be applied if present.
          
       foreach(dirPatch ${dirsPatch})
         #Apply all patches for given major version of LLVM
         string(REGEX MATCH "[0-9]+" LLVM_VER_MAJOR_FOLDER ${dirPatch})
         if(NOT ${LLVM_VERSION_MAJOR} MATCHES ${LLVM_VER_MAJOR_FOLDER})
           continue()
         endif()
         message(STATUS "[LLVM_PATCHER] : Applying patches for LLVM from version ${dirPatch}")
                  
          file(GLOB LLVM_PATCH_FILES
               "${CMAKE_CURRENT_SOURCE_DIR}/releases/${dirPatch}/patches_external/*.patch"
              )
          # Sort list of patch files.
          if(LLVM_PATCH_FILES)
              list(SORT LLVM_PATCH_FILES)
          endif()
          # Apply customization patches if any.
          foreach(patch_file ${LLVM_PATCH_FILES})
              message(STATUS "[LLVM_PATCHER] : Apply ${patch_file} file")
              execute_process(COMMAND ${PATCH} -d ${LLVM_SOURCE_DIR} -p1 -i ${patch_file} RESULT_VARIABLE rv)
              if(NOT rv EQUAL 0)
                  message(FATAL_ERROR "[LLVM_PATCHER] : error: applying patch '${patch_file}' failed")
              endif()
          endforeach()
         endforeach()
      endif()
endif()

if(CMAKE_CONFIGURATION_TYPES)
    # Multi-configuration generator.
    set (CMAKE_CONFIGURATION_TYPES "Debug" "Release" "ReleaseInternal")
    message(STATUS "[LLVM_PATCHER] : LLVM_CONFIGURATION_TYPES = ${CMAKE_CONFIGURATION_TYPES}")
else()
    # Single-configuration generator.
    message(STATUS "[LLVM_PATCHER] : LLVM_BUILD_TYPE   = ${CMAKE_BUILD_TYPE}")
endif()

# Set python interpreter for LLVM 
llvm_utils_python_set()
# Do not alter LLVM compilation flags
llvm_utils_push_build_flags()
if(BUILD_PACKAGE)
  add_subdirectory(${LLVM_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/src)
else()
  add_subdirectory(${LLVM_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/src EXCLUDE_FROM_ALL)
endif()
llvm_utils_pop_build_flags()
llvm_utils_python_restore()
# Get version of LLVM that we are currently using:
get_directory_property(LLVM_VERSION_MAJOR  DIRECTORY ${LLVM_SOURCE_DIR} DEFINITION "LLVM_VERSION_MAJOR")
get_directory_property(LLVM_VERSION_MINOR  DIRECTORY ${LLVM_SOURCE_DIR} DEFINITION "LLVM_VERSION_MINOR")
get_directory_property(LLVM_VERSION_PATCH  DIRECTORY ${LLVM_SOURCE_DIR} DEFINITION "LLVM_VERSION_PATCH")
get_directory_property(LLVM_VERSION_SUFFIX DIRECTORY ${LLVM_SOURCE_DIR} DEFINITION "LLVM_VERSION_SUFFIX")
# Make LLVM version accessible in parent scope:
set(LLVM_VERSION_MAJOR  ${LLVM_VERSION_MAJOR}  PARENT_SCOPE)
set(LLVM_VERSION_MINOR  ${LLVM_VERSION_MINOR}  PARENT_SCOPE)
set(LLVM_VERSION_PATCH  ${LLVM_VERSION_PATCH}  PARENT_SCOPE)
set(LLVM_VERSION_SUFFIX ${LLVM_VERSION_SUFFIX} PARENT_SCOPE)

set(PACKAGE_VERSION "${LLVM_VERSION_MAJOR}.${LLVM_VERSION_MINOR}.${LLVM_VERSION_PATCH}${LLVM_VERSION_SUFFIX}")

if(NOT (${PACKAGE_VERSION} EQUAL ${EXPECTED_LLVM_VERSION}))
  message(FATAL_ERROR "[LLVM_PATCHER] : Expected LLVM version ${EXPECTED_LLVM_VERSION} but found ${PACKAGE_VERSION}.")
endif()

set(LLVM_INCLUDE_DIRS "${LLVM_SOURCE_DIR}/include;${CMAKE_CURRENT_BINARY_DIR}/src/include")
set(LLVM_INCLUDE_DIRS ${LLVM_INCLUDE_DIRS} PARENT_SCOPE)

if(BUILD_PACKAGE)
  if(UNIX)
    if(EXISTS "/etc/debian_version")
      set(CPACK_GENERATOR "DEB")
    elseif(EXISTS "/etc/redhat-release")
      set(CPACK_GENERATOR "RPM")
    else()
      set(CPACK_GENERATOR "TXZ")
      set(CPACK_SET_DESTDIR ON)
    endif()

    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "intel")
    set(CPACK_PACKAGE_ARCHITECTURE "x86_64")
    set(CPACK_PACKAGE_NAME "intel")
    set(CPACK_PACKAGE_VERSION_MAJOR ${LLVM_VERSION_MAJOR})
    set(CPACK_PACKAGE_VERSION_MINOR ${LLVM_VERSION_MINOR})
    set(CPACK_PACKAGE_VERSION_PATCH ${LLVM_VERSION_PATCH})
    set(CPACK_PACKAGE_VERSION_SUFFIX ${LLVM_VERSION_SUFFIX})
    set(CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}${CPACK_PACKAGE_VERSION_SUFFIX}")
    set(CPACK_PACKAGE_INSTALL_DIRECTORY ${IGC_INSTALL_TIME_ROOT_DIR})
    set(CPACK_DEBIAN_PACKAGE_DESCRIPTION "LLVM patched library version for Intel")
    set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
    set(CPACK_RPM_PACKAGE_RELOCATABLE TRUE)
    set(CPACK_RPM_PACKAGE_ARCHITECTURE "x86_64")

    if(DEFINED LLVM_PACKAGE_RELEASE)
      set(CPACK_DEBIAN_PACKAGE_RELEASE ${LLVM_PACKAGE_RELEASE})
      set(CPACK_RPM_PACKAGE_RELEASE ${LLVM_PACKAGE_RELEASE})
    else()
      set(CPACK_DEBIAN_PACKAGE_RELEASE 1)
      set(CPACK_RPM_PACKAGE_RELEASE 1)
    endif()

    set(CPACK_DEBIAN_INTEL-LLVM-PATCHED-LIBRARY_FILE_NAME "intel-llvm-patched-library_${CPACK_PACKAGE_VERSION}-${CPACK_DEBIAN_PACKAGE_RELEASE}_${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}.deb")
    set(CPACK_DEBIAN_INTEL-LLVM-PATCHED-LIBRARY-DEVEL_FILE_NAME "intel-llvm-patched-library-devel_${CPACK_PACKAGE_VERSION}-${CPACK_DEBIAN_PACKAGE_RELEASE}_${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}.deb")

    set(CPACK_RPM_INTEL-LLVM-PATCHED-LIBRARY_FILE_NAME "intel-llvm-patched-library-${CPACK_PACKAGE_VERSION}-${CPACK_RPM_PACKAGE_RELEASE}.${CPACK_RPM_PACKAGE_ARCHITECTURE}.rpm")
    set(CPACK_RPM_INTEL-LLVM-PATCHED-LIBRARY-DEVEL_FILE_NAME "intel-llvm-patched-library-devel-${CPACK_PACKAGE_VERSION}-${CPACK_RPM_PACKAGE_RELEASE}.${CPACK_RPM_PACKAGE_ARCHITECTURE}.rpm")

    set(CPACK_ARCHIVE_INTEL-LLVM-PATCHED-LIBRARY_FILE_NAME "intel-llvm-patched-library-${CPACK_PACKAGE_VERSION}-${CPACK_DEBIAN_PACKAGE_RELEASE}.${CPACK_PACKAGE_ARCHITECTURE}")
    set(CPACK_ARCHIVE_INTEL-LLVM-PATCHED-LIBRARY-DEVEL_FILE_NAME "intel-llvm-patched-library-devel-${CPACK_PACKAGE_VERSION}-${CPACK_DEBIAN_PACKAGE_RELEASE}.${CPACK_PACKAGE_ARCHITECTURE}")

    set(CPACK_DEB_COMPONENT_INSTALL ON)
    set(CPACK_RPM_COMPONENT_INSTALL ON)
    set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
    set(CPACK_COMPONENTS_ALL intel-llvm-patched-library intel-llvm-patched-library-devel)

    include(CPack)
    include(GNUInstallDirs)

    install(FILES $<TARGET_SONAME_FILE:LLVM> DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR} COMPONENT intel-llvm-patched-library)
    install(DIRECTORY ${LLVM_SOURCE_DIR}/include/llvm ${LLVM_SOURCE_DIR}/include/llvm-c DESTINATION ${CMAKE_INSTALL_FULL_INCLUDEDIR} COMPONENT intel-llvm-patched-library-devel)

  endif()
endif()
