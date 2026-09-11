# Metodología SDD — plantillas de referencia

Plantillas y material del curso [Hello SDD](https://github.com/mouredev/hello-sdd)
(ver [`ORIGEN.md`](ORIGEN.md)), usadas como referencia rápida del flujo
que sigue AmiPets. Para cómo se aplica cada pieza en este proyecto en
concreto, ver el [`README.md`](../README.md) de `lineamientos/`.

| Archivo | Qué es |
|---|---|
| [`AGENTS.template.md`](AGENTS.template.md) | Plantilla del archivo de contexto para el agente de IA: qué es el proyecto, comandos, estilo, reglas y verificación obligatoria al terminar. El [`AGENTS.md`](../../AGENTS.md) real de AmiPets sigue esta forma. |
| [`spec-template.md`](spec-template.md) | Plantilla de especificación: contexto, usuarios, historias, requisitos funcionales numerados (RF-N) en notación EARS, casos límite, fuera de alcance, criterios de finalización y dudas abiertas. Cada `specs/NNN-nombre/spec.md` de AmiPets sigue esta forma. |
| [`prompts.md`](prompts.md) | Tabla con el prompt esencial de cada fase: constitución, spec, clarificación, plan, tareas, implementación, validación y cambio. |
| [`sdd.excalidraw`](sdd.excalidraw) | Pizarra del curso: qué es SDD, vibe coding, tipos de SDD, notación EARS, flujo de trabajo y diagramas de cómo trabaja un agente. Se abre arrastrándolo a [excalidraw.com](https://excalidraw.com). |

## El flujo, en una línea

Constitución → Spec → Clarificación → Plan → Tareas → Implementación
(una tarea a la vez, tests primero) → Validación → Cambio (primero la
spec, luego el código).

En AmiPets cada bloque funcional grande es además su propia rama de git
(`spec/NNN-nombre`) con su propio Pull Request — ver
["Cómo trabajamos" en el README de `lineamientos/`](../README.md#cómo-trabajamos-spec-driven-development-sdd).
