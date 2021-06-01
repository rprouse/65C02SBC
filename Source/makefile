RM_BINARY=rm
RM_FLAGS=-rf

MD5_BINARY=md5sum

BUILD_FOLDER=build
ROM_FOLDER=$(BUILD_FOLDER)/rom
FIRMWARE_PROJECTS_FOLDER=rom

ADDRESS_MODE=ext

FIRMWARE_PROJECTS = 01_serial_test       \
                    02_int_test          \
                    03_4bit_lcd          \
                    04_serial_irq        \
                    05_blink_test        \
                    06_keyboard_test     \
                    os1                  \
										microsoft_basic

FIRMWARE_BINARIES=$(FIRMWARE_PROJECTS:%=$(ROM_FOLDER)/%.$(ADDRESS_MODE).bin)

$(ROM_FOLDER)/%.$(ADDRESS_MODE).bin:
	$(MAKE) -C $(@:$(ROM_FOLDER)/%.$(ADDRESS_MODE).bin=$(FIRMWARE_PROJECTS_FOLDER)/%) ADDRESS_MODE=$(ADDRESS_MODE) all

all: $(FIRMWARE_BINARIES) $(LOADABLE_BINARIES)

test: $(FIRMWARE_BINARIES) $(LOADABLE_BINARIES)
	@$(MD5_BINARY) $^

clean:
	$(RM_BINARY) $(RM_FLAGS) $(BUILD_FOLDER)
