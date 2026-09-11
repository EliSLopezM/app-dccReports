# Spec 001 — Fundacional (tema, auth, roles, registro, panel de aprobación)

## Contexto y objetivo
DCC-BOGOTA restringe el acceso a personal autorizado por un
administrador. Esta spec construye la base sin la cual ninguna otra
funcionalidad (mapa, emergencias, chats) tiene sentido: identidad visual
institucional, registro indicando rol/cursos/organización, inicio de
sesión, y el flujo de aprobación — incluida una cuenta Admin que arranca
el sistema — todo dentro de la misma app, sin panel web separado.

## Usuarios / actores
- **Solicitante**: persona que se registra pidiendo cuenta (rango
  voluntario, funcionario, líder o líder funcionario).
- **Admin**: cuenta única (el dueño del producto), fuera de la jerarquía
  operativa de la DCC. Aprueba cualquier rango.
- **Funcionario / Líder funcionario**: pueden aprobar cuentas nuevas de
  rango voluntario o líder, pero no de rango funcionario/líder
  funcionario.
- **Voluntario / Líder**: no tienen acceso al panel de aprobación.

## Historias de usuario
- H1: Como persona interesada en unirme a la DCC, quiero registrarme
  indicando mi rol deseado, cursos activos y (si aplico a
  funcionario/líder funcionario) mi organización, para solicitar acceso a
  la app.
- H2: Como Admin, quiero ver la lista de cuentas pendientes y
  aprobar/rechazar cualquiera, para controlar quién usa la app.
- H3: Como Funcionario o Líder funcionario, quiero aprobar o rechazar
  cuentas pendientes de rango voluntario o líder, para agilizar el
  ingreso de mi equipo sin depender solo de Admin.
- H4: Como usuario aprobado, quiero iniciar sesión con mi correo o
  teléfono, para entrar a la app.
- H5: Como Admin, Funcionario o Líder funcionario, quiero ver el perfil
  de cualquier cuenta actual (rol, cursos, organización, estado), para
  tener visibilidad del personal registrado.
- H6: Como solicitante con cuenta pendiente, quiero poder ver
  Noticias/Capacítate/Prepárate mientras espero aprobación, para no
  sentir que la app está bloqueada del todo.

## Requisitos funcionales (criterios de aceptación en EARS)
- RF-1: EL SISTEMA usará una paleta de colores fija (blanco, naranja,
  azul) y el nombre "DCC-BOGOTA" en toda la interfaz.
- RF-2: CUANDO una persona completa el formulario de registro, EL SISTEMA
  creará una cuenta en estado "pendiente" con: nombre, email y/o
  teléfono, rango solicitado (voluntario/funcionario/líder/líder
  funcionario), cursos activos (selección múltiple de un catálogo
  cerrado de cursos DCC), y — solo si el rango es funcionario o líder
  funcionario — nombre y dirección de sede del grupo/comité (texto
  libre).
- RF-3: SI el rango solicitado es voluntario o líder, ENTONCES EL SISTEMA
  no pedirá datos de organización.
- RF-4: MIENTRAS una cuenta esté en estado "pendiente", EL SISTEMA
  permitirá el acceso únicamente a Noticias, Capacítate y Prepárate, y
  bloqueará mapa, emergencias, chats y panel.
- RF-5: EL SISTEMA reservará un rol adicional "Admin", no seleccionable
  desde el formulario de registro público, asignado manualmente (fuera
  del flujo normal, directamente en Firebase) a la cuenta que arranca el
  sistema.
- RF-6: CUANDO Admin, Funcionario o Líder funcionario aprueban una cuenta
  pendiente, EL SISTEMA cambiará su estado a "aprobado" y le dará acceso
  completo según su rango.
- RF-7: SI Funcionario o Líder funcionario intenta aprobar o rechazar una
  cuenta cuyo rango solicitado es funcionario o líder funcionario,
  ENTONCES EL SISTEMA rechazará la acción — solo Admin puede resolver
  esas solicitudes.
- RF-8: CUANDO Admin, Funcionario o Líder funcionario rechazan una cuenta
  pendiente, EL SISTEMA la marcará como "rechazada" y se lo mostrará a
  quien se registró la próxima vez que abra la app.
- RF-9: CUANDO un usuario aprobado inicia sesión con correo+contraseña o
  teléfono+contraseña, EL SISTEMA validará las credenciales contra
  Firebase Auth y le dará acceso según su rol.
- RF-10: SI las credenciales son incorrectas, ENTONCES EL SISTEMA
  mostrará un mensaje de error genérico, sin indicar si el correo/
  teléfono existe.
- RF-11: EL SISTEMA permitirá a Admin, Funcionario y Líder funcionario
  ver, desde el panel embebido en la app, la lista de todas las cuentas
  (pendientes, aprobadas, rechazadas) con su rol, cursos y organización.
- RF-12: EL SISTEMA permitirá a Admin, Funcionario y Líder funcionario
  abrir el perfil de cualquier cuenta actual para ver su detalle
  completo.

## Requisitos no funcionales
- Plataformas: Android (prioridad) e iOS.
- Idioma de interfaz: español.
- Contraseñas y sesión gestionadas por Firebase Auth (nunca texto plano
  en Firestore).

## Casos límite
- Alguien intenta registrarse dos veces con el mismo correo/teléfono →
  Firebase Auth rechaza el duplicado, se muestra error.
- Funcionario/Líder funcionario intenta aprobar a otro funcionario/líder
  funcionario → bloqueado por RF-7.
- Cuenta rechazada intenta registrarse de nuevo → se permite un nuevo
  intento (no hay bloqueo permanente en esta spec).
- Un solicitante de rango voluntario/líder nunca completa los datos de
  organización (porque no aplica) → el formulario no debe pedírselos
  (RF-3), y su ausencia no debe bloquear el registro.

## Fuera de alcance
- Gestión completa de grupos/comités (chat propio, delegado, selección de
  un comité existente en vez de texto libre) — spec 005.
- Reporte público de emergencias sin login — spec 002.
- Recuperación de contraseña con UI dedicada, edición de perfil propio,
  cierre de sesión con confirmación — se implementa lo mínimo viable
  (recuperación básica de Firebase Auth) y se amplía en spec futura si se
  pide.
- Notificaciones push de aprobación/rechazo (en esta spec solo se
  notifica dentro de la app).

## Criterios de finalización
- Todos los RF-1 a RF-12 con test en verde (unitarios en domain/data;
  widget tests en los flujos de registro, login y aprobación).
- Demo manual: registrar un voluntario → login bloqueado (solo
  Noticias/Capacítate/Prepárate) hasta aprobación → Admin (semilla
  manual en el emulador) aprueba → login exitoso → panel muestra la
  cuenta como aprobada. Repetir con un solicitante a funcionario para
  confirmar que un Funcionario normal no puede aprobarlo (RF-7) pero
  Admin sí.

## Dudas abiertas
- [NECESITA ACLARACIÓN] ¿El registro se guarda solo al enviar el
  formulario completo, o se permite guardar un borrador si la persona
  cierra la app a la mitad? Se asume "solo al final" (como en AmiPets)
  salvo que se diga lo contrario en la fase de Plan.
- [NECESITA ACLARACIÓN] Catálogo cerrado de cursos DCC: falta la lista
  real de nombres de curso. Se usará una lista provisional corta en el
  Plan y se ajusta cuando se tenga la lista oficial.
