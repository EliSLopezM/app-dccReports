# Tareas — Spec 003 — Mapa y despliegue

Cada tarea: tests primero, luego implementación mínima para pasarlos,
`flutter analyze` + `flutter test` en verde antes de marcar `[x]`.

## Domain

- [x] **T1 — `EmergencyDateFilter`** (RF-1, RF-2)
  `domain/entities/date_filter.dart`: enum + `cutoff(DateTime now)` por
  valor. Unit tests: cada valor calcula el corte esperado (ej. `today`
  → medianoche del mismo día; `lastYear` → un año atrás).
  Hecho cuando: los tests de `date_filter_test.dart` pasan.

- [x] **T2 — Ampliar `EmergencyType` con `recommendations`** (RF-4)
  Agregar `List<String> recommendations` a cada entrada de
  `kEmergencyTypeCatalog` con el texto provisional de plan.md. Unit
  test: cada tipo tiene al menos una recomendación.
  Hecho cuando: el test pasa.

- [x] **T3 — Ampliar `EmergencyReportRepository`** (RF-1)
  Agregar `watchActiveReports({required DateTime since})` a la interfaz.
  Sin test propio (solo interfaz).
  Hecho cuando: `flutter analyze` no marca nada en `domain/`.

## Data

- [x] **T4 — `watchActiveReports` en `FirestoreEmergencyReportRepositoryImpl`** (RF-1)
  Filtra por `status == activa` y `createdAt >= since`. Tests con
  `fake_cloud_firestore`: reportes dentro y fuera del rango, y un
  reporte "pending"/"verdadera" que nunca debe aparecer aunque esté en
  el rango.
  Hecho cuando: los 3 casos del test pasan.

## Presentation

- [x] **T5 — `maps_config.dart` + `MapScreen` (placeholder + filtro)** (RF-1, RF-2, RF-7)
  `kGoogleMapsConfigured = false` por defecto. `MapScreen` con selector
  de `EmergencyDateFilter` (chip/dropdown) que re-consulta
  `watchActiveReports`. Con el mapa desactivado, muestra un placeholder
  pero la lista de marcadores/pines sigue siendo inspeccionable en tests
  (mismo patrón que AmiPets). Widget tests: cambiar el filtro dispara una
  nueva consulta; con 0 resultados se ve el estado vacío.
  Hecho cuando: los widget tests pasan.

- [x] **T6 — `EmergencyDetailScreen`** (RF-3, RF-4)
  Tipo, dirección, fotos, y las recomendaciones de `kEmergencyTypeCatalog`
  para ese tipo. Widget test: cambia las recomendaciones mostradas según
  `emergencyTypeId`.
  Hecho cuando: el widget test pasa.

- [x] **T7 — `ActiveReportsBell`** (RF-5, RF-6)
  Ícono con badge = cantidad de reportes de `watchActiveReports`; al
  tocarlo, lista (título/tipo/dirección) que navega a
  `EmergencyDetailScreen` al tocar un ítem. Widget tests: conteo
  correcto, navegación al detalle.
  Hecho cuando: los widget tests pasan.

## Wiring final

- [x] **T8 — Entrada "Mapa" + campana en `HomeShell`**
  Agrega acceso a `MapScreen` visible para cualquier cuenta aprobada
  (no solo Revisores), y el ícono de `ActiveReportsBell` en el `AppBar`
  del `HomeShell`.
  Hecho cuando: `flutter analyze` y `flutter test` (suite completa) pasan
  en verde.

- [ ] **T9 — Boot-check manual** (requiere emulador/dispositivo Android
  real, igual que las specs anteriores)
  Con 2+ reportes "activa" de fechas distintas: cambiar el filtro de
  fecha y confirmar que la lista de pines cambia; tocar uno y ver sus
  recomendaciones; confirmar el conteo de la campana.
  Hecho cuando: el recorrido completo funciona y queda una captura.
