# Sprints

## Sprint 0 — 2026-09-15 — « Cadrage »

**Livré** : dépôt, vision, backlog, DoD, architecture et protocole proposés,
notes vérifiées sur l'API UEXT du Neo6502.

**Décisions** : cible Neo6502 ; carte **Adafruit Feather RP2040 USB Host**
(possédée par le PO) ; **mode MSC USB d'abord** (clé virtuelle, aucun driver
6502), puis mode bloc UEXT (UART v1, SPI v2), puis télécom (EPIC-02).

## Sprint 1 — à planifier — « Prototype clé USB virtuelle sur Pi Zero W »

Stories : **US-M0**, US-M4 (outil d'images). Objectif : le Neo6502 charge un
programme depuis une image choisie via la page web du Pi ; consigner :
alimentation par le hub, délai d'apparition, comportement au changement
d'image à chaud. Prérequis : hub USB, câble micro-USB OTG, carte SD Raspberry
Pi OS Lite. Aucun firmware à écrire.

## Sprint 2 — « Clé USB virtuelle embarquée (Feather) »

Stories : US-M1, US-M2, US-M3 (reprend images et outil validés en S1).
Prérequis : Pico SDK + TinyUSB + Pico-PIO-USB.

## Sprint 3 — « Périphérique bloc UEXT »

Candidats : US-01, US-02, US-03, US-04, US-10 (tout testable sans matériel).

## Sprint 4 — « Télécom : modem Hayes et AT sur Pi Zero W »

Stories : US-T1, US-T2, US-T3, US-T4 (Pi Zero W en UART UEXT, Python ;
simulateur Go pour le driver). US-05/US-11 (firmware bloc Feather, mesures)
glissent en sprint 4 bis selon disponibilité du matériel.

## Sprint 5 — « CDC dans le firmware » (EPIC-04)

Candidats : US-C1 (build du firmware officiel), US-C2, US-C3, US-C4 ; US-C5
sur le Pi Zero W (configfs) peut être préparé dès le sprint 1 en composite
MSC + CDC, le CDC restant inactif côté Neo6502 jusqu'à US-C2.
