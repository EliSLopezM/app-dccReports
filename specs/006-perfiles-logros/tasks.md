# Tareas — Spec 006 — Perfiles y logros

Cada tarea: tests primero, luego implementación mínima para pasarlos,
`flutter analyze` + `flutter test` en verde antes de marcar `[x]`.

## Domain

- [x] **T1 — `Achievement`, `ProfileStats`** (RF-1, RF-2)
  `domain/entities/achievement.dart` (catálogo cerrado),
  `domain/entities/profile_stats.dart` con `ProfileStats.from(List<Participation>)`
  y `unlockedAchievements(ProfileStats)`. Unit tests: 0/1/5/20
  emergencias y ≥100 horas desbloquean las insignias esperadas; una
  participación "withdrawn" cuenta igual que "completed".
  Hecho cuando: los tests pasan.

- [x] **T2 — `reportTitle`/`emergencyTypeId` en `Participation`** (RF-3)
  Agregar los campos (siempre presentes, ya que `goTo` los recibe).
  Actualizar la interfaz `ParticipationRepository.goTo` con los nuevos
  parámetros requeridos. Unit test: construir una participación con
  estos campos.
  Hecho cuando: `flutter analyze` no marca nada en `domain/`.

- [x] **T3 — `watchParticipationsForAccount` en `ParticipationRepository`** (RF-4)
  Agregar el método a la interfaz. Sin test propio (solo interfaz).
  Hecho cuando: `flutter analyze` no marca nada en `domain/`.

## Data

- [x] **T4 — `goTo` guarda `reportTitle`/`emergencyTypeId`/`accountId`** (RF-3)
  Test: el documento creado por `goTo` tiene los tres campos.
  Hecho cuando: el test pasa.

- [x] **T5 — `watchParticipationsForAccount` (collectionGroup)** (RF-4)
  Test con `fake_cloud_firestore`: participaciones de la misma cuenta en
  2 reportes distintos aparecen juntas; una participación de otra cuenta
  no aparece.
  Hecho cuando: el test pasa.

## Presentation

- [x] **T6 — `AccountDetailScreen` con logros e historial** (RF-2, RF-4)
  Nueva sección "Logros" (insignias desbloqueadas) e "Historial de
  emergencias" (título, tipo, tiempos) a partir de
  `watchParticipationsForAccount`. Widget tests: cuenta sin
  participaciones muestra historial vacío sin error; cuenta con 1
  finalizada muestra la insignia "Primeros pasos" y el item en el
  historial.
  Hecho cuando: los widget tests pasan.

- [x] **T7 — Filas tocables en `EmergencyResponseScreen` y `ComiteManagementScreen`** (RF-6)
  Tocar un participante o un miembro resuelve la cuenta
  (`AccountRepository.watchAccount`) y navega a `AccountDetailScreen`.
  Widget tests para ambas pantallas.
  Hecho cuando: los widget tests pasan.

## Wiring final

- [ ] **T8 — "Mi perfil" en `HomeShell`**
  Entrada visible para cualquier cuenta aprobada, navega a
  `AccountDetailScreen` con la cuenta propia. Widget test.
  Hecho cuando: `flutter analyze` y `flutter test` (suite completa) pasan
  en verde.

- [ ] **T9 — Boot-check manual** (requiere emulador/dispositivo Android
  real, igual que las specs anteriores)
  Un voluntario participa y finaliza 3 emergencias → su perfil muestra 3
  en el historial, el tiempo total, y la insignia correspondiente → otra
  cuenta toca su nombre en un chat/comité y ve el mismo perfil.
  Hecho cuando: el recorrido completo funciona y queda una captura.
