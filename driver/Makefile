# Programmes 6502 de Neo6502drive (64tass). make -C driver ; make -C driver test (Phosphoneo + faux modem)
PHOSPHONEO_DIR ?= $(HOME)/Phosphoneo
ASM = 64tass --mw65c02 --nostart
all: build/term.neo6502
build/term.neo6502: src/term.asm | build
	$(ASM) --output $@ $<
build:
	mkdir -p build
test: build/term.neo6502
	bash tests/test_term.sh
clean:
	rm -rf build
.PHONY: all test clean
