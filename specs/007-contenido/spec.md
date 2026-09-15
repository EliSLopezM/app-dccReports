# Spec 007 — Noticias, Capacítate, Prepárate

## Contexto y objetivo
El brief inicial (sección 9) pide tres secciones de contenido
institucional, ya visibles como accesos "Próximamente" en el `HomeShell`
desde la spec 001: **Noticias** (últimas noticias de la DCC),
**Capacítate** (cómo unirse a la Defensa Civil) y **Prepárate** (blog de
prevención: botiquín, sismos, RCP, etc.). Esta spec les da contenido
real.

## Usuarios / actores
- **Cualquier cuenta aprobada**: lee Noticias y Prepárate, y accede al
  formulario externo de Capacítate.
- **Admin**: única cuenta que publica/edita/elimina entradas de Noticias
  y Prepárate.

## Historias de usuario
- H1: Como cualquier cuenta aprobada, quiero ver una lista de noticias de
  la DCC con foto y texto, para estar informado.
- H2: Como cualquier cuenta aprobada, quiero ver un blog de preparación
  (botiquín, sismos, RCP, etc.), para aprender a reaccionar ante
  emergencias.
- H3: Como cualquier cuenta aprobada, quiero un botón claro para
  postularme a la Defensa Civil, para iniciar el proceso.
- H4: Como Admin, quiero publicar, editar y eliminar entradas de
  Noticias y Prepárate desde la misma app, para mantener el contenido
  actualizado sin depender de nadie más.

## Requisitos funcionales (criterios de aceptación en EARS)
- RF-1: EL SISTEMA mostrará, en "Noticias", la lista de publicaciones de
  tipo noticia ordenadas de más reciente a más antigua (título, foto
  opcional, y un extracto del cuerpo); al tocar una, mostrará el
  contenido completo.
- RF-2: EL SISTEMA mostrará, en "Prepárate", la lista de publicaciones de
  tipo prepárate con el mismo formato y comportamiento que Noticias
  (RF-1).
- RF-3: CUANDO la cuenta autenticada sea Admin, EL SISTEMA mostrará en
  "Noticias" y en "Prepárate" un acceso para crear una publicación nueva
  (título, cuerpo, foto opcional) y, sobre cada publicación existente,
  acciones para editarla o eliminarla.
- RF-4: SI la cuenta autenticada NO es Admin, EL SISTEMA NO mostrará
  ningún control de crear/editar/eliminar en Noticias ni Prepárate — la
  restricción se aplica también en `data`, no solo ocultando el botón en
  la UI (mismo patrón que RF-7 de la spec 001).
- RF-5: EL SISTEMA mostrará en "Capacítate" la información de requisitos
  para unirse a la Defensa Civil y un botón que abre, en el navegador o
  app externa, el formulario de postulación (Google Forms).
- RF-6: SI el enlace del formulario de Capacítate todavía no está
  configurado, EL SISTEMA mostrará un mensaje indicando que el
  formulario no está disponible todavía, en vez de intentar abrir un
  enlace inválido.

## Requisitos no funcionales
- Plataformas: Android (prioridad) e iOS.
- Idioma de interfaz: español.

## Casos límite
- Noticias/Prepárate sin ninguna publicación → estado vacío, sin error.
- Eliminar una publicación con foto no debe romper la lista de las demás.
- Un Admin edita una publicación quitándole la foto → el detalle deja de
  mostrarla (no queda una URL vieja colgando en pantalla).

## Fuera de alcance
- Comentarios o reacciones sobre publicaciones — no pedido.
- Notificaciones push al publicar — spec futura.
- Categorías/etiquetas dentro de Prepárate — una sola lista cronológica
  por ahora.
- Registrar o hacer seguimiento de postulaciones de Capacítate dentro de
  la app — se gestionan por completo en el Google Forms externo, la app
  solo enlaza a él.

## Criterios de finalización
- Todos los RF-1 a RF-6 con test en verde (unitarios en domain/data;
  widget tests en las tres pantallas y en el flujo de crear/editar/
  eliminar).
- Demo manual: Admin publica una noticia con foto → cualquier cuenta la
  ve en la lista y en el detalle; Admin la edita (cambia el título) →
  el cambio se refleja; Admin la elimina → desaparece de la lista; una
  cuenta no-Admin no ve ningún botón de gestión.

## Dudas abiertas
- [NECESITA ACLARACIÓN] URL real del Google Forms de Capacítate: se deja
  un placeholder vacío (ver plan.md, RF-6) hasta que la DCC entregue el
  enlace definitivo — no bloqueante para el resto de la spec.
