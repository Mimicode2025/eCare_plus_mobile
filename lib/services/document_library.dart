import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import '../models/medical_document.dart';
import 'document_storage.dart';
import 'document_export_cleanup.dart';

class DocumentLibrary extends ChangeNotifier {
  static final instance = DocumentLibrary();
  static const extensions = ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'];
  static const maxBytes = 20 * 1024 * 1024;
  final DocumentStorage storage;
  DocumentLibrary({DocumentStorage? storage})
    : storage = storage ?? createDocumentStorage();
  List<MedicalDocument> _documents = [];
  Set<MedicalCondition> _conditions = {};
  Future<void>? _loading;
  bool loaded = false;
  bool _busy = false;
  List<MedicalDocument> get documents => List.unmodifiable(_documents);
  Set<MedicalCondition> get conditions => Set.unmodifiable(_conditions);
  Future<void> load() => _loading ??= _load();
  Future<void> _load() async {
    try {
      final index = await storage.loadIndex();
      _documents = ((index['documents'] ?? []) as List)
          .map(
            (j) =>
                MedicalDocument.fromJson(Map<String, dynamic>.from(j as Map)),
          )
          .toList();
      _conditions = ((index['conditions'] ?? []) as List)
          .map((c) => MedicalCondition.values.byName(c as String))
          .toSet();
      loaded = true;
      notifyListeners();
    } catch (_) {
      _loading = null;
      rethrow;
    }
  }

  Future<void> _persist(
    List<MedicalDocument> docs,
    Set<MedicalCondition> conditions,
  ) => storage.saveIndex({
    'version': 1,
    'conditions': conditions.map((c) => c.name).toList(),
    'documents': docs.map((d) => d.toJson()).toList(),
  });
  Future<T> _change<T>(Future<T> Function() action) async {
    if (_busy) {
      throw const DocumentException(
        'Une opération est déjà en cours. Réessayez dans un instant.',
      );
    }
    _busy = true;
    try {
      await load();
      return await action();
    } finally {
      _busy = false;
    }
  }

  Future<void> setConditions(Set<MedicalCondition> conditions) =>
      _change(() async {
        await _persist(_documents, conditions);
        _conditions = Set.of(conditions);
        notifyListeners();
      });
  Future<XFile?> pickFile() => openFile(
    acceptedTypeGroups: [
      const XTypeGroup(
        label: 'Documents médicaux',
        extensions: extensions,
        mimeTypes: [
          'application/pdf',
          'image/jpeg',
          'image/png',
          'application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        ],
        uniformTypeIdentifiers: [
          'com.adobe.pdf',
          'public.jpeg',
          'public.png',
          'com.microsoft.word.doc',
          'org.openxmlformats.wordprocessingml.document',
        ],
      ),
    ],
  );
  Future<MedicalDocument> importFile(
    XFile file, {
    required String title,
    required DocumentCategory category,
    required Set<MedicalCondition> conditions,
    required DateTime date,
  }) => _change(() async {
    final fileName = file.name.split(RegExp(r'[/\\]')).last;
    final ext = fileName.split('.').last.toLowerCase();
    if (!extensions.contains(ext)) {
      throw const DocumentException(
        'Choisissez un PDF, une image JPG/PNG ou un document Word.',
      );
    }
    if (title.trim().isEmpty) {
      throw const DocumentException('Donnez un nom au document.');
    }
    if (await file.length() > maxBytes) {
      throw const DocumentException('Le fichier doit faire moins de 20 Mo.');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) throw const DocumentException('Ce fichier est vide.');
    if (bytes.length > maxBytes) {
      throw const DocumentException('Le fichier doit faire moins de 20 Mo.');
    }
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final item = MedicalDocument(
      id: id,
      title: title.trim(),
      fileName: fileName,
      storageName: '$id.$ext',
      size: bytes.length,
      date: date,
      category: category,
      conditions: conditions,
    );
    await storage.write(item.storageName, bytes);
    final next = [..._documents, item];
    try {
      await _persist(next, _conditions);
    } catch (_) {
      await storage.delete(item.storageName);
      rethrow;
    }
    _documents = next;
    notifyListeners();
    return item;
  });
  List<MedicalDocument> filtered({
    DocumentCategory? category,
    MedicalCondition? condition,
    bool general = false,
    String query = '',
    bool oldestFirst = false,
  }) {
    final search = query.trim().toLowerCase();
    final result = _documents
        .where(
          (d) =>
              (category == null || d.category == category) &&
              (condition == null || d.conditions.contains(condition)) &&
              (!general || d.conditions.isEmpty) &&
              (search.isEmpty ||
                  '${d.title} ${d.fileName} ${d.category.label} ${d.followUp}'
                      .toLowerCase()
                      .contains(search)),
        )
        .toList();
    result.sort((a, b) {
      final order = a.date.compareTo(b.date);
      return oldestFirst ? order : -order;
    });
    return result;
  }

  Future<Uint8List> read(MedicalDocument item) =>
      storage.read(item.storageName);
  Future<void> open(MedicalDocument item) async {
    final result = await OpenFilex.open(await storage.path(item.storageName));
    if (result.type != ResultType.done) {
      throw const DocumentException(
        'Aucune application ne peut ouvrir ce document. Vous pouvez le télécharger.',
      );
    }
  }

  Future<bool> export(MedicalDocument item) async {
    final bytes = await read(item);
    final ios = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final exportName = ios
        ? 'ecare-export-${DateTime.now().microsecondsSinceEpoch}-${item.fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '_')}'
        : item.fileName;
    try {
      final saved = await FilePicker.platform.saveFile(
        dialogTitle: 'Télécharger le document',
        fileName: exportName,
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: [item.extension],
      );
      if (saved == null) return false;
      // Mobile implementations write bytes themselves; desktop returns a destination.
      if (!kIsWeb &&
          defaultTargetPlatform != TargetPlatform.android &&
          defaultTargetPlatform != TargetPlatform.iOS) {
        await XFile.fromData(bytes).saveTo(saved);
      }
      return true;
    } finally {
      if (ios) await deleteIosExportStaging(exportName);
    }
  }

  Future<void> remove(MedicalDocument item) => _change(() async {
    final next = _documents.where((d) => d.id != item.id).toList();
    await _persist(next, _conditions);
    _documents = next;
    notifyListeners();
    await storage.delete(item.storageName);
  });
}
