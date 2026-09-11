# Lineamientos de DCC-BOGOTA

Punto de entrada para entender **qué es DCC-BOGOTA**, **cómo se está
construyendo** y **dónde está cada cosa** en el repositorio.

## Qué es DCC-BOGOTA

DCC-BOGOTA es una app móvil (Flutter + Firebase) para la Defensa Civil
Colombiana, seccional Bogotá. Resuelve, en un solo lugar:

- **Reporte público de emergencias** (incendios, sismos, accidentes
  estructurales, etc.), sin necesidad de cuenta: título, tipo, dirección,
  mínimo dos fotos — con antispam y captura mínima de evidencia del
  reportante para uso legal en caso de reporte falso.
- **Mapa de emergencias** con filtros por fecha (hoy, semana, mes, 3/6
  meses, último año) y detalle con recomendaciones según el tipo de
  emergencia.
- **Despliegue organizado**: al activarse una emergencia, se notifica a
  funcionarios/líderes/voluntarios del grupo o comité más cercano; botón
  "Voy" para confirmar asistencia, punto de encuentro en el mapa (reglas
  distintas para voluntario vs. líder/funcionario), botón "Ya llegué",
  solicitud de ambulancia, y cierre de la emergencia con foto, nivel de
  dificultad y tiempos (llegada → cierre) que quedan en el perfil del
  voluntario.
- **Roles y organización**: `voluntario`, `funcionario`, `líder`, `líder
  funcionario`; grupos/comités con sede, delegado y chat propio; chat
  general por departamento (ej. DCC Bogotá, DCC Medellín).
- **Acceso restringido**: solo usuarios autorizados por un admin pueden
  iniciar sesión. El panel administrativo (autorizar usuarios, ver
  perfiles, catalogar reportes como verdadera/activa/falsa
  controlada/en desarrollo) vive dentro de esta misma app, no en un
  panel web aparte.
- **Noticias**, **Capacítate** (unirse a la DCC) y **Prepárate** (blog:
  botiquín, qué hacer en un sismo, RCP para bebés, etc.).
- **Políticas y términos**, descargables en PDF.

Pensada desde el inicio con Flutter (en vez de nativo Android/Kotlin) para
poder portarla a iPhone más adelante sin reescribir la lógica de negocio,
aunque el uso real es y seguirá siendo mayoritariamente Android.

## Cómo trabajamos: Spec-Driven Development (SDD)

Este proyecto no se construye a golpe de prompts sueltos. Cada bloque
funcional grande sigue un flujo acordado **antes** de escribir código,
tomado del curso [Hello SDD de MoureDev](https://github.com/mouredev/hello-sdd)
— plantillas de referencia en [`metodologia-sdd/`](metodologia-sdd/):

```
Constitución → Spec → Clarificación → Plan → Tareas → Implementación → Validación → Cambio
```

| Paso | Qué produce | Dónde vive en DCC-BOGOTA |
|---|---|---|
| **Constitución** | Principios innegociables del proyecto (una sola vez, se amplía poco) | [`docs/constitution.md`](../docs/constitution.md) |
| **Contexto del agente** | Qué es el proyecto, comandos, estilo, reglas | [`AGENTS.md`](../AGENTS.md) |
| **Spec** | Entrevista de requisitos → `spec.md` con historias de usuario y RF-N en notación EARS | `specs/NNN-nombre/spec.md` |
| **Clarificación** | Revisión de la spec como QA: ambigüedades y huecos antes de planificar | discusión previa al `plan.md` |
| **Plan** | Módulos, modelo de datos, decisiones técnicas justificadas, estrategia de tests | `specs/NNN-nombre/plan.md` |
| **Tareas** | La implementación partida en pasos chicos, con checkbox y "Hecho cuando:" | `specs/NNN-nombre/tasks.md` |
| **Implementación** | Una tarea a la vez, tests primero, tests en verde antes de la siguiente | `lib/`, `test/` |
| **Validación** | Recorrido RF por RF: qué test cubre cada uno | verificado antes de cerrar la spec |
| **Cambio** | Ante un requisito nuevo: se actualiza la spec primero, el código después | "Enmienda N" dentro del `spec.md` afectado |

Cada spec grande vive además en su propia rama de git
(`spec/NNN-nombre-corto`) con su propio Pull Request hacia `main` — no se
mezcla el alcance de dos specs en una misma rama.

## De dónde sale el alcance completo

Todo el producto (roles, reportes, emergencias, chats, panel admin,
noticias, capacítate, prepárate, legal) se describió de una vez en una
conversación inicial con el dueño del producto. Esa descripción cruda,
organizada por área, vive en
[`docs/brief-inicial.md`](../docs/brief-inicial.md) — es la materia prima
de la que se van desprendiendo las specs numeradas, una a la vez, con su
propia entrevista de clarificación antes de escribirse como `spec.md`.

## Funcionalidades por spec

| Spec | Nombre | Estado |
|---|---|---|
| [001](../specs/001-fundacional/spec.md) | Fundacional (tema, auth, roles, registro, panel de aprobación) | Código completo (T1-T15) y en verde; falta el recorrido manual en un emulador Android real (T16) antes de mergear a `main` |
| [002](../specs/002-reporte-publico/spec.md) | Reporte público de emergencias y moderación | Código completo (T1-T11) y en verde; falta el recorrido manual (T12). Rama apilada sobre `spec/001-fundacional` |

Se irán agregando filas a medida que se cierren specs, igual que en
`amipets`.

## Estructura del repositorio

```
app-dccReports/
├── lib/
│   ├── domain/          # Entidades y contratos de repositorio, sin Flutter ni Firebase
│   ├── data/             # Implementaciones Firebase de esos contratos
│   ├── presentation/     # Widgets y controllers (Provider)
│   └── app/               # i18n, tema (blanco/naranja/azul), constantes compartidas
├── test/                 # Un test por archivo de lib/, mismo árbol de carpetas
├── specs/NNN-nombre/     # spec.md, plan.md, tasks.md de cada bloque funcional
├── docs/
│   ├── constitution.md   # Principios innegociables del proyecto
│   └── brief-inicial.md # Alcance completo tal como se describió, sin recortar
├── lineamientos/         # Estás aquí
│   ├── README.md         # Este archivo
│   ├── entorno-local.md  # Cómo correr el proyecto paso a paso
│   ├── diagrama-flujo.md # Navegación real de la app (se llena con las primeras specs)
│   └── metodologia-sdd/  # Plantillas de referencia del curso Hello SDD
└── AGENTS.md              # Contexto para el agente de IA
```

## Principios que no se negocian

Resumen de [`docs/constitution.md`](../docs/constitution.md) — ver ahí la
lista completa y por qué de cada uno:

- Flutter + Firebase; mapas vía `google_maps_flutter`.
- Arquitectura por capas: `domain` no importa Flutter ni Firebase.
- Ninguna funcionalidad se implementa si no está en la spec activa.
- Cada tarea termina con sus tests en verde antes de pasar a la siguiente.
- Alcance geográfico fijo: solo Bogotá por ahora.
- Una sola app: el panel administrativo vive dentro de la app, no en web.
- Reportar una emergencia como público general nunca requiere login.
- Roles fijos: voluntario, funcionario, líder, líder funcionario.
- Paleta institucional fija: blanco, naranja, azul.
- Prioridad Android, portable a iPhone.
- Secretos (Firebase, Google Maps) fuera del repo.
- Código en inglés, textos visibles al usuario en español.

## Cómo correr el proyecto

```bash
flutter pub get
flutter run              # requiere un emulador/dispositivo
flutter test              # suite completa
flutter analyze           # análisis estático
```

El detalle de comandos, estilo y reglas está en [`AGENTS.md`](../AGENTS.md).
Guía paso a paso del entorno local (Firebase Emulator Suite, etc.) en
[`entorno-local.md`](entorno-local.md).

## Qué falta

La spec 001 (rama `spec/001-fundacional`) tiene su código completo:
tema DCC, registro con rol/cursos/organización, login por correo o
teléfono, panel de aprobación (con la restricción RF-7 reforzada en
`data`, no solo en la UI), y el wiring real a Firebase en `main.dart`.
`flutter analyze`, `flutter test` (suite completa) y `flutter build apk
--debug` pasan en verde. Solo falta **T16**: el recorrido manual en un
emulador/dispositivo Android real (crear la cuenta Admin, registrar un
voluntario, aprobarlo, iniciar sesión) — instrucciones paso a paso en
[`entorno-local.md`](entorno-local.md). Una vez confirmado T16, la rama
se puede mergear a `main` con PR.

La spec 002 (rama `spec/002-reporte-publico`, apilada sobre
`spec/001-fundacional`) también tiene su código completo: formulario
público sin login, antispam por dispositivo, y moderación de reportes
desde el panel (verdadera/activa/falsa controlada/en desarrollo). Mismo
estado: todo en verde salvo **T12**, el recorrido manual — también
documentado en [`entorno-local.md`](entorno-local.md).

Como las specs 001 y 002 están apiladas (002 nace de 001, que todavía no
está en `main`), el orden recomendado para mergear es: probar T16 →
mergear 001 a `main` → probar T12 → mergear 002 a `main` (o revisar
ambas juntas si se prefiere).

Todo lo demás (specs 003-009) está pendiente — ver
`docs/brief-inicial.md` para el alcance completo y el orden propuesto.
