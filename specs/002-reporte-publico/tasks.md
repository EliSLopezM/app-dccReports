# Tareas — Spec 002 — Reporte público y moderación

Cada tarea: tests primero, luego implementación mínima para pasarlos,
`flutter analyze` + `flutter test` en verde antes de marcar `[x]`.

## Domain

- [x] **T1 — Entidades: `ReportStatus`, catálogo de tipos, `EmergencyReport`** (RF-2, RF-4, RF-5, RF-6)
  `domain/entities/report_status.dart`, `emergency_type_catalog.dart`,
  `reporter_evidence.dart`, `emergency_report.dart`. Unit tests: crear un
  reporte válido con y sin nombre/teléfono; estado inicial siempre
  `pending`.
  Hecho cuando: `flutter test test/domain/entities/emergency_report_test.dart` pasa.

- [x] **T2 — Interfaz `EmergencyReportRepository` + excepciones** (RF-7, RF-8, RF-9, RF-12)
  `domain/repositories/emergency_report_repository.dart`, más
  `SpamLimitExceededException` en `domain/exceptions.dart`. Sin test
  propio (solo interfaz).
  Hecho cuando: `flutter analyze` no marca nada en `domain/`.

## Data

- [x] **T3 — `DeviceIdProvider`** (RF-4)
  `data/device/device_id_provider.dart`: genera un uuid la primera vez,
  lo persiste en `shared_preferences`, lo reutiliza después. Tests con
  `SharedPreferences.setMockInitialValues`.
  Hecho cuando: test de "mismo id en dos llamadas" pasa.

- [x] **T4 — `FirestoreEmergencyReportRepositoryImpl`: enviar reporte** (RF-2, RF-3, RF-6)
  `submit(...)` sube fotos a Storage (función de subida inyectada, mismo
  patrón que amipets) y crea el documento con `status: pending`. Tests
  con `fake_cloud_firestore`: reporte con 2+ fotos pasa; con menos de 2
  lanza excepción.
  Hecho cuando: ambos tests pasan.

- [x] **T5 — Antispam por dispositivo** (RF-7)
  Antes de crear el reporte, cuenta cuántos tiene ese `deviceId` en la
  última hora; si son 3 o más, lanza `SpamLimitExceededException`. Tests:
  3 reportes seguidos pasan, el 4to lanza la excepción; pasada la hora
  (con un reloj inyectable `now`), se permite de nuevo.
  Hecho cuando: los 3 tests pasan.

- [x] **T6 — Lectura: todos los reportes y por dispositivo/teléfono** (RF-8, RF-12)
  `watchAllReports()`, `watchReportsByDevice(deviceId)`,
  `watchReportsByPhone(phone)`. Tests con `fake_cloud_firestore`
  sembrando reportes de varios dispositivos.
  Hecho cuando: los tests de lectura pasan.

- [x] **T7 — Cambiar estado** (RF-9, RF-10)
  `updateStatus(reviewerId, reportId, newStatus)`. Test: pasa de
  `pending` a `activa`, y de `activa` a `falsaControlada` (no es de un
  solo sentido, ver Casos límite de spec.md).
  Hecho cuando: el test pasa.

## Presentation

- [x] **T8 — `PublicReportScreen`** (RF-1, RF-2, RF-3, RF-5)
  Formulario sin `AuthRepository`: título, dirección, tipo (dropdown del
  catálogo), selector de fotos (mínimo 2, `image_picker`), nombre/
  teléfono opcionales. Widget tests: envío válido; bloqueo con 1 foto;
  bloqueo con campos vacíos; envío sin nombre/teléfono no se bloquea.
  Hecho cuando: los 4 widget tests pasan.

- [x] **T9 — `PanelReportsListScreen`** (RF-8)
  Lista de reportes con filtro por estado (mismo patrón que
  `PanelAccountsListScreen`), visible solo para Revisores. Widget test
  con `fake_cloud_firestore`.
  Hecho cuando: el widget test pasa.

- [x] **T10 — `ReportDetailScreen`** (RF-8, RF-9, RF-11)
  Detalle: fotos, tipo, dirección, evidencia del reportante
  (nombre/teléfono/deviceId), botones para cambiar de estado, y acceso a
  "ver historial de este dispositivo/teléfono" (RF-12). Widget test:
  la evidencia se muestra en esta pantalla (control indirecto de RF-11 —
  ninguna otra pantalla pública la expone porque `PublicReportScreen` no
  la lee de vuelta).
  Hecho cuando: el widget test pasa.

## Wiring final

- [x] **T11 — Providers + puntos de entrada en `main.dart`/`AuthGate`/`HomeShell`**
  Agrega `EmergencyReportRepository` a los `Provider`s de `main.dart`;
  botón "Reportar una emergencia" alcanzable sin sesión (ej. desde
  `LoginScreen`, ya que `AuthGate` hoy solo ofrece Login si no hay
  sesión); entrada "Reportes" en el Panel (`HomeShell`) para Revisores.
  Hecho cuando: `flutter analyze` y `flutter test` (suite completa) pasan
  en verde.

- [ ] **T12 — Boot-check manual** (requiere emulador/dispositivo Android
  real, igual que T16 de la spec 001)
  Con el emulador corriendo: enviar un reporte sin sesión desde el
  dispositivo de prueba, confirmar que aparece "pendiente" en el panel de
  un Revisor, cambiarlo a "activa", confirmar que un cuarto envío seguido
  desde el mismo dispositivo se bloquea por antispam.
  Hecho cuando: el recorrido completo funciona y queda una captura.
