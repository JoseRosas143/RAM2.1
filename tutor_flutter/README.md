# Tutor Flutter Starter — RegistroAnimalMX

## Pasos rápidos
1) Instala Flutter 3.x y Firebase CLI.
2) Crea App Web en Firebase y copia los valores al archivo:
   - `lib/core/firebase_options.dart` (sección kIsWeb) y `web/firebase-messaging-sw.js`.
3) `flutter pub get`
4) Ejecuta local: `flutter run -d chrome` (PWA)
5) Build web: `flutter build web` y despliega en `/app` (con firebase.json del directorio `../infra`).

## Notificaciones Web (FCM)
- Genera VAPID public key en Firebase Console → Cloud Messaging → Web → Generate key pair.
- En `main.dart`, al solicitar token usa esa VAPID key.
- `web/firebase-messaging-sw.js` debe contener tu config web.

## Autenticación
- Por ahora se permite sign-in **anónimo**. Cambiar a Google/Email en Fase 1.

## Estructura mínima de Firestore
- `pets` con campo `ownerId`.
- Agrega índices con `infra/firestore.indexes.json`.

## Producción
- Usa FlutterFire CLI para generar `firebase_options.dart` real para todas las plataformas.
