import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'document_storage.dart';

DocumentStorage createDocumentStorage() => LocalDocumentStorage();

class LocalDocumentStorage implements DocumentStorage {
  Directory? _directory;
  LocalDocumentStorage({Directory? directory}) : _directory = directory;
  Future<Directory> _root() async {
    final root = _directory ??= Directory(
      '${(await getApplicationSupportDirectory()).path}/medical-documents',
    );
    await root.create(recursive: true);
    return root;
  }

  @override
  Future<String> path(String name) async {
    if (!RegExp(r'^[a-zA-Z0-9_-]+\.[a-zA-Z0-9]+$').hasMatch(name)) {
      throw const FormatException('Invalid document file name');
    }
    return '${(await _root()).path}/$name';
  }

  @override
  Future<Map<String, dynamic>> loadIndex() async {
    final file = File('${(await _root()).path}/index.json');
    if (!await file.exists()) return {};
    return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  }

  @override
  Future<void> saveIndex(Map<String, dynamic> index) async {
    final root = await _root();
    final temporary = File('${root.path}/index.pending');
    await temporary.writeAsString(jsonEncode(index), flush: true);
    await temporary.rename('${root.path}/index.json');
  }

  @override
  Future<void> write(String name, Uint8List bytes) async =>
      File(await path(name)).writeAsBytes(bytes, flush: true);
  @override
  Future<Uint8List> read(String name) async =>
      File(await path(name)).readAsBytes();
  @override
  Future<void> delete(String name) async {
    final file = File(await path(name));
    if (await file.exists()) await file.delete();
  }
}
