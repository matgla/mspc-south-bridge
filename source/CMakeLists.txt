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

add_executable(south_bridge)

target_sources(south_bridge PRIVATE main.cpp system_stubs.cpp)

set(YASLD_ARCH "cortex-m0+")
set(YASLD_USE_CUSTOM_LINKER_SCRIPT TRUE)
find_package(yasld REQUIRED)

target_link_libraries(
  south_bridge
  PRIVATE hardware_uart
          hardware_gpio
          pico_float
          pico_divider
          yasld_executable_flags
          c
          m
          stdc++)

target_link_options(
  south_bridge PRIVATE -T${PROJECT_SOURCE_DIR}/linker/south_bridge.ld
  -L/opt/arm-none-eabi-with-pic/arm-none-eabi/lib/thumb/v6-m/nofp -nostdlib
  -Wl,--gc-sections)

set_target_properties(
  south_bridge PROPERTIES LINK_DEPENDS
                          ${PROJECT_SOURCE_DIR}/linker/south_bridge.ld)

include(ConvertElfToYasiff)

convert_elf_to_yasiff(south_bridge)
