# Neo6502drive — cibles communes.
#   make test      tests automatisés (cœur du modem Pico W sur PC)
#   make firmware  firmware Pico W (PICO_SDK_PATH requis) → firmware/picow-modem/build/picow_modem.uf2
#   make flash     copie l'UF2 sur un Pico W en mode BOOTSEL monté sous /media ou /run/media

PICO_SDK_PATH ?= $(HOME)/pico-sdk-internal
export PICO_SDK_PATH

test:
	$(MAKE) -C firmware/picow-modem/tests test

firmware:
	cmake -S firmware/picow-modem -B firmware/picow-modem/build -DCMAKE_BUILD_TYPE=Release
	cmake --build firmware/picow-modem/build -j

flash: firmware
	@dst=$$(ls -d /media/*/RPI-RP2 /run/media/*/RPI-RP2 2>/dev/null | head -1); \
	if [ -z "$$dst" ]; then echo "Aucun volume RPI-RP2 : brancher le Pico W en maintenant BOOTSEL"; exit 1; fi; \
	cp firmware/picow-modem/build/picow_modem.uf2 "$$dst/" && echo "Flashé sur $$dst"

clean:
	$(MAKE) -C firmware/picow-modem/tests clean
	rm -rf firmware/picow-modem/build

.PHONY: test firmware flash clean
