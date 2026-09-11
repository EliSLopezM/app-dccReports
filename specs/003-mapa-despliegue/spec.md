# Spec 003 — Mapa y despliegue

## Contexto y objetivo
Las emergencias catalogadas como "activa" (spec 002) necesitan ser
visibles para todo el personal de la DCC en un mapa, con recomendaciones
según el tipo de emergencia y un aviso (campana) de que algo nuevo está
activo. La convocatoria dirigida solo a los grupos/comités más cercanos
queda fuera de esta spec porque depende de que existan los
grupos/comités (spec 004) — aquí la campana avisa a todo el personal por
igual.

## Usuarios / actores
- **Cualquier cuenta aprobada** (voluntario, funcionario, líder, líder
  funcionario, admin): ve el mapa, la campana y el detalle de cada
  emergencia.

## Historias de usuario
- H1: Como voluntario, quiero ver en un mapa las emergencias activas
  cerca de mí, para saber a dónde puedo dirigirme.
- H2: Como voluntario, quiero filtrar el mapa por fecha (hoy, semana,
  mes, 3/6 meses, último año), para no perderme entre muchas emergencias
  acumuladas.
- H3: Como voluntario, quiero tocar una emergencia y ver recomendaciones
  según su tipo, para saber cómo actuar antes de llegar.
- H4: Como cualquier cuenta aprobada, quiero ver una campana con las
  emergencias activas, para enterarme rápido de que algo nuevo pasó.

## Requisitos funcionales (criterios de aceptación en EARS)
- RF-1: EL SISTEMA mostrará en un mapa los reportes en estado "activa",
  filtrados por fecha de creación según el filtro de fecha elegido.
- RF-2: EL SISTEMA ofrecerá un selector de rango de fecha (hoy, esta
  semana, este mes, 3 meses, 6 meses, último año), con "esta semana"
  como valor inicial.
- RF-3: CUANDO el usuario toca un pin del mapa, EL SISTEMA abrirá el
  detalle de esa emergencia: tipo, dirección, fotos, y recomendaciones
  de seguridad según el tipo.
- RF-4: EL SISTEMA mantendrá, por cada tipo de emergencia del catálogo,
  una lista corta de recomendaciones de seguridad (texto provisional,
  ver Dudas abiertas).
- RF-5: EL SISTEMA mostrará una campana con la cantidad de emergencias
  activas, visible para cualquier cuenta aprobada.
- RF-6: CUANDO el usuario toca la campana, EL SISTEMA mostrará la lista
  de emergencias activas (título, tipo, dirección) y permitirá tocar una
  para ver su detalle (RF-3).
- RF-7: MIENTRAS no exista una API key real de Google Maps configurada,
  EL SISTEMA mostrará un placeholder en el lugar del mapa, sin bloquear
  el resto de la lógica (filtros, pines, detalle) — mismo patrón que
  AmiPets.

## Requisitos no funcionales
- Plataformas: Android (prioridad) e iOS.
- Idioma de interfaz: español.

## Casos límite
- No hay emergencias activas en el rango de fecha elegido → el mapa/lista
  muestra un estado vacío, no un error.
- Un reporte pasa de "activa" a otro estado mientras el mapa está abierto
  → su pin desaparece en la siguiente actualización del stream (no hace
  falta refrescar manualmente).
- Cambiar el filtro de fecha mientras el mapa está abierto → se
  re-consulta con el nuevo rango de inmediato.

## Fuera de alcance
- Convocatoria/campana dirigida solo a grupos/comités cercanos — spec 004
  (grupos/comités), que ampliará esta campana.
- La mecánica de "tocar ver para que aparezca en mi mapa" del brief
  original — se decidió, para esta spec, que el mapa muestre directo
  todas las "activa" del rango de fecha; se revisita si hace falta
  cuando exista la convocatoria por cercanía.
- Recomendaciones oficiales redactadas por la DCC — se usa un texto
  provisional razonable (ver Dudas abiertas), reemplazable después.
- Botón "Ir", punto de encuentro, "Ya llegué", ambulancia — ciclo de vida
  de la emergencia, spec futura.

## Criterios de finalización
- Todos los RF-1 a RF-7 con test en verde (unitarios en domain/data;
  widget tests en el filtro, la campana y el detalle con recomendaciones).
- Demo manual: con 2+ reportes "activa" de distintas fechas, cambiar el
  filtro y confirmar que el mapa/lista se actualiza; tocar un pin/ítem y
  ver sus recomendaciones; confirmar que la campana muestra el conteo
  correcto.

## Dudas abiertas
- [NECESITA ACLARACIÓN] Texto oficial de recomendaciones de la DCC por
  tipo de emergencia — se redacta un texto genérico de seguridad básica
  en el Plan, a reemplazar cuando exista contenido oficial.
