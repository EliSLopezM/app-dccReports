# Spec 005 — Ciclo de vida de la emergencia

## Contexto y objetivo
Hasta ahora una emergencia "activa" (spec 003) solo se puede ver en el
mapa. Esta spec construye la respuesta organizada: confirmar que se va
("Ir"), marcar que se llegó ("Ya llegué") y poner un punto de encuentro,
pedir ambulancia, y finalizar la participación (con foto/nivel o razón de
retiro) — guardando los tiempos que alimentarán el perfil del voluntario
(spec futura). También resuelve la convocatoria por cercanía que había
quedado pendiente entre las specs 003 y 004, ahora que los comités tienen
coordenadas (spec 004, Enmienda 1).

## Usuarios / actores
- **Cualquier cuenta aprobada**: puede tocar "Ir", "Ya llegué", pedir
  ambulancia y finalizar su propia participación.
- **Funcionario / Líder / Líder funcionario** ("liderazgo"): además,
  pueden poner el punto de encuentro sin restricción, y cerrar la
  emergencia completa.

## Historias de usuario
- H1: Como voluntario, quiero tocar "Ir" en una emergencia activa y que
  me abra las direcciones, para saber cómo llegar.
- H2: Como cualquier cuenta aprobada, quiero ver qué comités fueron
  convocados por cercanía, para tener contexto de quién más podría estar
  respondiendo.
- H3: Como el primero en llegar, quiero que se me pida poner un punto de
  encuentro, para que los demás sepan dónde reunirse.
- H4: Como voluntario que puso el punto de encuentro, quiero ser el único
  que lo pueda cambiar, para evitar confusión entre varios puntos.
- H5: Como quien está en la emergencia, quiero pedir ambulancia y que se
  abra el marcador para llamar, para actuar rápido.
- H6: Como voluntario, quiero finalizar mi participación (terminé o me
  retiro) y que se guarde mi tiempo, para que quede en mi historial.
- H7: Como funcionario/líder, quiero poder cerrar la emergencia completa,
  para catalogarla como resuelta aunque yo mismo no haya finalizado mi
  participación todavía.

## Requisitos funcionales (criterios de aceptación en EARS)
- RF-1: EL SISTEMA permitirá a cualquier cuenta aprobada tocar "Ir" en
  una emergencia "activa", registrando su participación en estado
  "going" con la hora.
- RF-2: CUANDO alguien toca "Ir", EL SISTEMA ofrecerá abrir direcciones
  externas (Google Maps) hacia la dirección del reporte.
- RF-3: CUANDO una emergencia pasa a "activa", EL SISTEMA calculará los
  comités con coordenadas conocidas a menos de 10 km y los mostrará como
  "comités convocados" en el detalle de la emergencia — informativo, no
  restringe quién puede tocar "Ir" (eso sigue abierto a cualquier cuenta
  aprobada, como ya definió la spec 003).
- RF-4: EL SISTEMA permitirá a quien tiene participación "going" tocar
  "Ya llegué", registrando su llegada y la hora.
- RF-5: SI quien toca "Ya llegué" es el primero en llegar a esa
  emergencia y no existe un punto de encuentro todavía, ENTONCES EL
  SISTEMA le pedirá ubicar uno.
- RF-6: SI quien toca "Ya llegué" no es el primero, ENTONCES EL SISTEMA
  se lo mostrará a los demás participantes en la lista de participación
  (sin notificación push).
- RF-7: EL SISTEMA permitirá un único punto de encuentro por emergencia.
  Una cuenta de liderazgo (funcionario/líder/líder funcionario) puede
  ponerlo o reemplazarlo sin límite. Un voluntario solo puede ponerlo si
  no existe ninguno todavía, y solo puede cambiarlo o quitarlo si fue él
  quien lo puso.
- RF-8: SI un voluntario intenta poner un punto de encuentro mientras ya
  existe uno puesto por otra cuenta, ENTONCES EL SISTEMA rechazará la
  acción.
- RF-9: EL SISTEMA permitirá a quien tiene participación "going" o
  "arrived" pedir ambulancia: registra la solicitud y abre el marcador
  telefónico hacia la línea de emergencias para que la persona haga la
  llamada ella misma.
- RF-10: EL SISTEMA permitirá a quien tiene participación "arrived"
  finalizar su propia participación de dos formas: "Ya terminé" (foto +
  nivel de dificultad) o "Debo retirarme" (razón + nivel de dificultad).
  Ambas registran la hora de finalización.
- RF-11: CUANDO se finaliza una participación, EL SISTEMA calculará y
  guardará el tiempo desde "going" hasta "arrived", y desde "arrived"
  hasta el final — insumo para el perfil del voluntario (spec futura).
- RF-12: EL SISTEMA permitirá a una cuenta de liderazgo cerrar la
  emergencia completa (catalogarla como "verdadera", reusando la
  moderación de la spec 002), sin importar si su propia participación ya
  finalizó.

## Requisitos no funcionales
- Plataformas: Android (prioridad) e iOS.
- Idioma de interfaz: español.
- El punto de encuentro se ubica con la misma limitación que el resto de
  mapas de la app: sin una API key real de Google Maps, se confirma
  directo la ubicación GPS sugerida (no hay mini-mapa interactivo
  todavía, ver Requisitos no funcionales de la spec 003).

## Casos límite
- Alguien toca "Ir" dos veces en la misma emergencia → no duplica su
  participación.
- Alguien intenta finalizar sin haber llegado ("arrived") → bloqueado.
- Un voluntario pone el punto de encuentro y luego llega un funcionario
  que pone el suyo → el del funcionario reemplaza al del voluntario.
- Un comité sin coordenadas (spec 004, Enmienda 1) → no se cuenta como
  convocado, no bloquea el cálculo de los demás.
- Alguien pide ambulancia más de una vez → se permite, cada solicitud
  queda registrada.

## Fuera de alcance
- Restringir quién puede tocar "Ir" según cercanía o convocatoria — sigue
  abierto a cualquier cuenta aprobada.
- Notificaciones push de nuevas llegadas o participaciones.
- Perfil de voluntario con logros/estadísticas visibles — spec futura,
  que consumirá los tiempos que esta spec ya guarda.
- Contacto de ambulancia configurado por Admin — el/la voluntario/a hace
  la llamada directamente (decisión de esta spec).
- Mini-mapa con ajuste manual real del punto de encuentro — solo
  funciona con una API key real configurada; mientras tanto se confirma
  directo la ubicación GPS sugerida.

## Criterios de finalización
- Todos los RF-1 a RF-12 con test en verde (unitarios en domain/data;
  widget tests en "Ir"/"Ya llegué"/punto de encuentro/ambulancia/
  finalización).
- Demo manual: dos cuentas aprobadas tocan "Ir" en la misma emergencia →
  la primera en llegar pone el punto de encuentro → la segunda lo ve →
  una pide ambulancia (se abre el marcador) → ambas finalizan (una
  "terminé" con foto, otra "me retiro" con razón) → un funcionario cierra
  la emergencia completa.

## Dudas abiertas
- [NECESITA ACLARACIÓN] Radio de 10 km para "comités convocados": valor
  provisional, ajustable cuando haya datos reales de cobertura de la DCC
  Bogotá.
- [NECESITA ACLARACIÓN] Niveles de dificultad (baja/media/alta): catálogo
  provisional, se ajusta si la DCC usa una escala distinta.
