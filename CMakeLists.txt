#
# CMakeLists.txt
#
# Copyright (C) 2023 Mateusz Stadnik <matgla@live.com>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <https://www.gnu.org/licenses/>.
#

cmake_minimum_required(VERSION 3.12)

include(FetchContent)

FetchContent_Declare(
  yaspem
  GIT_REPOSITORY https://github.com/matgla/Yaspem.git
  GIT_TAG v1.2)

FetchContent_MakeAvailable(yaspem)

set(CMAKE_MODULE_PATH
    ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake
    ${yaspem_SOURCE_DIR}/cmake
    CACHE INTERNAL "")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(yaspem)

setup_yaspem(
  YASPEM_SOURCE ${yaspem_SOURCE_DIR} OUTPUT_DIRECTORY
  ${CMAKE_CURRENT_BINARY_DIR}/packages PACKAGE_FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/packages.json)

find_package(picosdk REQUIRED)

project(MspcSouthBridge NONE)

set(CXX_STANDARD 20)

include(cmake/preload/toolchains/pico_arm_gcc)

include(pico_sdk_init)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
enable_language(C CXX ASM)

add_definitions(-DPICO_FLOAT_IN_RAM=1 -DPICO_DIVIDER_CALL_LDIV0=0
                -DPICO_DIVIDER_CALL_IDIV0=0)

# Prevent picoSDK to add own pico_standard_link
add_library(pico_standard_link_headers INTERFACE)
add_library(pico_standard_link INTERFACE)

pico_sdk_init()

add_subdirectory(source)
