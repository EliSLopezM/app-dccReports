# Brief inicial — DCC-BOGOTA

Alcance completo del producto tal como se describió en la conversación de
arranque del proyecto (2026-09-11), organizado por área para poder
desprender specs numeradas de aquí, una a la vez. No es un `spec.md`
todavía — nada de esto se implementa sin pasar antes por la entrevista de
clarificación de su spec correspondiente (ver
[`lineamientos/metodologia-sdd/prompts.md`](../lineamientos/metodologia-sdd/prompts.md)).

## 1. Qué es y para quién

App para la **Defensa Civil Colombiana (DCC)**, de momento solo para
**Bogotá**, que permite:
- A **cualquier persona, sin iniciar sesión**, reportar de forma segura y
  sin spam una emergencia (incendio, zona afectada por terremoto,
  accidente estructural, etc.).
- A **personal autorizado por un admin** (voluntarios, funcionarios,
  líderes) iniciar sesión, ver esas emergencias en un mapa, organizarse
  para responder, y comunicarse por chat.
- A los roles de mayor rango (funcionario/líder), **desde dentro de la
  misma app**, autorizar nuevos usuarios y administrar reportes — no hay
  panel web separado, todo se maneja desde el celular.

## 2. Reporte público (sin login)

- Campos: título del reporte, dirección, tipo de emergencia, y **mínimo
  dos fotos**.
- Debe ser "seguro y sin spam" — mecanismo antispam pendiente de definir
  en la spec correspondiente.
- El reporte llega primero al panel administrativo para ser **autorizado**;
  solo tras esa autorización lo ve todo el personal de la DCC en el mapa.
- Al tocar una emergencia en el mapa: tipo de emergencia y
  **recomendaciones según ese tipo**.

### 2.1 Evidencia y moderación de reportes falsos

- Se guarda de forma ágil información de quien hizo el reporte (aunque no
  haya iniciado sesión), para que el admin tenga un **historial de
  reportes** por persona/número si resulta ser una broma.
- El admin cataloga cada reporte como: **verdadera**, **activa**, **falsa
  controlada**, **en desarrollo**.
- El objetivo declarado es poder **identificar usuarios o al menos sus
  números** para llevar a situaciones legales por falsedad si es
  necesario.

## 3. Roles y jerarquía

Usuarios aprobados por el admin se catalogan en uno de estos rangos:
- **Voluntario**
- **Funcionario**
- **Líder**
- **Líder funcionario**

El rango existe para que los voluntarios sepan quién está al mando y para
derivar permisos (ver secciones 5, 6 y 7).

### 3.1 Registro

- Al registrarse, la persona indica **cursos activos** y si es
  voluntario, funcionario o líder de un grupo/comité.
- **Solo líderes y funcionarios** registran información de su
  organización/grupo/comité: nombre del espacio y **dirección de la sede
  principal**.
- Cada grupo/comité tiene un **delegado**: segundo al mando si el líder no
  contesta.

## 4. Grupos / comités y chats

- Reglas de acceso: **solo hay chats entre usuarios autorizados** (nadie
  sin cuenta aprobada entra a un chat).
- Al asignarse un voluntario a un grupo/comité, se crea **por defecto un
  chat de ese grupo/comité**, visible solo para sus miembros.
- Existe además un **chat general por departamento** (ej. "DCC Bogotá",
  "DCC Medellín") — no aparece por defecto, solo si el usuario lo busca y
  se añade.
- **Solo el funcionario** puede: crear chats (máximo **5**), eliminar los
  chats que creó, y agregar a quien quiera a esos chats.

## 5. Mapa, notificaciones y filtros

- Al declararse una emergencia (tras ser autorizada), se activa una
  notificación tipo **campana** hacia funcionarios/líderes de los
  comités/grupos más cercanos y sus voluntarios.
- Si el usuario **no fue convocado** (no es de un grupo/comité cercano),
  la emergencia solo le aparece como **notificación dentro de la app**; al
  tocar "ver" en esa notificación, ahí sí aparece en su mapa.
- **Filtro por fecha** (ícono de filtros) para ver emergencias en el mapa:
  hoy, esta semana, este mes, 3 meses, 6 meses, último año.

## 6. Ciclo de vida de una emergencia

1. **Convocatoria**: se activa a funcionarios/líderes/voluntarios de los
   grupos/comités más cercanos (sección 5).
2. **"Ir"**: botón para que un voluntario/funcionario/líder confirme que
   se dirige a la emergencia.
3. **Punto de encuentro**:
   - Si llega primero un **líder o funcionario**, es quien pone el punto
     de encuentro cerca de la emergencia — **sin límite** de veces que lo
     puede reponer, pero **solo uno activo por emergencia**.
   - Si **no ha llegado** ni líder ni funcionario, un **voluntario** puede
     poner el punto de encuentro. Regla estricta: **solo quien lo puso
     puede cambiarlo/eliminarlo**; mientras exista ese punto, **ningún
     otro voluntario puede poner uno nuevo** (para evitar confusión sobre
     dónde reunirse). Un líder/funcionario que llegue después sí puede
     poner el suyo (reemplaza la restricción del voluntario).
4. **"Ya llegué"**: al llegar al punto, cada asistente toca este botón.
   - Si es el **primero en llegar**, se le pide poner el punto de
     encuentro (ver punto 3).
   - Si **no es el primero**, se notifica a los demás asistentes de que
     llegó.
   - Este momento marca el inicio del conteo de "tiempo en emergencia"
     para el perfil de ese voluntario.
5. **Ambulancia**: quien tomó/fue asignado a la emergencia indica si se
   necesita ambulancia; si es así, se dispara la llamada correspondiente a
   la persona que el admin haya asignado para eso desde el panel.
6. **Finalización**: cualquier voluntario que tomó la emergencia puede
   finalizarla en cualquier momento, por dos motivos:
   - Se tuvo que **retirar antes de que termine**: escribe razón y nivel
     de dificultad.
   - **La emergencia ya terminó**: sube foto, nivel de dificultad; se
     guarda el tiempo transcurrido desde que aceptó/se trasladó hasta que
     finalizó.
   - En ambos casos queda registrado en el **perfil del voluntario**:
     tiempo desde que llegó, tiempo total en la emergencia, y contribuye a
     sus **logros**.

## 7. Perfiles de voluntarios

- Historial de emergencias en las que participó, con tiempos (llegada →
  cierre).
- **Logros** derivados de ese historial.
- Cursos activos y rol/rango, visibles para que otros sepan quién es quién.

## 8. Panel administrativo (dentro de la app, no web)

Para roles con permiso de administración:
- Autorizar/rechazar nuevos usuarios.
- Ver perfiles de usuarios actuales.
- Autorizar reportes públicos entrantes antes de que sean visibles en el
  mapa general.
- Catalogar cada reporte: verdadera / activa / falsa controlada / en
  desarrollo (sección 2.1).
- Asignar quién recibe la llamada cuando se pide ambulancia (sección 6.5).

## 9. Secciones de contenido

- **Noticias**: últimas noticias de la DCC.
- **Capacítate**: información y flujo para unirse a la Defensa Civil
  (enviar lo que se requiera para postularse).
- **Prepárate**: espacio tipo blog con entradas como "crea tu botiquín",
  "qué hacer en un terremoto", "cómo reaccionar en caso de emergencia",
  "RCP para bebés", etc.

## 10. Legal

- Políticas / términos de uso, disponibles para **descargar en PDF**
  desde la app.

## 11. Identidad visual y plataformas

- Nombre de la app: **DCC-BOGOTA**.
- Colores institucionales DCC: **blanco, naranja, azul** — paleta fija,
  sin colores ad-hoc.
- Compatible con Android y iPhone, con **prioridad en Android**.

## Orden de specs propuesto

Desprendido de las secciones anteriores, agrupando por lo que se puede
construir y probar de forma independiente. Sujeto a que el dueño del
producto confirme o reordene antes de arrancar la spec 001:

1. **Fundacional** (spec 001, código completo): tema/paleta DCC,
   estructura de navegación base, auth (login solo para autorizados) +
   roles + registro (cursos, rol, organización si aplica) + flujo de
   aprobación de usuarios desde el panel embebido.
2. **Reporte público y moderación** (spec 002, código completo — junta lo
   que aquí se había separado en "reporte público" y "panel admin —
   moderación", mismo patrón que la spec 001 con registro+aprobación):
   formulario público sin login, antispam por dispositivo, evidencia del
   reportante, y su catalogación desde el panel
   (verdadera/activa/falsa controlada/en desarrollo).
3. **Mapa y despliegue** (spec 003, código completo): mapa con
   emergencias en estado "activa" (spec 002), filtros por fecha, campana
   con conteo/lista de activas (sin dirigirse todavía solo a los
   grupos/comités cercanos — eso lo amplía la spec 004), y detalle de
   emergencia con recomendaciones por tipo.
4. **Grupos/comités y chats** (spec 004, código completo): comité
   fundado por funcionario/líder funcionario al registrarse (elegido por
   voluntario/líder de una lista), delegado, chat automático de comité
   (se puebla al aprobar la cuenta), chat único de departamento (DCC
   Bogotá), chats personalizados creados/eliminados solo por funcionario
   (máx. 5 activos), y mensajería en tiempo real para los tres tipos.
5. **Ciclo de vida de la emergencia**: "Ir", punto de encuentro (reglas de
   voluntario vs. líder/funcionario), "Ya llegué", solicitud de ambulancia
   + llamada, finalización (foto/nivel/razón) y tiempos en el perfil.
6. **Perfiles y logros**: historial de participación, logros, cursos y rol
   visibles.
7. **Noticias, Capacítate, Prepárate**: las tres secciones de contenido.
8. **Legal**: políticas/términos + descarga en PDF.

Ver perfiles de usuarios actuales (mencionado en la sección 8 del brief)
ya quedó cubierto por el panel de la spec 001; ver perfiles de
voluntarios con logros/tiempos de participación es parte de la spec de
Perfiles y logros de arriba.

Cada una de estas, al arrancar, pasa primero por la entrevista de
clarificación de la spec (preguntas una a una) antes de escribirse como
`specs/NNN-nombre/spec.md` — este documento es la materia prima, no el
contrato final.
