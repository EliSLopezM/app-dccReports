# Plan — Spec 001 — Fundacional

## Módulos

```
lib/
├── app/
│   ├── theme.dart            # ThemeData DCC: blanco/naranja/azul (RF-1)
│   ├── routes.dart           # Rutas nombradas + guard de sesión/estado
│   └── firebase_options.dart # Config del emulador (demo-dccbogota)
├── domain/
│   ├── entities/
│   │   ├── account_role.dart       # enum: voluntario, funcionario, lider, liderFuncionario, admin
│   │   ├── account_status.dart     # enum: pending, approved, rejected
│   │   ├── organization_info.dart  # { name, address } — solo funcionario/líder funcionario
│   │   ├── account.dart            # entidad Account
│   │   └── course_catalog.dart     # lista const de cursos DCC (catálogo cerrado, RF-2)
│   └── repositories/
│       ├── auth_repository.dart    # interfaz: register, login, currentUid stream, logout
│       └── account_repository.dart # interfaz: watchAccount, watchAllAccounts, approve, reject
├── data/
│   ├── firebase_auth_repository.dart
│   └── firestore_account_repository.dart
└── presentation/
    ├── register/register_screen.dart
    ├── login/login_screen.dart
    ├── pending/pending_approval_screen.dart   # RF-4: solo Noticias/Capacítate/Prepárate (stubs)
    ├── panel/panel_accounts_list_screen.dart  # RF-11
    ├── panel/account_detail_screen.dart       # RF-12
    └── home/home_shell.dart                   # post-aprobación, navegación según rol
```

## Modelo de datos (Firestore)

`accounts/{uid}` (uid = Firebase Auth uid):
```
{
  name: string,
  email: string | null,
  phone: string | null,
  role: "voluntario" | "funcionario" | "lider" | "liderFuncionario" | "admin",
  status: "pending" | "approved" | "rejected",
  activeCourses: string[],            // ids del catálogo cerrado
  organization: { name, address } | null,  // solo si role pedido es funcionario/liderFuncionario
  createdAt: timestamp,
  reviewedBy: uid | null,
  reviewedAt: timestamp | null
}
```

El catálogo de cursos (RF-2) es una **constante en `domain/entities/course_catalog.dart`**,
no una colección de Firestore — es cerrado y no cambia por spec (decisión:
más simple que gestionar un CRUD de catálogo que nadie pidió; alternativa
descartada: colección `courses` en Firestore, se revisita si algún día se
pide administrar el catálogo desde el panel).

## Decisiones técnicas

- **`Account` único con `role` + `status`**, en vez de colecciones
  separadas por rol. Alternativa descartada: `pendingRequests/` +
  `accounts/` separadas — se descarta porque duplica el modelo y complica
  el caso "cuenta rechazada se registra de nuevo" (RF de casos límite).
- **`role: admin` no es seleccionable en el formulario de registro**
  (RF-5): el picker de rol en `register_screen.dart` solo ofrece
  voluntario/funcionario/líder/líder funcionario. La cuenta Admin se crea
  escribiendo directamente el documento `accounts/{uid}` con `role:
  "admin", status: "approved"` en el emulador (documentado en
  `lineamientos/entorno-local.md`), después de crear el usuario en el tab
  Auth del emulador. No hay pantalla para esto — es deliberadamente
  manual (constitución, "la spec manda": no se construye UI para un caso
  que ocurre una sola vez).
- **Regla RF-7 (Funcionario no aprueba funcionario)** se aplica en dos
  capas: la UI oculta el botón aprobar/rechazar para esas filas, y
  `FirestoreAccountRepository.approve/reject` valida el rol de quien
  llama contra el rol de la cuenta objetivo antes de escribir — así
  aunque se agreguen Firestore Rules más adelante (constitución, hoy
  permisivas por ser solo emulador), la regla de negocio ya vive en
  `data/`, no solo en la UI.
- **Login por correo o teléfono**: mismo patrón que AmiPets
  (`country_code_picker` ya no hace falta si se resuelve con
  `firebase_auth` signInWithEmailAndPassword para ambos casos,
  normalizando el teléfono a un email sintético `+57...@phone.dccbogota.app`
  solo si Firebase Auth de teléfono con contraseña no es directo —
  **a confirmar en la Tarea 1** contra la versión real de `firebase_auth`
  disponible; si requiere SMS/OTP en vez de contraseña, se ajusta esta
  spec con una Enmienda antes de seguir, porque cambiaría RF-9/RF-10).
- **Noticias/Capacítate/Prepárate como stubs** ("Próximamente") en esta
  spec — solo existen para que RF-4 tenga algo real que mostrar a una
  cuenta pendiente. Contenido real: spec futura (ver
  `docs/brief-inicial.md`, spec 008).

## Estrategia de tests

| RF | Cómo se prueba |
|---|---|
| RF-1 | Widget test: `ThemeData` expone los 3 colores DCC. |
| RF-2, RF-3 | Widget test de `RegisterScreen`: cambia el rol y verifica que los campos de organización aparecen/desaparecen; unit test de `Account.fromForm(...)`. |
| RF-4 | Widget test: `PendingApprovalScreen` solo navega a los 3 stubs, no a Home/Panel. |
| RF-5 | No aplica test de UI (es un procedimiento manual); se documenta y se verifica en la demo manual. |
| RF-6, RF-7, RF-8 | Unit tests de `FirestoreAccountRepository.approve/reject` con `fake_cloud_firestore`, cubriendo el caso permitido y el caso RF-7 bloqueado. |
| RF-9, RF-10 | Unit tests de `FirebaseAuthRepository` (con fake/mocks) para login correcto e incorrecto. |
| RF-11, RF-12 | Widget tests de `PanelAccountsListScreen` y `AccountDetailScreen` con datos de `fake_cloud_firestore`. |

## Orden de implementación

1. `domain` (entidades, enums, catálogo, interfaces de repositorio) — sin
   Flutter ni Firebase, 100% testeable con Dart puro.
2. `data` (implementaciones Firebase) con tests contra
   `fake_cloud_firestore` y el emulador de Auth.
3. `presentation` (pantallas), de afuera hacia adentro: registro → login
   → pendiente → panel → detalle → home shell con navegación por rol.
4. Wiring final en `main.dart` (Firebase.initializeApp + emulador +
   inyección de repositorios reales) + boot-check manual en un
   emulador/dispositivo Android.
