import 'package:flutter/foundation.dart';

enum NotificationCategory { medication, appointment, measurement, alert }

class CareNotification {
  final String title;
  final String message;
  final DateTime date;
  final NotificationCategory category;
  const CareNotification({
    required this.title,
    required this.message,
    required this.date,
    required this.category,
  });
}

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

class BloodPressureReading {
  final double systolic;
  final double diastolic;
  final DateTime date;
  const BloodPressureReading({
    required this.systolic,
    required this.diastolic,
    required this.date,
  });
}

/// Local session data until the patient services are connected.
class CareData extends ChangeNotifier {
  final List<CareAppointment> _appointments = [];
  final List<CareNotification> _notifications = [];
  final List<GlucoseReading> _readings = [];
  final List<BloodPressureReading> _bloodPressureReadings = [];
  bool remindersEnabled = true;
  Uint8List? _profilePhoto;
  Uint8List? get profilePhoto => _profilePhoto;

  void setProfilePhoto(Uint8List bytes) {
    _profilePhoto = Uint8List.fromList(bytes).asUnmodifiableView();
    notifyListeners();
  }

  List<CareNotification> get notifications {
    final items = [
      ..._notifications.where(
        (item) =>
            remindersEnabled ||
            item.category != NotificationCategory.appointment,
      ),
      for (final appointment
          in remindersEnabled ? _appointments : <CareAppointment>[])
        CareNotification(
          title: appointment.doctor,
          message: 'Rendez-vous dans votre agenda personnel',
          date: appointment.date,
          category: NotificationCategory.appointment,
        ),
    ]..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(items);
  }

  void addNotification(CareNotification notification) {
    _notifications.add(notification);
    notifyListeners();
  }

  List<CareAppointment> get appointments => List.unmodifiable(_appointments);
  List<GlucoseReading> get readings => List.unmodifiable(_readings);
  List<BloodPressureReading> get bloodPressureReadings =>
      List.unmodifiable(_bloodPressureReadings);

  void addAppointment(CareAppointment appointment) {
    _appointments.add(appointment);
    _appointments.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  void removeAppointment(CareAppointment appointment) {
    _appointments.remove(appointment);
    notifyListeners();
  }

  void addReading(double value, {DateTime? date}) {
    _readings.add(GlucoseReading(value: value, date: date ?? DateTime.now()));
    _readings.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void addBloodPressure(double systolic, double diastolic, {DateTime? date}) {
    _bloodPressureReadings.add(
      BloodPressureReading(
        systolic: systolic,
        diastolic: diastolic,
        date: date ?? DateTime.now(),
      ),
    );
    _bloodPressureReadings.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void setReminders(bool value) {
    remindersEnabled = value;
    notifyListeners();
  }

  void clear() {
    _profilePhoto = null;
    _appointments.clear();
    _notifications.clear();
    _readings.clear();
    _bloodPressureReadings.clear();
    remindersEnabled = true;
    notifyListeners();
  }
}
