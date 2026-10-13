import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> deleteTemporaryRecording(String path) async {
  final file = File(path);
  final directory = await getTemporaryDirectory();
  final name = file.uri.pathSegments.last;
  if (file.parent.absolute.path == Directory(directory.path).absolute.path &&
      name.startsWith('ecare-vocal-') &&
      name.endsWith('.m4a') &&
      await file.exists()) {
    await file.delete();
  }
}
