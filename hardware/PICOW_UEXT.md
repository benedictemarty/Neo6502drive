# Câblage Pico W ↔ Neo6502 (modem Wi-Fi)

## Par USB (cible finale)

Pico W (micro-USB) → hub USB → port USB-A du Neo6502. Le Pico W est alimenté
par le hub ; il apparaît en périphérique **CDC-ACM**. **Prérequis : story
F-13 (hôte CDC) du dépôt Neo6502firmware** — le firmware officiel n'accepte
que HID, MSC et hub (`CFG_TUH_CDC 0`, voir `docs/NEO6502_UEXT_NOTES.md`).
Aucun câble supplémentaire.

## Par UEXT (utilisable dès maintenant)

Même rôle que le MOD-WIFI-ESP8266 : UART 115200 8N1 sur le connecteur UEXT.

| UEXT (brochage standard Olimex, 10 broches) | Signal | Pico W |
|---|---|---|
| 1 | 3,3 V | **ne pas relier** si le Pico W est alimenté par USB |
| 2 | GND | GND (ex. broche 3, 8, 13…) |
| 3 | TXD (sortie Neo6502) | GP1 (UART0 RX, broche 2) |
| 4 | RXD (entrée Neo6502) | GP0 (UART0 TX, broche 1) |
| 5–10 | I2C / SPI | libres |

- Niveaux 3,3 V des deux côtés (RP2040 des deux côtés) : aucun adaptateur.
- **Alimentation** : par le câble USB du Pico W (PC ou hub du Neo6502). Le
  Pico W en Wi-Fi consomme des pointes de quelques centaines de mA ; le
  budget du 3,3 V de l'UEXT n'est pas connu (**non vérifié**), donc ne pas
  l'utiliser pour alimenter le Pico W sans mesure préalable.
- Le brochage ci-dessus est celui **standard des connecteurs UEXT Olimex** ;
  à confirmer sur le schéma Neo6502 rev. B1 avant le premier branchement
  (`docs/NEO6502_UEXT_NOTES.md`, « non vérifié »).
- L'interrupteur de configuration du Neo6502 (RESB/NMIB/IRQB sur les GPIO
  UEXT) ne concerne que le SPI ; l'UART fonctionne dans la position livrée
  (c'est ainsi que la communauté utilise le MOD-WIFI-ESP8266).

## Test rapide depuis le PC

```
screen /dev/ttyACM0 115200
AT                         → OK
AT+CWLAP                   → liste des réseaux
AT+CWJAP_DEF="ssid","pass" → WIFI CONNECTED / WIFI GOT IP / OK
AT+CIFSR                   → adresse IP
ATDT mimuma.pl:8998        → CONNECT (mode transparent ; +++ puis ATH pour raccrocher)
```

Sur le Neo6502 : lancer `netsetup.neo` (neo-networking) pour configurer le
Wi-Fi, puis `prophet.neo`.
