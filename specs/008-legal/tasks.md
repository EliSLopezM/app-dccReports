# Tareas — Spec 008 — Legal

Cada tarea: tests primero, luego implementación mínima para pasarlos,
`flutter analyze` + `flutter test` en verde antes de marcar `[x]`.

## Contenido

- [x] **T1 — `legal_content.dart`** (RF-1)
  `kLegalDocumentTitle`, `kLegalDocumentBody` con un texto placeholder
  razonable de políticas/términos (a reemplazar cuando la DCC entregue
  el texto real). Sin test propio (es una constante).
  Hecho cuando: `flutter analyze` no marca nada.

## Presentation

- [x] **T2 — `LegalScreen`** (RF-1, RF-2)
  Muestra título/cuerpo; botón "Descargar PDF" llama a `generatePdf` y
  luego a `sharePdf` (ambas inyectables, con defaults reales usando
  `pdf`/`printing`); se deshabilita mientras genera. Widget tests: se ve
  el texto; tocar el botón llama a ambas funciones con los argumentos
  esperados y vuelve a habilitarse al terminar.
  Hecho cuando: los widget tests pasan.

## Wiring final

- [ ] **T3 — Entrada "Legal" en `HomeShell` y `PendingApprovalScreen`** (RF-3)
  Ambas navegan a `LegalScreen`. Widget tests en las dos pantallas.
  Hecho cuando: `flutter analyze` y `flutter test` (suite completa) pasan
  en verde.

- [ ] **T4 — Boot-check manual** (requiere emulador/dispositivo Android
  real, igual que las specs anteriores)
  Desde el Home y desde la pantalla de cuenta pendiente, entra a
  "Legal", lee el texto, toca "Descargar PDF" y confirma que se abre el
  selector nativo de guardar/compartir con un PDF válido y legible.
  Hecho cuando: el recorrido completo funciona y queda una captura.
