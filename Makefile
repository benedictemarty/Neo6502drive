# Neo6502drive — cibles communes.
#   make test      tests automatisés (cœur du modem Pico W sur PC, terminal 6502 dans Phosphoneo)
#   make term      terminal série 6502 → driver/build/term.neo6502 (charger @800 cold)
#   make firmware  firmware Pico W (PICO_SDK_PATH requis) → firmware/picow-modem/build/picow_modem.uf2
#   make flash     copie l'UF2 sur un Pico W en mode BOOTSEL monté sous /media ou /run/media

PICO_SDK_PATH ?= $(HOME)/pico-sdk-internal
export PICO_SDK_PATH

test: test-firmware test-driver

test-firmware:
	$(MAKE) -C firmware/picow-modem/tests test

# driver 6502 (ca65) : bibliothèque CDC groupe 14, terminal et test HTTPS
driver:
	$(MAKE) -C driver

test-driver:
	$(MAKE) -C driver test

test-driver-hw:
	$(MAKE) -C driver test-hw

clean:
	$(MAKE) -C firmware/picow-modem/tests clean
	$(MAKE) -C driver clean
	rm -rf firmware/picow-modem/build

.PHONY: test test-firmware test-driver test-driver-hw driver firmware flash clean
