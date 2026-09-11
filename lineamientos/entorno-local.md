# Entorno local

Cómo dejar DCC-BOGOTA corriendo en tu máquina, sin necesitar un proyecto de
Firebase real ni una API key de Google Maps todavía.

## Requisitos

- **Flutter** (canal estable) y su toolchain de Dart.
- **JDK 17** — lo usa la compilación de Android.
- **JDK 21** — lo usa el Firebase Local Emulator Suite (herramienta de
  Firebase CLI, no la app).
- **Firebase CLI** (`npm install -g firebase-tools` o `brew install
  firebase-cli`).
- Un emulador de **Android Studio** (prioridad de desarrollo/pruebas — ver
  principio 10 de [`docs/constitution.md`](../docs/constitution.md)) y,
  cuando aplique, **iOS Simulator** (Xcode).

## Primeros pasos

```bash
flutter pub get
```

## Backend: Firebase Local Emulator Suite

El proyecto no usa un proyecto de Firebase real todavía. Corre contra el
emulador local, proyecto de demostración `demo-dccbogota` (`.firebaserc`),
con reglas de Firestore/Storage deliberadamente permisivas ("solo para el
emulador") porque no hay datos reales en juego.

Para levantarlo:

```bash
firebase emulators:start
```

Puertos (de `firebase.json`):

| Servicio | Puerto |
|---|---|
| Auth | 9099 |
| Firestore | 8080 |
| Storage | 9199 |
| UI del emulador | 4000 |

La UI queda en <http://localhost:4000> — útil para ver/editar usuarios,
documentos de Firestore y archivos de Storage a mano mientras se prueba un
flujo (por ejemplo, aprobar un usuario nuevo desde el panel admin, o ver
un reporte anónimo antes de que exista la UI que lo lista).

## Mapa: Google Maps

Mientras no haya una API key real, el mapa mostrará un placeholder (mismo
patrón que en `amipets`: una vez exista `lib/app/maps_config.dart`, la
bandera `kGoogleMapsConfigured` controla esto). Conseguir la key es un
paso pendiente, no bloqueante para desarrollar el resto de la app.

## Correr y probar

```bash
flutter run        # con un emulador/dispositivo abierto
flutter test        # suite completa
flutter analyze     # análisis estático
dart format .        # formato
```

## Cuando exista un proyecto de Firebase real

Este es un paso futuro, no necesario para desarrollar hoy: se reemplaza
`lib/firebase_options.dart` corriendo `flutterfire configure` contra el
proyecto real, y se endurecen `firestore.rules`/`storage.rules` (hoy son
permisivas a propósito, solo válidas para el emulador).
