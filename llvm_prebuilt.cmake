#===================== begin_copyright_notice ==================================
# 
# Copyright (c) 2018 Intel Corporation.
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

set(LLVM_USE_PREBUILT true)

if(NOT LLVM_PREBUILT_PATH)
    set(LLVM_PREBUILT_PATH "${CMAKE_CURRENT_BINARY_DIR}/src")
endif()
find_path (LLVM_DIR LLVM-Config.cmake
    ${LLVM_PREBUILT_PATH}/lib/cmake/llvm
)
if(NOT LLVM_DIR)
    message(FATAL_ERROR "LLVM prebuilt not found at: ${LLVM_PREBUILT_PATH}/lib/cmake/llvm")
endif()
find_package(LLVM REQUIRED CONFIG)
message(STATUS "[LLVM Prebuilt] Found LLVM ${LLVM_PACKAGE_VERSION} in ${LLVM_DIR}")
message(STATUS "[LLVM Prebuilt] Using LLVM includes from: ${LLVM_INCLUDE_DIRS}")
message(STATUS "[LLVM Prebuilt] Using LLVM libraries from: ${LLVM_LIBRARY_DIR}")
unset(LLVM_DIR CACHE)

#set(LLVM_INCLUDE_DIRS ${LLVM_INCLUDE_DIRS} PARENT_SCOPE)
#set(LLVM_LIBRARY_DIR ${LLVM_LIBRARY_DIR} PARENT_SCOPE)
#set(LLVM_DEFINITIONS ${LLVM_DEFINITIONS} PARENT_SCOPE)
