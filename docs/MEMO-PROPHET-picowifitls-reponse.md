# Réponse au mémo « picowifitls » — TLS sur le modem Pico W

De : projet Neo6502drive (`firmware/picow-modem`) — 2026-09-16
Pour : projet Neo6502Prophet (mémo `docs/MEMO-NEO6502DRIVE-picowifitls.md`)

## 1. Livré (US-T9, commit dans Neo6502drive, validé sur carte)

- `AT+CIPSTART="SSL","<hôte>",<port>` (dialecte ESP8266) **et**
  `AT+TLSPORT=443[,…]` persistant : toute `CIPSTART="TCP"` vers un port listé
  est faite en TLS → `prophet.neo` non modifié, `set port 443`, rien d'autre.
  `ATDT hôte:port` suit la même règle.
- `AT+CIPSSLCCONF?` répond `2` (CA vérifiée) ; `=0`/`=2` → `OK`, `=1`/`=3`
  (certificat client) → `ERROR`.
- Validation **obligatoire** : chaîne contre les racines embarquées
  (`certs/roots.pem` = ISRG Root X1, empreinte dans `certs/README.md` ;
  ajout d'autres racines = concaténer + recompiler), nom d'hôte (SNI),
  dates (heure SNTP exigée : sans heure → `no time (SNTP) for TLS` / `ERROR`).
  Pas de mode « accepter tout ». Vérifié : IP directe (nom faux) et
  www.google.com (racine GTS absente) → `TLS handshake failed`.
- Reprise de session (ticket) par hôte:port, adaptée au « une connexion par
  bloc Range ». Client TLS seulement, aucune clé privée côté modem.
- `ATI` : ligne `TLS:` (mbedTLS 3.6.2, racines, état de l'heure, durée et
  suite du dernier handshake, `resumed`, drapeaux X.509, derniers messages)
  et `TLS ports:`. `AT+TLSTEST` : autotests des primitives sur carte.

## 2. Mesures sur carte (Pico W, RP2040 125 MHz, partage de connexion 2,4 GHz)

| Cas | Durée |
|---|---|
| Handshake complet, mimuma.pl (Apache, Let's Encrypt, ECDHE-RSA-AES256-GCM-SHA384, chaîne de 4 certificats) | 2,4–2,8 s (vérification de chaîne ≈ 1,7 s) |
| Handshake repris (ticket) | 0,3–0,5 s |
| `AT+CIPSTART` → `CONNECT`, scénario Prophet (DNS + TCP + TLS), 1re connexion | 3–4 s |
| idem, connexions suivantes (repris) | **1,2 s par bloc** |
| letsencrypt.org (ECDSA P-384, CDN) | 5 s |
| Empreinte | flash 523 Ko, BSS 85 Ko, contexte TLS sur le tas newlib (~170 Ko libres) |

Le watchdog (8 s max sur RP2040) est rafraîchi par un timer prioritaire
pendant le handshake (plafond 60 s) : aucun reset observé.

## 3. Suites / prérequis côté serveur

- TLS 1.2 avec ECDHE-ECDSA ou ECDHE-RSA + AES-GCM (128/256), P-256/P-384/
  X25519 ; **pas de TLS 1.3** (PSA/RAM, non retenu pour l'instant) : le
  reverse proxy doit accepter TLS 1.2. Tickets de session côté serveur
  bienvenus (Apache les émet par défaut).
- Certificat Let's Encrypt (chaîne vers ISRG Root X1) : rien à ajouter.
  Autre autorité → me transmettre la racine (PEM + empreinte publiée).
- Le client envoie `GET /… HTTP/1.1 ` avec un **espace final** dans la ligne
  de requête (`http.inc`) : Apache répond `400`, le serveur Prophet doit
  rester tolérant (il l'était en clair).

## 4. Reste à faire ensemble

Test de bout en bout `cat` → `list games` → `get tetris` depuis `prophet.neo`
sur carte avec `set port 443` contre votre serveur HTTPS (Sprint 2), mesure
du débit `pget` réel et vérification `sha256` côté PC. Côté modem, transport
UART (UEXT) encore à valider sur le Neo6502 réel.
