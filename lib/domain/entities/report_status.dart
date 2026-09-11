/// RF-6/RF-9: pending es el estado inicial; el resto son las categorías
/// que un Revisor asigna desde el panel.
enum ReportStatus { pending, activa, verdadera, falsaControlada, enDesarrollo }

extension ReportStatusX on ReportStatus {
  /// RF-10: único estado visible en el mapa general (spec futura).
  bool get isVisibleOnMap => this == ReportStatus.activa;
}
