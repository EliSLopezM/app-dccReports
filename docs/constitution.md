# Constitución — DCC-BOGOTA (app-dccReports)

Principios innegociables. Toda spec, plan y tarea debe cumplirlos.

1. **Stack**: Flutter (canal estable) + Firebase (Auth, Firestore, Storage,
   Cloud Messaging, Cloud Functions para llamadas/orquestación). Mapas vía
   `google_maps_flutter`.
2. **Arquitectura limpia por capas**: `domain` (entidades y casos de uso
   puros, sin imports de Flutter ni Firebase) → `data` (repositorios e
   implementaciones Firebase, implementan interfaces de domain) →
   `presentation` (widgets y manejo de estado). Domain no depende de nada;
   las dependencias solo apuntan hacia adentro.
3. **La spec manda**: ningún comportamiento se implementa si no está en la
   spec activa. Si falta una decisión, se detiene el trabajo y se pregunta.
4. **Tests como puerta**: cada tarea termina con sus tests en verde
   (unitarios obligatorios en domain/data; widget tests donde aporten
   valor real). Prohibido avanzar con tests en rojo.
5. **Alcance geográfico fijo**: solo Bogotá por ahora, tanto para reportar
   emergencias como para el despliegue de grupos/comités de la Defensa
   Civil.
6. **Una sola app, sin panel web separado**: el panel administrativo (autorizar
   usuarios, catalogar reportes, ver perfiles) vive dentro de la misma app
   Flutter, mostrado según el rol de quien inicia sesión — no hay un
   proyecto web aparte.
7. **Acceso restringido por invitación**: solo personas autorizadas por un
   admin pueden crear cuenta e iniciar sesión. Reportar una emergencia
   como público general NUNCA requiere cuenta ni login.
8. **Jerarquía de roles fija**: `voluntario`, `funcionario`, `líder`,
   `líder funcionario`. Los permisos (crear/eliminar chats, poner punto de
   encuentro sin restricción, ver información de organización, etc.) se
   derivan de este rol y no se redefinen spec a spec.
9. **Identidad visual DCC**: paleta fija blanco / naranja / azul (colores
   institucionales de la Defensa Civil Colombiana). Sin colores ad-hoc por
   pantalla.
10. **Prioridad Android, portable a iPhone**: se desarrolla y prueba
    principalmente en Android (el uso real es mayormente Android), evitando
    código o plugins que solo funcionen en una plataforma sin documentar el
    equivalente pendiente en la otra.
11. **Datos sensibles y legales**: todo reporte anónimo guarda evidencia
    mínima identificable de quien lo hizo (para poder actuar legalmente ante
    reportes falsos), pero esos datos solo son visibles para el panel
    administrativo, nunca en el mapa público de emergencias.
12. **Secretos fuera del repo**: claves de Google Maps y configuración de
    Firebase viven en archivos ignorados por git; nunca hardcodeadas en el
    código.
13. **Idioma**: código e identificadores en inglés; mensajes al usuario y
    documentación en español.
14. **Iteración por specs**: cada bloque funcional grande es una spec
    numerada independiente en `specs/NNN-nombre/`; no se mezclan alcances.
