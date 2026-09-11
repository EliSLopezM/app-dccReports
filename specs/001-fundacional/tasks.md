# Tareas — Spec 001 — Fundacional

Cada tarea: tests primero, luego implementación mínima para pasarlos,
`flutter analyze` + `flutter test` en verde antes de marcar `[x]`.

## Domain

- [x] **T1 — Enums y entidad `Account`** (RF-2, RF-3, RF-5)
  `domain/entities/account_role.dart`, `account_status.dart`,
  `organization_info.dart`, `account.dart`. Unit tests: construir una
  `Account` válida por cada rol; `organization` debe ser `null` si el rol
  es voluntario/líder.
  Hecho cuando: `flutter test test/domain/entities/account_test.dart`
  pasa.

- [x] **T2 — Catálogo de cursos** (RF-2)
  `domain/entities/course_catalog.dart` con una lista const provisional
  de cursos DCC (ver Dudas abiertas de `spec.md`). Unit test: la lista no
  está vacía y no tiene ids duplicados.
  Hecho cuando: test de `course_catalog_test.dart` pasa.

- [x] **T3 — Interfaces de repositorio** (RF-6 a RF-12)
  `domain/repositories/auth_repository.dart`,
  `account_repository.dart` — solo interfaces, sin implementación. Sin
  test propio (no hay comportamiento que probar todavía).
  Hecho cuando: `flutter analyze` no marca nada en `domain/`.

## Data

- [x] **T4 — `FirebaseAuthRepository`: registro** (RF-2)
  Implementa `register(...)` creando el usuario en Firebase Auth
  (emulador) y el documento `accounts/{uid}` con `status: pending`. Test
  contra el emulador de Auth + `fake_cloud_firestore`.
  Hecho cuando: test de registro exitoso y de correo duplicado
  (RF caso límite) pasan.

- [x] **T5 — `FirebaseAuthRepository`: login** (RF-9, RF-10)
  Implementa `login(identifier, password)` aceptando correo o teléfono.
  Tests: login correcto, login con credenciales incorrectas (mensaje
  genérico).
  Hecho cuando: ambos tests pasan.

- [x] **T6 — `FirestoreAccountRepository`: lectura** (RF-4, RF-11, RF-12)
  `watchAccount(uid)`, `watchAllAccounts()`, `watchPendingAccounts()`.
  Tests con `fake_cloud_firestore` sembrando cuentas de los 3 estados.
  Hecho cuando: tests de lectura pasan.

- [x] **T7 — `FirestoreAccountRepository`: aprobar/rechazar** (RF-6,
  RF-7, RF-8)
  `approve(reviewerRole, accountId)`, `reject(reviewerRole, accountId,
  reason?)`. Tests: Admin aprueba a un funcionario (OK), Funcionario
  intenta aprobar a un funcionario (bloqueado, RF-7), Funcionario aprueba
  a un voluntario (OK), rechazo marca `status: rejected`.
  Hecho cuando: los 4 tests pasan.

## Presentation

- [x] **T8 — Tema DCC** (RF-1)
  `app/theme.dart` con los colores institucionales. Widget test: los
  `ColorScheme`/botones usan esos colores.
  Hecho cuando: test de tema pasa.

- [x] **T9 — `RegisterScreen`** (RF-2, RF-3)
  Formulario con selector de rol, checkboxes de cursos (del catálogo T2),
  y campos de organización que solo aparecen si el rol es
  funcionario/líder funcionario. Widget tests para ambas ramas.
  Hecho cuando: los widget tests de T9 pasan.

- [x] **T10 — `LoginScreen`** (RF-9, RF-10)
  Formulario correo/teléfono + contraseña, muestra el error genérico de
  T5. Widget test de ambos casos con un fake `AuthRepository`.
  Hecho cuando: los widget tests de T10 pasan.

- [x] **T11 — `PendingApprovalScreen`** (RF-4)
  Muestra estado "pendiente" y accesos únicamente a Noticias/Capacítate/
  Prepárate (stubs "Próximamente" nuevos en esta tarea). Widget test:
  no hay navegación a Home/Panel visible.
  Hecho cuando: el widget test de T11 pasa.

- [x] **T12 — `PanelAccountsListScreen`** (RF-11)
  Lista todas las cuentas con filtro por estado; oculta
  aprobar/rechazar en filas de funcionario/líder funcionario si quien
  mira no es Admin (RF-7 en UI). Widget test con `fake_cloud_firestore`.
  Hecho cuando: el widget test de T12 pasa, incluida la fila oculta.

- [x] **T13 — `AccountDetailScreen`** (RF-12)
  Detalle de una cuenta: rol, cursos, organización, estado. Widget test
  con una cuenta de cada rol.
  Hecho cuando: el widget test de T13 pasa.

- [x] **T14 — `HomeShell` con navegación por rol**
  Shell post-login: Admin/Funcionario/Líder funcionario ven acceso al
  panel (T12); voluntario/líder no. Widget test de ambos casos.
  Hecho cuando: el widget test de T14 pasa.

## Wiring final

- [x] **T15 — Firebase real en `main.dart`**
  `Firebase.initializeApp` apuntando al emulador en modo debug (mismo
  patrón que AmiPets: `10.0.2.2` en Android, `localhost` en el resto),
  inyecta `FirebaseAuthRepository`/`FirestoreAccountRepository` reales
  vía `provider`, rutas iniciales: pendiente de sesión → Login/Register →
  Pending o Home según estado.
  Hecho cuando: `flutter analyze` y `flutter test` (suite completa) pasan
  en verde.

- [ ] **T16 — Boot-check manual + semilla de Admin** (pendiente — requiere
  emulador/dispositivo Android real, fuera del entorno de este agente)
  Con el emulador corriendo (`firebase emulators:start`): crear a mano el
  usuario Admin (Auth + documento `accounts/{uid}` con `role: admin,
  status: approved`) siguiendo el paso a paso de
  `lineamientos/entorno-local.md` ("Crear la cuenta Admin" y "Recorrido
  de prueba completo"), correr la app en un emulador Android, registrar
  un voluntario de prueba, confirmar que queda bloqueado en Pending,
  loguear como Admin, aprobarlo, loguear como el voluntario y confirmar
  acceso a Home.
  Verificado en su lugar: `flutter build apk --debug` compila sin
  errores (confirma que Firebase/Android/Gradle están bien conectados
  sin necesitar `google-services.json`, gracias a `FirebaseOptions`
  explícitas).
  Hecho cuando: el recorrido completo funciona en un emulador/dispositivo
  real y queda una captura.
