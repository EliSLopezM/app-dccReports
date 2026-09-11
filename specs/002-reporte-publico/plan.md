# Plan — Spec 002 — Reporte público y moderación

## Módulos

```
lib/
├── domain/
│   ├── entities/
│   │   ├── report_status.dart          # enum: pending, activa, verdadera, falsaControlada, enDesarrollo
│   │   ├── emergency_type_catalog.dart # catálogo cerrado (igual patrón que course_catalog.dart)
│   │   ├── reporter_evidence.dart      # { name?, phone?, deviceId }
│   │   └── emergency_report.dart       # entidad EmergencyReport
│   └── repositories/
│       └── emergency_report_repository.dart
├── data/
│   ├── device/
│   │   └── device_id_provider.dart     # uuid persistido en shared_preferences
│   └── firebase/
│       └── firestore_emergency_report_repository_impl.dart
└── presentation/
    ├── report/
    │   └── public_report_screen.dart   # formulario público, sin AuthRepository
    └── panel/
        ├── panel_reports_list_screen.dart
        └── report_detail_screen.dart   # detalle + evidencia + cambio de estado
```

## Modelo de datos (Firestore)

`reports/{id}`:
```
{
  title: string,
  address: string,
  emergencyTypeId: string,          // id del catálogo cerrado
  photoUrls: string[],              // Storage, mínimo 2 (RF-2/RF-3)
  status: "pending" | "activa" | "verdadera" | "falsaControlada" | "enDesarrollo",
  reporterName: string | null,
  reporterPhone: string | null,
  deviceId: string,                 // RF-4, siempre presente
  createdAt: timestamp,
  reviewedBy: uid | null,
  reviewedAt: timestamp | null
}
```

`photoUrls` se sube a Firebase Storage en `report_photos/{reportId}/{n}.jpg`
(mismo patrón `_uploadX` de amipets: una función de subida inyectada al
repositorio, no acoplada directamente a `FirebaseStorage.instance` dentro
del repositorio — más fácil de testear).

## Decisiones técnicas

- **`deviceId` con `uuid` + `shared_preferences`**, no un identificador
  de hardware real (IMEI/Android ID). Alternativa descartada:
  `device_info_plus` con identificadores de hardware — se descarta por
  ser más invasivo en privacidad y no necesario: un uuid generado una
  vez en el primer uso y guardado localmente ya sirve para RF-4/RF-7/
  RF-12 (agrupar reportes del "mismo dispositivo"); se pierde si
  desinstalan la app, aceptable para esta spec.
- **Antispam (RF-7) client-side**: antes de enviar, el repositorio
  cuenta cuántos reportes tiene ese `deviceId` en la última hora
  (`where('deviceId', isEqualTo: ...).where('createdAt', isGreaterThan:
  haceUnaHora)`) y bloquea si son 3 o más. Alternativa descartada: Cloud
  Function que valide en el servidor — más robusto (no depende de que el
  cliente "se porte bien"), pero exige backend con Functions, fuera de
  alcance de esta spec (constitución: solo lo que la spec pide). Se
  documenta como hardening futuro.
- **`EmergencyReport` sin validación de organización/roles**: a
  diferencia de `Account`, cualquier combinación de campos opcionales es
  válida — la única regla dura es "mínimo 2 fotos", validada en la UI
  (RF-3) y también en el repositorio (defensa en profundidad, mismo
  criterio que RF-7 de la spec 001 se validó en dos capas).
- **Catálogo de tipos de emergencia, provisional**: `incendio`,
  `sismo_estructura_afectada`, `accidente_estructural`, `inundacion`,
  `otro`. Mismo patrón que `course_catalog.dart` — constante en domain,
  no colección de Firestore (ver Dudas abiertas de spec.md).
- **Moderación reutiliza el concepto de "Revisor"** de la spec 001
  (`AccountRole.canReviewAccounts`) sin restricción adicional tipo RF-7:
  cualquier Admin/Funcionario/Líder funcionario puede catalogar
  cualquier reporte (a diferencia de aprobar cuentas, donde solo Admin
  revisa rangos altos) — no hay jerarquía de reportes por ahora.

## Estrategia de tests

| RF | Cómo se prueba |
|---|---|
| RF-1, RF-2, RF-3 | Widget test de `PublicReportScreen`: envío válido, envío con 1 foto bloqueado, campos vacíos bloqueados. |
| RF-4 | Unit test de `DeviceIdProvider`: mismo id en dos llamadas, persistido. |
| RF-5 | Widget test: nombre/teléfono quedan `null` si no se llenan, sin bloquear envío. |
| RF-6, RF-9, RF-10 | Unit tests de `FirestoreEmergencyReportRepositoryImpl` con `fake_cloud_firestore`. |
| RF-7 | Unit test: 3 reportes seguidos del mismo `deviceId` pasan, el 4to lanza excepción. |
| RF-8, RF-11 | Widget test de `PanelReportsListScreen`/`ReportDetailScreen`: la evidencia se ve en el panel; test de "no hay pantalla pública que la muestre" se cubre por diseño (PublicReportScreen no la lee de vuelta). |
| RF-12 | Unit test: repositorio filtra reportes por `deviceId`/teléfono. |

## Orden de implementación

1. `domain` (entidades, catálogo, interfaz de repositorio).
2. `data/device` (uuid persistido) — no depende de Firebase, se puede
   testear con `SharedPreferences.setMockInitialValues`.
3. `data/firebase` (repositorio Firestore + Storage) con tests
   `fake_cloud_firestore`.
4. `presentation/report` (formulario público).
5. `presentation/panel` (lista + detalle de moderación).
6. Wiring: agregar `EmergencyReportRepository` a los providers de
   `main.dart`, y un acceso a "Reportar emergencia" visible sin sesión
   (antes de `AuthGate`, o como opción adicional en `LoginScreen`) más un
   acceso a la lista de reportes dentro del Panel existente.
