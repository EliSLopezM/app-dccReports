# Tareas — Spec 004 — Grupos/comités y chats

Cada tarea: tests primero, luego implementación mínima para pasarlos,
`flutter analyze` + `flutter test` en verde antes de marcar `[x]`.

## Domain

- [x] **T1 — Entidades: `Comite`, `Chat`, `ChatKind`, `ChatMessage`** (RF-1, RF-3, RF-6, RF-7, RF-11)
  Más el campo `comiteId: String?` en `Account` (spec 001). Unit tests:
  construir cada entidad válida.
  Hecho cuando: los tests de entidades pasan.

- [x] **T2 — Excepciones + interfaz `ComiteRepository`** (RF-1, RF-5)
  `NotComiteLeaderException` en `domain/exceptions.dart`;
  `domain/repositories/comite_repository.dart` con `create`,
  `watchAllComites`, `watchComite`, `setDelegate`.
  Hecho cuando: `flutter analyze` no marca nada en `domain/`.

- [x] **T3 — Excepciones + interfaz `ChatRepository`** (RF-4, RF-6 a RF-12)
  `NotChatOwnerException`, `ChatLimitExceededException`,
  `NotChatMemberException`; `domain/repositories/chat_repository.dart`
  con `ensureComiteMembership`, `joinDepartmentChat`, `createCustomChat`,
  `deleteChat`, `addMember`, `watchMyChats`, `sendMessage`,
  `watchMessages`.
  Hecho cuando: `flutter analyze` no marca nada en `domain/`.

## Data — Comités

- [x] **T4 — `FirestoreComiteRepositoryImpl.create`** (RF-1, RF-3)
  Crea el documento del comité y, en la misma operación, el chat de tipo
  "comité" asociado. Tests con `fake_cloud_firestore`: el comité y su
  chat quedan creados; el chat tiene `kind: comite` y `comiteId`
  apuntando al comité.
  Hecho cuando: el test pasa.

- [x] **T5 — `FirestoreComiteRepositoryImpl.setDelegate`** (RF-5)
  Solo el `leaderId` puede asignar delegado, y solo a alguien que ya sea
  miembro (ver T6, se valida contra el chat de comité). Tests: líder
  asigna a un miembro real (OK); alguien que no es el líder intenta
  (bloqueado).
  Hecho cuando: ambos tests pasan.

## Data — Chats

- [x] **T6 — `ensureComiteMembership`** (RF-4)
  Agrega el uid a `memberIds` del chat de ese comité (`arrayUnion`,
  idempotente). Tests: se agrega una vez; llamarlo dos veces no duplica.
  Hecho cuando: ambos tests pasan.

- [x] **T7 — Chat de departamento sembrado + `joinDepartmentChat`** (RF-6)
  Documento `chats/dept-bogota` con `kind: department`, creado si no
  existe. Tests: unirse agrega el uid; buscar por nombre lo encuentra
  aunque el uid no sea miembro todavía.
  Hecho cuando: los tests pasan.

- [x] **T8 — `createCustomChat` con límite de 5 activos** (RF-7)
  Tests: 5 chats seguidos del mismo funcionario pasan; el 6to lanza
  `ChatLimitExceededException`.
  Hecho cuando: ambos tests pasan.

- [x] **T9 — `deleteChat` y `addMember`, solo el creador** (RF-8, RF-9)
  Tests: el creador elimina y libera cupo (crear uno más tras eliminar
  pasa); el creador agrega un miembro; alguien que no es el creador
  intenta eliminar/agregar y se rechaza.
  Hecho cuando: los 4 casos pasan.

- [x] **T10 — `watchMyChats`** (RF-10)
  Tests: trae solo los chats donde `memberIds` contiene el uid dado,
  de los 3 tipos mezclados.
  Hecho cuando: el test pasa.

- [x] **T11 — `sendMessage`/`watchMessages`** (RF-11, RF-12)
  Tests: un miembro manda un mensaje y aparece en `watchMessages`; un no
  miembro intenta mandar y `NotChatMemberException` se lanza.
  Hecho cuando: ambos tests pasan.

## Presentation

- [x] **T12 — `ComitePickerField` + cambios en `RegisterScreen`** (RF-1, RF-2)
  Rol funcionario/liderFuncionario: al enviar el registro, además crea
  el comité (T4) con el nombre/dirección ya capturados (spec 001).
  Rol voluntario/lider: selector de comité existente (lista vacía si
  no hay ninguno, sin bloquear el registro). Widget tests para ambas
  ramas.
  Hecho cuando: los widget tests pasan.

- [x] **T13 — `ComiteManagementScreen`** (RF-5)
  Visible solo para quien sea `leaderId` de un comité; lista miembros y
  permite asignar/cambiar delegado. Widget test.
  Hecho cuando: el widget test pasa.

- [x] **T14 — `ChatsListScreen`** (RF-6, RF-10)
  Lista "mis chats"; buscador para encontrar y unirse al chat de
  departamento. Widget tests: lista mis chats; buscar y unirse agrega el
  chat a la lista.
  Hecho cuando: los widget tests pasan.

- [x] **T15 — `ChatScreen`** (RF-11, RF-12)
  Mensajería en tiempo real dentro de un chat. Widget test: enviar un
  mensaje lo agrega a la lista visible.
  Hecho cuando: el widget test pasa.

- [x] **T16 — `CreateChatScreen`** (RF-7, RF-8, RF-9)
  Solo visible/alcanzable para funcionario; crear, ver mis chats creados,
  eliminar, agregar miembros. Widget tests: crear chat; bloqueado al
  llegar a 5 activos; eliminar libera cupo.
  Hecho cuando: los widget tests pasan.

## Wiring final

- [ ] **T17 — Providers + integración con aprobación + `HomeShell`**
  `ComiteRepository`/`ChatRepository` en `main.dart`.
  `PanelAccountsListScreen` llama `ensureComiteMembership` justo después
  de un `approve()` exitoso si la cuenta tiene `comiteId` (RF-4).
  Entradas "Chats" (cualquier cuenta aprobada) y "Mi comité" (solo para
  quien sea líder de alguno) en `HomeShell`.
  Hecho cuando: `flutter analyze` y `flutter test` (suite completa) pasan
  en verde.

- [ ] **T18 — Boot-check manual** (requiere emulador/dispositivo Android
  real, igual que las specs anteriores)
  Un funcionario se registra (funda comité) → un voluntario se registra
  eligiendo ese comité → Admin aprueba a ambos → ambos ven el chat del
  comité y se mandan mensajes → el funcionario crea un chat personalizado
  y agrega al voluntario → chatean ahí también → el funcionario asigna
  al voluntario como delegado.
  Hecho cuando: el recorrido completo funciona y queda una captura.
