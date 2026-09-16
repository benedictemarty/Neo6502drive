; term.s — terminal série pour le Neo6502 (US-T9), version ca65 au-dessus de la
; bibliothèque cdc (driver/src/cdc.s). Le clavier part vers le modem USB CDC
; (API groupe 14, fork Neo6502firmware F-90), ce qui arrive du modem s'affiche.
; Pour un modem Hayes / le Pico W Wi-Fi modem : ATI, ATDT hote:port, +++, ATH...
; Échap = quitter (RTS vers l'appelant / le Télémon) ; Entrée envoie CR.
; SPDX-License-Identifier: EUPL-1.2
; Auteur : bmarty <bmarty@mailo.com>

.include "neo6502.inc"
.include "cdc.inc"
.PC02

.segment "STARTUP"
    jmp start
    jmp start
    jmp start

.code
start:
    ldx #<banner
    ldy #>banner
    jsr con_puts
wait_modem:
    jsr cdc_status
    bne connected
    jsr con_getkey              ; Échap pendant l'attente = sortie
    cmp #27
    beq quit
    bra wait_modem
connected:
    ldx #<online
    ldy #>online
    jsr con_puts
loop:
@rx:                            ; modem -> écran : vider tout le disponible
    jsr cdc_getc
    bcc @tx                     ; rien à lire
    cmp #13
    beq @rx                     ; CR ignoré
    cmp #10
    bne @rxchar
    lda #13                     ; LF -> nouvelle ligne console
    jsr con_putc
    bra @rx
@rxchar:
    cmp #32
    bcc @rx                     ; autres codes de contrôle ignorés
    cmp #127
    bcs @rx
    jsr con_putc
    bra @rx
@tx:                            ; clavier -> modem
    jsr con_getkey
    beq @link
    cmp #27
    beq quit
    cmp #8                      ; Backspace : envoyé tel quel
    beq @send
    cmp #13
    beq @send
    cmp #32
    bcc @link
@send:
    jsr cdc_putc
@link:
    jsr cdc_status              ; le modem est-il toujours là ?
    bne loop
    ldx #<lost
    ldy #>lost
    jsr con_puts
    bra wait_modem
quit:
    ldx #<bye
    ldy #>bye
    jsr con_puts
    rts

.rodata
banner: .byte "NEO TERM - serie USB CDC (Echap = quitter)",13,"Attente du modem...",13,0
online: .byte "Modem connecte. Tapez AT.",13,0
lost:   .byte 13,"Modem deconnecte.",13,0
bye:    .byte 13,"Fin.",13,0
