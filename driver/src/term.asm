; ***************************************************************************************
;
;      Name :      term.asm
;      Author :    bmarty <bmarty@mailo.com>
;      Purpose :   Terminal série pour le Neo6502 (US-T9) : le clavier part vers le modem
;                  USB CDC (API groupe 14 du fork Neo6502firmware, F-90), ce qui arrive du
;                  modem s'affiche sur la console. Pour parler à un modem Hayes / au Pico W
;                  Wi-Fi modem : ATI, ATDT hote:port, +++, ATH...
;
;      Touches :   Échap = quitter (RTS vers l'appelant / le Télémon) ; Entrée envoie CR.
;      Affichage : CR ignoré, LF = nouvelle ligne ; les octets < 32 autres sont ignorés.
;
;      64tass --mw65c02 --nostart --output=term.neo6502 term.asm   (charger @800, cold)
;
; ***************************************************************************************

* = $800

API_COMMAND    = $FF00
API_FUNCTION   = $FF01
API_ERROR      = $FF02
API_PARAMETERS = $FF04

G_CONSOLE = 2
G_CDC     = 14

start:
  ldx #<banner
  ldy #>banner
  jsr print
wait_modem:
  stz API_PARAMETERS+7        ; périphérique CDC 0
  lda #1
  jsr cdc                     ; 14,1 statut
  lda API_PARAMETERS
  bne connected
  jsr key                     ; Échap pendant l'attente = sortie
  cmp #27
  beq quit
  bra wait_modem
connected:
  ldx #<online
  ldy #>online
  jsr print

loop:
  ; --- modem -> écran : vide tout ce qui est disponible
rx:
  stz API_PARAMETERS+7
  lda #2
  jsr cdc                     ; 14,2 lecture d'un octet
  lda API_ERROR
  bne tx                      ; rien
  lda API_PARAMETERS
  cmp #13
  beq rx                      ; CR ignoré
  cmp #10
  bne rx_char
  lda #13                     ; LF -> nouvelle ligne console
  jsr wchar
  bra rx
rx_char:
  cmp #32
  bcc rx                      ; autres codes de contrôle ignorés
  cmp #127
  bcs rx
  jsr wchar
  bra rx

  ; --- clavier -> modem
tx:
  jsr key
  beq check_link
  cmp #27
  beq quit
  cmp #8                      ; Backspace : envoyé tel quel (le modem gère l'édition)
  beq send
  cmp #13
  beq send
  cmp #32
  bcc check_link
send:
  sta API_PARAMETERS
  stz API_PARAMETERS+7
  lda #3
  jsr cdc                     ; 14,3 écriture d'un octet
check_link:
  stz API_PARAMETERS+7
  lda #1
  jsr cdc                     ; le modem est-il toujours là ?
  lda API_PARAMETERS
  bne loop
  ldx #<lost
  ldy #>lost
  jsr print
  bra wait_modem

quit:
  ldx #<bye
  ldy #>bye
  jsr print
  rts

; --- utilitaires -------------------------------------------------------------------------
cdc:                          ; A = fonction du groupe 14
  sta API_FUNCTION
  lda #G_CDC
  sta API_COMMAND
  bra wait_api

key:                          ; -> A = caractère ASCII de la file firmware (0 si rien)
  lda #1                      ; 2,1 lecture clavier
  sta API_FUNCTION
  lda #G_CONSOLE
  sta API_COMMAND
  jsr wait_api
  lda API_PARAMETERS
  rts

wchar:                        ; A = caractère
  pha
  sta API_PARAMETERS
  lda #6                      ; 2,6 écriture console
  sta API_FUNCTION
  lda #G_CONSOLE
  sta API_COMMAND
  jsr wait_api
  pla
  rts

wait_api:
  lda API_COMMAND
  bne wait_api
  rts

print:                        ; X/Y = chaîne ASCIIZ
  stx ptr
  sty ptr+1
  ldy #0
pl:
  lda (ptr),y
  beq pd
  phy
  jsr wchar
  ply
  iny
  bne pl
pd:
  rts

ptr = $F0

banner: .text "NEO TERM - serie USB CDC (Echap = quitter)", 13, "Attente du modem...", 13, 0
online: .text "Modem connecte. Tapez AT.", 13, 0
lost:   .text 13, "Modem deconnecte.", 13, 0
bye:    .text 13, "Fin.", 13, 0
