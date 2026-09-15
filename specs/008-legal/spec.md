# Spec 008 — Legal

## Contexto y objetivo
El brief inicial (sección 10) pide que las políticas/términos de uso
estén disponibles para descargar en PDF desde la app. Esta es la última
spec del alcance descrito en `docs/brief-inicial.md`.

## Usuarios / actores
- **Cualquier cuenta** (aprobada o pendiente de aprobación): puede leer
  el documento y descargarlo/compartirlo en PDF.

## Historias de usuario
- H1: Como cualquier cuenta, quiero leer las políticas y términos de uso
  dentro de la app, para saber a qué me comprometo.
- H2: Como cualquier cuenta, quiero descargar o compartir ese documento
  en PDF, para guardarlo o enviarlo fuera de la app.

## Requisitos funcionales (criterios de aceptación en EARS)
- RF-1: EL SISTEMA mostrará, en una pantalla "Legal" accesible desde el
  menú principal, el texto completo de políticas y términos de uso.
- RF-2: CUANDO alguien toque "Descargar PDF", EL SISTEMA generará un PDF
  con ese mismo texto en el dispositivo y abrirá el selector nativo para
  guardarlo o compartirlo (sin subir nada a Firebase Storage).
- RF-3: EL SISTEMA mostrará el acceso "Legal" tanto a cuentas aprobadas
  (`HomeShell`) como a cuentas pendientes/rechazadas
  (`PendingApprovalScreen`, spec 001 RF-4) — es contenido público, no
  requiere aprobación.

## Requisitos no funcionales
- Plataformas: Android (prioridad) e iOS.
- Idioma de interfaz: español.

## Casos límite
- Generar el PDF no debe bloquear la UI de forma silenciosa: mientras se
  genera, el botón se deshabilita para evitar toques repetidos.
- Si el usuario cancela el selector nativo de compartir/guardar, la app
  no debe mostrar ningún error — es un flujo normal.

## Fuera de alcance
- Edición del texto legal desde la app (ni por Admin): el texto vive en
  el código (`lib/app/legal_content.dart`), versionado en git — el
  contenido legal real pasa por revisión humana antes de cada cambio,
  no por un panel editable.
- Aceptar/registrar que alguien leyó o aceptó los términos — no pedido.
- Subir el PDF a Firebase Storage o exponerlo por una URL fija — se
  genera en el dispositivo en el momento (RF-2).

## Criterios de finalización
- Todos los RF-1 a RF-3 con test en verde (widget tests).
- Demo manual: desde el Home y desde la pantalla de cuenta pendiente,
  entrar a "Legal", leer el texto, tocar "Descargar PDF" y confirmar que
  se abre el selector nativo de guardar/compartir con un PDF válido.

## Dudas abiertas
- [NECESITA ACLARACIÓN] Texto legal real de políticas/términos: se deja
  un placeholder en `lib/app/legal_content.dart` (ver plan.md) hasta que
  la DCC entregue el texto definitivo — no bloqueante para el resto de
  la spec, mismo patrón que `kCapacitateFormUrl` (spec 007).
