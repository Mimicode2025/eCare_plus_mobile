enum MedicalCondition {
  diabetes('Diabète'),
  hypertension('Hypertension');

  final String label;
  const MedicalCondition(this.label);
}

enum DocumentCategory {
  prescription('Ordonnances'),
  results('Résultats'),
  report('Comptes rendus'),
  other('Autres');

  final String label;
  const DocumentCategory(this.label);
}

class MedicalDocument {
  final String id, title, fileName, storageName;
  final int size;
  final DateTime date;
  final DocumentCategory category;
  final Set<MedicalCondition> conditions;
  MedicalDocument({
    required this.id,
    required this.title,
    required this.fileName,
    required this.storageName,
    required this.size,
    required this.date,
    required this.category,
    required Set<MedicalCondition> conditions,
  }) : conditions = Set.unmodifiable(conditions);
  String get extension => fileName.split('.').last.toLowerCase();
  String get followUp => conditions.isEmpty
      ? 'Général'
      : conditions.map((c) => c.label).join(' · ');
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'fileName': fileName,
    'storageName': storageName,
    'size': size,
    'date': date.toIso8601String(),
    'category': category.name,
    'conditions': conditions.map((c) => c.name).toList(),
  };
  factory MedicalDocument.fromJson(Map<String, dynamic> json) =>
      MedicalDocument(
        id: json['id'] as String,
        title: json['title'] as String,
        fileName: json['fileName'] as String,
        storageName: json['storageName'] as String,
        size: json['size'] as int,
        date: DateTime.parse(json['date'] as String),
        category: DocumentCategory.values.byName(json['category'] as String),
        conditions: (json['conditions'] as List)
            .map((c) => MedicalCondition.values.byName(c as String))
            .toSet(),
      );
}

class DocumentException implements Exception {
  final String message;
  const DocumentException(this.message);
}
