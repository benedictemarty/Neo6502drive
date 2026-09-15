# Definition of Done

1. Code compilé/assemblé sans avertissement ; `go vet` propre pour l'outil.
2. Tests automatisés (`make test`) : unitaires Go, protocole (simulateur),
   driver assemblé exécuté dans le simulateur pour les stories `driver/`.
3. Firmware Feather : compile avec le Pico SDK ; test sur carte réelle
   consigné dans `docs/SPRINTS.md` quand le matériel est disponible.
4. Documentation à jour (README, ARCHITECTURE/protocole, notes vérifiées).
5. `CHANGELOG.md`, `docs/BACKLOG.md`, `docs/SPRINTS.md` mis à jour.
6. Commit par `bmarty <bmarty@mailo.com>`, message explicite, sans co-auteur.
