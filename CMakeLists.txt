#
# CMakeLists.txt
#
# Copyright (C) 2023 Mateusz Stadnik <matgla@live.com>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version. This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <https://www.gnu.org/licenses/>.
#

cmake_minimum_required(VERSION 3.28)

find_program(yaspem yaspem.py)

if (NOT yaspem OR $ENV{YASPEM_FETCH_FROM_GIT}})
  include(FetchContent)

  FetchContent_Declare(
    yaspem
    GIT_REPOSITORY https://github.com/matgla/Yaspem.git
    GIT_TAG master)

  FetchContent_MakeAvailable(yaspem)

else ()
  cmake_path(GET yaspem PARENT_PATH yaspem_dir)
  message(STATUS "Populating locally available Yaspem: ${yaspem_dir}")
  set (yaspem_SOURCE_DIR ${yaspem_dir})
endif ()
    
list (APPEND CMAKE_MODULE_PATH ${yaspem_SOURCE_DIR}/cmake) 
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(yaspem)

setup_yaspem(
  YASPEM_SOURCE ${yaspem_SOURCE_DIR} OUTPUT_DIRECTORY
  ${CMAKE_CURRENT_BINARY_DIR}/packages PACKAGE_FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/packages.json)

find_package (CMakeUtils REQUIRED)
#set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set (CMAKE_TOOLCHAIN_FILE ${CMakeUtils_SOURCE_DIR}/toolchains/arm-none-eabi-with-pic.cmake)


add_definitions(
  -DPICO_DISABLE_SHARED_IRQ_HANDLERS
  -DPICO_NO_BINARY_INFO
)
add_library(pico_divider INTERFACE)
add_library(pico_bit_ops INTERFACE)
add_library(pico_mem_ops INTERFACE)
add_library(pico_mem_ops_headers INTERFACE)
add_library(pico_double INTERFACE)
add_library(pico_double_headers INTERFACE)
add_library(pico_float INTERFACE)
add_library(pico_float_headers INTERFACE)
# end of libgcc hacks 

add_library(pico_standard_link INTERFACE)
add_library(pico_standard_link_headers INTERFACE)
target_link_libraries(pico_standard_link INTERFACE pico_binary_info_headers)

find_package (pico-sdk REQUIRED)

include (pico_sdk_init)

project(MspcSouthBridge ASM C CXX)

pico_sdk_init()

set(CMAKE_CPPFRONT_FLAGS "-fno-exceptions -fno-rtti" CACHE INTERNAL "")

set(CMAKE_INTERPROCEDURAL_OPTIMIZATION FALSE)
set(common_flags "-Werror -Wall -Wextra -Wconversion -Wno-unused -Wshadow -Wpointer-arith -Wcast-qual -Wdouble-promotion -Wno-missing-braces ")
set(common_release_flags "") 
set(common_debug_flags "-g")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti -fno-exceptions -fmodules-ts -fno-threadsafe-statics -fno-module-lazy  ${common_flags}")

set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} ${common_release_flags}")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${common_debug_flags}")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${common_flags}")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} ${common_release_flags}")
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} ${common_debug_flags}")

set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} ${common_flags}")
set(CMAKE_ASM_FLAGS_RELEASE "${CMAKE_ASM_FLAGS_RELEASE} ${common_release_flags}")
set(CMAKE_ASM_FLAGS_DEBUG "${CMAKE_ASM_FLAGS_DEBUG} ${common_debug_flags}")

set(CMAKE_CXX_SCAN_FOR_MODULES ON) 

set (CMAKE_CXX_STANDARD 23)
set (CMAKE_CXX_STANDARD_REQUIRED ON)
set (CMAKE_CXX_EXTENSIONS OFF)

include(cppfront)

add_subdirectory(source)

find_package(Yasboot REQUIRED)

list (APPEND CMAKE_MODULE_PATH ${Yasboot_SOURCE_DIR}/cmake)
include (yasboot_create_disk)

if (NOT EXISTS ${CMAKE_BINARY_DIR}/disk)
  message(STATUS "Creating link: ${CMAKE_CURRENT_SOURCE_DIR}/disk -> ${CMAKE_CURRENT_BINARY_DIR}/disk")
  execute_process(
    COMMAND 
      ${CMAKE_COMMAND} -E create_symlink ${CMAKE_CURRENT_SOURCE_DIR}/disk ${CMAKE_BINARY_DIR}/disk
  )
endif ()

set(binary_dir ${PROJECT_BINARY_DIR}/source)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/disk/disk_layout.json.template
  ${CMAKE_CURRENT_BINARY_DIR}/disk/disk_layout.json
  @ONLY
)

yasboot_create_disk(
  TARGET 
    mspc_south_disk 
  OUTPUT 
    mspc_south_disk.img 
  LAYOUT 
    ${PROJECT_BINARY_DIR}/disk/disk_layout.json
  YASBOOT_CONFIG
    mspc
  DEPENDS
    generate_mspc_south_bridge.yaff
)


if (${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin")
  set(renode_executable mono /Applications/Renode.app/Contents/MacOS/bin/Renode.exe)
else () 
  find_program(renode_executable renode)
endif ()

if (NOT renode_executable)
  message(FATAL_ERROR "Can't find renode executable")
endif ()

add_subdirectory(simulation)

