# Plan — Spec 006 — Perfiles y logros

## Módulos

```
lib/
├── domain/
│   └── entities/
│       ├── achievement.dart          # catálogo cerrado (id, label, description, umbral)
│       └── profile_stats.dart        # totalParticipations, totalServiceTime, unlockedAchievements(...)
└── presentation/
    └── panel/
        └── account_detail_screen.dart # (spec 001) se amplía con logros + historial
```

`Participation` (spec 005) gana dos campos: `reportTitle` y
`emergencyTypeId`, guardados al tocar "Ir" — evita re-consultar cada
reporte para listar el historial.

`ParticipationRepository` (spec 005) gana
`watchParticipationsForAccount(accountId)`, vía `collectionGroup` sobre
`participations` (soportado por `fake_cloud_firestore`, confirmado antes
de diseñar esto).

`EmergencyResponseScreen` (spec 005) y `ComiteManagementScreen` (spec
004): sus filas de participante/miembro pasan a ser tocables → abren
`AccountDetailScreen` de esa cuenta (RF-6).

## Modelo de datos (Firestore)

`reports/{reportId}/participations/{accountId}` (spec 005) gana:
```
{
  ...campos existentes...,
  accountId: string,        // redundante con el id del doc, necesario
                              // para que collectionGroup pueda filtrar
  reportTitle: string,
  emergencyTypeId: string
}
```

## Decisiones técnicas

- **Denormalizar `reportTitle`/`emergencyTypeId` en la participación**,
  en vez de consultar `EmergencyReportRepository` por cada item del
  historial: en el momento de "Ir" ya se tiene el `EmergencyReport`
  completo en memory (`EmergencyResponseScreen` lo recibe como
  parámetro), así que guardarlo de una vez evita N+1 consultas al armar
  el historial de una cuenta con muchas participaciones.
- **`accountId` como campo explícito**, aunque ya es el id del documento:
  las collectionGroup queries de Firestore no pueden filtrar de forma
  fiable por el último segmento del id del documento entre distintas
  subcolecciones, así que se necesita como campo real para
  `watchParticipationsForAccount`.
- **`ProfileStats`/`unlockedAchievements` son funciones puras de
  dominio** sobre `List<Participation>`, no un repositorio — no hay nada
  que consultar aparte de las participaciones ya traídas; calcularlo en
  domain evita duplicar la lógica entre distintas pantallas que muestren
  el perfil.
- **Catálogo de insignias** (provisional, ver spec.md):
  - "Primeros pasos": ≥ 1 emergencia finalizada.
  - "Comprometido": ≥ 5 emergencias finalizadas.
  - "Veterano": ≥ 20 emergencias finalizadas.
  - "100 horas de servicio": tiempo total de servicio ≥ 100 horas.
- **Un solo `AccountDetailScreen` reusado** para "mi perfil" y "ver
  perfil de X" (RF-4/RF-5): no hay una pantalla aparte de "mi perfil",
  solo distintos puntos de entrada que navegan a la misma pantalla con
  la cuenta correspondiente.

## Estrategia de tests

| RF | Cómo se prueba |
|---|---|
| RF-1 | Unit test: `ProfileStats.from(participations)` suma tiempos y cuenta solo finalizadas, incluyendo `withdrawn`. |
| RF-2 | Unit test: `unlockedAchievements` devuelve las insignias correctas para 0, 1, 5, 20 emergencias y para ≥100 horas. |
| RF-3 | Unit test: `goTo` guarda `reportTitle`/`emergencyTypeId` en el documento. |
| RF-4 | Widget test: `AccountDetailScreen` muestra insignias e historial a partir de `watchParticipationsForAccount`. |
| RF-5 | Widget test: `HomeShell` tiene una entrada "Mi perfil" que navega con la cuenta propia. |
| RF-6 | Widget tests: tocar un participante en `EmergencyResponseScreen` y un miembro en `ComiteManagementScreen` navega a `AccountDetailScreen`. |

## Orden de implementación

1. `domain`: `Achievement`, `ProfileStats`, y los dos campos nuevos en
   `Participation`.
2. `data`: `accountId`/`reportTitle`/`emergencyTypeId` en el mapper y en
   `goTo`; `watchParticipationsForAccount` (collectionGroup).
3. `presentation`: ampliar `AccountDetailScreen` con logros + historial;
   hacer tocables las filas de `EmergencyResponseScreen` y
   `ComiteManagementScreen` (necesitan `AccountRepository.watchAccount`
   para resolver la cuenta completa antes de navegar).
4. Wiring: "Mi perfil" en `HomeShell`.
