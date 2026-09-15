# Product Backlog

Priorité P1 > P2 > P3. État : À faire / En cours / Terminé (sprint).

| ID | P | User story | État |
|----|---|------------|------|
| US-01 | P1 | En tant que développeur, je veux un protocole bloc documenté (commandes, trames, erreurs), afin que firmware, driver et outils partagent une même spécification. | À faire (S1) |
| US-02 | P1 | En tant que développeur, je veux un simulateur Go du périphérique (protocole sur flux), afin de tester driver et outils sans matériel. | À faire (S1) |
| US-03 | P1 | En tant que développeur 6502, je veux un driver ca65 `drv_read`/`drv_write`/`drv_info` par UART (API 10,13-10,18), afin de lire et écrire des secteurs. | À faire (S1) |
| US-04 | P1 | En tant qu'utilisateur, je veux créer et inspecter des images (`.img` brut, taille libre) avec un outil PC, afin de préparer un disque. | À faire (S1) |
| US-05 | P1 | En tant qu'utilisateur, je veux un firmware Feather RP2040 servant des images depuis la microSD (FeatherWing Adalogger) par UART. | À faire (S2) |
| US-06 | P2 | En tant qu'utilisateur, je veux sélectionner plusieurs unités (DD + disquettes) et changer d'image sans redémarrer. | À faire |
| US-07 | P2 | En tant qu'utilisateur, je veux le transport SPI (API 10,11/10,12, 1 MHz) pour des transferts plus rapides. | À faire |
| US-08 | P2 | En tant qu'utilisateur, je veux servir des images depuis une clé USB (USB hôte sur le Feather). | À faire |
| US-09 | P3 | En tant qu'utilisateur, je veux quelques images en flash interne du Feather. | À faire |
| US-10 | P2 | En tant que développeur, je veux un schéma de câblage UEXT ↔ Feather (niveaux 3,3 V, alimentation) vérifié. | À faire (S1) |
| US-11 | P2 | En tant que développeur, je veux mesurer le débit réel (UART vs SPI) sur matériel et le consigner. | À faire |
| US-12 | P3 | En tant qu'utilisateur du Télémon, je veux des commandes de chargement/sauvegarde par secteurs (intégration EPIC-01 de Neo6502kbd). | À faire |

## Questions ouvertes

- Vitesse UART maximale supportée de bout en bout (firmware Neo6502 :
  `IOUARTInitialise`, tampon de réception) : à mesurer (US-11).
- Le mode esclave SPI du RP2040 à 1 MHz avec le CS du Neo6502 (GP25) : à
  valider sur matériel avant US-07.
- Format d'image : brut (`.img`, 512 o/secteur) en v1 ; `.dsk` Oric/Apple
  seulement s'il y a un usage réel.
