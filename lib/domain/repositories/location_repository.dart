/// RF-13/RF-14 (spec 002, Enmienda 1): intenta obtener la ubicación
/// actual del dispositivo. Devuelve `null` si no hay permiso, el GPS
/// está apagado, o cualquier otro error — nunca lanza, para no bloquear
/// el envío de un reporte por falta de ubicación.
abstract class LocationRepository {
  Future<({double latitude, double longitude})?> getCurrentLocation();
}
