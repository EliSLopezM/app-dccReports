# Tareas — Spec 007 — Noticias, Capacítate, Prepárate

Cada tarea: tests primero, luego implementación mínima para pasarlos,
`flutter analyze` + `flutter test` en verde antes de marcar `[x]`.

## Domain

- [x] **T1 — `ContentKind`, `ContentPost`, `NotAdminException`** (RF-1, RF-2)
  `domain/entities/content_kind.dart` (enum), `domain/entities/
  content_post.dart` (id, kind, title, body, photoUrl?, authorId,
  createdAt). `NotAdminException` en `domain/exceptions.dart`. Unit test:
  construir un `ContentPost` con y sin foto.
  Hecho cuando: `flutter analyze` no marca nada en `domain/`.

- [x] **T2 — `ContentRepository`** (RF-1, RF-2, RF-3, RF-4)
  Interfaz con `watchPosts(ContentKind kind)`, `create(...)`,
  `update(...)`, `delete(...)` — las tres últimas reciben `authorRole` y
  documentan que lanzan `NotAdminException` si no es Admin. Sin test
  propio (solo interfaz).
  Hecho cuando: `flutter analyze` no marca nada en `domain/`.

## Data

- [x] **T3 — `FirestoreContentRepositoryImpl`: `watchPosts`** (RF-1, RF-2)
  Test con `fake_cloud_firestore`: publicaciones filtradas por `kind` y
  ordenadas por `createdAt` descendente.
  Hecho cuando: el test pasa.

- [x] **T4 — `create`/`update`/`delete` con validación de rol** (RF-3, RF-4)
  Test: `authorRole: AccountRole.admin` crea/edita/elimina correctamente;
  cualquier otro rol lanza `NotAdminException` y no escribe nada. Test de
  `update` con foto: subir una nueva reemplaza `photoUrl`; pasar
  `removePhoto: true` lo deja en null; no tocar la foto la conserva.
  Hecho cuando: los tests pasan.

## Presentation

- [x] **T5 — `ContentListScreen`** (RF-1, RF-2, RF-4)
  Lista parametrizada por `ContentKind`, título/extracto/foto por item,
  tocar navega a `ContentDetailScreen`. Sin controles de gestión si
  `viewerRole` no es Admin. Widget tests: noticia vs. prepárate muestran
  solo lo suyo; estado vacío sin publicaciones.
  Hecho cuando: los widget tests pasan.

- [x] **T6 — `ContentDetailScreen`** (RF-1, RF-2)
  Título, foto (si existe) y cuerpo completo. Widget test básico.
  Hecho cuando: el widget test pasa.

- [x] **T7 — `ContentFormScreen` (crear/editar) y botones en la lista** (RF-3, RF-4)
  Solo accesible si `viewerRole == AccountRole.admin` (reforzado también
  en que `ContentListScreen` no muestra el acceso a otros roles). Formulario
  con título, cuerpo, foto opcional (elegir/quitar). Widget tests: Admin
  ve FAB de crear y editar/eliminar por item y funcionan; un rol no-Admin
  no ve ninguno de los tres.
  Hecho cuando: los widget tests pasan.

- [x] **T8 — `CapacitateScreen`** (RF-5, RF-6)
  Info de requisitos + botón que abre `kCapacitateFormUrl` (parámetro
  inyectable para tests) vía `launchUrl`. Si la URL está vacía, muestra
  el mensaje de "no disponible" en vez del botón. Widget tests para
  ambos casos.
  Hecho cuando: los widget tests pasan.

## Wiring final

- [ ] **T9 — Reemplazar los stubs en `HomeShell` y registrar el repositorio**
  Borrar `news_stub_screen.dart`, `capacitate_stub_screen.dart`,
  `preparate_stub_screen.dart`. `HomeShell` navega a `ContentListScreen`
  (Noticias/Prepárate) y `CapacitateScreen`, pasando `viewerRole`.
  `main.dart` registra `ContentRepository` con el uploader real a
  Firebase Storage (`content_photos/{postId}.jpg`).
  Hecho cuando: `flutter analyze` y `flutter test` (suite completa) pasan
  en verde.

- [ ] **T10 — Boot-check manual** (requiere emulador/dispositivo Android
  real, igual que las specs anteriores)
  Con la cuenta Admin: publica una noticia con foto → aparece en la
  lista y el detalle para cualquier cuenta → edítala (cambia el título,
  quita la foto) → el cambio se refleja → elimínala → desaparece. Repite
  brevemente en Prepárate. Con una cuenta no-Admin, confirma que no ve
  ningún control de gestión. En Capacítate, confirma el mensaje de "no
  disponible" (mientras `kCapacitateFormUrl` siga vacío) o que el botón
  abre el formulario real una vez configurado.
  Hecho cuando: el recorrido completo funciona y queda una captura.
