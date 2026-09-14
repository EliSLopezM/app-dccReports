# Spec 004 — Grupos/comités y chats

## Contexto y objetivo
La spec 001 dejó la organización de funcionario/líder funcionario como
texto libre, sin gestión real de comités. Esta spec construye la entidad
real `Comite`, la vincula al registro (voluntario/líder ahora eligen a
cuál pertenecen), y construye los chats de grupo que dependen de esa
estructura: chat automático por comité, chat único de departamento (DCC
Bogotá), y chats personalizados creados por funcionarios — con mensajería
de texto en tiempo real para los tres tipos.

## Usuarios / actores
- **Funcionario / Líder funcionario**: al registrarse, funda un comité
  nuevo (nombre + dirección) y queda como su líder. Puede asignar
  delegado, y es el único que crea/elimina/gestiona chats personalizados.
- **Voluntario / Líder**: al registrarse, elige un comité existente (o
  continúa sin comité si todavía no hay ninguno).
- **Cualquier cuenta aprobada**: puede unirse al chat de departamento y
  enviar/recibir mensajes en los chats de los que es miembro.

## Historias de usuario
- H1: Como funcionario, quiero que mi registro funde mi comité, para no
  tener que crearlo por separado.
- H2: Como voluntario, quiero elegir mi comité al registrarme, para
  quedar conectado a su chat automáticamente cuando me aprueben.
- H3: Como líder de un comité, quiero asignar un delegado entre mis
  miembros, para que alguien responda si yo no puedo.
- H4: Como cualquier cuenta aprobada, quiero buscar y unirme al chat de
  departamento, para enterarme de lo que pasa en toda la seccional.
- H5: Como funcionario, quiero crear chats propios (hasta 5 activos) y
  decidir quién entra, para coordinar grupos de trabajo específicos.
- H6: Como miembro de un chat, quiero enviar y ver mensajes en tiempo
  real, para coordinarme con mi equipo.

## Requisitos funcionales (criterios de aceptación en EARS)
- RF-1: CUANDO una cuenta de rango funcionario o líder funcionario
  completa el registro (spec 001, RF-2), EL SISTEMA creará un `Comite`
  nuevo con el nombre y dirección dados, y la asignará como su líder
  (`leaderId`).
- RF-2: CUANDO una cuenta de rango voluntario o líder completa el
  registro, EL SISTEMA le pedirá elegir un comité existente de una
  lista; si todavía no existe ninguno, permitirá continuar sin comité
  asignado.
- RF-3: CUANDO se crea un `Comite` (RF-1), EL SISTEMA creará
  automáticamente su chat de tipo "comité", visible solo para sus
  miembros.
- RF-4: CUANDO una cuenta con comité asignado es aprobada (spec 001,
  RF-6), EL SISTEMA la agregará como miembro del chat de ese comité.
- RF-5: EL SISTEMA permitirá al líder de un comité asignar como delegado
  a cualquier miembro actual de ese comité, y cambiarlo cuando quiera.
- RF-6: EL SISTEMA mantendrá un único chat de departamento ("DCC
  Bogotá"), buscable, al que cualquier cuenta aprobada puede unirse
  voluntariamente — no aparece por defecto en la lista de chats de
  nadie.
- RF-7: EL SISTEMA permitirá únicamente a cuentas de rango funcionario
  crear chats personalizados, hasta un máximo de 5 **activos** a la vez
  por funcionario.
- RF-8: EL SISTEMA permitirá al funcionario que creó un chat
  personalizado eliminarlo (liberando el cupo de RF-7) y agregar
  miembros libremente.
- RF-9: SI alguien distinto del funcionario creador intenta eliminar o
  agregar miembros a un chat personalizado, ENTONCES EL SISTEMA
  rechazará la acción.
- RF-10: EL SISTEMA mostrará a cada cuenta aprobada la lista de chats de
  los que es miembro (comité, departamento si se unió, personalizados si
  fue agregada).
- RF-11: EL SISTEMA permitirá enviar y recibir mensajes de texto en
  tiempo real dentro de cualquier chat del que la cuenta sea miembro.
- RF-12: SI una cuenta que no es miembro de un chat intenta enviarle un
  mensaje, ENTONCES EL SISTEMA rechazará el envío.

## Requisitos no funcionales
- Plataformas: Android (prioridad) e iOS.
- Idioma de interfaz: español.
- Solo cuentas aprobadas acceden a chats (constitución, principio 7 y
  spec 001 RF-4): una cuenta pendiente/rechazada no ve nada de esto.

## Casos límite
- Un funcionario con 5 chats personalizados activos intenta crear un
  sexto → bloqueado (RF-7).
- Un funcionario elimina uno de sus 5 chats y crea otro → permitido
  (RF-7 cuenta solo los activos).
- Un voluntario se registra sin comité asignado (ninguno existe todavía)
  → no tiene chat de comité hasta que se le asigne uno (el flujo para
  asignarlo después de aprobado queda fuera de alcance, ver abajo).
- Dos funcionarios registran comités con el mismo nombre → se permite,
  no hay unicidad de nombre exigida.
- Alguien que no es miembro de un chat intenta leer sus mensajes →
  rechazado, mismo criterio que RF-12 para enviar.

## Fuera de alcance
- Notificaciones push de mensajes nuevos — spec futura.
- Editar o eliminar mensajes individuales una vez enviados.
- Chat 1 a 1 entre dos cuentas — el brief solo pide chats de grupo.
- Pantalla para que una cuenta ya aprobada, registrada sin comité,
  se una a uno después — mejora futura si se pide explícitamente.
- Más de un chat de departamento (solo "DCC Bogotá" por ahora, RF-6) —
  el modelo queda listo para agregar más cuando la app cubra otras
  ciudades.
- Editar nombre/dirección de un comité después de creado.

## Criterios de finalización
- Todos los RF-1 a RF-12 con test en verde (unitarios en domain/data;
  widget tests en registro con comité, delegado, chats y mensajería).
- Demo manual: un funcionario se registra (funda comité) → un voluntario
  se registra eligiendo ese comité → Admin aprueba a ambos → ambos ven el
  chat del comité y pueden mandarse mensajes → el funcionario crea un
  chat personalizado y agrega al voluntario → ambos chatean ahí también
  → el funcionario asigna al voluntario como delegado del comité.

## Dudas abiertas
- [NECESITA ACLARACIÓN] Qué pasa con una cuenta aprobada que se registró
  sin comité (porque no existía ninguno) cuando después sí aparece uno —
  por ahora queda sin chat de comité hasta que se construya un flujo de
  "unirme después" (ver Fuera de alcance).
