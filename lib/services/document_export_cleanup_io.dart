import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> deleteIosExportStaging(String name, {Directory? directory}) async {
  if (!RegExp(r'^ecare-export-\d+-[a-zA-Z0-9_.-]+$').hasMatch(name)) {
    throw const FormatException('Invalid export staging name');
  }
  final root = directory ?? await getApplicationDocumentsDirectory();
  final file = File('${root.path}/$name');
  if (await file.exists()) await file.delete();
}
