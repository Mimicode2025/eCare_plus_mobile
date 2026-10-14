import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medical_document.dart';
import '../../services/document_library.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../../widgets/care_page.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/document_import_sheet.dart';

class DocumentsPage extends StatefulWidget {
  final DocumentLibrary? library;
  const DocumentsPage({super.key, this.library});
  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  late final DocumentLibrary _library =
      widget.library ??
      context.read<DocumentLibrary?>() ??
      DocumentLibrary.instance;
  final _search = TextEditingController();
  DocumentCategory? _category;
  MedicalCondition? _condition;
  bool _general = false, _oldest = false, _working = false;
  String? _error;
  bool _importSheetOpen = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      await _library.load();
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is DocumentException
              ? e.message
              : 'Impossible de charger votre carnet. Réessayez.',
        );
      }
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _notice(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _action(Future<void> Function() action) async {
    if (_working) return;
    setState(() => _working = true);
    try {
      await action();
    } catch (e) {
      _notice(
        e is DocumentException
            ? e.message
            : 'Impossible de terminer cette opération. Réessayez.',
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _add() => _action(() async {
    final file = await _library.pickFile();
    if (file == null || !mounted) return;
    if (await file.length() > DocumentLibrary.maxBytes) {
      throw const DocumentException('Le fichier doit faire moins de 20 Mo.');
    }
    if (!mounted) return;
    setState(() => _importSheetOpen = true);
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.scaffoldBackground,
      builder: (_) => DocumentImportSheet(library: _library, file: file),
    );
    if (mounted) setState(() => _importSheetOpen = false);
    if (added == true) _notice('Document ajouté à votre carnet.');
  });
  Future<void> _configure() async {
    final chosen = Set<MedicalCondition>.of(_library.conditions);
    final result = await showDialog<Set<MedicalCondition>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Mes suivis médicaux'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choisissez les pathologies suivies pour personnaliser votre carnet.',
              ),
              for (final condition in MedicalCondition.values)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(condition.label),
                  value: chosen.contains(condition),
                  onChanged: (value) => update(() {
                    if (value == true) {
                      chosen.add(condition);
                    } else {
                      chosen.remove(condition);
                    }
                  }),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, chosen),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    if (result == null || !mounted) return;
    await _action(() async {
      await _library.setConditions(result);
      if (mounted) {
        setState(() {
          _condition = null;
          _general = false;
        });
      }
    });
  }

  Future<void> _menu(MedicalDocument item, String action) => _action(() async {
    if (action == 'open') await _library.open(item);
    if (action == 'download') {
      if (await _library.export(item)) {
        _notice('Document enregistré à l’emplacement choisi.');
      }
    }
    if (action == 'delete') {
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Retirer ce document ?'),
          content: Text(
            '« ${item.title} » sera supprimé de ce carnet. Le fichier d’origine restera intact.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Retirer'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await _library.remove(item);
        _notice('Document retiré du carnet.');
      }
    }
  });
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _library,
    builder: (context, _) {
      final docs = _library.filtered(
        category: _category,
        condition: _library.conditions.contains(_condition) ? _condition : null,
        general: _general,
        query: _search.text,
        oldestFirst: _oldest,
      );
      return CarePage(
        title: 'Mes documents',
        subtitle: 'Votre carnet de santé, à portée de main.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _NotebookCover(),
            const SizedBox(height: 16),
            if (_error != null)
              CareEmpty(
                icon: Icons.folder_off_outlined,
                title: 'Carnet indisponible',
                description: _error!,
                action: TextButton(
                  onPressed: _load,
                  child: const Text('Réessayer'),
                ),
              )
            else if (!_library.loaded)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              GradientButton(
                text: 'Ajouter un document',
                icon: Icons.add_rounded,
                onPressed: _add,
                isLoading: _working && !_importSheetOpen,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Rechercher un document',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Effacer la recherche',
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(_search.clear),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _filters([
                _chip(
                  'Tous',
                  _category == null,
                  () => setState(() => _category = null),
                ),
                for (final category in DocumentCategory.values)
                  _chip(
                    category.label,
                    _category == category,
                    () => setState(() => _category = category),
                  ),
              ]),
              const SizedBox(height: 10),
              _filters([
                _chip(
                  'Tous les suivis',
                  _condition == null && !_general,
                  () => setState(() {
                    _condition = null;
                    _general = false;
                  }),
                ),
                for (final condition in _library.conditions)
                  _chip(
                    condition.label,
                    _condition == condition && !_general,
                    () => setState(() {
                      _condition = condition;
                      _general = false;
                    }),
                  ),
                _chip(
                  'Général',
                  _general,
                  () => setState(() {
                    _condition = null;
                    _general = true;
                  }),
                ),
              ]),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _working ? null : _configure,
                  icon: const Icon(Icons.tune_rounded, size: 17),
                  label: const Text('Personnaliser mes suivis'),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(
                    'Documents récents',
                    style: AppDecor.t(
                      20,
                      w: FontWeight.w700,
                      c: AppColors.primaryDeep,
                    ),
                  ),
                  PopupMenuButton<bool>(
                    tooltip: 'Trier les documents',
                    initialValue: _oldest,
                    onSelected: (value) => setState(() => _oldest = value),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: false,
                        child: Text('Plus récents'),
                      ),
                      const PopupMenuItem(
                        value: true,
                        child: Text('Plus anciens'),
                      ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _oldest ? 'Plus anciens' : 'Plus récents',
                            style: AppDecor.t(12, c: AppColors.textMuted),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (docs.isEmpty)
                CareEmpty(
                  icon: Icons.folder_copy_outlined,
                  title: _library.documents.isEmpty
                      ? 'Votre carnet commence ici'
                      : 'Aucun document trouvé',
                  description: _library.documents.isEmpty
                      ? 'Ajoutez vos ordonnances, résultats et comptes rendus pour les retrouver facilement.'
                      : 'Essayez une autre recherche ou modifiez vos filtres.',
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: .6),
                    ),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < docs.length; i++) ...[
                        if (i > 0)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: Divider(height: 1, color: AppColors.border),
                          ),
                        _DocumentRow(
                          item: docs[i],
                          enabled: !_working,
                          onOpen: () => _menu(docs[i], 'open'),
                          onAction: (action) => _menu(docs[i], action),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.phone_android_rounded,
                    size: 15,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Votre carnet est conservé sur ce téléphone.',
                      style: AppDecor.t(11, c: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    },
  );
  Widget _filters(List<Widget> children) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final child in children)
          Padding(padding: const EdgeInsets.only(right: 8), child: child),
      ],
    ),
  );
  Widget _chip(String label, bool selected, VoidCallback onTap) => ChoiceChip(
    label: Text(label),
    selected: selected,
    showCheckmark: false,
    selectedColor: AppColors.primary,
    backgroundColor: Colors.white,
    labelStyle: AppDecor.t(
      12,
      w: FontWeight.w600,
      c: selected ? Colors.white : AppColors.primaryDeep,
    ),
    side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
    onSelected: (_) => onTap(),
  );
}

class _NotebookCover extends StatelessWidget {
  const _NotebookCover();
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(26),
    child: Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppDecor.buttonGradient),
      child: Stack(
        children: [
          Positioned(right: -42, top: -65, child: _circle(180)),
          Positioned(right: -18, bottom: -105, child: _circle(175)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.folder_shared_outlined,
                  color: Colors.white,
                  size: 38,
                ),
                const SizedBox(height: 14),
                Text(
                  'Mon carnet de santé',
                  style: AppDecor.t(22, w: FontWeight.w700, c: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Vos documents, votre histoire',
                  style: AppDecor.t(14, c: Colors.white.withValues(alpha: .85)),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  Widget _circle(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withValues(alpha: .14)),
    ),
  );
}

class _DocumentRow extends StatelessWidget {
  final MedicalDocument item;
  final bool enabled;
  final VoidCallback onOpen;
  final ValueChanged<String> onAction;
  const _DocumentRow({
    required this.item,
    required this.enabled,
    required this.onOpen,
    required this.onAction,
  });
  @override
  Widget build(BuildContext context) {
    final isPdf = item.extension == 'pdf';
    final color = isPdf ? const Color(0xFFD35A65) : AppColors.primary;
    final date =
        '${item.date.day.toString().padLeft(2, '0')}/${item.date.month.toString().padLeft(2, '0')}/${item.date.year}';
    final size = item.size < 1024 * 1024
        ? '${(item.size / 1024).ceil()} Ko'
        : '${(item.size / (1024 * 1024)).toStringAsFixed(1)} Mo';
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 4, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isPdf
                  ? Icons.picture_as_pdf_outlined
                  : ['jpg', 'jpeg', 'png'].contains(item.extension)
                  ? Icons.image_outlined
                  : Icons.description_outlined,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: enabled ? onOpen : null,
              borderRadius: BorderRadius.circular(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppDecor.t(
                      15,
                      w: FontWeight.w700,
                      c: AppColors.primaryDeep,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$date · ${item.extension.toUpperCase()} · $size',
                    style: AppDecor.t(11, c: AppColors.textMuted),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _tag(item.category.label, AppColors.primary),
                      _tag(
                        item.followUp,
                        item.conditions.contains(MedicalCondition.diabetes)
                            ? const Color(0xFF17766F)
                            : AppColors.primaryDeep,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            enabled: enabled,
            tooltip: 'Actions pour ${item.title}',
            onSelected: onAction,
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'open', child: Text('Ouvrir')),
              const PopupMenuItem(
                value: 'download',
                child: Text('Télécharger'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Retirer du carnet'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(text, style: AppDecor.t(10, c: color)),
  );
}
