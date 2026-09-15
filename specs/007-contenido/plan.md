# Plan — Spec 007 — Noticias, Capacítate, Prepárate

## Módulos

```
lib/
├── domain/
│   ├── entities/
│   │   ├── content_kind.dart          # enum ContentKind { noticia, preparate }
│   │   └── content_post.dart          # id, kind, title, body, photoUrl?, authorId, createdAt
│   ├── exceptions.dart                 # + NotAdminException
│   └── repositories/
│       └── content_repository.dart    # watchPosts, create, update, delete
├── data/
│   └── firebase/
│       ├── content_mapper.dart
│       └── firestore_content_repository_impl.dart
└── presentation/
    └── content/
        ├── content_list_screen.dart   # reusa para Noticias y Prepárate (parametrizado por ContentKind)
        ├── content_detail_screen.dart
        ├── content_form_screen.dart   # crear/editar (solo Admin llega aquí)
        └── capacitate_screen.dart     # info + botón externo (sin repositorio)
```

Se eliminan `news_stub_screen.dart`, `capacitate_stub_screen.dart` y
`preparate_stub_screen.dart` (spec 001) — `HomeShell` pasa a apuntar a
las pantallas reales.

## Modelo de datos (Firestore)

`content_posts/{postId}`:
```
{
  kind: 'noticia' | 'preparate',
  title: string,
  body: string,
  photoUrl: string?,
  authorId: string,
  createdAt: Timestamp
}
```

## Decisiones técnicas

- **Una sola pantalla de lista parametrizada por `ContentKind`**, no dos
  pantallas casi idénticas — Noticias y Prepárate comparten forma y
  comportamiento (RF-1/RF-2), la única diferencia es el filtro y el
  título del `AppBar`.
- **Restricción de gestión solo Admin, reforzada en `data`**: igual que
  RF-7 de la spec 001, `ContentRepository.create/update/delete` reciben
  `authorRole` y lanzan `NotAdminException` si no es
  `AccountRole.admin` — la UI también oculta los controles (RF-4), pero
  la regla real vive en el repositorio.
- **Capacítate sin domain/data propio**: es contenido estático (RF-5) más
  un enlace externo, no hay nada que persistir. El enlace vive en
  `lib/app/capacitate_config.dart` como `const String
  kCapacitateFormUrl = ''` — mismo patrón que `kGoogleMapsConfigured` en
  `amipets`/spec 003: placeholder hasta tener el valor real, sin
  bloquear el resto de la spec. RF-6: si está vacío, la pantalla muestra
  un mensaje en vez de intentar `launchUrl('')`.
- **Foto opcional vía `ContentPhotoUploader` inyectable**, mismo patrón
  que `ParticipationPhotoUploader`/`uploadPhoto` en reportes: la
  implementación real sube a Firebase Storage
  (`content_photos/{postId}.jpg`) y el repositorio la llama internamente
  al crear/editar con foto nueva.
- **Editar sin tocar la foto no la borra; editar quitándola limpia
  `photoUrl`**: el formulario distingue "sin cambios", "nueva foto
  elegida" y "foto eliminada" para que `update` sepa qué hacer.

## Estrategia de tests

| RF | Cómo se prueba |
|---|---|
| RF-1/RF-2 | Widget test: `ContentListScreen` con `ContentKind.noticia` y `ContentKind.preparate` muestra solo las publicaciones de ese tipo, ordenadas; tocar una navega al detalle con el cuerpo completo. |
| RF-3 | Widget test: con `authorRole: AccountRole.admin`, aparece el FAB de crear y los botones de editar/eliminar; enviarlos llama al repositorio. |
| RF-4 | Widget test: con `authorRole` distinto de admin, no aparece ningún control de gestión. Unit test: `ContentRepository.create/update/delete` lanzan `NotAdminException` si `authorRole != admin`. |
| RF-5 | Widget test: `CapacitateScreen` con `kCapacitateFormUrl` no vacío muestra el botón y, al tocarlo, llama a `launchUrl` con esa URL. |
| RF-6 | Widget test: con `kCapacitateFormUrl` vacío (inyectado como parámetro para el test), muestra el mensaje de "no disponible" y no aparece el botón. |

## Orden de implementación

1. `domain`: `ContentKind`, `ContentPost`, `ContentRepository`,
   `NotAdminException`.
2. `data`: `FirestoreContentRepositoryImpl` con `ContentPhotoUploader`
   inyectable.
3. `presentation`: `ContentListScreen`, `ContentDetailScreen`,
   `ContentFormScreen`, `CapacitateScreen`.
4. Wiring: reemplazar los tres accesos "Próximamente" en `HomeShell` por
   las pantallas reales; registrar `ContentRepository` en `main.dart`
   con el uploader real; borrar los tres stubs.
