; cdc.s — driver série USB CDC (groupe 14 du fork Neo6502firmware, F-90) et
; petite couche modem AT pour Neo6502drive (modem Wi-Fi Pico W en USB).
; Périphérique 0 uniquement (P7 = 0). Aucune page zéro imposée en dehors de
; deux octets (segment ZEROPAGE, résolus par l'éditeur de liens).
; SPDX-License-Identifier: EUPL-1.2
; Auteur : bmarty <bmarty@mailo.com>

.include "neo6502.inc"
.include "cdc.inc"
.PC02

LINE_MAX = 120

.zeropage
ptr:        .res 2
ptr2:       .res 2

.bss
modem_lastline:
line:       .res LINE_MAX+1
linelen:    .res 1
target:     .res 2
t_start:    .res 4
modem_echo:   .res 1
modem_timeout: .res 2
initdone:   .res 1
tlen:       .res 1
synccount:  .res 1
synctmp:    .res 1

.code

; ---------------------------------------------------------------- API 14
; A = fonction ; P7 = 0
cdc_call:
    sta NEO_FUNC
    stz NEO_PARAM+7
    lda #NEO_G_CDC
    sta NEO_GROUP
@w: lda NEO_GROUP
    bne @w
    rts

cdc_status:
    jsr defaults
    lda #NEO_F_CDC_STATUS
    jsr cdc_call
    lda NEO_PARAM
    rts

cdc_getc:
    lda #NEO_F_CDC_READBYTE
    jsr cdc_call
    lda NEO_ERROR
    bne @none
    lda NEO_PARAM
    sec
    rts
@none:
    clc
    rts

cdc_putc:
    sta NEO_PARAM
    lda #NEO_F_CDC_WRITEBYTE
    jsr cdc_call
    lda NEO_ERROR
    bne @err
    clc
    rts
@err:
    sec
    rts

cdc_puts:
    stx ptr
    sty ptr+1
    ldy #0
@l: lda (ptr),y
    beq @d
    phy
    jsr cdc_putc
    ply
    iny
    bne @l
@d: rts

cdc_wait_connect:
    jsr cdc_status
    beq cdc_wait_connect
    rts

; --------------------------------------------------------------- modem
; Synchronise le modem : jusqu'à 4 fois « AT » -> « OK ». Purge un octet
; résiduel qui collerait devant la première vraie commande (vu sur le Pico W
; juste après l'ouverture du CDC). A = 0 si OK obtenu, 2 sinon.
modem_sync:
    lda #4
    sta synccount
@try:
    ldx #<s_at
    ldy #>s_at
    jsr modem_line
    ldx #<s_ok
    ldy #>s_ok
    lda modem_timeout
    pha
    lda modem_timeout+1
    pha
    lda #100                ; timeout court (1 s) par tentative
    sta modem_timeout
    stz modem_timeout+1
    jsr modem_wait
    sta synctmp
    pla
    sta modem_timeout+1
    pla
    sta modem_timeout
    lda synctmp
    beq @ok
    dec synccount
    bne @try
    lda #MODEM_TIMEOUT
    rts
@ok:
    lda #MODEM_OK
    rts

defaults:
    lda initdone
    bne @ok
    inc initdone
    lda #1
    sta modem_echo
    lda modem_timeout
    ora modem_timeout+1
    bne @ok                 ; déjà réglé par le programme
    lda #<3000
    sta modem_timeout
    lda #>3000
    sta modem_timeout+1
@ok: rts

; jette tout ce qui est en attente (réponses d'une commande précédente avortée)
modem_flush:
    jsr cdc_getc
    bcs modem_flush
    rts

modem_line:
    phx
    phy
    jsr modem_flush
    ply
    plx
    jsr cdc_puts
    lda #13
    jsr cdc_putc
    lda #10
    jmp cdc_putc

; lit le timer 100 Hz dans t_start
timer_start:
    lda #NEO_F_SYS_TIMER
    sta NEO_FUNC
    lda #NEO_G_SYSTEM
    sta NEO_GROUP
@w: lda NEO_GROUP
    bne @w
    lda NEO_PARAM
    sta t_start
    lda NEO_PARAM+1
    sta t_start+1
    rts

; C = 1 si le délai modem_timeout est écoulé depuis timer_start (16 bits)
timer_expired:
    lda #NEO_F_SYS_TIMER
    sta NEO_FUNC
    lda #NEO_G_SYSTEM
    sta NEO_GROUP
@w: lda NEO_GROUP
    bne @w
    sec
    lda NEO_PARAM
    sbc t_start
    tax
    lda NEO_PARAM+1
    sbc t_start+1
    tay                     ; Y:X = écoulé
    cpy modem_timeout+1
    bcc @no
    bne @yes
    cpx modem_timeout
    bcc @no
@yes:
    sec
    rts
@no:
    clc
    rts

; attend une ligne égale à la cible (X/Y) ; ERROR / FAIL / NO CARRIER -> 1 ;
; timeout -> 2. Les lignes reçues sont affichées si modem_echo.
modem_wait:
    stx target
    sty target+1
    jsr defaults
    jsr timer_start
    stz linelen
@loop:
    jsr cdc_getc
    bcc @idle
    cmp #13
    beq @loop               ; CR ignoré
    cmp #10
    beq @eol
    ldx linelen
    cpx #LINE_MAX
    bcs @loop
    sta line,x
    inc linelen
    bra @loop
@idle:
    jsr timer_expired
    bcc @loop
    lda #MODEM_TIMEOUT
    rts
@eol:
    lda linelen
    beq @loop               ; ligne vide
    ldx linelen
    stz line,x              ; ASCIIZ
    lda modem_echo
    beq @cmp
    ldx #<line
    ldy #>line
    jsr con_puts
    lda #13
    jsr con_putc
@cmp:
    ldx #<line
    ldy #>line
    lda target
    sta ptr
    lda target+1
    sta ptr+1
    jsr streq
    beq @found
    ldx #<s_error
    ldy #>s_error
    jsr streq_line
    beq @err
    ldx #<s_fail
    ldy #>s_fail
    jsr streq_line
    beq @err
    ldx #<s_nocarrier
    ldy #>s_nocarrier
    jsr streq_line
    beq @err
    stz linelen
    bra @loop
@found:
    lda #MODEM_OK
    rts
@err:
    lda #MODEM_ERROR
    rts

; Z = 1 si line se termine par la chaîne X/Y (« CLOSED » peut être collé à la
; fin des données : « </html>CLOSED » ; « SEND OK » vaut « OK »).
streq_line:
    stx ptr
    sty ptr+1
    ldx #<line
    ldy #>line
; Z = 1 si la chaîne X/Y (ptr2) se termine par (ptr)
streq:
    stx ptr2
    sty ptr2+1
    ldy #0                  ; longueur de la cible
@tl: lda (ptr),y
    beq @tld
    iny
    bne @tl
@tld:
    sty tlen
    ldy #0                  ; longueur de la ligne
@ll: lda (ptr2),y
    beq @lld
    iny
    bne @ll
@lld:
    cpy tlen
    bcc @ne                 ; ligne plus courte que la cible
    tya
    sec
    sbc tlen                ; décalage de départ dans la ligne
    clc
    adc ptr2
    sta ptr2
    bcc @cmp
    inc ptr2+1
@cmp:
    ldy #0
@c: lda (ptr),y
    cmp (ptr2),y
    bne @ne
    tax
    beq @eq
    iny
    bne @c
@ne:
    lda #1
    rts
@eq:
    lda #0
    rts

; attend le caractère '>' (invite d'AT+CIPSEND) ; tout le reste est ignoré
modem_wait_prompt:
    jsr defaults
    jsr timer_start
@l: jsr cdc_getc
    bcc @idle
    cmp #'>'
    bne @l
    lda #MODEM_OK
    rts
@idle:
    jsr timer_expired
    bcc @l
    lda #MODEM_TIMEOUT
    rts

; -------------------------------------------------------------- console
con_putc:
    sta NEO_PARAM
    lda #NEO_F_CON_WRITECHAR
    sta NEO_FUNC
    lda #NEO_G_CONSOLE
    sta NEO_GROUP
@w: lda NEO_GROUP
    bne @w
    rts

con_puts:
    stx ptr
    sty ptr+1
    ldy #0
@l: lda (ptr),y
    beq @d
    phy
    jsr con_putc
    ply
    iny
    bne @l
@d: rts

con_getkey:
    lda #NEO_F_CON_READKEY
    sta NEO_FUNC
    lda #NEO_G_CONSOLE
    sta NEO_GROUP
@w: lda NEO_GROUP
    bne @w
    lda NEO_PARAM
    rts

.rodata
s_at:        .byte "AT",0
s_ok:        .byte "OK",0
s_error:     .byte "ERROR",0
s_fail:      .byte "FAIL",0
s_nocarrier: .byte "NO CARRIER",0
