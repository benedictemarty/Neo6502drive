# Changelog

Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/) ;
versionnement SemVer.

## [Unreleased]

### Ajouté
- Sprint 0 (2026-09-15) : création du projet, cadrage (vision, backlog, DoD,
  architecture et protocole proposés, notes vérifiées sur l'API UEXT).
- EPIC-03 « périphérique sur BUS1 » (US-B1..B4) ; note sur l'interrupteur de
  configuration : SPI UEXT indisponible sans déconnecter RESB/NMIB/IRQB.
- US-M0 : prototype sur Raspberry Pi Zero W (gadget USB) en sprint 1 ; sprints
  replanifiés ; EPIC-02 précisée (pile TCP sur le périphérique) ; bank
  switching déclaré hors périmètre (modification du firmware).
- Réorientation : carte Feather RP2040 USB Host ; mode « clé USB virtuelle »
  (MSC) en sprint 1 (US-M1..M5), mode bloc UEXT ensuite, EPIC-02 télécom.
