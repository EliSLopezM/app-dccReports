# Spec 002 — Reporte público de emergencias y moderación

## Contexto y objetivo
Cualquier persona en Bogotá debe poder alertar a la Defensa Civil de un
incendio, sismo, accidente estructural, etc. sin necesidad de cuenta.
Ese reporte no debe llegar "crudo" a todo el personal: primero pasa por
el panel administrativo, que lo cataloga y decide si activa una
respuesta. Esta spec junta ambos extremos del mismo flujo — igual que la
spec 001 juntó registro y aprobación — porque comparten el mismo modelo
de datos (`EmergencyReport` y su estado).

## Usuarios / actores
- **Reportante**: cualquier persona, sin cuenta ni sesión.
- **Revisor** (Admin, Funcionario, Líder funcionario — mismos roles que
  aprueban cuentas en la spec 001): cataloga el reporte desde el panel.

## Historias de usuario
- H1: Como reportante, quiero enviar un reporte (título, dirección, tipo
  de emergencia, mínimo 2 fotos) sin crear una cuenta, para alertar a la
  DCC rápido.
- H2: Como reportante, quiero poder dejar (opcionalmente) mi nombre y
  teléfono, para que la DCC me pueda contactar si necesita más
  información.
- H3: Como Revisor, quiero ver todos los reportes entrantes con su
  evidencia (incluida la del reportante), para catalogarlos como
  verdadera, activa, falsa controlada o en desarrollo.
- H4: Como Revisor, quiero ver el historial de reportes de un mismo
  teléfono o dispositivo, para identificar patrones de reportes falsos.
- H5: Como sistema, quiero limitar cuántos reportes puede enviar un
  mismo dispositivo en poco tiempo, para frenar spam sin exigir cuenta.

## Requisitos funcionales (criterios de aceptación en EARS)
- RF-1: EL SISTEMA permitirá abrir y enviar el formulario de reporte sin
  sesión iniciada.
- RF-2: CUANDO alguien envía el formulario, EL SISTEMA creará un
  `EmergencyReport` con: título, dirección (texto libre), tipo de
  emergencia (catálogo cerrado), y al menos 2 fotos.
- RF-3: SI el formulario no tiene título, dirección, tipo de emergencia o
  menos de 2 fotos, ENTONCES EL SISTEMA bloqueará el envío indicando qué
  falta.
- RF-4: EL SISTEMA capturará automáticamente, sin pedirlo, un
  identificador de instalación (`deviceId`) para cada reporte enviado
  desde ese dispositivo.
- RF-5: EL SISTEMA permitirá al reportante indicar, de forma opcional, su
  nombre y un teléfono de contacto.
- RF-6: EL SISTEMA asignará a todo reporte nuevo el estado inicial
  "pendiente".
- RF-7: SI un mismo `deviceId` ya envió 3 reportes en la última hora,
  ENTONCES EL SISTEMA bloqueará un nuevo envío desde ese dispositivo
  hasta que la ventana expire (antispam, RF caso límite en "Casos
  límite").
- RF-8: EL SISTEMA permitirá a un Revisor ver, desde el panel, todos los
  reportes con su estado, tipo, fotos y evidencia del reportante (nombre/
  teléfono si se dieron, y `deviceId`).
- RF-9: EL SISTEMA permitirá a un Revisor cambiar el estado de un reporte
  a: activa, verdadera, falsa controlada, o en desarrollo.
- RF-10: EL SISTEMA considerará "visible en el mapa general" únicamente
  los reportes en estado "activa" (el mapa en sí es una spec futura; esta
  spec solo deja el campo/regla lista para que el mapa lo consuma).
- RF-11: EL SISTEMA nunca mostrará nombre, teléfono o `deviceId` del
  reportante fuera del panel (ninguna vista pública los expone).
- RF-12: EL SISTEMA permitirá a un Revisor, dado un `deviceId` o teléfono,
  ver todos los reportes previos asociados a ese mismo dato.

## Requisitos no funcionales
- Plataformas: Android (prioridad) e iOS.
- Idioma de interfaz: español.
- El límite antispam (RF-7) se aplica en el cliente por ahora (no hay
  backend con Cloud Functions en esta spec); ver plan.md para la
  alternativa descartada y por qué se puede vivir con esto por ahora.

## Casos límite
- Envío con exactamente 2 fotos (el mínimo) → debe pasar.
- Envío con 1 foto → debe bloquearse (RF-3).
- Cuarto reporte del mismo dispositivo dentro de la misma hora →
  bloqueado (RF-7); pasada la hora, se permite de nuevo.
- Reportante deja nombre pero no teléfono, o viceversa → ambos siguen
  siendo opcionales de forma independiente, no se bloquea el envío.
- Un Revisor cambia el estado más de una vez (ej. pendiente → activa →
  falsa controlada) → se permite, el estado no es de un solo sentido.

## Fuera de alcance
- El mapa general donde se ven los reportes "activa" — spec futura
  (docs/brief-inicial.md, spec 004).
- Recomendaciones mostradas al público según tipo de emergencia — spec
  004 (se muestran al tocar el pin en el mapa).
- Notificación tipo campana a grupos/comités cercanos cuando un reporte
  pasa a "activa" — spec 004/006.
- Llamado de ambulancia — spec del ciclo de vida de la emergencia.
- Antispam robusto del lado servidor (Cloud Functions / Firestore
  Security Rules con conteo) — ver Requisitos no funcionales.

## Criterios de finalización
- Todos los RF-1 a RF-12 con test en verde (unitarios en domain/data;
  widget tests en el formulario público y la vista de moderación).
- Demo manual: enviar un reporte sin sesión → queda "pendiente" → un
  Revisor lo ve en el panel con la evidencia → lo pasa a "activa" →
  queda marcado como visible en el mapa (campo, aunque el mapa real
  todavía no exista).

## Dudas abiertas
- [NECESITA ACLARACIÓN] Catálogo cerrado de tipos de emergencia: se usa
  una lista provisional corta (incendio, sismo/estructura afectada,
  accidente estructural, inundación, otro) en el Plan, ajustable después.

## Enmienda 1 — Coordenadas del reporte (motivada por la spec 003)

La spec 003 (Mapa y despliegue) necesita ubicar cada reporte en un mapa,
y el modelo original de esta spec solo guardaba la dirección como texto
libre, sin coordenadas. Se agrega:

- RF-13: CUANDO se envía un reporte, EL SISTEMA intentará capturar la
  ubicación GPS del dispositivo (latitud/longitud) en el momento del
  envío y la guardará junto con el reporte si se obtiene.
- RF-14: SI no se puede obtener la ubicación (permiso denegado, GPS
  apagado, error), ENTONCES EL SISTEMA permitirá el envío igualmente,
  sin coordenadas — ese reporte no aparecerá en el mapa (spec 003) hasta
  que se agregue una ubicación por otro medio (fuera de alcance).

Decisión: priorizar que el envío nunca se bloquee por falta de permiso
de ubicación (RF caso límite de esta spec: "sin fricción para reportar
rápido"), sobre la garantía de que todo reporte tenga coordenadas.
- [NECESITA ACLARACIÓN] Si "verdadera" (confirmado pero ya no urgente) 
  también debería ser visible en el mapa general quedó fuera por la
  respuesta del dueño del producto (solo "activa" es visible) — revisar
  si esto cambia cuando se construya la spec del mapa.
