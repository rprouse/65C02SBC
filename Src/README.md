# 65C02 system software


### Setting up development environment

Development environment requires the following tools:

- `make` to invoke all the below,
- `cc65` compiler, available [here](https://github.com/cc65/cc65),
- `minipro` software to upload ROM image to EEPROM, available [here](https://gitlab.com/DavidGriffith/minipro/),
- `picocom` for serial communication with the computer (Linux/MacOS),
- `sz` for loadable module upload via `picocom` (Linux/MacOS),

One important thing to note is that you might need to install FTDI Virtual COM Port drivers, and it applies to all operating systems.


```shell
make clean all test
```

## Connecting via the Serial Port

- 19200 baud,
- 8-bit, no parity, 1 stop bit,
- CTS/RTS hardware flow control.

In MacOS/Linux you can use `picocom` for this operation, under Windows I have successfully used [ExtraPuTTy](https://www.extraputty.com/).

After connection is established you need to press enter as prompted (either on PS/2 keyboard or terminal window) and you will be prompted to initiate file transfer. In `picocom` this requires that your send command is set to `sz -X` (see `make terminal` target in `Software/common/makefile`) and you initiate transfer with Ctrl+A followed by Ctrl+S. Enter load file path (i.e. `Software/build/load/01_blink_test.load.bin`) and press enter. If the transfer fails, try again. `picocom` seems to fail every now and then, while ExtraPuTTy hardly ever has any issues.

In ExtraPuTTy open "Files Transfer" menu item, then "Xmodem" and "Send". Point to loadable module (i.e. `Software/build/load/02_hello_world.load.bin`) and click "Open" button.

Program should load and be automatically executed. Congratulations, you got yourself working bootloader!

### Installing OS/1

OS/1 is simple operating system, currently being developed for the machine. It already provides bootloader functionality and more is coming every day. **THIS IS WORK IN PROGRESS, SO EXPECT STABILITY ISSUES**

After installing to ROM and booting, it will display basic startup messages on onboard LCD and prompt you to connect via serial port (19200 baud, no parity, 8 data bits, 1 stop bit, CTS/RTS hardware flow control) and confirm connection by sending single char via serial, if no keyboard is connected to PS/2 port or by pressing Enter key on attached PS/2 keyboard otherwise.

Simple prompt will be displayed, and the following commands are currently supported:

- `HELP` - will display simple help message with basic description of the commands,
- `LOAD` - will initiate XModem file receive operation to enable loading loadable modules (see [Using the bootloader](#using-the-bootloader) section for details),
- `RUN` - will run the loaded program,
- `MONITOR` - will run monitor application that can be used to check/alter contents of computer memory,
- `BLINK` - with parameter `ON` or `OFF` will toggle onboard blink LED state,
- `EXIT` - will exit the shell - and go back to it after soft reset.

Loaded programs might fail or fall into infinite loop. To prevent having to reset them, you can press CTRL+X key combination on attached PS/2 keyboard - this will initiate system break operation and should return you back into the shell.

#### Using built-in monitor application

Currently monitor application is fairly limited, but it should provide sufficient functionality for basic troubleshooting. The following commands are supported:

- `GET` with single address (in format `XX` or `XXXX`) will display data from this address and 15 following bytes,
- `GET` with address range (in format `XXXX:XXXX`, zeropage addresses can be substituted with `XX`) will display all the data within given range,
- `PUT` will store provided value (in format `XXXX=XX`) under given address.

Standard commands like `HELP` and `EXIT` are obviously also supported.

## Building software

General rule is simple: `make` should be sufficient for all the build/installation. The following `make` targets are to be used for building software:

- `all` - build the project,
- `clean` - delete all temporary files,
- `test` - dump the contents and checksum of generated binary file,
- `install` - upload generated binary to AT28C256 chip using `minipro` tool,
- `terminal` - connect to the 6502 computer using serial port, please note - currently uses my own device ID as visible under MacOS and most likely needs to be adapted to your build/OS,
- `emu` - run the generated binary in system emulator. Again: suitable for simple programs, more complex ones are not yet supported. So far I needed it only for simple debugging and that's why it is so limited.

Beside the targets, there are three very important build flags:

- `ADDRESS_MODE` - with acceptable values `basic` and `ext` (the latter being default if omitted) that drives target addressing model. To build for Ben Eater's machine, use `basic` mode; for my build, use `ext` mode. If you want to support your own model, create additional configuration file, as explained in common sources section below,
- `CLOCK_MODE` - used to control internal delay routines to work with different clock setups. The following modes are supported:
  - `slow` - to be used with external clock module, all delays are basically disabled,
  - `250k` - to be used with Arduino Mega Debugger (my own variant running at approx. 275kHz),
  - `1m` - to be used with 1MHz oscillator,
  - `2m` - to be used with 2MHz oscillator,
  - `4m` - to be used with 4MHz oscillator,
  - `8m` - to be used with 8MHz oscillator.
- `LCD_MODE` - with acceptable values `8bit` and `4bit` (the latter being default if omitted) enables build time selection of LCD interface. If your own build of 6502 computer uses 8-bit interface towards LCD, this will let you use provided software with it. The only thing you might want to check is the LCD data and port definitions at the beginning of `common/source/lcd8bit.s` (or, if you are using your own build with 4-bit mode `common/source/lcd4bit.s`) for symbols `LCD_DATA_PORT` and `LCD_CONTROL_PORT`, as well as their DDR counterparts. The same is possible with 4-bit mode, but there is just one symbol - `LCD_PORT` accompanied by DDR counterpart. Default configuration is obviously immediately compatible with 4-bit onboard LCD connector, and 8-bit interface connected to VIA2 PA for control and PB for data (like in BE6502),
- `ACIA_TX_IRQ` - flag was introduced to enable compatibility with WDC65C51 ACIA chip and acceptable values are `0` and `1`. It controls usage of IRQ request to indicate that transmit operation was completed. When disabled (value `0`), fixed time delay is used to wait for the transmit operation to complete. Rockwell R6551 chips can work with both settings, but `1` is recommended.

Build examples:

```shell
make ADDRESS_MODE=basic CLOCK_MODE=slow clean all test install
```

This will build sources with Ben's addressing scheme (16K RAM, 32K ROM, VIA at 0x6000), with support for slow clocking - any delay routines will be skipped. First, all the binaries will be removed, then built from scratch, hexdump of the resulting binary will be displayed and the binary uploaded to the EEPROM, assuming it's connected via minipro-compatible programmer.

```shell
make CLOCK_MODE=1m all test
```

This command will rebuild only modified modules with support for my own addressing scheme (32K RAM, 24K ROM, VIA at 0x9000) and suitable for 1MHz execution - all delays will be enabled.

## Adding new shared code

Defining new shared function requires the following:

- implementation of the code in `common/source` folder,
- implementation of the interface include in `common/include` folder,
- adding this new function to `common/source/syscalls.s` module,
- adding stub function to `common/source/loadlib.s` module,
- adding new objects to `rom/minimal_bootloader/makefile` and `rom/22_modem_test/makefile`.

The list above should help you understand how this code reusability has been achieved.
