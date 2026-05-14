/**
 * Student Numbers: 223064473, 223023603, 221003431, 220031298, 220024412
 * Student Names  : LM Mosoetsa, A Mbonambi, D Hlalele, NA Pesa, MP Lephole
 * Question: Main Application Entry Point (Routing & Provider Setup)
 */

// ============================================================
// main.dart
// Application entry point. Initialises Supabase, sets up the
// Provider tree (MVVM state management), and configures GoRouter
// for navigation with role-based redirect guards.
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/application.dart';
import 'utils/app_constants.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/application_viewmodel.dart';
import 'views/auth/login_screen.dart';
import 'views/student/student_home_screen.dart';
import 'views/student/application_form_screen.dart';
import 'views/student/application_detail_screen.dart';
import 'views/admin/admin_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Initialise Supabase ─────────────────────────────────────
  // Replace AppConstants.supabaseUrl and supabaseAnonKey with
  // your actual Supabase project credentials.
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const MyApp());
}

// ============================================================
// MyApp — Root widget
// Sets up MultiProvider so that ViewModels are accessible
// throughout the entire widget tree (no prop drilling).
// ============================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // ─── Provide ViewModels to the entire widget tree ────────
      providers: [
        // AuthViewModel: manages login/logout state and current user
        ChangeNotifierProvider(create: (_) => AuthViewModel()),

        // ApplicationViewModel: manages all CRUD operations on applications
        ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Student Assistant App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            // ─── GoRouter configuration ───────────────────────
            routerConfig: _buildRouter(context),
          );
        },
      ),
    );
  }

  // ============================================================
  // GoRouter — defines all named routes and redirect logic
  // ============================================================
  GoRouter _buildRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/login',

      // ─── Route definitions ──────────────────────────────────
      routes: [
        // Login (shared for all users)
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        // ── Student routes ──────────────────────────────────
        GoRoute(
          path: '/student/home',
          name: 'studentHome',
          builder: (context, state) => const StudentHomeScreen(),
        ),
        GoRoute(
          path: '/student/apply',
          name: 'apply',
          builder: (context, state) {
            // The existing application is passed as 'extra' when editing
            final existing = state.extra as Application?;
            return ApplicationFormScreen(existingApplication: existing);
          },
        ),
        GoRoute(
          path: '/student/application/:id',
          name: 'applicationDetail',
          builder: (context, state) {
            final application = state.extra as Application;
            return ApplicationDetailScreen(application: application);
          },
        ),

        // ── Admin routes ────────────────────────────────────
        GoRoute(
          path: '/admin/dashboard',
          name: 'adminDashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
      ],

      // ─── Redirect guard: controls access based on auth state ─
      redirect: (context, state) {
        final authVM = Provider.of<AuthViewModel>(context, listen: false);
        final isLoggedIn = authVM.isAuthenticated;
        final isAdmin = authVM.isAdmin;
        final location = state.uri.toString();

        // Not logged in → force to login page
        if (!isLoggedIn && location != '/login') {
          return '/login';
        }

        // Logged in but trying to access login page → redirect to role home
        if (isLoggedIn && location == '/login') {
          return isAdmin ? '/admin/dashboard' : '/student/home';
        }

        // Admin trying to access student routes → redirect to admin dashboard
        if (isLoggedIn && isAdmin && location.startsWith('/student')) {
          return '/admin/dashboard';
        }

        // Student trying to access admin routes → redirect to student home
        if (isLoggedIn && !isAdmin && location.startsWith('/admin')) {
          return '/student/home';
        }

        return null; // No redirect needed
      },
    );
  }
}
