import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotoTooLargeException implements Exception {
  const ProfilePhotoTooLargeException();
}

class ProfilePhotoService {
  static Future<Uint8List> readPhoto(XFile image) async {
    if (await image.length() > 10 * 1024 * 1024) {
      throw const ProfilePhotoTooLargeException();
    }
    final bytes = await image.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 512);
    try {
      final frame = await codec.getNextFrame();
      frame.image.dispose();
    } finally {
      codec.dispose();
    }
    return bytes;
  }

  /// Android can restart the activity while its gallery picker is open.
  static Future<Uint8List?> recoverPhoto() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      final response = await ImagePicker().retrieveLostData();
      final files = response.files;
      if (files == null || files.isEmpty) return null;
      return await readPhoto(files.first);
    } catch (_) {
      // A failed recovery must not prevent the application from starting.
      return null;
    }
  }
}
