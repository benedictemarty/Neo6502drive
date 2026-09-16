; uarttest.s — prouve le routage UART -> CDC (F-93) : ce programme n'utilise QUE
; l'API UART UEXT (10,15/16/17/18), comme netsetup.neo / prophet.neo, sans jamais
; toucher au groupe 14. En mode routage AUTO (défaut) et avec un modem CDC branché,
; il doit dialoguer avec le modem : ATE0, ATI -> identification + OK.
; Charger @800, cold.  SPDX-License-Identifier: EUPL-1.2
; Auteur : bmarty <bmarty@mailo.com>

.include "neo6502.inc"
.include "cdc.inc"
.PC02

NEO_G_UEXT       = 10
NEO_F_UART_SPEED = 15
NEO_F_UART_WBYTE = 16
NEO_F_UART_RBYTE = 17
NEO_F_UART_AVAIL = 18

.zeropage
uptr: .res 2
.bss
tmo:   .res 2                  ; fenêtre d'affichage en 1/100 s
tstart: .res 2

.segment "STARTUP"
    jmp start
    jmp start
    jmp start

CFG_MAGIC   = $07FC
CFG_TIMEOUT = $07FE

.code
start:
    lda #<200                  ; 2 s par défaut ; l'émulateur relève via --poke-at
    sta tmo
    lda #>200
    sta tmo+1
    lda CFG_MAGIC
    cmp #'T'
    bne @nocfg
    lda CFG_MAGIC+1
    cmp #'O'
    bne @nocfg
    lda CFG_TIMEOUT
    sta tmo
    lda CFG_TIMEOUT+1
    sta tmo+1
@nocfg:
    ldx #<banner
    ldy #>banner
    jsr con_puts
    jsr uart_setup             ; 10,15 : 115200 8N1 (route AUTO -> CDC si modem)
    ldx #<c_ate0
    ldy #>c_ate0
    jsr uart_sendln
    jsr uart_drain
    ldx #<c_ati
    ldy #>c_ati
    jsr uart_sendln
    jsr uart_show              ; affiche la réponse pendant la fenêtre configurée
    ldx #<done
    ldy #>done
    jsr con_puts
halt:
    jmp halt

uart_setup:
    lda #<115200
    sta NEO_PARAM
    lda #>115200
    sta NEO_PARAM+1
    lda #^115200
    sta NEO_PARAM+2
    lda #<(115200 >> 24)
    sta NEO_PARAM+3
    stz NEO_PARAM+4            ; protocole 0 = 8N1
    lda #NEO_F_UART_SPEED
    sta NEO_FUNC
    lda #NEO_G_UEXT
    sta NEO_GROUP
@w: lda NEO_GROUP
    bne @w
    rts

uart_wbyte:                    ; A -> 10,16
    sta NEO_PARAM
    lda #NEO_F_UART_WBYTE
    sta NEO_FUNC
    lda #NEO_G_UEXT
    sta NEO_GROUP
@w: lda NEO_GROUP
    bne @w
    rts

uart_sendln:                   ; X/Y = ASCIIZ + CRLF
    stx uptr
    sty uptr+1
    ldy #0
@l: lda (uptr),y
    beq @d
    phy
    jsr uart_wbyte
    ply
    iny
    bne @l
@d: lda #13
    jsr uart_wbyte
    lda #10
    jmp uart_wbyte

; lit un octet : C=1 et A=octet, C=0 si rien (10,18 puis 10,17)
uart_getc:
    lda #NEO_F_UART_AVAIL
    sta NEO_FUNC
    lda #NEO_G_UEXT
    sta NEO_GROUP
@w: lda NEO_GROUP
    bne @w
    lda NEO_PARAM
    beq @none
    lda #NEO_F_UART_RBYTE
    sta NEO_FUNC
    lda #NEO_G_UEXT
    sta NEO_GROUP
@w2: lda NEO_GROUP
    bne @w2
    lda NEO_ERROR
    bne @none
    lda NEO_PARAM
    sec
    rts
@none:
    clc
    rts

; vide ce qui reste (~court), sans afficher
uart_drain:
    ldx #40
@l: jsr uart_getc
    bcc @dec
    ldx #40
    bra @l
@dec:
    dex
    bne @l
    rts

; affiche ce qui arrive pendant la fenêtre tmo (1/100 s), mesurée au timer 1,1
uart_show:
    jsr timer_now
    sta tstart
    stx tstart+1
@l: jsr uart_getc
    bcc @chk
    cmp #10
    bne @pr
    lda #13
@pr:
    cmp #32
    bcc @ctl
    jsr con_putc
    bra @l
@ctl:
    cmp #13
    bne @l
    jsr con_putc
    bra @l
@chk:
    jsr timer_now             ; A=bas, X=haut
    sec
    sbc tstart
    tay
    txa
    sbc tstart+1              ; A:Y = écoulé
    cmp tmo+1
    bcc @l
    bne @done
    cpy tmo
    bcc @l
@done:
    rts

timer_now:                    ; -> A = octet bas, X = octet haut du timer 100 Hz
    lda #1
    sta NEO_FUNC
    lda #1
    sta NEO_GROUP
@w: lda NEO_GROUP
    bne @w
    lda NEO_PARAM
    ldx NEO_PARAM+1
    rts

.rodata
banner: .byte "UART -> CDC (F-93) : API UART seule",13,0
c_ate0: .byte "ATE0",0
c_ati:  .byte "ATI",0
done:   .byte 13,"FIN",13,0
