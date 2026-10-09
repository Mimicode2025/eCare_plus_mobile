import 'package:url_launcher/url_launcher.dart';

typedef ContactLauncher = Future<bool> Function(Uri uri);

class DoctorContactService {
  final ContactLauncher _launcher;
  DoctorContactService({ContactLauncher? launcher})
    : _launcher = launcher ?? _launch;

  static Future<bool> _launch(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  static Uri? contactUri(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
    return uri;
  }

  Future<bool> open(String? value) async {
    final uri = contactUri(value);
    if (uri == null) return false;
    try {
      return await _launcher(uri);
    } catch (_) {
      return false;
    }
  }
}
