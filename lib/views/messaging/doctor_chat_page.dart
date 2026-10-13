import 'dart:async';
import 'dart:math' as math;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../services/chat_media_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/doctor_catalog.dart';
import '../../models/care_data.dart';
import '../../models/doctor_message.dart';
import '../../utils/app_colors.dart';
import '../../widgets/page_header.dart';
import '../../widgets/recording_waveform.dart';
import 'doctor_call_page.dart';
import 'doctor_contact_page.dart';

class DoctorChatPage extends StatefulWidget {
  final CareDoctor doctor;
  final ChatMediaService? mediaService;
  const DoctorChatPage({super.key, required this.doctor, this.mediaService});

  @override
  State<DoctorChatPage> createState() => _DoctorChatPageState();
}

class _DoctorChatPageState extends State<DoctorChatPage>
    with WidgetsBindingObserver {
  final _text = TextEditingController();
  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _recordTimer;
  int _seconds = 0;
  bool _recording = false;
  bool _searching = false;
  late final ChatMediaService _media =
      widget.mediaService ?? ChatMediaService(doctorName: widget.doctor.name);
  final _inputFocus = FocusNode();
  bool _showEmojis = false;
  String _emojiCategory = 'Émojis et personnes';
  bool _busy = false;
  int _recordAttempt = 0;
  final _examples = [
    DoctorMessage(
      text: 'Bonjour docteur, j’aimerais faire le point sur mon suivi.',
      isExample: true,
    ),
    DoctorMessage(
      text:
          'Bonjour, vous pouvez joindre un document ou un message vocal pour préparer notre échange.',
      fromPatient: false,
      isExample: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _recordAttempt++;
      if (_recording && !_busy) _cancelRecording();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordTimer?.cancel();
    _inputFocus.dispose();
    unawaited(_media.dispose());
    _text.dispose();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _contact() {
    _recordAttempt++;
    if (_recording) _cancelRecording();
    unawaited(_media.pausePlayback());
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DoctorContactPage(doctor: widget.doctor),
      ),
    );
  }

  void _call(bool video) {
    _recordAttempt++;
    if (_recording) _cancelRecording();
    unawaited(_media.pausePlayback());
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DoctorCallPage(doctor: widget.doctor, video: video),
      ),
    );
  }

  void _send(DoctorMessage message) {
    context.read<CareData>().addDoctorMessage(widget.doctor.name, message);
    if (message.kind == DoctorMessageKind.text) _text.clear();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _error(Object error, String fallback) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error is ChatMediaException ? error.message : fallback),
      ),
    );
  }

  Future<void> _startRecording() async {
    if (_busy || _recording) return;
    final attempt = ++_recordAttempt;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _showEmojis = false;
    });
    try {
      final allowed = await _media.startRecording();
      final lifecycle = WidgetsBinding.instance.lifecycleState;
      if (!mounted ||
          attempt != _recordAttempt ||
          ModalRoute.of(context)?.isCurrent != true ||
          (lifecycle != null && lifecycle != AppLifecycleState.resumed)) {
        await _media.cancelRecording();
        return;
      }
      if (!allowed) {
        _error(
          const ChatMediaException(
            'Autorisez le microphone dans les paramètres du téléphone.',
          ),
          'Microphone indisponible.',
        );
        return;
      }
      if (context.read<CareData>().isDoctorBlocked(widget.doctor.name)) {
        await _media.cancelRecording();
        return;
      }
      setState(() {
        _recording = true;
        _seconds = 0;
      });
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _seconds++);
        if (_seconds >= 120) _finishRecording();
      });
    } catch (error) {
      _error(error, 'Impossible de démarrer le microphone.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancelRecording() async {
    if (_busy) return;
    _recordTimer?.cancel();
    setState(() {
      _recording = false;
      _busy = true;
    });
    try {
      await _media.cancelRecording();
    } catch (error) {
      _error(error, 'Impossible d’annuler le vocal.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _finishRecording() async {
    if (_busy || !_recording) return;
    _recordTimer?.cancel();
    setState(() => _busy = true);
    try {
      final message = await _media.stopRecording();
      if (mounted && message != null) _send(message);
    } catch (error) {
      _error(error, 'Impossible d’enregistrer ce vocal.');
    } finally {
      if (mounted) {
        setState(() {
          _recording = false;
          _busy = false;
        });
      }
    }
  }

  Future<void> _pickMedia({bool camera = false, bool document = false}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final message = document
          ? await _media.pickDocument()
          : await _media.pickPhoto(camera: camera);
      if (mounted && message != null) _send(message);
    } catch (error) {
      _error(
        error,
        'Impossible d’ouvrir ce média. Vérifiez les autorisations dans les paramètres du téléphone.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _attachments() async {
    final kind = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Joindre un fichier'),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Photo'),
              onTap: () => Navigator.pop(context, 'photo'),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Document'),
              onTap: () => Navigator.pop(context, 'document'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || kind == null) return;
    await _pickMedia(document: kind == 'document');
  }

  void _emojis() {
    if (_showEmojis) {
      setState(() => _showEmojis = false);
      _inputFocus.requestFocus();
    } else {
      FocusScope.of(context).unfocus();
      setState(() => _showEmojis = true);
    }
  }

  Widget _emojiPanel(double maxHeight) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: double.infinity,
        color: const Color(0xFFF3F7FB),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        child: Text(
          _emojiCategory,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      EmojiPicker(
        textEditingController: _text,
        onCategoryChanged: (category) => setState(() {
          _emojiCategory = switch (category) {
            Category.RECENT => 'Récemment utilisés',
            Category.SMILEYS => 'Émojis et personnes',
            Category.ANIMALS => 'Animaux et nature',
            Category.FOODS => 'Alimentation et boissons',
            Category.ACTIVITIES => 'Activités',
            Category.TRAVEL => 'Voyages et lieux',
            Category.OBJECTS => 'Objets',
            Category.SYMBOLS => 'Symboles',
            Category.FLAGS => 'Drapeaux',
          };
        }),
        onEmojiSelected: (_, _) => setState(() {}),
        onBackspacePressed: () => setState(() {}),
        config: Config(
          height: math.min(300, maxHeight * .48),
          locale: const Locale('fr'),
          checkPlatformCompatibility: false,
          viewOrderConfig: const ViewOrderConfig(
            top: EmojiPickerItem.searchBar,
            middle: EmojiPickerItem.emojiView,
            bottom: EmojiPickerItem.categoryBar,
          ),
          emojiViewConfig: const EmojiViewConfig(
            columns: 8,
            emojiSizeMax: 28,
            recentsLimit: 32,
            backgroundColor: Color(0xFFF3F7FB),
            noRecents: Text(
              'Vos émojis récents apparaîtront ici',
              textAlign: TextAlign.center,
            ),
          ),
          categoryViewConfig: const CategoryViewConfig(
            initCategory: Category.SMILEYS,
            backgroundColor: Color(0xFFE8F0F8),
            indicatorColor: AppColors.navigationBlue,
            iconColorSelected: AppColors.navigationBlue,
          ),
          bottomActionBarConfig: const BottomActionBarConfig(
            backgroundColor: Color(0xFFF3F7FB),
            buttonColor: Color(0xFFF3F7FB),
            buttonIconColor: AppColors.navigationBlue,
          ),
          searchViewConfig: const SearchViewConfig(
            hintText: 'Rechercher un émoji',
            backgroundColor: Color(0xFFF3F7FB),
            buttonIconColor: AppColors.navigationBlue,
          ),
        ),
      ),
    ],
  );

  Widget _composerIcon(String tooltip, IconData icon, VoidCallback onPressed) =>
      IconButton(
        tooltip: tooltip,
        onPressed: _busy ? null : onPressed,
        constraints: const BoxConstraints.tightFor(width: 44, height: 48),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        icon: Icon(icon, size: 24, color: AppColors.textMuted),
      );

  Future<void> _menu(String action) async {
    final data = context.read<CareData>();
    switch (action) {
      case 'contact':
        _contact();
      case 'search':
        setState(() => _searching = true);
      case 'block':
        final blocked = data.isDoctorBlocked(widget.doctor.name);
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              blocked ? 'Débloquer ce contact ?' : 'Bloquer ce contact ?',
            ),
            content: const Text(
              'Ce contact ne pourra plus recevoir de nouveaux messages sur cet appareil.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmer'),
              ),
            ],
          ),
        );
        if (!mounted || confirmed != true) return;
        data.toggleDoctorBlocked(widget.doctor.name);
        _cancelRecording();
      case 'report':
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Signaler le contact'),
            content: const Text(
              'Le service de signalement n’est pas encore connecté. Aucun signalement ne sera transmis.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      case 'clear':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Effacer mes messages ?'),
            content: const Text(
              'Les messages seront retirés de cette conversation.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Effacer'),
              ),
            ],
          ),
        );
        if (!mounted || confirmed != true) return;
        data.clearConversation(widget.doctor.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<CareData>();
    final blocked = data.isDoctorBlocked(widget.doctor.name);
    final storedMessages = data.messagesFor(widget.doctor.name);
    final messages =
        [
              if (storedMessages.isEmpty && !_searching) ..._examples,
              ...storedMessages,
            ]
            .where(
              (m) => m.text.toLowerCase().contains(_search.text.toLowerCase()),
            )
            .toList();
    return PopScope(
      canPop: !_showEmojis,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showEmojis) setState(() => _showEmojis = false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          leadingWidth: 64,
          leading: PageBackButton(
            color: Colors.white,
            backgroundColor: Colors.white.withAlpha(45),
          ),
          titleSpacing: 0,
          title: InkWell(
            onTap: _contact,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(widget.doctor.imageAsset),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.doctor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            PopupMenuButton<bool>(
              tooltip: 'Appeler',
              enabled: !blocked,
              icon: const Icon(Icons.call_outlined),
              onSelected: _call,
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: false,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.call_outlined),
                    title: Text('Appel audio'),
                  ),
                ),
                PopupMenuItem(
                  value: true,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.videocam_outlined),
                    title: Text('Appel vidéo'),
                  ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              tooltip: 'Options de la conversation',
              onSelected: _menu,
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'contact',
                  child: Text('Afficher le contact'),
                ),
                const PopupMenuItem(value: 'search', child: Text('Rechercher')),
                const PopupMenuItem(value: 'report', child: Text('Signaler')),
                PopupMenuItem(
                  value: 'block',
                  child: Text(blocked ? 'Débloquer' : 'Bloquer'),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Text('Effacer mes messages'),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              if (_searching)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _search,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Rechercher dans la conversation',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        tooltip: 'Fermer la recherche',
                        onPressed: () => setState(() {
                          _searching = false;
                          _search.clear();
                        }),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _searching
                                ? 'Aucun message trouvé'
                                : 'Commencez votre conversation',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(18),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: messages.length,
                        itemBuilder: (_, i) => _MessageBubble(
                          key: ObjectKey(messages[i]),
                          message: messages[i],
                          media: _media,
                        ),
                      ),
              ),
              if (blocked)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Contact bloqué'),
                      TextButton(
                        onPressed: () =>
                            data.toggleDoctorBlocked(widget.doctor.name),
                        child: const Text('Débloquer'),
                      ),
                    ],
                  ),
                )
              else if (_recording)
                Container(
                  margin: const EdgeInsets.fromLTRB(8, 6, 8, 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FC),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFCFE2F5)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Text(
                        'Enregistrement vocal · 2 minutes maximum',
                        style: TextStyle(fontSize: 11),
                      ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Annuler le vocal',
                            onPressed: _cancelRecording,
                            icon: const Icon(Icons.delete_outline),
                          ),
                          Text(
                            _duration(Duration(seconds: _seconds)),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navigationBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RecordingWaveform(
                              levels: _media.recordingLevels,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            tooltip: 'Envoyer le vocal',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.navigationBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(48, 48),
                              shape: const CircleBorder(),
                            ),
                            onPressed: _busy ? null : _finishRecording,
                            icon: const Icon(Icons.send_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_seconds / 120).clamp(0.0, 1.0),
                          minHeight: 3,
                          color: AppColors.navigationBlue,
                          backgroundColor: AppColors.navigationBlue.withValues(
                            alpha: .1,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4F8),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _composerIcon(
                                _showEmojis
                                    ? 'Afficher le clavier'
                                    : 'Choisir un emoji',
                                _showEmojis
                                    ? Icons.keyboard_outlined
                                    : Icons.emoji_emotions_outlined,
                                _emojis,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _text,
                                  focusNode: _inputFocus,
                                  onTap: () {
                                    if (_showEmojis) {
                                      setState(() => _showEmojis = false);
                                    }
                                  },
                                  minLines: 1,
                                  maxLines: 4,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  decoration: const InputDecoration(
                                    hintText: 'Message',
                                    hintMaxLines: 1,
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 2,
                                      vertical: 12,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ),
                              ),
                              _composerIcon(
                                'Joindre un fichier',
                                Icons.attach_file_rounded,
                                _attachments,
                              ),
                              _composerIcon(
                                'Prendre une photo',
                                Icons.camera_alt_outlined,
                                () => _pickMedia(camera: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          minimumSize: const Size(52, 52),
                          shape: const CircleBorder(),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        tooltip: _text.text.trim().isEmpty
                            ? 'Message vocal'
                            : 'Envoyer le message',
                        onPressed: _busy
                            ? null
                            : _text.text.trim().isEmpty
                            ? _startRecording
                            : () =>
                                  _send(DoctorMessage(text: _text.text.trim())),
                        icon: Icon(
                          _text.text.trim().isEmpty
                              ? Icons.mic_rounded
                              : Icons.send_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_showEmojis && !blocked && !_recording)
                LayoutBuilder(
                  builder: (context, constraints) => _emojiPanel(
                    MediaQuery.sizeOf(context).height -
                        MediaQuery.viewInsetsOf(context).bottom -
                        110,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _duration(Duration duration) =>
    '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

class _MessageBubble extends StatelessWidget {
  final DoctorMessage message;
  final ChatMediaService media;
  const _MessageBubble({super.key, required this.message, required this.media});

  @override
  Widget build(BuildContext context) {
    final mine = message.fromPatient;
    final color = mine ? Colors.white : AppColors.textDark;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .78,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: mine ? AppColors.primary : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(mine ? 16 : 4),
              bottomRight: Radius.circular(mine ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (message.kind == DoctorMessageKind.voice)
                _VoicePlayer(message: message, color: color, media: media)
              else if (message.kind == DoctorMessageKind.attachment)
                if (message.isImage && message.bytes != null)
                  InkWell(
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (context) => Dialog(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                tooltip: 'Fermer la photo',
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),
                            ),
                            Flexible(
                              child: InteractiveViewer(
                                child: Image.memory(message.bytes!),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        message.bytes!,
                        height: 170,
                        width: 220,
                        fit: BoxFit.cover,
                        semanticLabel: 'Photo jointe',
                        errorBuilder: (_, _, _) => Text(
                          'Photo indisponible',
                          style: TextStyle(color: color),
                        ),
                      ),
                    ),
                  )
                else
                  InkWell(
                    onTap: () async {
                      try {
                        await media.openDocument(message);
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                error is ChatMediaException
                                    ? error.message
                                    : 'Impossible d’ouvrir ce fichier.',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.insert_drive_file_outlined, color: color),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            message.text,
                            style: TextStyle(color: color, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.open_in_new, color: color, size: 16),
                      ],
                    ),
                  )
              else
                Text(
                  message.text,
                  style: TextStyle(color: color, fontSize: 13, height: 1.5),
                ),
              if (message.isExample) ...[
                const SizedBox(height: 8),
                Text(
                  'Exemple de message',
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withValues(alpha: .85),
                  ),
                ),
              ] else if (mine) ...[
                const SizedBox(height: 8),
                Text(
                  'Non envoyé · sur cet appareil',
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withValues(alpha: .85),
                  ),
                ),
              ],
              const SizedBox(height: 7),
              Text(
                '${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: .7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoicePlayer extends StatefulWidget {
  final DoctorMessage message;
  final Color color;
  final ChatMediaService media;
  const _VoicePlayer({
    required this.message,
    required this.color,
    required this.media,
  });
  @override
  State<_VoicePlayer> createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<_VoicePlayer>
    with WidgetsBindingObserver {
  late final VoicePlayback _player = widget.media.createPlayback();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Duration _position = Duration.zero;
  bool _playing = false;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscriptions.add(
      _player.positions.listen((position) {
        if (mounted) setState(() => _position = position);
      }),
    );
    _subscriptions.add(
      _player.states.listen((playing) {
        if (mounted) setState(() => _playing = playing);
      }),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _playing) {
      unawaited(_player.pause());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      if (_playing) {
        await _player.pause();
      } else {
        await widget.media.pausePlayback();
        await _player.play(widget.message);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de lire ce message vocal.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          IconButton(
            tooltip: _playing ? 'Pause du vocal' : 'Lire le vocal',
            onPressed: _loading ? null : _toggle,
            icon: Icon(
              _playing ? Icons.pause : Icons.play_arrow,
              color: widget.color,
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: widget.message.duration.inMilliseconds > 0
                  ? (_position.inMilliseconds /
                            widget.message.duration.inMilliseconds)
                        .clamp(0.0, 1.0)
                  : 0,
              color: widget.color,
              backgroundColor: widget.color.withValues(alpha: .25),
            ),
          ),
        ],
      ),
      Text(
        '${_duration(_position)} / ${_duration(widget.message.duration)}',
        style: TextStyle(color: widget.color, fontSize: 10),
      ),
    ],
  );
}
