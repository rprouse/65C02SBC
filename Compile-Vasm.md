## Compile VASM for Windows from WSL

```sh
sudo apt-get install gcc-mingw-w64

mkdir obj

make CPU=z80 SYNTAX=oldstyle CC=x86_64-w64-mingw32-gcc CFLAGS='-Os' LDFLAGS="-s -static" TARGETEXTENSION=.exe

make CPU=6502 SYNTAX=oldstyle CC=x86_64-w64-mingw32-gcc CFLAGS='-Os' LDFLAGS="-s -static" TARGETEXTENSION=.exe
```

## Compile Assembly using VASM

```sh
vasm6502_oldstyle.exe -Fbin -dotdir -o blink.bin blink.asm
```

## View HEX using Powershell

```ps
Format-Hex blink.bin

Format-Hex blink.bin | select -first 10
```