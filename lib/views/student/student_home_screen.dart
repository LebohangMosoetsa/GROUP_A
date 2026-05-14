/**
 * Student Numbers: 223064473, 223023603, 221003431, 220031298, 220024412
 * Student Names  : LM Mosoetsa, A Mbonambi, D Hlalele, NA Pesa, MP Lephole
 * Question: Student Home Screen (Read Operation)
 */

// ============================================================
// views/student/student_home_screen.dart
// The student's dashboard — shows their application(s) and
// allows navigation to submit or manage an application.
// READ OPERATION: Retrieves applications scoped to the logged-in user.
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/application.dart';
import '../../utils/app_constants.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load applications when the screen first appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentId = context.read<AuthViewModel>().currentUser?.id ?? '';
      // use read() here — one-time action on init, not watching
      context.read<ApplicationViewModel>().fetchStudentApplications(studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // watch() the AuthViewModel so we get live updates to user data
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthViewModel>().logout();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Welcome Card ───────────────────────────────
            _buildWelcomeCard(user?.fullName ?? 'Student', user?.studentNumber ?? ''),

            const SizedBox(height: 24),

            // ─── Applications Section ───────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Applications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh',
                  onPressed: () {
                    context
                        .read<ApplicationViewModel>()
                        .fetchStudentApplications(user?.id ?? '');
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // watch() the ApplicationViewModel — UI must rebuild when data changes
            Consumer<ApplicationViewModel>(
              builder: (context, appVM, child) {
                if (appVM.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (appVM.errorMessage != null) {
                  return _buildErrorCard(appVM.errorMessage!);
                }

                if (appVM.applications.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appVM.applications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildApplicationCard(
                      context,
                      appVM.applications[index],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),

      // ─── FAB: only show if student has no application yet ──
      floatingActionButton: Consumer<ApplicationViewModel>(
        builder: (context, appVM, _) {
          if (appVM.applications.isNotEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => context.push('/student/apply'),
            backgroundColor: AppTheme.primaryColor,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Apply Now',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
    );
  }

  // ─── Welcome Card ─────────────────────────────────────────
  Widget _buildWelcomeCard(String name, String studentNumber) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.waving_hand_rounded, color: Colors.amber, size: 28),
          const SizedBox(height: 8),
          Text(
            'Welcome back,',
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
          ),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Student No: $studentNumber',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'IT Department — Student Assistant Programme',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Application Card ─────────────────────────────────────
  Widget _buildApplicationCard(BuildContext context, Application app) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/student/application/${app.id}', extra: app),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      app.module1Code,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  StatusBadge(status: app.status),
                ],
              ),
              const SizedBox(height: 8),
              _infoRow(Icons.school_outlined, 'Level: ${app.module1Level}'),
              if (app.hasSecondModule) ...[
                const SizedBox(height: 4),
                _infoRow(Icons.add_box_outlined, 'Also: ${app.module2Code ?? ''}'),
              ],
              const SizedBox(height: 4),
              _infoRow(
                Icons.calendar_today_outlined,
                'Year of Study: ${app.yearOfStudy}',
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    app.createdAt != null
                        ? 'Submitted: ${_formatDate(app.createdAt!)}'
                        : 'Recently submitted',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  // ─── Empty State ──────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No applications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to submit\nyour Student Assistant application.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
