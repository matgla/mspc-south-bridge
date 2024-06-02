#
# CMakeLists.txt
#
# Copyright (C) 2024 Mateusz Stadnik <matgla@live.com>
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
add_executable(mspc_south_bridge)

target_sources(mspc_south_bridge 
  PRIVATE 
    main.cpp2
    vector_table.S
)

use_cppfront(
  TARGET mspc_south_bridge
)

set (YASLD_USE_CUSTOM_LINKER_SCRIPT ON)
find_package(Yasld REQUIRED)
list (APPEND CMAKE_MODULE_PATH ${Yasld_SOURCE_DIR}/cmake)

target_link_libraries(mspc_south_bridge
  PRIVATE 
    pico_stdlib
    yasld_standalone_executable_flags
)

target_link_options(mspc_south_bridge 
  PRIVATE 
    -T${PROJECT_SOURCE_DIR}/linker/south_bridge.ld
    -Wl,--gc-sections
)

set_target_properties(mspc_south_bridge 
  PROPERTIES LINK_DEPENDS
    ${PROJECT_SOURCE_DIR}/linker/south_bridge.ld)

include(ConvertElfToYasiff)

convert_elf_to_yasiff(
  TARGET mspc_south_bridge
  TYPE executable
)
