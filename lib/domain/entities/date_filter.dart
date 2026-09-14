/// RF-1/RF-2: filtro de fecha para el mapa. Ventanas móviles relativas a
/// `now` (no semana/mes calendario) — más simple y suficiente para
/// acotar cuántas emergencias "activa" se muestran.
enum EmergencyDateFilter {
  today,
  thisWeek,
  thisMonth,
  last3Months,
  last6Months,
  lastYear,
}

extension EmergencyDateFilterX on EmergencyDateFilter {
  DateTime cutoff(DateTime now) {
    switch (this) {
      case EmergencyDateFilter.today:
        return now.subtract(const Duration(days: 1));
      case EmergencyDateFilter.thisWeek:
        return now.subtract(const Duration(days: 7));
      case EmergencyDateFilter.thisMonth:
        return now.subtract(const Duration(days: 30));
      case EmergencyDateFilter.last3Months:
        return now.subtract(const Duration(days: 90));
      case EmergencyDateFilter.last6Months:
        return now.subtract(const Duration(days: 180));
      case EmergencyDateFilter.lastYear:
        return now.subtract(const Duration(days: 365));
    }
  }
}
