# eCARE+ launcher icon

Source: `assets/images/ecare_logo.png`, the current splash logo.

`launcher_foreground.png` is the approved symbol without the wordmark, edited with the built-in imagegen tool. `launcher_icon.png` is the opaque export for platform packaging. The original logo is preserved.

Edit prompt: Preserve the cyan medical cross and stethoscope geometry, orientation and colors. Remove the entire ECARE+ wordmark. Slightly smooth and round the existing stroke junctions and corners. Center only the symbol on a transparent square canvas, occupying about 60 percent of the canvas. No background tile, border, shadow or text.

Regenerate the Android density variants and the iOS AppIcon catalog with `powershell -File tool/generate_launcher_icons.ps1` on Windows. Android 8+ uses foreground/background layers and the phone's launcher mask; older Android versions use the rounded PNG. The iOS exports are opaque square PNGs; iOS applies its own corner mask. No additional Flutter package is needed.

Platform references: [Android adaptive icons](https://developer.android.com/codelabs/basic-android-kotlin-compose-training-change-app-icon), [Apple app icons](https://developer.apple.com/design/human-interface-guidelines/app-icons/).
