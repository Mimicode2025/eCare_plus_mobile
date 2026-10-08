import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/care_data.dart';
import 'services/profile_photo_service.dart';
import 'widgets/main_shell.dart';
import 'utils/app_colors.dart';
import 'routes/app_routes.dart';

// Views — Onboarding
import 'views/onbording/splash_screen.dart';
import 'views/onbording/onboarding_screen.dart';

// Views — Auth
import 'views/auth/login_page.dart';
import 'views/auth/register_page.dart';
import 'views/auth/forgot_password_page.dart';
import 'views/auth/registration_success_page.dart';
import 'views/profile/profile_page.dart';
import 'views/dashbord/appointments_page.dart';
import 'views/dashbord/documents_page.dart';
import 'views/dashbord/doctors_page.dart';
import 'views/dashbord/treatments_page.dart';
import 'views/notification/notifications_page.dart';
import 'views/measurement/follow_up_page.dart';
import 'views/error/page_not_found_page.dart';
import 'views/error/no_connection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final data = CareData();
  final photo = await ProfilePhotoService.recoverPhoto();
  if (photo != null) data.setProfilePhoto(photo);
  runApp(ECarePlusApp(initialData: data));
}

class ECarePlusApp extends StatelessWidget {
  final CareData? initialData;
  const ECarePlusApp({super.key, this.initialData});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => initialData ?? CareData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'eCARE+',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.primaryLight,
            surface: AppColors.scaffoldBackground,
          ),
          scaffoldBackgroundColor: AppColors.scaffoldBackground,
          textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.onboarding: (_) => const OnboardingScreen(),
          AppRoutes.login: (_) => const LoginPage(),
          AppRoutes.register: (_) => const RegisterPage(),
          AppRoutes.forgotPassword: (_) => const ForgotPasswordPage(),
          AppRoutes.registrationSuccess: (_) => const RegistrationSuccessPage(),
          AppRoutes.home: (_) => const MainShell(),
          AppRoutes.profile: (_) => const ProfilePage(firstTime: true),
          AppRoutes.appointments: (_) => const AppointmentsPage(),
          AppRoutes.notifications: (_) => const NotificationsPage(),
          AppRoutes.followUp: (_) => const FollowUpPage(),
          AppRoutes.documents: (_) => const DocumentsPage(),
          AppRoutes.doctors: (_) => const DoctorsPage(),
          AppRoutes.treatments: (_) => const TreatmentsPage(),
          AppRoutes.pageNotFound: (_) => const PageNotFoundPage(),
          AppRoutes.noConnection: (_) => const NoConnectionPage(),
        },
        onUnknownRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const PageNotFoundPage(),
        ),
      ),
    );
  }
}
