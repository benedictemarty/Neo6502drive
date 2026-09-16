; neo6502.inc — sous-ensemble de l'API Neo6502 utilisé par Neo6502drive (ca65).
; Source : neo6502-firmware (firmware/common/config/*.inc) et le fork
; Neo6502firmware (groupe 14 « USB Serial (CDC) », F-90).
; Protocole : NEO_FUNC, NEO_PARAM+n, puis NEO_GROUP ; le firmware remet
; NEO_GROUP à 0 quand c'est fini ; NEO_ERROR ≠ 0 = erreur.
; SPDX-License-Identifier: EUPL-1.2

.ifndef NEO6502_INC
NEO6502_INC = 1

NEO_CTRL        = $FF00
NEO_GROUP       = NEO_CTRL+0
NEO_FUNC        = NEO_CTRL+1
NEO_ERROR       = NEO_CTRL+2
NEO_STATUS      = NEO_CTRL+3
NEO_PARAM       = NEO_CTRL+4    ; P0..P7 = $FF04..$FF0B

; --- Groupe 1 : System ---
NEO_G_SYSTEM        = 1
NEO_F_SYS_TIMER     = 1     ; P0..3 = compteur 100 Hz

; --- Groupe 2 : Console ---
NEO_G_CONSOLE       = 2
NEO_F_CON_READKEY   = 1     ; P0 = touche ASCII (0 si aucune)
NEO_F_CON_WRITECHAR = 6     ; P0 = caractère (13 = fin de ligne)

; --- Groupe 14 : USB Serial (CDC) — fork Neo6502firmware, F-90 ---
NEO_G_CDC           = 14
NEO_F_CDC_STATUS    = 1     ; P7 = périphérique -> P0 = 1 connecté, P1-2 = octets en attente
NEO_F_CDC_READBYTE  = 2     ; P7 -> P0 = octet ; NEO_ERROR si rien
NEO_F_CDC_WRITEBYTE = 3     ; P0 = octet, P7
NEO_F_CDC_READBLOCK = 4     ; P0-1 = adresse, P2-3 = max, P7 -> P2-3 = lus
NEO_F_CDC_WRITEBLOCK= 5     ; P0-1 = adresse, P2-3 = nombre, P7 -> P2-3 = écrits
NEO_F_CDC_LINECODING= 6     ; P0-3 = bauds, P4 = bits, P5 = parité, P6 = stop, P7

.endif
