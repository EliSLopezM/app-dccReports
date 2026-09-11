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

## Crear la cuenta Admin (semilla manual, RF-5)

El rol Admin no se pide desde el formulario de registro (a propósito —
ver `specs/001-fundacional/plan.md`). Para tener con qué aprobar las
primeras cuentas:

1. Con el emulador corriendo, abre la UI en <http://localhost:4000>.
2. Pestaña **Authentication** → "Add user" → crea el usuario con tu
   correo (o el correo sintético `<dígitos>@phone.dccbogota.app` si vas a
   usar teléfono) y una contraseña. Copia el **User UID** generado.
3. Pestaña **Firestore** → colección `accounts` → "Add document" → usa
   ese mismo UID como id del documento, con estos campos:
   ```json
   {
     "name": "Tu nombre",
     "email": "tu-correo@example.com",
     "phone": null,
     "role": "admin",
     "status": "approved",
     "activeCourseIds": [],
     "organization": null,
     "createdAt": <timestamp actual>,
     "reviewedBy": null,
     "reviewedAt": null
   }
   ```
4. Ya puedes iniciar sesión en la app con ese correo/contraseña y verás
   acceso al Panel.

## Recorrido de prueba completo (T16 de la spec 001)

Con el emulador corriendo y la cuenta Admin ya sembrada:

1. `flutter run` en un emulador/dispositivo Android.
2. Regístrate como voluntario de prueba → debe quedar en "pendiente"
   (solo ves Noticias/Capacítate/Prepárate).
3. Cierra sesión, entra con la cuenta Admin, ve a Panel, aprueba esa
   cuenta.
4. Cierra sesión, vuelve a entrar con la cuenta del voluntario → debe
   entrar directo a Home.
5. (Opcional) repite el registro con un rol funcionario/líder
   funcionario para confirmar que pide organización, y que una cuenta
   Funcionario normal (no Admin) no puede aprobarla (RF-7) — solo Admin
   ve los botones de aprobar/rechazar en esa fila del Panel.

## Recorrido de prueba completo (T12 de la spec 002)

Con el emulador corriendo (incluido Storage, puerto 9199):

1. Desde la pantalla de Login (sin iniciar sesión), toca "Reportar una
   emergencia", completa título/dirección/tipo, agrega 2 fotos, y
   envíalo sin dar nombre ni teléfono.
2. Entra con una cuenta Revisora (Admin/Funcionario/Líder funcionario) →
   Reportes → debe aparecer "pendiente" con la evidencia (nombre/
   teléfono en blanco, pero con un `deviceId`).
3. Cámbialo a "Activa" y confirma que el estado se actualiza en la
   lista.
4. Desde el mismo dispositivo, envía 3 reportes más seguidos (ya son 4
   en la última hora) → el cuarto debe bloquearse con el mensaje de
   antispam (RF-7).

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
