/**
 * Student Numbers: 223064473, 223023603, 221003431, 220031298, 220024412
 * Student Names  : LM Mosoetsa, A Mbonambi, D Hlalele, NA Pesa, MP Lephole
 * Question: Application Detail Screen (Read / Delete Operation)
 */

// ============================================================
// views/student/application_detail_screen.dart
// Shows full details of a submitted application.
// Allows editing (while pending) and deleting (with confirmation).
// READ OPERATION: displays application data
// DELETE OPERATION: removes the application after confirmation
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/application.dart';
import '../../utils/app_constants.dart';
import '../../viewmodels/application_viewmodel.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final Application application;

  const ApplicationDetailScreen({super.key, required this.application});

  // ─── Delete with confirmation dialog ─────────────────────────
  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Delete Application'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this application? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // use read() — one-time delete action
      final success = await context
          .read<ApplicationViewModel>()
          .deleteApplication(application.id!);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application deleted successfully.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/student/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = application.status == 'pending';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Edit button — only visible for pending applications
          if (isPending)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Application',
              onPressed: () =>
                  context.push('/student/apply', extra: application),
            ),
          // Delete button — only visible for pending applications
          if (isPending)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete Application',
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, appVM, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Status Banner ───────────────────────
                    _buildStatusBanner(),

                    const SizedBox(height: 20),

                    // ─── Student Info Card ───────────────────
                    _buildInfoCard(
                      title: 'Student Information',
                      icon: Icons.person_outline,
                      children: [
                        _detailRow('Full Name', application.studentName),
                        _detailRow('Student Number', application.studentNumber),
                        _detailRow('Year of Study', 'Year ${application.yearOfStudy}'),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─── Module 1 Card ───────────────────────
                    _buildInfoCard(
                      title: 'Primary Module Application',
                      icon: Icons.book_outlined,
                      children: [
                        _detailRow('Academic Level', application.module1Level),
                        _detailRow('Module', application.module1Code),
                      ],
                    ),

                    // ─── Module 2 Card (if applicable) ───────
                    if (application.hasSecondModule) ...[
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        title: 'Second Module Application',
                        icon: Icons.add_box_outlined,
                        children: [
                          _detailRow('Academic Level', application.module2Level ?? 'N/A'),
                          _detailRow('Module', application.module2Code ?? 'N/A'),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // ─── Eligibility & Documents Card ─────────
                    _buildInfoCard(
                      title: 'Eligibility & Documentation',
                      icon: Icons.verified_outlined,
                      children: [
                        _detailRow(
                          'Eligibility Confirmed',
                          application.eligibilityConfirmed ? 'Yes' : 'No',
                          valueColor: application.eligibilityConfirmed
                              ? AppTheme.approvedColor
                              : Colors.red,
                        ),
                        _detailRow(
                          'Supporting Document',
                          application.documentUrl != null
                              ? 'Uploaded'
                              : 'Not uploaded',
                          valueColor: application.documentUrl != null
                              ? AppTheme.approvedColor
                              : Colors.orange,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─── Submission Info Card ─────────────────
                    _buildInfoCard(
                      title: 'Submission Details',
                      icon: Icons.calendar_today_outlined,
                      children: [
                        _detailRow(
                          'Submitted On',
                          application.createdAt != null
                              ? _formatDate(application.createdAt!)
                              : 'Unknown',
                        ),
                        _detailRow('Application ID', application.id ?? 'N/A'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ─── Note for non-pending ─────────────────
                    if (!isPending)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This application has been reviewed and can no longer be edited or deleted.',
                                style: TextStyle(fontSize: 13, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // Loading overlay during delete
              if (appVM.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.2),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  // ─── Status Banner ────────────────────────────────────────────
  Widget _buildStatusBanner() {
    Color bgColor;
    Color borderColor;
    IconData icon;
    String message;

    switch (application.status.toLowerCase()) {
      case 'approved':
        bgColor = Colors.green.shade50;
        borderColor = Colors.green.shade300;
        icon = Icons.check_circle_outline_rounded;
        message = 'Your application has been approved!';
        break;
      case 'rejected':
        bgColor = Colors.red.shade50;
        borderColor = Colors.red.shade300;
        icon = Icons.cancel_outlined;
        message = 'Your application was not approved this time.';
        break;
      default:
        bgColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade300;
        icon = Icons.hourglass_top_rounded;
        message = 'Your application is pending review.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: borderColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${application.status.toUpperCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: borderColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(fontSize: 13, color: borderColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Info Card ────────────────────────────────────────────────
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  // ─── Detail Row ───────────────────────────────────────────────
  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
