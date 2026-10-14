import 'dart:typed_data';
export 'document_storage_stub.dart'
    if (dart.library.io) 'document_storage_io.dart'
    show createDocumentStorage;

abstract class DocumentStorage {
  Future<Map<String, dynamic>> loadIndex();
  Future<void> saveIndex(Map<String, dynamic> index);
  Future<void> write(String name, Uint8List bytes);
  Future<Uint8List> read(String name);
  Future<String> path(String name);
  Future<void> delete(String name);
}
