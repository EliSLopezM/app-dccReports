# Spec 006 — Perfiles y logros

## Contexto y objetivo
La spec 005 ya guarda, por cada participación, los tiempos desde que se
acepta una emergencia hasta que se finaliza. Esta spec convierte eso en
un perfil visible: estadísticas de servicio, insignias por hitos, y el
historial de emergencias — para que, como pide el brief original,
"otros sepan quién es quién".

## Usuarios / actores
- **Cualquier cuenta aprobada**: puede ver su propio perfil y el de
  cualquier otra cuenta aprobada.

## Historias de usuario
- H1: Como voluntario, quiero ver "Mi perfil" con mis estadísticas e
  insignias, para llevar la cuenta de mi servicio.
- H2: Como cualquier cuenta aprobada, quiero tocar el nombre de alguien
  (en una emergencia, en mi comité) y ver su perfil, para saber quién es.
- H3: Como cualquier cuenta aprobada, quiero ver el historial de
  emergencias de alguien con sus tiempos, para tener contexto de su
  experiencia.

## Requisitos funcionales (criterios de aceptación en EARS)
- RF-1: EL SISTEMA calculará, para cada cuenta, sus estadísticas de
  servicio a partir de sus participaciones finalizadas (RF-10 de la spec
  005): número total de emergencias y tiempo total de servicio (suma del
  tiempo entre llegada y finalización de cada una).
- RF-2: EL SISTEMA mantendrá un catálogo cerrado de insignias por hitos
  (cantidad de emergencias y horas de servicio) y mostrará en el perfil
  las que la cuenta ya desbloqueó.
- RF-3: CUANDO alguien toca "Ir" en una emergencia (spec 005, RF-1), EL
  SISTEMA guardará en esa participación el título y tipo de la
  emergencia, para poder listar el historial sin volver a consultar cada
  reporte por separado.
- RF-4: EL SISTEMA permitirá a cualquier cuenta aprobada ver el perfil
  detallado de cualquier otra: rol, cursos activos, organización/comité
  si aplica, insignias desbloqueadas, y el historial de emergencias en
  las que participó (título, tipo, tiempos).
- RF-5: EL SISTEMA permitirá acceder al propio perfil ("Mi perfil") desde
  el menú principal.
- RF-6: EL SISTEMA permitirá tocar el nombre de un participante (en la
  pantalla de respuesta a una emergencia, spec 005) o de un miembro de un
  comité (spec 004) para ver su perfil.

## Requisitos no funcionales
- Plataformas: Android (prioridad) e iOS.
- Idioma de interfaz: español.

## Casos límite
- Una cuenta sin ninguna participación → estadísticas en cero, sin
  insignias, historial vacío, sin error.
- Una participación "me retiro" (withdrawn) cuenta igual que "terminé"
  (completed) para las estadísticas — ambas representan tiempo de
  servicio real.
- Alguien ve su propio perfil igual que verían el de otra cuenta — no
  hay una vista especial de "mi perfil" distinta de "ver perfil de X".

## Fuera de alcance
- Notificar (push) cuando se desbloquea una insignia — spec futura.
- Insignias personalizables o editables por Admin — catálogo fijo en
  código por ahora, igual que el resto de catálogos de la app.
- Ranking o comparación entre perfiles — no pedido.

## Criterios de finalización
- Todos los RF-1 a RF-6 con test en verde (unitarios en domain/data;
  widget tests en el perfil y sus puntos de entrada).
- Demo manual: un voluntario participa y finaliza 3 emergencias distintas
  → su perfil muestra 3 en el historial, el tiempo total sumado, y la
  insignia de "Primeros pasos" desbloqueada → otra cuenta toca su nombre
  en un chat/comité y ve el mismo perfil.

## Dudas abiertas
- [NECESITA ACLARACIÓN] Catálogo de insignias (umbrales de cantidad y
  horas): provisional, se ajusta cuando la DCC defina el suyo (ver
  plan.md).
