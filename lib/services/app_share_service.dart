import 'dart:ui';

import 'package:share_plus/share_plus.dart';

class AppShareService {
  static const message =
      'Découvrez eCARE+, une application pour suivre vos constantes vitales, '
      'conserver vos documents médicaux et organiser vos rendez-vous. '
      'La publication sur le Play Store est en préparation.';

  static Future<void> share({required Rect origin}) async {
    await SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: 'Découvrez eCARE+',
        title: 'Partager eCARE+',
        sharePositionOrigin: origin,
      ),
    );
  }
}
