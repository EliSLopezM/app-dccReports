# Plan — Spec 008 — Legal

## Módulos

```
lib/
├── app/
│   └── legal_content.dart      # kLegalDocumentTitle, kLegalDocumentBody (placeholder)
└── presentation/
    └── legal/
        └── legal_screen.dart   # texto + botón "Descargar PDF"
```

Sin `domain`/`data`: el texto es estático (mismo criterio que
`CapacitateScreen` en la spec 007 — no hay nada que persistir ni
consultar).

## Decisiones técnicas

- **Texto legal fijo en código** (`lib/app/legal_content.dart`), no
  editable desde la app ni por Admin: es contenido sensible que necesita
  revisión humana antes de publicarse, así que cambiarlo pasa por code
  review como cualquier otro cambio de código — no por un formulario en
  runtime. Placeholder hasta que la DCC entregue el texto real.
- **PDF generado en el dispositivo con el paquete `pdf`** (ya en
  `pubspec.yaml`, sin usar todavía) a partir del mismo texto que se
  muestra en pantalla — un solo documento, no dos, para no duplicar
  contenido a mantener.
- **Compartir/guardar con `printing` (`Printing.sharePdf`)**, no subir a
  Firebase Storage: no hay backend que mantener para un documento que no
  cambia con datos de usuario, y `Printing.sharePdf` ya abre el selector
  nativo (guardar en archivos, compartir por otra app, imprimir) en
  Android e iOS.
- **Dos funciones inyectables** (`GeneratePdf`, `SharePdf`), mismo patrón
  que `PickImage`/`LaunchUrl` en el resto de la app: permite testear que
  `LegalScreen` llama a ambas con los argumentos correctos sin renderizar
  un PDF real ni abrir un selector nativo en los widget tests.
- **Visible también sin cuenta aprobada** (RF-3): se agrega junto a
  Noticias/Capacítate/Prepárate en `PendingApprovalScreen`, no solo en
  `HomeShell` — es información legal que cualquiera debería poder leer
  antes de que su cuenta sea aprobada.

## Estrategia de tests

| RF | Cómo se prueba |
|---|---|
| RF-1 | Widget test: `LegalScreen` muestra el título y el cuerpo del texto legal. |
| RF-2 | Widget test: tocar "Descargar PDF" llama a `generatePdf(title, body)` y luego a `sharePdf(bytes, filename)` con los valores devueltos/esperados; el botón se deshabilita mientras genera. |
| RF-3 | Widget tests: `HomeShell` y `PendingApprovalScreen` tienen un acceso "Legal" que navega a `LegalScreen`. |

## Orden de implementación

1. `lib/app/legal_content.dart` con el texto placeholder.
2. `LegalScreen` con las funciones inyectables y su widget test.
3. Wiring: entrada "Legal" en `HomeShell` y `PendingApprovalScreen`.
