# Infra (Firebase Hosting + Firestore)

- `firebase.json` con rewrites a:
  - `/app/**` → Flutter web (Tutor)
  - `/vet/**` → Portal Vet (Fase 2)
  - `/p/**` → Function `publicProfile` (perfil público por QR)
  - `/api/**` → Function `api` (endpoints REST/callables)
- `firestore.rules` mínimas (endurecer en Fase 2/3).
- `firestore.indexes.json` con índices útiles.

Deploy:
  firebase deploy --only hosting
  firebase deploy --only firestore:indexes
  firebase deploy --only firestore:rules
