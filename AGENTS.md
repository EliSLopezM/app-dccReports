# AGENTS.md — DCC-BOGOTA (app-dccReports)

## Proyecto
App Flutter para la Defensa Civil Colombiana (seccional Bogotá): reporte
público (sin login) de emergencias — incendios, sismos, accidentes
estructurales, etc. — con mapa, despliegue organizado de voluntarios,
funcionarios y líderes por grupo/comité, chats internos, y un panel
administrativo embebido en la misma app (sin panel web aparte) para
autorizar usuarios y moderar reportes. Backend: Firebase (Auth, Firestore,
Storage, Cloud Messaging).

## Comandos
- Ejecutar: `flutter run`
- Tests: `flutter test`
- Análisis estático: `flutter analyze`
- Formato: `dart format .`

## Estilo y convenciones
- Dart estable más reciente, `flutter_lints` activo.
- Arquitectura por capas: `lib/domain`, `lib/data`, `lib/presentation`
  (ver docs/constitution.md, principio 2). El domain no importa
  `package:flutter` ni `package:cloud_firestore`.
- Nombres de clases, archivos y variables en inglés. Textos visibles al
  usuario (labels, mensajes, errores) en español.
- Paleta de colores fija: blanco / naranja / azul (identidad DCC) — ver
  `lib/app/theme.dart` una vez exista.

## Reglas
- Lee `docs/constitution.md` y la spec activa en `specs/` antes de tocar
  código.
- No añadas pantallas, campos, roles o comportamiento que no estén en la
  spec activa sin preguntar primero.
- El panel administrativo va DENTRO de esta misma app Flutter (visible
  según rol), nunca como proyecto web separado.
- No hardcodees API keys ni credenciales; usa la configuración de Firebase
  y variables de entorno ignoradas por git.

## Al terminar cualquier tarea
- Ejecuta `flutter analyze` y `flutter test`; ambos deben pasar en verde
  antes de marcar la tarea como hecha.
