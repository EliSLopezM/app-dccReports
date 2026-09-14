# Tareas — Spec 005 — Ciclo de vida de la emergencia

Cada tarea: tests primero, luego implementación mínima para pasarlos,
`flutter analyze` + `flutter test` en verde antes de marcar `[x]`.

## Domain

- [x] **T1 — Enums y entidades: `Participation`, `MeetingPoint`** (RF-1, RF-7, RF-10)
  `participation_status.dart`, `finish_type.dart`, `difficulty_level.dart`,
  `participation.dart`, `meeting_point.dart`. Unit tests: construir cada
  entidad válida.
  Hecho cuando: los tests pasan.

- [x] **T2 — Excepciones + interfaz `ParticipationRepository`** (RF-1 a RF-12)
  `NotArrivedException`, `MeetingPointBlockedException` en
  `domain/exceptions.dart`; `domain/repositories/participation_repository.dart`
  con `goTo`, `arrive`, `requestAmbulance`, `finishCompleted`,
  `finishWithdrawn`, `watchMyParticipation`, `watchParticipations`,
  `watchMeetingPoint`, `setMeetingPoint`.
  Hecho cuando: `flutter analyze` no marca nada en `domain/`.

- [x] **T3 — `watchNearbyComites` en `ComiteRepository`** (RF-3)
  Agregar el método a la interfaz existente (spec 004). Sin test propio
  (solo interfaz).
  Hecho cuando: `flutter analyze` no marca nada en `domain/`.

## Data

- [x] **T4 — `goTo`/`arrive`** (RF-1, RF-4, RF-5, RF-6, caso límite "Ir" x2)
  Tests: `goTo` crea en "going"; llamarlo dos veces no duplica; `arrive`
  marca "arrived"; el primero en llegar (sin punto de encuentro) se
  distingue del segundo.
  Hecho cuando: los tests pasan.

- [x] **T5 — `setMeetingPoint`** (RF-7, RF-8)
  Tests: voluntario pone el primero (OK); segundo voluntario bloqueado;
  funcionario reemplaza el de un voluntario (OK); el mismo voluntario que
  lo puso lo cambia (OK).
  Hecho cuando: los 4 casos pasan.

- [x] **T6 — `requestAmbulance`** (RF-9)
  Test: registra el timestamp de la solicitud, se puede llamar más de
  una vez.
  Hecho cuando: el test pasa.

- [x] **T7 — `finishCompleted`/`finishWithdrawn` con cálculo de tiempos** (RF-10, RF-11)
  Tests con reloj inyectable: tiempo going→arrived y arrived→fin
  calculados correctamente para ambos tipos de finalización; finalizar
  sin haber llegado lanza `NotArrivedException`.
  Hecho cuando: los tests pasan.

- [x] **T8 — `watchNearbyComites`** (RF-3)
  Tests con `fake_cloud_firestore`: comité a 2 km aparece, uno a 50 km no;
  uno sin coordenadas no aparece ni rompe el cálculo.
  Hecho cuando: los tests pasan.

## Presentation

- [x] **T9 — `EmergencyResponseScreen`: Ir / Ya llegué / ambulancia** (RF-1, RF-2, RF-4, RF-6, RF-9)
  Botones según el estado de la propia participación; lista de
  participantes con su estado. Widget tests: "Ir" llama a `goTo` y abre
  direcciones; "Ya llegué" llama a `arrive`; "Pedir ambulancia" llama a
  `requestAmbulance` y abre `tel:123`.
  Hecho cuando: los widget tests pasan.

- [x] **T10 — `MeetingPointPickerScreen`** (RF-5, RF-7, RF-8)
  Sugiere la ubicación GPS actual, botón "Confirmar aquí"; se abre
  automáticamente para el primero en llegar (T9). Widget test: confirmar
  llama a `setMeetingPoint`; error de `MeetingPointBlockedException` se
  muestra como mensaje, no crashea.
  Hecho cuando: el widget test pasa.

- [x] **T11 — `FinishParticipationSheet`** (RF-10)
  Formulario "Ya terminé" (foto + nivel) o "Debo retirarme" (razón +
  nivel). Widget tests para ambas ramas.
  Hecho cuando: los widget tests pasan.

- [x] **T12 — Comités convocados + "Cerrar emergencia" en `EmergencyDetailScreen`** (RF-3, RF-12)
  Lista de comités convocados (spec 003, pantalla existente); botón
  "Cerrar emergencia" visible solo para liderazgo, llama a
  `updateStatus(verdadera)` (spec 002). Widget tests: lista de comités
  convocados; el botón de cerrar no aparece para voluntario.
  Hecho cuando: los widget tests pasan.

## Wiring final

- [ ] **T13 — Providers + acceso a `EmergencyResponseScreen`**
  `ParticipationRepository` en `main.dart` (con el uploader de fotos de
  finalización). Botón "Responder" en `EmergencyDetailScreen` que navega
  a `EmergencyResponseScreen`.
  Hecho cuando: `flutter analyze` y `flutter test` (suite completa) pasan
  en verde.

- [ ] **T14 — Boot-check manual** (requiere emulador/dispositivo Android
  real, igual que las specs anteriores)
  Dos cuentas aprobadas tocan "Ir" en la misma emergencia; la primera en
  llegar pone el punto de encuentro; la segunda lo ve; una pide
  ambulancia; ambas finalizan (una "terminé", otra "me retiro"); un
  funcionario cierra la emergencia completa.
  Hecho cuando: el recorrido completo funciona y queda una captura.
