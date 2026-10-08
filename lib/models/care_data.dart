import 'package:flutter/foundation.dart';

class CareAppointment {
  final String doctor;
  final DateTime date;
  const CareAppointment({required this.doctor, required this.date});
}

class GlucoseReading {
  final double value;
  final DateTime date;
  const GlucoseReading({required this.value, required this.date});
}

/// Local session data until the patient services are connected.
class CareData extends ChangeNotifier {
  final List<CareAppointment> _appointments = [];
  final List<GlucoseReading> _readings = [];
  bool remindersEnabled = true;

  List<CareAppointment> get appointments => List.unmodifiable(_appointments);
  List<GlucoseReading> get readings => List.unmodifiable(_readings);

  void addAppointment(CareAppointment appointment) {
    _appointments.add(appointment);
    _appointments.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  void removeAppointment(CareAppointment appointment) {
    _appointments.remove(appointment);
    notifyListeners();
  }

  void addReading(double value) {
    _readings.insert(0, GlucoseReading(value: value, date: DateTime.now()));
    notifyListeners();
  }

  void setReminders(bool value) {
    remindersEnabled = value;
    notifyListeners();
  }

  void clear() {
    _appointments.clear();
    _readings.clear();
    remindersEnabled = true;
    notifyListeners();
  }
}
