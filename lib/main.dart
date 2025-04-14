import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'role_selection_page.dart';
import 'user_home_page.dart';
import 'admin_home_page.dart';
import 'job_listings_page.dart';
import 'job_details_page.dart';
import 'user_profile_page.dart';
import 'employer_dashboard.dart';
import 'login_page.dart';
import 'sign_up_page.dart';
import 'admin_panel.dart';
import 'pending_admin.dart'; // Add this import
import 'error_page.dart';
import 'providers/app_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String appName = 'JobQuest';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.black87),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 4,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      initialRoute: '/role-selection',
      routes: {
        '/role-selection': (context) => const RoleSelectionPage(),
        '/user-home': (context) => const UserHomePage(),
        '/admin-home': (context) => const AdminHomePage(),
        '/job-listings': (context) => const JobListingsPage(),
        '/job-details': (context) => const JobDetailsPage(),
        '/profile': (context) => const UserProfilePage(),
        '/employer-dashboard': (context) => const EmployerDashboard(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/admin-panel': (context) => const AdminPanel(),
        '/pending-admin': (context) => const PendingAdminPage(), // Add this route
        '/error': (context) => const ErrorPage(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(builder: (context) => const ErrorPage()),
    );
  }
}