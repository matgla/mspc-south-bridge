/**
 * main.cpp
 *
 * Copyright (C) 2023 Mateusz Stadnik <matgla@live.com>
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation, either version
 * 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General
 * Public License along with this program. If not, see
 * <https://www.gnu.org/licenses/>.
 */

#include <hardware/gpio.h>
#include <hardware/uart.h>

#include <cstdlib>
#include <cstring>

int global;

int main(int argc, char *argv[])
{
  uart_init(uart0, 115200);

  gpio_set_function(0, GPIO_FUNC_UART);
  gpio_set_function(1, GPIO_FUNC_UART);

  uart_puts(uart0, "Hello from South Bridge!\n");

  while (true)
  {
    ++global;
    char buffer[100];
    itoa(global, buffer, 16);
    uart_puts(uart0, buffer);
  }
}
