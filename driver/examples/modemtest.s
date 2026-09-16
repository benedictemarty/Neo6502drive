; modemtest.s — test du modem Wi-Fi Pico W branché en USB sur le Neo6502
; (groupe 14, fork Neo6502firmware) : identité, IP, requête HTTPS via
; AT+TLSPORT=443 avec le client « TCP » inchangé, affichage de la réponse.
; Exécution : Phosphoneo --headless avec NEO_CDC_TTY=/dev/ttyACM0 (vrai modem)
; ou le faux modem driver/test/fake_picow_modem.py.
; SPDX-License-Identifier: EUPL-1.2
; Auteur : bmarty <bmarty@mailo.com>

.include "neo6502.inc"
.include "cdc.inc"
.PC02

.macro say s
    ldx #<s
    ldy #>s
    jsr con_puts
.endmacro

.macro at s, expect
    ldx #<s
    ldy #>s
    jsr modem_line
    ldx #<expect
    ldy #>expect
    jsr modem_wait
    jsr check
.endmacro

.segment "STARTUP"
    jmp start
    jmp start
    jmp start

; Délai modem : 3000 (30 s) par défaut ; l'émulateur (≈40× plus rapide que le
; réel) fournit sa valeur hors du binaire, à $07FC : "TO" puis mot en 1/100 s
; (--poke-at, avant le chargement à $0800 qui écraserait un mot dans le code).
CFG_MAGIC = $07FC
CFG_TIMEOUT = $07FE

.code
start:
    lda #<3000
    sta modem_timeout
    lda #>3000
    sta modem_timeout+1
    lda CFG_MAGIC
    cmp #'T'
    bne @nocfg
    lda CFG_MAGIC+1
    cmp #'O'
    bne @nocfg
    lda CFG_TIMEOUT
    sta modem_timeout
    lda CFG_TIMEOUT+1
    sta modem_timeout+1
@nocfg:
    say m_title
    say m_delay
    lda modem_timeout+1
    jsr hex2
    lda modem_timeout
    jsr hex2
    lda #13
    jsr con_putc
    jsr cdc_wait_connect
    say m_conn
    stz modem_echo
    jsr modem_sync              ; purge un octet résiduel, modem prêt
    jsr check
    at c_ate0, r_ok
    lda #1
    sta modem_echo
    at c_ati, r_ok
    at c_cifsr, r_ok
    at c_tlsport, r_ok
    say m_https
    at c_cipstart, r_ok         ; CONNECT puis OK (TLS car port 443 listé)
    stz modem_echo
    ldx #<c_cipsend
    ldy #>c_cipsend
    jsr modem_line
    jsr modem_wait_prompt
    jsr check
    ldx #<c_get
    ldy #>c_get
    jsr cdc_puts                ; exactement 35 octets, comme annoncé
    ldx #<r_sendok
    ldy #>r_sendok
    jsr modem_wait
    jsr check
    lda #1
    sta modem_echo
    ldx #<r_closed              ; +IPD,n:… affiché ligne à ligne jusqu'à CLOSED
    ldy #>r_closed
    jsr modem_wait
    jsr check
    stz modem_echo
    at c_tlsport0, r_ok
    say m_fin
halt:
    jmp halt                    ; JMP * : arrêt de Phosphoneo (--stop-on-self-jmp)

; A -> deux chiffres hexadécimaux sur la console
hex2:
    pha
    lsr
    lsr
    lsr
    lsr
    jsr hex1
    pla
    and #15
hex1:
    cmp #10
    bcc @d
    adc #6
@d: adc #'0'
    jmp con_putc

; A = résultat de modem_wait : 0 continue, sinon affiche et s'arrête
check:
    cmp #MODEM_OK
    beq @ok
    cmp #MODEM_ERROR
    beq @err
    say m_timeout
    jmp halt
@err:
    say m_error
    ldx #<modem_lastline
    ldy #>modem_lastline
    jsr con_puts
    lda #13
    jsr con_putc
    jmp halt
@ok:
    rts

.rodata
m_title:    .byte "Neo6502drive modem CDC test",13,"attente du modem (14,1)...",13,0
m_conn:     .byte "modem connecte",13,0
m_delay:    .byte "delai modem (1/100 s, hex): ",0
m_https:    .byte "HTTPS mimuma.pl:443 via AT+TLSPORT",13,0
m_fin:      .byte "FIN",13,0
m_error:    .byte "ECHEC: ERROR du modem, ligne: ",0
m_timeout:  .byte "ECHEC: timeout",13,0
c_ate0:     .byte "ATE0",0
c_ati:      .byte "ATI",0
c_cifsr:    .byte "AT+CIFSR",0
c_tlsport:  .byte "AT+TLSPORT=443",0
c_tlsport0: .byte "AT+TLSPORT=0",0
c_cipstart: .byte "AT+CIPSTART=",34,"TCP",34,",",34,"mimuma.pl",34,",443",0
c_cipsend:  .byte "AT+CIPSEND=35",0
c_get:      .byte "GET / HTTP/1.0",13,10,"Host: mimuma.pl",13,10,13,10,0
r_ok:       .byte "OK",0
r_sendok:   .byte "SEND OK",0
r_closed:   .byte "CLOSED",0
