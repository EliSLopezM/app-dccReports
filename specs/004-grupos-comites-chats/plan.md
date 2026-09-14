# Plan — Spec 004 — Grupos/comités y chats

## Módulos

```
lib/
├── domain/
│   ├── entities/
│   │   ├── comite.dart          # id, name, address, leaderId, delegateId?
│   │   ├── chat.dart            # id, name, kind, memberIds, comiteId?, createdBy?
│   │   ├── chat_kind.dart       # enum: comite, department, custom
│   │   └── chat_message.dart    # id, chatId, senderId, senderName, text, sentAt
│   └── repositories/
│       ├── comite_repository.dart
│       └── chat_repository.dart
├── data/
│   └── firebase/
│       ├── firestore_comite_repository_impl.dart
│       └── firestore_chat_repository_impl.dart
└── presentation/
    ├── comite/
    │   ├── comite_picker_field.dart      # selector de comité, reusado por RegisterScreen
    │   └── comite_management_screen.dart # asignar delegado (RF-5)
    └── chat/
        ├── chats_list_screen.dart        # RF-10: mis chats + buscar/unirme a departamento
        ├── chat_screen.dart              # RF-11/RF-12: mensajería
        └── create_chat_screen.dart       # RF-7/RF-8: solo funcionario
```

`RegisterScreen` (spec 001) se modifica para: (a) si el rol es
funcionario/liderFuncionario, tras crear la cuenta también crear su
`Comite` (RF-1); (b) si el rol es voluntario/lider, mostrar
`ComitePickerField` para elegir uno existente (RF-2), guardando
`comiteId` en el registro.

`Account` (domain, spec 001) gana un campo nuevo: `comiteId: String?`.

## Modelo de datos (Firestore)

`comites/{id}`:
```
{ name, address, leaderId, delegateId: uid | null, createdAt }
```

`chats/{id}`:
```
{
  name: string,
  kind: "comite" | "department" | "custom",
  memberIds: string[],       // uids
  comiteId: string | null,   // solo kind == comite
  createdBy: string | null,  // solo kind == custom
  createdAt: timestamp
}
```

`chats/{id}/messages/{messageId}`:
```
{ senderId, senderName, text, sentAt }
```

`accounts/{uid}` (spec 001) gana el campo `comiteId: string | null`.

## Decisiones técnicas

- **Membresía siempre como `memberIds` explícito**, incluso para el chat
  de comité (en vez de calcularla al vuelo comparando
  `account.comiteId`). Alternativa descartada: membresía "derivada"
  (consultar cuentas con ese `comiteId` cada vez) — se descarta porque
  complica "mis chats" (RF-10) con una unión de fuentes distintas por
  tipo de chat; con `memberIds` uniforme, esa pantalla es una sola
  consulta `where('memberIds', arrayContains: uid)` para los tres tipos.
- **La membresía del chat de comité se llena en la aprobación, no en el
  registro** (RF-4): una cuenta pendiente no debe aparecer como miembro
  de un chat al que igual no puede entrar todavía (constitución,
  cuentas pendientes solo ven Noticias/Capacítate/Prepárate). Se agrega
  `ChatRepository.ensureComiteMembership(comiteId, uid)`, invocado desde
  `PanelAccountsListScreen` justo después de un `approve()` exitoso si
  la cuenta aprobada tiene `comiteId` — composición en la capa de
  presentación (ambos repositorios ya están disponibles ahí vía
  `provider`), no una dependencia cruzada entre repositorios de datos.
- **Un solo chat de departamento, sembrado con id fijo** `dept-bogota`
  (no autogenerado) para poder buscarlo/upsertarlo de forma idempotente
  sin colección de "departamentos" aparte — YAGNI hasta que exista más
  de una ciudad (constitución, alcance Bogotá).
- **Límite de 5 chats activos (RF-7) verificado en el repositorio**,
  contando `chats` con `kind == custom && createdBy == uid`, igual
  patrón que el antispam de la spec 002 (conteo vía query antes de
  escribir, defensa en profundidad además de la UI).
- **Mensajes en subcolección `chats/{id}/messages`**, no en un array
  dentro del documento del chat — evita el límite de tamaño de documento
  de Firestore y permite paginar/ordenar por `sentAt` de forma nativa.
- **RF-12 (rechazar envío de no-miembros) verificado en el repositorio**:
  `sendMessage` primero lee el chat y confirma `memberIds.contains(senderId)`
  antes de escribir el mensaje.

## Estrategia de tests

| RF | Cómo se prueba |
|---|---|
| RF-1, RF-3 | Unit test: `FirestoreComiteRepositoryImpl.create` crea el comité y su chat de tipo comité en la misma operación. |
| RF-2 | Widget test de `RegisterScreen`: rol voluntario muestra `ComitePickerField`; sin comités disponibles, permite continuar. |
| RF-4 | Unit test: `ChatRepository.ensureComiteMembership` agrega el uid una sola vez (idempotente si se llama dos veces). |
| RF-5 | Unit test: el líder asigna delegado a un miembro real; alguien que no es el líder intenta asignar y se rechaza. |
| RF-6 | Unit test: `joinDepartmentChat` agrega al uid al chat sembrado `dept-bogota`. |
| RF-7, RF-8, RF-9 | Unit tests de `FirestoreChatRepositoryImpl`: 5 chats activos permiten, el 6to se bloquea; eliminar libera cupo; solo el creador elimina/agrega miembros. |
| RF-10 | Unit test: `watchMyChats(uid)` trae solo los chats donde `memberIds` contiene ese uid. |
| RF-11, RF-12 | Unit tests de `sendMessage`/`watchMessages`: miembro manda y lo recibe; no-miembro es rechazado. |

## Orden de implementación

1. `domain`: `Comite`, `Chat`, `ChatKind`, `ChatMessage`, interfaces de
   repositorio, y el campo `comiteId` en `Account`.
2. `data`: `FirestoreComiteRepositoryImpl` (crear comité + su chat en una
   operación), `FirestoreChatRepositoryImpl` (membresía, límite de 5,
   mensajería).
3. `presentation/comite`: `ComitePickerField` (integrado a
   `RegisterScreen`), `ComiteManagementScreen` (delegado).
4. `presentation/chat`: `ChatsListScreen`, `ChatScreen`,
   `CreateChatScreen`.
5. Wiring: `RegisterScreen` crea comité o pide elegirlo según rol;
   `PanelAccountsListScreen` llama `ensureComiteMembership` tras aprobar;
   entrada "Chats" en `HomeShell`; entrada "Mi comité" (delegado) para
   quien sea `leaderId` de alguno.
