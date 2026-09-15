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

## Recorrido de prueba completo (T9 de la spec 003)

Con al menos un reporte ya "activa" (ver recorrido de la spec 002) y
permiso de ubicación concedido al enviarlo:

1. Entra con cualquier cuenta aprobada → Mapa. Con `kGoogleMapsConfigured
   = false` verás el placeholder, pero la campana y la lista de
   marcadores ya funcionan de verdad (revisa `MapView.markers` si estás
   depurando, o simplemente confirma que la campana del `AppBar` del
   Home muestra el conteo correcto).
2. Toca el ícono de filtro y cambia entre "Hoy"/"Esta semana"/"Último
   año" — confirma que el estado vacío aparece si no hay activas en el
   rango elegido, y que reaparecen al ampliar el rango.
3. Toca la campana → debe listar la(s) emergencia(s) activa(s); toca una
   → debe abrir el detalle con sus recomendaciones según el tipo.
4. Envía un segundo reporte con un tipo de emergencia distinto (ej.
   inundación) y confírmalo como "activa" — las recomendaciones del
   detalle deben ser distintas a las del primero.
5. (Opcional, cuando exista una API key real de Google Maps) cambia
   `kGoogleMapsConfigured` a `true` en `lib/app/maps_config.dart` y
   confirma que el mapa real muestra los pines en las coordenadas
   correctas.

## Recorrido de prueba completo (T18 de la spec 004)

Con el emulador corriendo y la cuenta Admin ya sembrada:

1. Registra un funcionario ("Jane", comité "Comité Suba", dirección "Cra
   1 # 2-3") → queda "pendiente".
2. Registra un voluntario ("John") eligiendo "Comité Suba" en el
   selector de comité → queda "pendiente".
3. Con la cuenta Admin, aprueba a Jane y a John desde el Panel.
4. Entra con Jane → Chats → debe aparecer el chat "Comité Suba". Entra
   con John → debe ver el mismo chat. Mándense un mensaje desde ambas
   cuentas y confirma que se ven en tiempo real en la otra.
5. Con Jane → "Crear chats" → crea uno nuevo, agrega a John desde la
   lista de cuentas → ambos deben poder chatear ahí también.
6. Con Jane → "Mi comité" → asigna a John como delegado → confirma que
   queda marcado como delegado.
7. (Opcional) Busca "DCC Bogotá" en Chats y únete desde cualquier cuenta
   aprobada.
8. (Opcional) Con Jane, crea 5 chats personalizados y confirma que el
   sexto se bloquea; elimina uno y confirma que ya puede crear otro.

## Recorrido de prueba completo (T14 de la spec 005)

Con Jane (funcionario, comité "Comité Suba" con ubicación GPS) y John
(voluntario del mismo comité) ya aprobados, y un reporte "activa" cerca
de la ubicación de ese comité (ver recorrido de la spec 002/003):

1. Entra con John → abre la emergencia → "Comités convocados" debe
   listar "Comité Suba" (si está a menos de 10 km).
2. Toca "Responder" → "Ir" → confirma que se abren direcciones externas
   y que John aparece como participante "En camino".
3. Con Jane, haz lo mismo ("Ir").
4. Con John, toca "Ya llegué" → como es el primero, debe pedirle ubicar
   el punto de encuentro → confirma con la ubicación sugerida.
5. Con Jane, toca "Ya llegué" → no debe pedirle punto de encuentro (ya
   existe uno de John) — pero como Jane es funcionario, puede reemplazar
   el de John desde la misma pantalla si quisiera (RF-7).
6. Con John, toca "Pedir ambulancia" → confirma que se abre el marcador
   telefónico hacia 123.
7. Con John, "Finalizar mi participación" → "Ya terminé" con una foto y
   nivel de dificultad. Con Jane, "Debo retirarme" con una razón.
8. Con Jane, vuelve al detalle de la emergencia → "Cerrar emergencia" →
   confirma que el reporte pasa a "verdadera" en el Panel de Reportes.

## Recorrido de prueba completo (T9 de la spec 006)

Con John (voluntario) ya aprobado y al menos un reporte "activa" cerca de
su comité (ver recorridos de las specs 002/003/005):

1. Con John, participa y finaliza (completada o retirada, cualquiera
   cuenta) 3 emergencias distintas usando el flujo de la spec 005 ("Ir"
   → "Ya llegué" → "Ya terminé"/"Debo retirarme").
2. Entra a "Mi perfil" desde el Home → confirma que "Logros" muestra al
   menos la insignia "Primeros pasos" (y "Comprometido" si llegaste a 5),
   que "Historial de emergencias" lista las 3 con su título/tipo, y que
   el tiempo total de servicio sumado es razonable.
3. Desde otra cuenta (ej. Jane), abre un chat o el comité donde esté
   John y toca su nombre → debe abrir el mismo perfil con las mismas
   insignias e historial.
4. Desde `EmergencyResponseScreen` de una emergencia donde John haya
   participado, toca su nombre en la lista de participantes → mismo
   resultado.

## Recorrido de prueba completo (T10 de la spec 007)

Con la cuenta Admin y al menos otra cuenta aprobada de rol distinto
(ej. John, voluntario) ya sembradas:

1. Con Admin, entra a "Noticias" → toca el botón "+" → crea una
   publicación con título, cuerpo y una foto → confirma que aparece en
   la lista y, al tocarla, en el detalle con la foto y el texto
   completo.
2. Con John, entra a "Noticias" → confirma que ve la misma publicación
   pero sin ningún botón de editar/eliminar ni el "+" de crear.
3. Con Admin, edita la publicación (cambia el título, quita la foto) →
   confirma que el cambio se refleja en la lista y el detalle.
4. Con Admin, elimínala → confirma que desaparece de la lista.
5. Repite brevemente los pasos 1 y 4 en "Prepárate" (mismo
   comportamiento, otra colección de contenido).
6. Entra a "Capacítate" (con cualquier cuenta, o incluso con una cuenta
   pendiente desde `PendingApprovalScreen`) → mientras
   `kCapacitateFormUrl` siga vacío en `lib/app/capacitate_config.dart`,
   confirma el mensaje de "no disponible"; una vez configurado con la
   URL real del Google Forms, confirma que el botón "Postúlate" abre el
   formulario en el navegador/app externa.

## Recorrido de prueba completo (T4 de la spec 008)

Con cualquier cuenta aprobada (y, por separado, una cuenta con estado
pendiente/rechazado):

1. Desde el Home, entra a "Legal" → confirma que se ve el título y el
   texto completo de políticas y términos (`lib/app/legal_content.dart`
   mientras la DCC no entregue el texto definitivo).
2. Toca "Descargar PDF" → confirma que el botón se deshabilita
   brevemente ("Generando...") y que se abre el selector nativo de
   guardar/compartir con un PDF válido y legible (mismo título y texto
   que en pantalla).
3. Cierra sesión, entra con una cuenta pendiente de aprobación (o
   rechazada) → confirma que "Legal" también está disponible ahí
   (`PendingApprovalScreen`, junto a Noticias/Capacítate/Prepárate) y
   repite el paso 2.

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
