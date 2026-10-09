enum DoctorMessageKind { text, voice, attachment }

class DoctorMessage {
  final String text;
  final bool fromPatient;
  final DoctorMessageKind kind;
  final Duration duration;
  final DateTime time;

  DoctorMessage({
    required this.text,
    this.fromPatient = true,
    this.kind = DoctorMessageKind.text,
    this.duration = Duration.zero,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}
