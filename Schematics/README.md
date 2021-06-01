# 6502 system schematics

This documentation provides all the information regarding my variant of BE6502 computer:

- [Differences between the builds](#deviations-from-ben-eaters-design)
- [Getting started with the PCB](#building-pcb).

## Deviations from Ben Eater's design

This section describes details of each deviation from original BE6502 design.

### Automatic power-on reset

More of a cosmetic thing, but I liked the idea of computer running automatic reset on power-up. The added appeal was that the circuitry is actually copied from the original C64, which makes it instantly 1000x cooler :) You can read more on that here:
[Dirk Grappendorf's 6502 project - RESET](https://www.grappendorf.net/projects/6502-home-computer/reset-circuit.html)

As a side note - I would strongly recommend anybody interested to read about Dirk's project, he has plenty of great insight there!

### Address decoder change

As Ben explained in his video, there are many ways to handle address decoding logic and he opted for model with 16K RAM, 16K I/O shadow and 32K ROM. He does note that it's a bit of a waste, but given the simplicity of the project it should not be a problem - and he is absolutely right.

David posted thread on [Reddit](https://www.reddit.com/r/beneater/comments/ej3lqi/65c02_address_decoder_for_32k_ram_24k_rom_and_2/) explaining what he did, how he did it and why it works. His build provides 32K RAM, 8K I/O shadow (for up to 11 devices), 24K ROM.

The key takeway here is that when porting Ben's programs you have to use this "mapping table":
|Segment|BE6502 |DB6502 |Comment |
|-------|-------------|-------------|------------------------------------------------------------------|
|RAM |0x0000-0x3fff|0x0000-0x7fff| |
|VIA1 | |0x9000 |Connected to keyboard/LCD/blink LED in my build |
|VIA2 |0x6000 |0x8800 |Can be used to run Ben's programs |
|ACIA | |0x8400 | |
|ROM |0x8000-0xffff|0xa000-0xffff|**First 8K are not accessible, but need to be burned to the chip**|

### LCD interface change

David decided to save pins on the first VIA chip with the following mapping:

| Port  | Pins    | Connection                                                                                |
| ----- | ------- | ----------------------------------------------------------------------------------------- |
| PORTA | CA1,CA2 | Keyboard controller read handshake - for IRQ based communication with keyboard controller |
| PORTA | D0-D7   | Keyboard controller data line - for transferring ASCII scancodes of pressed characters    |
| PORTB | CB1,CB2 | Not used, disconnected                                                                    |
| PORTB | D0      | Blink LED - to be used as the Arduino onboard LED, for easy debugging                     |
| PORTB | D1-D3   | LCD control signals (register select, R/W, enable)                                        |
| PORTB | D4-D7   | LCD data signals for 4-bit operation                                                      |

Afterwards it turned out that 4-bit operation is actually bit more complicated that 8-bit, and it breaks compatibility with Ben's programs. If you want to run Ben's LCD programs on this build, is to use the second VIA port and 8-bit interface.

If you want to use onboard LCD conector and 4-bit interface it is suggested to use the code I supplied in this repo. It has all the data communication routines for LCD 4-bit operation tested and ready to go.

### Extra ACIA chip for serial communication

This one is really important - thanks to ACIA chip you can actually forget about LCD and keyboard altogether, and all the input/output can be handled by the serial port. This also allows you to run programs that are loaded in runtime, over the serial line, making the ROM flashing no longer necessary. Obviously, there is a bootloader program required in ROM and one will be provided in this repo for your use shortly.

Currently my software supports only Rockwell R6551P chips and it uses fully asynchronous, buffered and IRQ driven send/receive operations.

### Extra USB->UART interface chip

With the FT230X chip onboard, you will have a 6502 computer that requires only USB cable - simply plug it in your PC, connect using serial terminal and you are good to go, nothing else needed. Power consumption is well below USB limits, even with LCD and external keyboard connected.

### PS/2 Keyboard interface and ATtiny4313 based controller

Software to be uploaded to ATtiny is provided in this repo and discussed in detail in dedicated section. You can either program the chip away from the board or use the included AVR ISP interface.

### Clock input

Clock signal can be provided in one of three ways:

1. Use onboard 1MHz oscillator - simply put jumper on J1 connector two leftmost pins,
2. Use external clock module - remove the jumper from J1 connector, and connect clock signal to middle pin,
3. Use expansion port - remove jumper from J1 connector and provide clock signal via CLK pin of the expansion port.

### 65C02 Computer Bill Of Materials

The following components are required for DB65C02 Computer

| Reference | Type                   | Value         | Description                        | Jameco                                                                  | DigiKey                                                                               |
| --------- | ---------------------- | ------------- | ---------------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| C1        | Unpolarized Capacitor  | 100 nF        | Disk, 2.5mm raster                 | [151116](https://www.jameco.com/shop/ProductDisplay?productId=151116)   | [399-4151-ND](https://www.digikey.com/products/en?keywords=399-4151-ND)               |
| C2        | Unpolarized Capacitor  | 100 nF        | Disk, 2.5mm raster                 | [151116](https://www.jameco.com/shop/ProductDisplay?productId=151116)   | [399-4151-ND](https://www.digikey.com/products/en?keywords=399-4151-ND)               |
| C3        | Unpolarized Capacitor  | 100 nF        | Disk, 2.5mm raster                 | [151116](https://www.jameco.com/shop/ProductDisplay?productId=151116)   | [399-4151-ND](https://www.digikey.com/products/en?keywords=399-4151-ND)               |
| C4        | Unpolarized Capacitor  | 100 nF        | Disk, 2.5mm raster                 | [151116](https://www.jameco.com/shop/ProductDisplay?productId=151116)   | [399-4151-ND](https://www.digikey.com/products/en?keywords=399-4151-ND)               |
| C5        | Unpolarized Capacitor  | 100 nF        | Disk, 2.5mm raster                 | [151116](https://www.jameco.com/shop/ProductDisplay?productId=151116)   | [399-4151-ND](https://www.digikey.com/products/en?keywords=399-4151-ND)               |
| C6        | Polarized Capacitor    | 10 uF         | Tube, 2.5mm raster, 5mm diameter   | [330692](https://www.jameco.com/shop/ProductDisplay?productId=330692)   | [1189-2322-ND](https://www.digikey.com/products/en?keywords=1189-2322-ND)             |
| C7        | Unpolarized Capacitor  | 100 nF        | Disk, 2.5mm raster                 | [151116](https://www.jameco.com/shop/ProductDisplay?productId=151116)   | [399-4151-ND](https://www.digikey.com/products/en?keywords=399-4151-ND)               |
| C8        | Unpolarized Capacitor  | 10 nF         | Disk, 2.5mm raster                 |                                                                         | [399-4150-ND](https://www.digikey.com/products/en?keywords=399-4150-ND)               |
| C9        | Unpolarized Capacitor  | 47 pF         | Disk, 2.5mm raster                 | [2300831](https://www.jameco.com/shop/ProductDisplay?productId=2300831) | [399-9737-ND](https://www.digikey.com/products/en?keywords=399-9737-ND)               |
| C10       | Unpolarized Capacitor  | 47 pF         | Disk, 2.5mm raster                 | [2300831](https://www.jameco.com/shop/ProductDisplay?productId=2300831) | [399-9737-ND](https://www.digikey.com/products/en?keywords=399-9737-ND)               |
| C11       | Polarized Capacitor    | 1000 uF       | Tube, 5mm raster, 10mm diameter    | [330722](https://www.jameco.com/shop/ProductDisplay?productId=330722)   | [1189-1745-ND](https://www.digikey.com/products/en?keywords=1189-1745-ND)             |
| C12       | Unpolarized Capacitor  | 100 nF        | Disk, 2.5mm raster                 | [151116](https://www.jameco.com/shop/ProductDisplay?productId=151116)   | [399-4151-ND](https://www.digikey.com/products/en?keywords=399-4151-ND)               |
| C13       | Unpolarized Capacitor  | 100 nF        | Disk, 2.5mm raster                 | [151116](https://www.jameco.com/shop/ProductDisplay?productId=151116)   | [399-4151-ND](https://www.digikey.com/products/en?keywords=399-4151-ND)               |
| C14       | Unpolarized Capacitor  | 100 nF        | Disk, 2.5mm raster                 | [151116](https://www.jameco.com/shop/ProductDisplay?productId=151116)   | [399-4151-ND](https://www.digikey.com/products/en?keywords=399-4151-ND)               |
| C15       | Unpolarized Capacitor  | 100 nF        | Disk, 2.5mm raster                 | [151116](https://www.jameco.com/shop/ProductDisplay?productId=151116)   | [399-4151-ND](https://www.digikey.com/products/en?keywords=399-4151-ND)               |
| C16       | Unpolarized Capacitor  | 100 nF        | Disk, 2.5mm raster                 | [151116](https://www.jameco.com/shop/ProductDisplay?productId=151116)   | [399-4151-ND](https://www.digikey.com/products/en?keywords=399-4151-ND)               |
| C17       | Unpolarized Capacitor  | 100 nF        | Disk, 2.5mm raster                 | [151116](https://www.jameco.com/shop/ProductDisplay?productId=151116)   | [399-4151-ND](https://www.digikey.com/products/en?keywords=399-4151-ND)               |
| D1        | LED                    | Green         | 5mm diameter (PWR)                 | [2279199](https://www.jameco.com/shop/ProductDisplay?productId=2279199) | [754-1263-ND](https://www.digikey.com/products/en?keywords=754-1263-ND)               |
| D2        | LED                    | Red           | 5mm diameter (TX)                  | [333973](https://www.jameco.com/shop/ProductDisplay?productId=333973)   | [754-1264-ND](https://www.digikey.com/products/en?keywords=754-1264-ND)               |
| D3        | LED                    | Green         | 5mm diameter (RX)                  | [2279199](https://www.jameco.com/shop/ProductDisplay?productId=2279199) | [754-1263-ND](https://www.digikey.com/products/en?keywords=754-1263-ND)               |
| D4        | LED                    | Red           | 5mm diameter (BLINK)               | [333973](https://www.jameco.com/shop/ProductDisplay?productId=333973)   | [754-1264-ND](https://www.digikey.com/products/en?keywords=754-1264-ND)               |
| FB1       | Ferrite bead small     |               |                                    | [1844580](https://www.jameco.com/shop/ProductDisplay?productId=1844580) | [490-10997-ND](https://www.digikey.com/products/en?keywords=490-10997-ND)             |
| J1        | Pin header 3x1         |               | 2.54mm raster                      |                                                                         | [2057-PH1-03-UA-ND](https://www.digikey.com/products/en?keywords=2057-PH1-03-UA-ND)   |
| J2        | Female pin header 6x1  |               | 2.54mm raster                      |                                                                         | [S7004-ND](https://www.digikey.com/products/en?keywords=S7004-ND)                     |
| J3        | USB B Micro            |               | Molex 105017-0001                  |                                                                         | [WM1399CT-ND](https://www.digikey.com/products/en?keywords=WM1399CT-ND)               |
| J4        | USB B                  |               | Standard THT horizontal USB B port | [2096245](https://www.jameco.com/shop/ProductDisplay?productId=2096245) | [2057-USB-B-S-RA-ND](https://www.digikey.com/products/en?keywords=2057-USB-B-S-RA-ND) |
| J5        | Barrel Jack            |               | Standard power input 2.1/5.5       | [101178](https://www.jameco.com/shop/ProductDisplay?productId=101178)   |                                                                                       |
| J6        | Mini-Din-6             |               | Standard THT PS/2 Keyboard port    | [119475](https://www.jameco.com/shop/ProductDisplay?productId=119475)   | [CP-2260-ND](https://www.digikey.com/products/en?keywords=CP-2260-ND)                 |
| J7        | Female pin header 16x2 |               | 2.54mm raster                      |                                                                         | [S7119-ND](https://www.digikey.com/products/en?keywords=S7119-ND)                     |
| J8        | Pin header 3x2         |               | AVR ISP 2.54mm raster              |                                                                         | [609-3234-ND](https://www.digikey.com/products/en?keywords=609-3234-ND)               |
| J9        | Pin header 12x1        |               | 2.54mm raster                      |                                                                         | [2057-PH1-12-UA-ND](https://www.digikey.com/products/en?keywords=2057-PH1-12-UA-ND)   |
| J10       | Pin header 12x1        |               | 2.54mm raster                      |                                                                         | [2057-PH1-12-UA-ND](https://www.digikey.com/products/en?keywords=2057-PH1-12-UA-ND)   |
| J11       | Female pin header 16x1 |               | 2.54mm raster                      |                                                                         | [S7049-ND](https://www.digikey.com/products/en?keywords=S7049-ND)                     |
| R1        | Resistor               | 1M            | 1/4 watt                           | [691585](https://www.jameco.com/shop/ProductDisplay?productId=691585)   |                                                                                       |
| R2        | Resistor               | 47K           | 1/4 watt                           | [691260](https://www.jameco.com/shop/ProductDisplay?productId=691260)   |                                                                                       |
| R3        | Resistor               | 10K           | 1/4 watt                           | [691104](https://www.jameco.com/shop/ProductDisplay?productId=691104)   |                                                                                       |
| R4        | Resistor               | 27            | 1/4 watt                           | [690486](https://www.jameco.com/shop/ProductDisplay?productId=690486)   |                                                                                       |
| R5        | Resistor               | 27            | 1/4 watt                           | [690486](https://www.jameco.com/shop/ProductDisplay?productId=690486)   |                                                                                       |
| R6        | Resistor               | 4K7           | 1/4 watt                           | [691024](https://www.jameco.com/shop/ProductDisplay?productId=691024)   |                                                                                       |
| R7        | Resistor               | 4K7           | 1/4 watt                           | [691024](https://www.jameco.com/shop/ProductDisplay?productId=691024)   |                                                                                       |
| R8        | Resistor               | 4K7           | 1/4 watt                           | [691024](https://www.jameco.com/shop/ProductDisplay?productId=691024)   |                                                                                       |
| R9        | Resistor               | 220           | 1/4 watt                           | [690700](https://www.jameco.com/shop/ProductDisplay?productId=690700)   |                                                                                       |
| R10       | Resistor               | 220           | 1/4 watt                           | [690700](https://www.jameco.com/shop/ProductDisplay?productId=690700)   |                                                                                       |
| R11       | Resistor               | 220           | 1/4 watt                           | [690700](https://www.jameco.com/shop/ProductDisplay?productId=690700)   |                                                                                       |
| R12       | Resistor               | 220           | 1/4 watt                           | [690700](https://www.jameco.com/shop/ProductDisplay?productId=690700)   |                                                                                       |
| R13       | Resistor               | 4K7           | 1/4 watt                           | [691260](https://www.jameco.com/shop/ProductDisplay?productId=691260)   |                                                                                       |
| RV1       | Potentiometer          | 10K           | Piher PT10-LV10-103                |                                                                         | [1993-1116-ND](https://www.digikey.com/products/en?keywords=1993-1116-ND)             |
| SW1       | Pushbutton             |               | Standard 6mm THT pushbutton        | [149948](https://www.jameco.com/shop/ProductDisplay?productId=149948)   |                                                                                       |
| U1        | IC                     | 74HC21        |                                    | [2285255](https://www.jameco.com/shop/ProductDisplay?productId=2285255) | [296-8266-5-ND](https://www.digikey.com/products/en?keywords=296-8266-5-ND)           |
| U1        | Socket                 | 14-pin        |                                    | [37197](https://www.jameco.com/shop/ProductDisplay?productId=37197)     | [ED3314-ND](https://www.digikey.com/products/en?keywords=ED3314-ND)                   |
| U2        | IC                     | 74HC00        |                                    | [45161](https://www.jameco.com/shop/ProductDisplay?productId=45161)     | [296-1563-5-ND](https://www.digikey.com/products/en?keywords=296-1563-5-ND)           |
| U2        | Socket                 | 14-pin        |                                    | [37197](https://www.jameco.com/shop/ProductDisplay?productId=37197)     | [ED3314-ND](https://www.digikey.com/products/en?keywords=ED3314-ND)                   |
| U3        | IC                     | 74HC02        |                                    | [45188](https://www.jameco.com/shop/ProductDisplay?productId=45188)     | [296-1564-5-ND](https://www.digikey.com/products/en?keywords=296-1564-5-ND)           |
| U3        | Socket                 | 14-pin        |                                    | [37197](https://www.jameco.com/shop/ProductDisplay?productId=37197)     | [ED3314-ND](https://www.digikey.com/products/en?keywords=ED3314-ND)                   |
| U4        | IC                     | NE555         |                                    | [27422](https://www.jameco.com/shop/ProductDisplay?productId=27422)     | [296-NE555P-ND](https://www.digikey.com/products/en?keywords=296-NE555P-ND)           |
| U4        | Socket                 | 8-pin         |                                    | [51626](https://www.jameco.com/shop/ProductDisplay?productId=51626)     | [ED90048-ND](https://www.digikey.com/products/en?keywords=ED90048-ND)                 |
| U5        | IC                     | 6551          | ACIA chip, see notes below         | [43318](https://www.jameco.com/shop/ProductDisplay?productId=43318)     |                                                                                       |
| U6        | IC                     | FT230XS       |                                    |                                                                         | [768-1135-1-ND](https://www.digikey.com/products/en?keywords=768-1135-1-ND)           |
| U7        | IC                     | 65C02S        |                                    | [2143638](https://www.jameco.com/shop/ProductDisplay?productId=2143638) |                                                                                       |
| U7        | Socket                 | 40-pin        |                                    | [41136](https://www.jameco.com/shop/ProductDisplay?productId=41136)     | [ED90059-ND](https://www.digikey.com/products/en?keywords=ED90059-ND)                 |
| U8        | IC                     | 28C256        |                                    | [74843](https://www.jameco.com/shop/ProductDisplay?productId=74843)     | [AT28C256-15PU-ND](https://www.digikey.com/products/en?keywords=AT28C256-15PU-ND)     |
| U8        | Socket                 | 28-pin        | Order two                          | [2289583](https://www.jameco.com/shop/ProductDisplay?productId=2289583) | [ED90520-ND](https://www.digikey.com/products/en?keywords=ED90520-ND)                 |
| U9        | IC                     | 62256         |                                    | [82472](https://www.jameco.com/shop/ProductDisplay?productId=82472)     | [1450-1480-ND](https://www.digikey.com/products/en?keywords=1450-1480-ND)             |
| U9        | Socket                 | 28-pin        |                                    | [2289583](https://www.jameco.com/shop/ProductDisplay?productId=2289583) | [ED90520-ND](https://www.digikey.com/products/en?keywords=ED90520-ND)                 |
| U10       | IC                     | ATtiny4313-PU | Add socket                         |                                                                         | [ATTINY4313-PU-ND](https://www.digikey.com/products/en?keywords=ATTINY4313-PU-ND)     |
| U10       | Socket                 | 20-pin        |                                    | [38623](https://www.jameco.com/shop/ProductDisplay?productId=38623)     | [ED90036-ND](https://www.digikey.com/products/en?keywords=ED90036-ND)                 |
| U11       | IC                     | 65C22S        |                                    | [2143591](https://www.jameco.com/shop/ProductDisplay?productId=2143591) |                                                                                       |
| U11       | Socket                 | 40-pin        |                                    | [41136](https://www.jameco.com/shop/ProductDisplay?productId=41136)     | [ED90059-ND](https://www.digikey.com/products/en?keywords=ED90059-ND)                 |
| U12       | IC                     | 65C22S        |                                    | [2143591](https://www.jameco.com/shop/ProductDisplay?productId=2143591) |                                                                                       |
| U12       | Socket                 | 40-pin        |                                    | [41136](https://www.jameco.com/shop/ProductDisplay?productId=41136)     | [ED90059-ND](https://www.digikey.com/products/en?keywords=ED90059-ND)                 |
| X1        | Crystal Oscillator     | 1MHz          |                                    | [27861](https://www.jameco.com/shop/ProductDisplay?productId=27861)     | [X937-ND](https://www.digikey.com/products/en?keywords=X937-ND)                       |
| X2        | Crystal Oscillator     | 1.8432MHz     |                                    | [27879](https://www.jameco.com/shop/ProductDisplay?productId=27879)     | [X939-ND](https://www.digikey.com/products/en?keywords=X939-ND)                       |

[
_Important note about the ACIA chip_: There are basically two types of chips that can be used. Modern, rated to higher frequencies WDC65C51 and older, Rockwell 6551P chips, rated only for 1MHz. The problem with former is that there is a bug with interrupt handling on transmit operation - both IRQ and status flag polling fail, you have to implement dead loop to wait long enough for the byte to be transmitted. Latter chip is probably no longer manufactured, but can be purchased online from Chinese sellers - these are cheap, but not all of them work correctly, so get more than one to be safe. For me the second chip worked correctly and both polling and IRQ-based transmit work as expected.