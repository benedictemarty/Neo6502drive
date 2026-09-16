# Mémo — périphérique réseau « N: » pour le Neo6502 (proposition)

De : projet Neo6502Prophet — 2026-09-16
Pour : projets **Neo6502firmware** (fork bmarty, groupe 3) et **Neo6502drive**
(modem Pico W, story US-T3 « proxy de sockets »). Proposition à mettre au
backlog ; rien de tout cela n'existe aujourd'hui (vérifié : `api-listing.md`,
`firmware/common/sources/interface/fileinterface.cpp`, backlog du fork).

## Idée (modèle FujiNet / Atari `N:`)
Le firmware reconnaît un préfixe **`N:`** dans les noms de fichiers du groupe 3
et délègue l'accès au modem : le programme lit/écrit une ressource réseau
**comme un fichier**, sans parser AT ni HTTP.

```
LOAD "N:HTTP://prophet.3617.fr:8998/files/tetris/0"      (NeoBASIC)
3,4 open  "N:HTTP://…"  → canal ; 3,8 read ; 3,5 close   (API)
```
Bénéfices : tout programme (BASIC, cc65, Pascal) devient client réseau en une
ligne ; `prophet.neo`/ProphetGui se réduisent à des `LOAD` ; le TLS reste dans
le modem (`AT+TLSPORT` / `N:HTTPS://`).

## Partage des rôles
| Où | Quoi |
|---|---|
| **Modem (Neo6502drive, US-T3)** | proxy binaire déjà prévu : open/read/write/close, DNS, statut, 4 connexions, non bloquant. Y ajouter un mode « **flux HTTP** » : `open(url)` fait la requête GET (Host, Range optionnel), renvoie code + Content-Length, puis `read(n)` sert le corps. Le 6502 ne voit jamais l'en-tête. |
| **Firmware (fork, groupe 3)** | dans `FIOReadFile`/`FISOpenFileHandle` : si le nom commence par `N:` (insensible à la casse) → canal virtuel routé vers le proxy du modem (via UART/CDC, routage 10,19). `3,2 Load File` → GET complet en mémoire ; `3,4/8/5` → flux ; `3,16 File Stat` → HEAD ou Content-Length. Erreurs : réutiliser les codes `FIOERROR_*` (+ un code « réseau »). |
| **Serveur Prophet** | rien à changer (HTTP/1.1, `Range`, `/sha256`). |

## Contraintes vérifiées / à vérifier
- Le firmware charge un `.neo` par `FIOReadFile` (en-tête `NEO` puis blocs) :
  avec `N:` le `run "N:…"` fonctionnerait tel quel — à condition que la lecture
  soit bloquante avec timeout (le chargeur lit octet par octet, sans reprise).
- Débit : UART 115 200 bauds ≈ 11 Ko/s max ; un `.neo` de 20 Ko ≈ 2 s. CDC USB
  bien plus rapide (F-90) — non mesuré.
- Sécurité : le préfixe `N:` ne doit **jamais** être accepté pour l'écriture
  vers des hôtes non prévus sans consentement ; prévoir une liste d'hôtes
  autorisés dans le modem (`AT+NHOSTS=…`) ou au moins un journal. Un `.neo`
  malveillant pourrait sinon exfiltrer le stockage via `N:` — à traiter avec
  l'audit `neo-sandbox` (appels 3,x avec nom `N:` = à signaler).
- Le SHA-256 côté client reste utile (le modem pourrait aussi le calculer :
  `N:…#sha256` — idée, non chiffrée).

## Étapes proposées
1. US-T3 (modem) + mode flux HTTP — Neo6502drive.
2. `N:` en lecture seule dans le fork firmware (`3,2`, `3,4` mode 0, `3,8`, `3,5`,
   `3,16`) + test Phosphoneo avec le faux modem de ProphetGui (`tools/fake_modem.py`
   sait déjà relayer vers un vrai serveur).
3. NeoBASIC `LOAD "N:…"` et `run "N:…"` ; puis ProphetGui « mode N: » (un `LOAD`
   par fichier) en gardant le mode AT pour les modems ESP8266 sans proxy.
