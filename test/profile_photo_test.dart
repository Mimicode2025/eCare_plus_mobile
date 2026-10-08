import 'dart:typed_data';
import 'package:ecare_plus_mobile/models/care_data.dart';
import 'package:ecare_plus_mobile/views/profile/profile_page.dart';
import 'package:ecare_plus_mobile/widgets/patient_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class GalleryPicker extends ImagePicker {
  final XFile? image;
  final bool fail;
  int calls = 0;
  GalleryPicker(this.image, {this.fail = false});
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    calls++;
    expect(source, ImageSource.gallery);
    if (fail) throw PlatformException(code: 'photo_access_denied');
    return image;
  }
}

void main() {
  Future<void> openProfile(
    WidgetTester tester,
    CareData data,
    ImagePicker picker,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: data,
        child: MaterialApp(home: ProfilePage(imagePicker: picker)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Plus imports a gallery photo and shared avatars use it', (
    tester,
  ) async {
    final data = CareData();
    final bytes = (await rootBundle.load(
      'lib/data/Profile.png',
    )).buffer.asUint8List();
    final picker = GalleryPicker(
      XFile.fromData(bytes, name: 'portrait.png', mimeType: 'image/png'),
    );
    await openProfile(tester, data, picker);
    await tester.tap(find.byTooltip('Choisir une photo'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(picker.calls, 1);
    expect(data.profilePhoto, isNotNull);
    expect(
      tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundImage,
      isA<MemoryImage>(),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: data,
        child: const MaterialApp(
          home: Scaffold(body: PatientAvatar(radius: 25)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundImage,
      isA<MemoryImage>(),
    );
    data.clear();
    await tester.pumpAndSettle();
    expect(data.profilePhoto, isNull);
    expect(
      tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundImage,
      isA<AssetImage>(),
    );
  });

  testWidgets('Cancel and gallery errors keep the existing photo', (
    tester,
  ) async {
    final data = CareData();
    final bytes = (await rootBundle.load(
      'lib/data/Profile.png',
    )).buffer.asUint8List();
    data.setProfilePhoto(Uint8List.fromList(bytes));
    await openProfile(tester, data, GalleryPicker(null));
    await tester.tap(find.byTooltip('Choisir une photo'));
    await tester.pumpAndSettle();
    expect(data.profilePhoto, orderedEquals(bytes));
    await openProfile(tester, data, GalleryPicker(null, fail: true));
    await tester.tap(find.byTooltip('Choisir une photo'));
    await tester.pumpAndSettle();
    expect(data.profilePhoto, orderedEquals(bytes));
    expect(
      find.text(
        'Autorisez l’accès aux photos dans les paramètres du téléphone.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
