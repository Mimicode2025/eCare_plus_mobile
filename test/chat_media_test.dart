import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ecare_plus_mobile/services/profile_photo_service.dart';
import 'dart:convert';
import 'package:ecare_plus_mobile/data/doctor_catalog.dart';
import 'package:ecare_plus_mobile/models/care_data.dart';
import 'package:ecare_plus_mobile/models/doctor_message.dart';
import 'package:ecare_plus_mobile/services/chat_media_service.dart';
import 'package:ecare_plus_mobile/views/messaging/doctor_chat_page.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceMedia extends ChatMediaService {
  final levels = StreamController<double>.broadcast();
  @override
  Stream<double> get recordingLevels => levels.stream;
  bool allowMicrophone = true;
  Completer<bool>? pendingStart;
  bool cancelled = false;
  bool failPicker = false;
  bool? cameraUsed;
  DoctorMessage? pickedDocument;
  final audio = DevicePlayback();
  @override
  Future<DoctorMessage?> pickPhoto({required bool camera}) async {
    cameraUsed = camera;
    if (failPicker) throw const ChatMediaException('Accès aux photos refusé');
    return DoctorMessage(
      text: 'photo.png',
      kind: DoctorMessageKind.attachment,
      isImage: true,
      bytes: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLbtAAAAABJRU5ErkJggg==',
      ),
    );
  }

  @override
  Future<DoctorMessage?> pickDocument() async => pickedDocument;
  @override
  Future<bool> startRecording() async =>
      pendingStart == null ? allowMicrophone : await pendingStart!.future;
  @override
  Future<void> cancelRecording() async {
    cancelled = true;
  }

  @override
  Future<DoctorMessage?> stopRecording() async => DoctorMessage(
    text: 'Message vocal',
    kind: DoctorMessageKind.voice,
    bytes: Uint8List.fromList([1, 2, 3, 4]),
    duration: const Duration(seconds: 3),
  );
  @override
  VoicePlayback createPlayback() => audio;
  @override
  Future<void> dispose() async {
    await levels.close();
  }
}

class DevicePlayback extends VoicePlayback {
  final positionEvents = StreamController<Duration>.broadcast();
  final stateEvents = StreamController<bool>.broadcast();
  DoctorMessage? played;
  @override
  Stream<Duration> get positions => positionEvents.stream;
  @override
  Stream<bool> get states => stateEvents.stream;
  @override
  Future<void> play(DoctorMessage message) async {
    played = message;
    stateEvents.add(true);
    positionEvents.add(const Duration(seconds: 1));
  }

  @override
  Future<void> pause() async {
    stateEvents.add(false);
  }

  @override
  Future<void> dispose() async {
    await positionEvents.close();
    await stateEvents.close();
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Future<void> open(
    WidgetTester tester,
    CareData data,
    DeviceMedia media,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: data,
        child: MaterialApp(
          home: DoctorChatPage(
            doctor: doctorCatalog.first,
            mediaService: media,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Android recovers a chat photo into its conversation and never the profile',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      SharedPreferences.setMockInitialValues({
        ChatMediaService.pendingPhotoKey: doctorCatalog.first.name,
      });
      const channel = MethodChannel('plugins.flutter.io/image_picker');
      final photo = File(
        '${Directory.systemTemp.path}/ecare-chat-recovery-${DateTime.now().microsecondsSinceEpoch}.png',
      );
      await tester.runAsync(() => photo.writeAsBytes([1, 2, 3]));
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (call) async => {
          'path': photo.path,
          'pathList': [photo.path],
          'type': 'image',
        },
      );
      try {
        expect(
          await tester.runAsync(() => ProfilePhotoService.recoverPhoto()),
          isNull,
        );
        final recovered = await tester.runAsync(
          () => ChatMediaService.recoverPhoto(),
        );
        expect(recovered?.$1, doctorCatalog.first.name);
        expect(recovered?.$2.bytes, orderedEquals([1, 2, 3]));
        expect(
          (await SharedPreferences.getInstance()).containsKey(
            ChatMediaService.pendingPhotoKey,
          ),
          false,
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        );
        await tester.runAsync(() => photo.delete());
      }
    },
  );

  testWidgets(
    'Camera and gallery attach actual image bytes while preserving draft',
    (tester) async {
      final data = CareData();
      final media = DeviceMedia();
      await open(tester, data, media);
      await tester.enterText(find.byType(TextField).last, 'Mon brouillon');
      await tester.tap(find.byTooltip('Prendre une photo'));
      await tester.pumpAndSettle();
      expect(media.cameraUsed, true);
      expect(
        data.messagesFor(doctorCatalog.first.name).single.bytes,
        isNotEmpty,
      );
      expect(find.bySemanticsLabel('Photo jointe'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).last).controller!.text,
        'Mon brouillon',
      );
      await tester.tap(find.byTooltip('Joindre un fichier'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Photo'));
      await tester.pumpAndSettle();
      expect(media.cameraUsed, false);
      expect(data.messagesFor(doctorCatalog.first.name), hasLength(2));
      expect(find.text('Non envoyé · sur cet appareil'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'File selection retains filename and bytes and cancellation creates nothing',
    (tester) async {
      final data = CareData();
      final media = DeviceMedia();
      media.pickedDocument = DoctorMessage(
        text: 'analyse.pdf',
        kind: DoctorMessageKind.attachment,
        bytes: Uint8List.fromList([37, 80, 68, 70]),
      );
      await open(tester, data, media);
      await tester.enterText(find.byType(TextField).last, 'Voici mon document');
      await tester.tap(find.byTooltip('Joindre un fichier'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Document'));
      await tester.pumpAndSettle();
      expect(find.text('analyse.pdf'), findsOneWidget);
      expect(
        data.messagesFor(doctorCatalog.first.name).single.bytes,
        orderedEquals([37, 80, 68, 70]),
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).last).controller!.text,
        'Voici mon document',
      );
      media.pickedDocument = null;
      await tester.tap(find.byTooltip('Joindre un fichier'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Document'));
      await tester.pumpAndSettle();
      expect(data.messagesFor(doctorCatalog.first.name), hasLength(1));
    },
  );

  testWidgets('Denied camera access creates no fake attachment', (
    tester,
  ) async {
    final data = CareData();
    final media = DeviceMedia()..failPicker = true;
    await open(tester, data, media);
    await tester.tap(find.byTooltip('Prendre une photo'));
    await tester.pumpAndSettle();
    expect(find.text('Accès aux photos refusé'), findsOneWidget);
    expect(data.messagesFor(doctorCatalog.first.name), isEmpty);
  });

  testWidgets(
    'Recording waveform follows microphone levels and stops listening after cancellation',
    (tester) async {
      final data = CareData();
      final media = DeviceMedia();
      final semantics = tester.ensureSemantics();
      await open(tester, data, media);
      await tester.tap(find.byTooltip('Message vocal'));
      await tester.pump();
      await tester.pump();
      expect(
        find.bySemanticsLabel('Niveau sonore du microphone'),
        findsOneWidget,
      );
      media.levels.add(-60);
      await tester.pump();
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Niveau sonore du microphone'))
            .value,
        '0 %',
      );
      media.levels.add(-15);
      await tester.pump();
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Niveau sonore du microphone'))
            .value,
        '75 %',
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('0:02'), findsOneWidget);
      await tester.tap(find.byTooltip('Annuler le vocal'));
      await tester.pumpAndSettle();
      expect(media.levels.hasListener, false);
      media.levels.add(-5);
      await tester.pump();
      expect(
        find.bySemanticsLabel('Niveau sonore du microphone'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      semantics.dispose();
    },
  );

  testWidgets(
    'Voice cancel discards recording; saved bytes are played and paused',
    (tester) async {
      final data = CareData();
      final media = DeviceMedia();
      await open(tester, data, media);
      await tester.tap(find.byTooltip('Message vocal'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byTooltip('Annuler le vocal'));
      await tester.pumpAndSettle();
      expect(media.cancelled, true);
      expect(data.messagesFor(doctorCatalog.first.name), isEmpty);
      await tester.tap(find.byTooltip('Message vocal'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.byTooltip('Envoyer le vocal'));
      await tester.pumpAndSettle();
      expect(find.text('0:00 / 0:03'), findsOneWidget);
      expect(
        data.messagesFor(doctorCatalog.first.name).single.bytes,
        orderedEquals([1, 2, 3, 4]),
      );
      await tester.tap(find.byTooltip('Lire le vocal'));
      await tester.pumpAndSettle();
      expect(media.audio.played?.bytes, orderedEquals([1, 2, 3, 4]));
      expect(find.text('0:01 / 0:03'), findsOneWidget);
      await tester.tap(find.byTooltip('Pause du vocal'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Lire le vocal'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets(
    'Delayed microphone startup is cancelled after contact navigation',
    (tester) async {
      final data = CareData();
      final media = DeviceMedia()..pendingStart = Completer<bool>();
      await open(tester, data, media);
      await tester.tap(find.byTooltip('Message vocal'));
      await tester.pump();
      await tester.tap(find.text(doctorCatalog.first.name));
      await tester.pumpAndSettle();
      media.pendingStart!.complete(true);
      await tester.pumpAndSettle();
      expect(media.cancelled, true);
      expect(data.messagesFor(doctorCatalog.first.name), isEmpty);
      await tester.tap(find.byTooltip('Retour'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Envoyer le vocal'), findsNothing);
    },
  );

  testWidgets(
    'Microphone denial leaves the composer usable without a recording',
    (tester) async {
      final data = CareData();
      final media = DeviceMedia()..allowMicrophone = false;
      await open(tester, data, media);
      await tester.tap(find.byTooltip('Message vocal'));
      await tester.pumpAndSettle();
      expect(
        find.text('Autorisez le microphone dans les paramètres du téléphone.'),
        findsOneWidget,
      );
      expect(find.byTooltip('Envoyer le vocal'), findsNothing);
      expect(data.messagesFor(doctorCatalog.first.name), isEmpty);
      expect(find.byType(TextField), findsOneWidget);
    },
  );

  testWidgets(
    'Emoji categories insert at cursor, search in French and restore keyboard',
    (tester) async {
      final data = CareData();
      final media = DeviceMedia();
      await open(tester, data, media);
      await tester.enterText(find.byType(TextField).last, 'Bonjour ');
      await tester.tap(find.byTooltip('Choisir un emoji'));
      await tester.pumpAndSettle();
      expect(find.byType(EmojiPicker), findsOneWidget);
      await tester.tap(find.text('😀').first);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).last).controller!.text,
        'Bonjour 😀',
      );
      await tester.tap(find.byIcon(Icons.flag).first);
      await tester.pumpAndSettle();
      expect(find.text('Drapeaux'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.search).last);
      await tester.pumpAndSettle();
      final search = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Rechercher un émoji',
      );
      await tester.enterText(search, 'pizza');
      await tester.pumpAndSettle();
      expect(find.text('🍕'), findsOneWidget);
      await tester.tap(find.text('🍕'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Afficher le clavier'));
      await tester.pumpAndSettle();
      expect(find.byType(EmojiPicker), findsNothing);
      expect(find.byTooltip('Envoyer le message'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
