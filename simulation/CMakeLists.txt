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

message (STATUS "Adding simulation")

find_package(renode_rp2040 REQUIRED)

set (RENODE_BOARD_DIR ${renode_rp2040_SOURCE_DIR})
set (RENODE_BINARY ${PROJECT_BINARY_DIR}/mspc_south_disk.img)
set (RENODE_NORTH_BRIDGE_BINARY ${PROJECT_SOURCE_DIR}/north_bridge/hello.elf)

configure_file(mspc.resc ${CMAKE_CURRENT_BINARY_DIR}/mspc.resc)
configure_file(south_bridge.resc ${CMAKE_CURRENT_BINARY_DIR}/south_bridge.resc)
configure_file(north_bridge.resc ${CMAKE_CURRENT_BINARY_DIR}/north_bridge.resc)

add_custom_target(
  run 
  COMMAND ${renode_executable} --console --disable-xwt ${CMAKE_CURRENT_BINARY_DIR}/mspc.resc
  DEPENDS mspc_south_disk ${CMAKE_CURRENT_BINARY_DIR}/mspc.resc
  VERBATIM
  USES_TERMINAL
)

