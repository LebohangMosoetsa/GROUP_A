/**
 * Student Numbers: 223064473, 223023603, 221003431, 220031298, 220024412
 * Student Names  : LM Mosoetsa, A Mbonambi, D Hlalele, NA Pesa, MP Lephole
 * Question: Admin Dashboard Screen (Read / Update / Delete Operations)
 */

// ============================================================
// views/admin/admin_dashboard_screen.dart
// Admin-only screen showing all submitted applications.
// Supports: view all, approve, reject, delete, filter by status.
// READ / UPDATE / DELETE OPERATIONS
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/application.dart';
import '../../utils/app_constants.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // ─── Filter state ────────────────────────────────────────────
  String _filterStatus = 'All'; // 'All' | 'pending' | 'approved' | 'rejected'

  final List<String> _statusFilters = ['All', 'pending', 'approved', 'rejected'];

  @override
  void initState() {
    super.initState();
    // Fetch all applications when admin dashboard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationViewModel>().fetchAllApplications();
    });
  }

  // ─── Filtered applications ────────────────────────────────────
  List<Application> _getFiltered(List<Application> all) {
    if (_filterStatus == 'All') return all;
    return all.where((a) => a.status == _filterStatus).toList();
  }

  // ─── Update status ────────────────────────────────────────────
  Future<void> _updateStatus(String appId, String status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '${status == 'approved' ? 'Approve' : 'Reject'} Application',
        ),
        content: Text(
          'Are you sure you want to ${status == 'approved' ? 'approve' : 'reject'} this application?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'approved'
                  ? AppTheme.approvedColor
                  : AppTheme.rejectedColor,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(status == 'approved' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<ApplicationViewModel>().updateApplicationStatus(appId, status);
      if (mounted) {
        final msg = context.read<ApplicationViewModel>().successMessage;
        if (msg != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: status == 'approved'
                  ? AppTheme.approvedColor
                  : AppTheme.rejectedColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  // ─── Delete application ───────────────────────────────────────
  Future<void> _deleteApplication(String appId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Remove Application'),
          ],
        ),
        content: const Text(
          'This will permanently remove the application. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<ApplicationViewModel>().deleteApplication(appId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<ApplicationViewModel>().fetchAllApplications();
            },
          ),
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
      body: Consumer<ApplicationViewModel>(
        builder: (context, appVM, _) {
          final filtered = _getFiltered(appVM.applications);

          return Column(
            children: [
              // ─── Stats Row ───────────────────────────────
              _buildStatsRow(appVM.applications),

              // ─── Filter Chips ─────────────────────────────
              _buildFilterChips(),

              // ─── Applications List ────────────────────────
              Expanded(
                child: appVM.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : appVM.errorMessage != null
                        ? _buildErrorState(appVM.errorMessage!)
                        : filtered.isEmpty
                            ? _buildEmptyState()
                            : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return _buildApplicationCard(
                                    context,
                                    filtered[index],
                                  );
                                },
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Stats Row ────────────────────────────────────────────────
  Widget _buildStatsRow(List<Application> all) {
    final pending = all.where((a) => a.status == 'pending').length;
    final approved = all.where((a) => a.status == 'approved').length;
    final rejected = all.where((a) => a.status == 'rejected').length;

    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _statItem('Total', all.length.toString(), Colors.white),
          _statItem('Pending', pending.toString(), AppTheme.pendingColor),
          _statItem('Approved', approved.toString(), AppTheme.approvedColor),
          _statItem('Rejected', rejected.toString(), AppTheme.rejectedColor),
        ],
      ),
    );
  }

  Widget _statItem(String label, String count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Filter Chips ─────────────────────────────────────────────
  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: _statusFilters.map((filter) {
          final isSelected = _filterStatus == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter == 'All' ? 'All' : filter.substring(0, 1).toUpperCase() + filter.substring(1),
              ),
              selected: isSelected,
              selectedColor: AppTheme.primaryColor.withOpacity(0.15),
              checkmarkColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) => setState(() => _filterStatus = filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Application Card ─────────────────────────────────────────
  Widget _buildApplicationCard(BuildContext context, Application app) {
    final isPending = app.status == 'pending';

    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Text(
            app.studentName.isNotEmpty ? app.studentName[0].toUpperCase() : 'S',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          app.studentName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          '${app.studentNumber} • ${app.module1Code}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: StatusBadge(status: app.status),
        children: [
          // ─── Full details ──────────────────────────────
          const Divider(),
          _adminDetailRow('Year of Study', 'Year ${app.yearOfStudy}'),
          _adminDetailRow('Module 1 Level', app.module1Level),
          _adminDetailRow('Module 1', app.module1Code),
          if (app.hasSecondModule) ...[
            _adminDetailRow('Module 2 Level', app.module2Level ?? 'N/A'),
            _adminDetailRow('Module 2', app.module2Code ?? 'N/A'),
          ],
          _adminDetailRow(
            'Eligibility',
            app.eligibilityConfirmed ? 'Confirmed' : 'Not confirmed',
          ),
          _adminDetailRow(
            'Document',
            app.documentUrl != null ? 'Available' : 'Not submitted',
          ),
          if (app.createdAt != null)
            _adminDetailRow('Submitted', _formatDate(app.createdAt!)),

          const SizedBox(height: 12),

          // ─── Action buttons ────────────────────────────
          Row(
            children: [
              if (isPending) ...[
                // Approve
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.approvedColor,
                      minimumSize: const Size(0, 42),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Approve'),
                    onPressed: () => _updateStatus(app.id!, 'approved'),
                  ),
                ),
                const SizedBox(width: 8),
                // Reject
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.rejectedColor,
                      minimumSize: const Size(0, 42),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Reject'),
                    onPressed: () => _updateStatus(app.id!, 'rejected'),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Delete — always visible
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                tooltip: 'Remove application',
                onPressed: () => _deleteApplication(app.id!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _adminDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
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
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _filterStatus == 'All'
                ? 'No applications submitted yet'
                : 'No ${_filterStatus} applications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<ApplicationViewModel>().fetchAllApplications(),
              child: const Text('Retry'),
            ),
          ],
        ),
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



