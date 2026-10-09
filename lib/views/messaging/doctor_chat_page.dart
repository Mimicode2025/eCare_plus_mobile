import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/doctor_catalog.dart';
import '../../models/care_data.dart';
import '../../models/doctor_message.dart';
import '../../utils/app_colors.dart';
import '../../widgets/page_header.dart';
import 'doctor_call_page.dart';
import 'doctor_contact_page.dart';

class DoctorChatPage extends StatefulWidget {
  final CareDoctor doctor;
  const DoctorChatPage({super.key, required this.doctor});

  @override
  State<DoctorChatPage> createState() => _DoctorChatPageState();
}

class _DoctorChatPageState extends State<DoctorChatPage> {
  final _text = TextEditingController();
  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _recordTimer;
  int _seconds = 0;
  bool _recording = false;
  bool _searching = false;
  final _examples = [
    DoctorMessage(
      text: 'Bonjour, comment vous sentez-vous aujourd’hui ?',
      fromPatient: false,
    ),
    DoctorMessage(text: 'Je souhaite faire le point sur mon suivi.'),
    DoctorMessage(
      text: 'Message vocal de démonstration',
      fromPatient: false,
      kind: DoctorMessageKind.voice,
      duration: const Duration(seconds: 23),
    ),
  ];

  @override
  void dispose() {
    _recordTimer?.cancel();
    _text.dispose();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _contact() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => DoctorContactPage(doctor: widget.doctor),
    ),
  );

  void _call(bool video) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => DoctorCallPage(doctor: widget.doctor, video: video),
    ),
  );

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

  void _startRecording() {
    FocusScope.of(context).unfocus();
    setState(() {
      _recording = true;
      _seconds = 0;
    });
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  void _cancelRecording() {
    _recordTimer?.cancel();
    setState(() => _recording = false);
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
              child: Text('Joindre un fichier · Aperçu'),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Photo'),
              onTap: () => Navigator.pop(context, 'Photo de démonstration'),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Document'),
              onTap: () => Navigator.pop(context, 'Document de démonstration'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || kind == null) return;
    _send(DoctorMessage(text: kind, kind: DoctorMessageKind.attachment));
  }

  Future<void> _emojis() async {
    final selection = _text.selection;
    final emoji = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choisir un emoji'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final emoji in [
                    '🙂',
                    '😊',
                    '👍',
                    '🙏',
                    '❤️',
                    '👋',
                    '✅',
                    '💬',
                  ])
                    TextButton(
                      onPressed: () => Navigator.pop(context, emoji),
                      child: Text(emoji, style: const TextStyle(fontSize: 28)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || emoji == null) return;
    final start = selection.isValid ? selection.start : _text.text.length;
    final end = selection.isValid ? selection.end : _text.text.length;
    _text.value = TextEditingValue(
      text: _text.text.replaceRange(start, end, emoji),
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
    setState(() {});
  }

  Future<void> _cameraPreview() async {
    final add = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Aperçu caméra',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 52,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'La caméra n’est pas activée dans cette démonstration.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Ajouter l’aperçu'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || add != true) return;
    _send(
      DoctorMessage(
        text: 'Photo de démonstration',
        kind: DoctorMessageKind.attachment,
      ),
    );
  }

  Widget _composerIcon(String tooltip, IconData icon, VoidCallback onPressed) =>
      IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
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
              'Cette action concerne uniquement la démonstration sur cet appareil.',
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
              'Le signalement sera disponible après connexion du service. Aucun signalement n’est envoyé dans cet aperçu.',
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
              'Les messages ajoutés pendant cette démonstration seront effacés.',
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
    final messages = [..._examples, ...data.messagesFor(widget.doctor.name)]
        .where((m) => m.text.toLowerCase().contains(_search.text.toLowerCase()))
        .toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: const PageBackButton(
          color: Colors.white,
          backgroundColor: Colors.transparent,
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              color: AppColors.primaryLighter,
              child: const Text(
                'Mode démonstration · Messages locaux, audios et appels simulés',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
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
                  ? const Center(child: Text('Aucun message trouvé'))
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(18),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: messages.length + 1,
                      itemBuilder: (_, i) => i == 0
                          ? const Padding(
                              padding: EdgeInsets.only(bottom: 24),
                              child: Text(
                                'Exemple de conversation',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textHint,
                                ),
                              ),
                            )
                          : _MessageBubble(
                              key: ObjectKey(messages[i - 1]),
                              message: messages[i - 1],
                            ),
                    ),
            ),
            if (blocked)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Contact bloqué dans la démonstration'),
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
                color: AppColors.primaryLighter,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      'Aperçu de message vocal · Microphone inactif',
                      style: TextStyle(fontSize: 11),
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Annuler le vocal',
                          onPressed: _cancelRecording,
                          icon: const Icon(Icons.delete_outline),
                        ),
                        Text(_duration(Duration(seconds: _seconds))),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: _Waveform(color: AppColors.primary),
                        ),
                        IconButton.filled(
                          tooltip: 'Envoyer le vocal',
                          onPressed: () {
                            final duration = Duration(
                              seconds: _seconds < 1 ? 1 : _seconds,
                            );
                            _cancelRecording();
                            _send(
                              DoctorMessage(
                                text: 'Message vocal de démonstration',
                                kind: DoctorMessageKind.voice,
                                duration: duration,
                              ),
                            );
                          },
                          icon: const Icon(Icons.send_rounded),
                        ),
                      ],
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
                              'Choisir un emoji',
                              Icons.emoji_emotions_outlined,
                              _emojis,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _text,
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
                              'Aperçu caméra',
                              Icons.camera_alt_outlined,
                              _cameraPreview,
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
                      onPressed: _text.text.trim().isEmpty
                          ? _startRecording
                          : () => _send(DoctorMessage(text: _text.text.trim())),
                      icon: Icon(
                        _text.text.trim().isEmpty
                            ? Icons.mic_rounded
                            : Icons.send_rounded,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _duration(Duration duration) =>
    '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

class _MessageBubble extends StatelessWidget {
  final DoctorMessage message;
  const _MessageBubble({super.key, required this.message});

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
                _VoicePlayer(duration: message.duration, color: color)
              else if (message.kind == DoctorMessageKind.attachment)
                Row(
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
                  ],
                )
              else
                Text(
                  message.text,
                  style: TextStyle(color: color, fontSize: 13, height: 1.5),
                ),
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
  final Duration duration;
  final Color color;
  const _VoicePlayer({required this.duration, required this.color});
  @override
  State<_VoicePlayer> createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<_VoicePlayer> {
  Timer? _timer;
  int _position = 0;
  bool _playing = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_playing) {
      _timer?.cancel();
      setState(() => _playing = false);
      return;
    }
    setState(() {
      _playing = true;
      if (_position >= widget.duration.inSeconds) _position = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _position++;
        if (_position >= widget.duration.inSeconds) {
          _playing = false;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          IconButton(
            tooltip: _playing
                ? 'Pause du vocal simulé'
                : 'Lire le vocal simulé',
            onPressed: _toggle,
            icon: Icon(
              _playing ? Icons.pause : Icons.play_arrow,
              color: widget.color,
            ),
          ),
          Expanded(child: _Waveform(color: widget.color)),
        ],
      ),
      Text(
        '${_duration(Duration(seconds: _position))} / ${_duration(widget.duration)} · Aperçu',
        style: TextStyle(color: widget.color, fontSize: 10),
      ),
    ],
  );
}

class _Waveform extends StatelessWidget {
  final Color color;
  const _Waveform({required this.color});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 32,
    child: Row(
      children: List.generate(
        24,
        (i) => Expanded(
          child: Center(
            child: Container(
              width: 3,
              height: (6 + ((i * 7) % 25)).toDouble(),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .65),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
