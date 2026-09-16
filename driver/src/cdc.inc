; cdc.inc — driver série USB CDC (groupe 14) + couche modem AT, Neo6502drive.
; SPDX-License-Identifier: EUPL-1.2
.ifndef CDC_INC
CDC_INC = 1

.global cdc_status          ; -> A = 1 si un modem est branché (P0), sinon 0
.global cdc_getc            ; -> C = 1 et A = octet, C = 0 si rien
.global cdc_putc            ; A = octet -> C = 0 ok, C = 1 pas de périphérique
.global cdc_puts            ; X/Y = ASCIIZ (bas/haut) -> envoyée telle quelle
.global cdc_wait_connect    ; bloque jusqu'à 14,1 = connecté
.global modem_sync          ; envoie AT jusqu'à OK (purge un octet résiduel) -> A=0 ok, 2 timeout
.global modem_flush         ; jette les octets reçus en attente (réponses tardives)
.global modem_line          ; X/Y = ASCIIZ : vide l'entrée puis envoie la ligne + CRLF
.global modem_wait          ; X/Y = ligne attendue -> A = 0 trouvée, 1 ERROR/FAIL, 2 timeout
.global modem_wait_prompt   ; attend '> ' (AT+CIPSEND) -> A = 0 ok, 2 timeout
.global modem_echo          ; 0 = silencieux, ≠0 = lignes reçues affichées (défaut 1)
.global modem_timeout       ; délai de modem_wait en 1/100 s (mot, défaut 3000)
.global modem_lastline      ; ASCIIZ : dernière ligne reçue par modem_wait
.global con_puts            ; X/Y = ASCIIZ -> console (13 = fin de ligne)
.global con_putc            ; A -> console
.global con_getkey          ; -> A = touche ASCII de la file clavier (0 si aucune)

MODEM_OK      = 0
MODEM_ERROR   = 1
MODEM_TIMEOUT = 2

.endif
