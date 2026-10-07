# ecare_plus_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Architecture.

lib/
│
├── main.dart
│
├── models/
│   ├── user_model.dart
│   ├── patient_model.dart
│   ├── glucose_model.dart
│   ├── blood_pressure_model.dart
│   ├── appointment_model.dart
│   ├── notification_model.dart
│   └── education_model.dart
│
├── views/
│   │
│   ├── auth/
│   │   ├── login_page.dart
│   │   ├── register_page.dart 36BFFA
│   │   └── forgot_password_page.dart
│   │
│   ├── dashboard/
│   │   └── dashboard_page.dart
│   │
│   ├── measurements/
│   │   ├── glucose_page.dart
│   │   ├── blood_pressure_page.dart
│   │   └── measurement_history_page.dart
│   │
│   ├── statistics/
│   │   └── statistics_page.dart
│   │
│   ├── reminders/
│   │   └── reminders_page.dart
│   │
│   ├── education/
│   │   └── education_page.dart
│   │
│   ├── notifications/
│   │   └── notifications_page.dart
│   │
│   └── profile/
│       └── profile_page.dart
│
├── services/
│   ├── auth_service.dart
│   ├── patient_service.dart
│   ├── glucose_service.dart
│   ├── blood_pressure_service.dart
│   ├── statistics_service.dart
│   ├── notification_service.dart
│   ├── reminder_service.dart
│   └── api_service.dart
│
├── widgets/
│   ├── measurement_card.dart
│   ├── statistic_card.dart
│   ├── custom_button.dart
│   ├── custom_textfield.dart
│   └── bottom_navigation.dart
│
├── utils/
│   ├── constants.dart
│   ├── validators.dart
│   └── helpers.dart
│
└── routes/
    └── app_routes.dart