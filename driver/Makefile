# Programmes 6502 de Neo6502drive (ca65/ld65, convention du projet).
#   make -C driver            assemble build/term.bin et build/modemtest.bin
#   make -C driver test       tests Phosphoneo (faux modem, sans matériel)
#   make -C driver test-hw    tests contre le vrai Pico W (MODEM_TTY=/dev/ttyACM0)
CA65   = ca65
LD65   = ld65
CAFLAGS = --cpu 65C02 -I src
CFG    = cfg/neo.cfg
BUILD  = build
PROGS  = $(BUILD)/term.bin $(BUILD)/modemtest.bin

all: $(PROGS)

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/cdc.o: src/cdc.s src/cdc.inc src/neo6502.inc | $(BUILD)
	$(CA65) $(CAFLAGS) -l $(BUILD)/cdc.lst -o $@ $<

$(BUILD)/%.o: examples/%.s src/cdc.inc src/neo6502.inc | $(BUILD)
	$(CA65) $(CAFLAGS) -l $(BUILD)/$*.lst -o $@ $<

$(BUILD)/%.bin: $(BUILD)/%.o $(BUILD)/cdc.o $(CFG)
	$(LD65) -C $(CFG) -m $(BUILD)/$*.map -o $@ $< $(BUILD)/cdc.o

test: all
	bash tests/test_term.sh
	bash tests/test_modem_cdc.sh

test-hw: all
	MODEM_TTY=$${MODEM_TTY:-/dev/ttyACM0} bash tests/test_term.sh
	MODEM_TTY=$${MODEM_TTY:-/dev/ttyACM0} bash tests/test_modem_cdc.sh

clean:
	rm -rf $(BUILD)

.PHONY: all test test-hw clean
