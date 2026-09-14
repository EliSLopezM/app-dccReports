# Plan — Spec 005 — Ciclo de vida de la emergencia

## Módulos

```
lib/
├── domain/
│   ├── entities/
│   │   ├── participation_status.dart  # enum: going, arrived, finished
│   │   ├── finish_type.dart           # enum: completed, withdrawn
│   │   ├── difficulty_level.dart      # enum: baja, media, alta
│   │   ├── participation.dart
│   │   └── meeting_point.dart
│   └── repositories/
│       └── participation_repository.dart
├── data/
│   └── firebase/
│       ├── participation_mapper.dart
│       └── firestore_participation_repository_impl.dart
└── presentation/
    └── emergency_response/
        ├── emergency_response_screen.dart   # "Ir"/"Ya llegué"/ambulancia/finalizar
        ├── meeting_point_picker_screen.dart # RF-5/RF-7
        └── finish_participation_sheet.dart  # RF-10 (terminé / retirarme)
```

`ComiteRepository` (spec 004) gana `watchNearbyComites` (RF-3).
`EmergencyDetailScreen` (spec 003) se amplía con la lista de "comités
convocados" y un botón a `EmergencyResponseScreen`.

## Modelo de datos (Firestore)

`reports/{reportId}/participations/{accountId}` — doc id = accountId,
así "Ir" dos veces es idempotente (RF caso límite):
```
{
  accountName, accountRole,
  status: "going" | "arrived" | "finished",
  goingAt, arrivedAt: timestamp | null, finishedAt: timestamp | null,
  finishType: "completed" | "withdrawn" | null,
  difficultyLevel: "baja" | "media" | "alta" | null,
  photoUrl: string | null,       // solo completed
  reason: string | null,          // solo withdrawn
  ambulanceRequestedAt: timestamp | null
}
```

`meetingPoints/{reportId}` — doc id = reportId, 1:1, un solo punto activo
por emergencia:
```
{ latitude, longitude, setByUid, setByRole, setAt }
```

## Decisiones técnicas

- **`ParticipationRepository` junta participación + punto de encuentro +
  ambulancia** en un solo repositorio (mismo criterio que specs
  anteriores: conceptos que solo tienen sentido juntos, para el ciclo de
  vida de una emergencia, no se separan en repositorios distintos sin
  necesidad).
- **Doc id = accountId** en `participations` (no autogenerado): hace que
  "Ir" sea `set` idempotente en vez de necesitar una consulta previa para
  evitar duplicados — más simple y sin condición de carrera.
- **`watchNearbyComites` calcula distancia en Dart (fórmula de
  Haversine)**, no con una consulta geoespacial de Firestore. Alternativa
  descartada: geohashing con un índice compuesto — se descarta por
  complejidad innecesaria a esta escala (un comité por seccional, no
  miles); se trae la lista completa de comités con coordenadas y se
  filtra/ordena en memoria.
- **Regla de punto de encuentro (RF-7/RF-8) verificada en el
  repositorio**, no solo en la UI: `setMeetingPoint` lee el punto actual
  y compara `setByRole` (liderazgo vs voluntario) y `setByUid` antes de
  escribir — mismo patrón de "defensa en profundidad" que RF-7 de la
  spec 001 y RF-9 de la spec 004.
- **Ambulancia sin contacto configurado**: `requestAmbulance` solo
  registra la solicitud (timestamp); la UI abre `tel:123` con
  `url_launcher` para que la persona llame — decisión de la entrevista de
  esta spec, más simple que gestionar un contacto por Admin.
- **Foto de finalización sube por el mismo patrón de uploader inyectado**
  que reportes (spec 002) y comités — `ParticipationPhotoUploader =
  Future<String> Function(String reportId, String accountId, String
  localPhotoPath)`.
- **Punto de encuentro sin mini-mapa interactivo todavía**: se reutiliza
  `LocationRepository.getCurrentLocation()` (spec 002) para sugerir la
  ubicación de quien lo pone, con un botón "Confirmar aquí" — ajustar el
  pin a mano en un mapa real queda listo en el código (`MeetingPointPickerScreen`
  ya construye sobre `MapView`, spec 003) pero solo se puede ejercer
  cuando exista una API key real, igual que el resto de mapas de la app.

## Estrategia de tests

| RF | Cómo se prueba |
|---|---|
| RF-1 | Unit test: `goTo` crea la participación en "going"; llamarlo dos veces no duplica (mismo doc id). |
| RF-3 | Unit test: `watchNearbyComites` trae solo comités con coordenadas dentro de 10 km, ordenados por distancia; uno sin coordenadas no aparece. |
| RF-4, RF-5, RF-6 | Unit tests: `arrive` marca "arrived"; el primero en llegar dispara la necesidad de punto de encuentro (se verifica con `watchMeetingPoint` devolviendo `null`); un segundo "arrive" no la dispara de nuevo. |
| RF-7, RF-8 | Unit tests de `setMeetingPoint`: voluntario pone el primero (OK); segundo voluntario intenta (bloqueado); funcionario reemplaza el del voluntario (OK); el mismo voluntario que lo puso lo cambia (OK). |
| RF-9 | Unit test: `requestAmbulance` registra el timestamp; widget test de que se invoca el lanzador de `tel:`. |
| RF-10, RF-11 | Unit tests: `finishCompleted`/`finishWithdrawn` calculan y guardan los tiempos correctamente a partir de `goingAt`/`arrivedAt`/`finishedAt` inyectados. |
| RF-12 | Widget test: botón "Cerrar emergencia" visible solo para liderazgo, llama a `EmergencyReportRepository.updateStatus(verdadera)` (spec 002) ya existente. |

## Orden de implementación

1. `domain`: enums, `Participation`, `MeetingPoint`, interfaz del
   repositorio; `watchNearbyComites` en la interfaz de `ComiteRepository`.
2. `data`: `FirestoreParticipationRepositoryImpl` completo (participación,
   punto de encuentro, ambulancia); `watchNearbyComites` en
   `FirestoreComiteRepositoryImpl`.
3. `presentation`: `EmergencyResponseScreen` (Ir/Ya llegué/ambulancia/
   finalizar + lista de participantes), `MeetingPointPickerScreen`,
   `FinishParticipationSheet`.
4. Wiring: `EmergencyDetailScreen` (spec 003) gana "comités convocados" +
   botón a `EmergencyResponseScreen`; providers en `main.dart`.
