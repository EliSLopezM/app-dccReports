# Plan — Spec 003 — Mapa y despliegue

## Módulos

```
lib/
├── app/
│   └── maps_config.dart              # kGoogleMapsConfigured (mismo patrón que amipets)
├── domain/
│   └── entities/
│       └── date_filter.dart          # enum EmergencyDateFilter + cutoff(now)
├── data/
│   └── firebase/
│       └── firestore_emergency_report_repository_impl.dart  # + watchActiveReports(since)
└── presentation/
    ├── map/
    │   ├── map_screen.dart           # mapa real o placeholder + filtro + pines
    │   └── emergency_detail_screen.dart  # tipo, fotos, dirección, recomendaciones
    └── notifications/
        └── active_reports_bell.dart  # ícono con contador + lista (RF-5/RF-6)
```

`domain/entities/emergency_type_catalog.dart` (spec 002) se amplía con un
campo `recommendations` por tipo — no es una entidad nueva, es una
modificación menor al catálogo existente.

`domain/repositories/emergency_report_repository.dart` (spec 002) gana un
método nuevo: `watchActiveReports({required DateTime since})`.

## Modelo de datos

Sin colecciones nuevas en Firestore. `EmergencyType.recommendations` es
una constante en código (domain), no un campo de Firestore — coherente
con que el catálogo entero ya vive en código, no en la base de datos.

`EmergencyDateFilter` (domain, sin Firebase):
```dart
enum EmergencyDateFilter { today, thisWeek, thisMonth, last3Months, last6Months, lastYear }
```
Cada valor calcula su `since` (fecha de corte) a partir de un `DateTime now`
inyectable, igual que el reloj de la spec 002 — necesario para poder
testear "hoy" vs "esta semana" sin depender de la fecha real del sistema.

## Decisiones técnicas

- **Recomendaciones como texto provisional en código**, redactado ahora
  (ver abajo), no en Firestore. Alternativa descartada: colección
  `emergencyTypes` en Firestore editable desde el panel — se descarta
  por ahora porque nadie pidió administrar esto desde la app; se
  reconsidera si algún día se pide editar recomendaciones sin
  desplegar una nueva versión.
- **Mapa con placeholder mientras no haya API key real**, idéntico patrón
  a AmiPets: `kGoogleMapsConfigured` en `lib/app/maps_config.dart`,
  `false` por defecto. Toda la lógica de pines (consulta, filtro,
  tap → detalle) se construye y testea igual, sin depender de que el
  mapa real esté visible.
- **Campana sin destinatarios ni "visto/no visto" por ahora**: cualquier
  cuenta aprobada ve el mismo conteo y la misma lista de "activa" — ver
  "Fuera de alcance" de spec.md. `watchActiveReports` ya filtra por fecha
  para que la campana y el mapa compartan la misma fuente de datos con
  el mismo filtro aplicado.
- **`watchActiveReports` como método nuevo del repositorio** (en vez de
  filtrar `watchAllReports()` en la UI): mantiene la regla "visible en
  mapa = activa + rango de fecha" en una sola capa (`data`), reusable por
  `MapScreen` y `ActiveReportsBell` sin duplicar la lógica de filtro.

## Contenido provisional de recomendaciones (RF-4)

- **Incendio**: Aléjate del fuego y el humo. No uses ascensores. Cubre
  nariz y boca con un paño húmedo. Si tu ropa se incendia, detente,
  tírate al piso y rueda.
- **Sismo / estructura afectada**: Aléjate de fachadas, ventanas y
  cables. Busca un lugar despejado o agáchate junto a un mueble bajo y
  resistente. No uses ascensores. Revisa si hay heridos antes de mover
  escombros.
- **Accidente estructural**: No ingreses a la zona afectada. Mantén
  distancia de columnas o techos visiblemente dañados. Espera
  instrucciones del personal de la Defensa Civil en el lugar.
- **Inundación**: No cruces zonas con agua en movimiento. Corta la
  energía eléctrica si es seguro hacerlo. Aléjate de orillas de ríos o
  canales crecidos.
- **Otro**: Mantén distancia de la zona reportada y espera instrucciones
  del personal de la Defensa Civil en el lugar.

Texto provisional — se reemplaza cuando exista contenido oficial de la
DCC (spec.md, "Dudas abiertas").

## Estrategia de tests

| RF | Cómo se prueba |
|---|---|
| RF-1, RF-2 | Unit test de `EmergencyDateFilter.cutoff(now)` para cada valor; unit test de `watchActiveReports` con `fake_cloud_firestore` sembrando reportes en distintas fechas. |
| RF-3, RF-4 | Widget test de `EmergencyDetailScreen`: muestra las recomendaciones correctas según `emergencyTypeId`. |
| RF-5, RF-6 | Widget test de `ActiveReportsBell`: cuenta correcta, lista al tocar, navega al detalle. |
| RF-7 | Widget test de `MapScreen`: con `kGoogleMapsConfigured = false` (valor por defecto), se ve el placeholder; la lista de pines sigue siendo accesible para test (mismo patrón que AmiPets: inspeccionar el widget `MapView`/lista de marcadores directamente). |

## Orden de implementación

1. `domain`: `EmergencyDateFilter`, ampliar `EmergencyType` con
   `recommendations`, ampliar la interfaz del repositorio.
2. `data`: `watchActiveReports` en
   `FirestoreEmergencyReportRepositoryImpl`.
3. `presentation/map`: `maps_config.dart`, `MapScreen` (placeholder +
   filtro + pines), `EmergencyDetailScreen`.
4. `presentation/notifications`: `ActiveReportsBell`.
5. Wiring: entrada "Mapa" en `HomeShell`, campana en su `AppBar`.
