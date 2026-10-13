import 'dart:typed_data';

enum DoctorMessageKind { text, voice, attachment }

class DoctorMessage {
  final String text;
  final bool fromPatient;
  final DoctorMessageKind kind;
  final Duration duration;
  final DateTime time;
  final Uint8List? bytes;
  final String? filePath;
  final bool isImage;
  final bool isExample;
  final String? mimeType;

  DoctorMessage({
    required this.text,
    this.fromPatient = true,
    this.kind = DoctorMessageKind.text,
    this.duration = Duration.zero,
    this.bytes,
    this.filePath,
    this.isImage = false,
    this.isExample = false,
    this.mimeType,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}
