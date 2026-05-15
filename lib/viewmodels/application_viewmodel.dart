/// Student Numbers: 223064473, 223023603, 221003431, 220031298, 220024412
/// Student Names  : LM Mosoetsa, A Mbonambi, D Hlalele, NA Pesa, MP Lephole
/// Question: Application ViewModel
library;

// ============================================================
// viewmodels/application_viewmodel.dart
// Manages application state and all CRUD operations.
// Extends ChangeNotifier — notifies the View whenever data changes.
// ============================================================

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application.dart';

class ApplicationViewModel extends ChangeNotifier {
  // ─── Private state ────────────────────────────────────────────
  List<Application> _applications = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // ─── Public getters ───────────────────────────────────────────
  List<Application> get applications => List.unmodifiable(_applications);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // ─── Supabase client reference ────────────────────────────────
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // READ OPERATIONS
  // ============================================================

  /// Fetches all applications belonging to the currently logged-in student.
  /// Called on the Student Home screen.
  Future<void> fetchStudentApplications(String studentId) async {
    _setLoading(true);
    _clearMessages();

    try {
      final data = await _supabase
          .from('applications')
          .select()
          .eq('student_id', studentId)
          .order('created_at', ascending: false);

      _applications = (data as List)
          .map((map) => Application.fromMap(map as Map<String, dynamic>))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to load applications: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// Fetches ALL applications — for the Admin Dashboard only.
  Future<void> fetchAllApplications() async {
    _setLoading(true);
    _clearMessages();

    try {
      final data = await _supabase
          .from('applications')
          .select()
          .order('created_at', ascending: false);

      _applications = (data as List)
          .map((map) => Application.fromMap(map as Map<String, dynamic>))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to load applications: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// Checks if the current student already has an application.
  Future<bool> hasExistingApplication(String studentId) async {
    try {
      final data = await _supabase
          .from('applications')
          .select('id')
          .eq('student_id', studentId);

      return (data as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // CREATE OPERATION
  // ============================================================

  /// Submits a new Student Assistant application.
  /// Returns true on success, false on failure.
  Future<bool> submitApplication(Application application) async {
    _setLoading(true);
    _clearMessages();

    try {
      await _supabase.from('applications').insert(application.toMap());

      // Refresh the student's applications list after submission
      await fetchStudentApplications(application.studentId);

      _successMessage = 'Application submitted successfully!';
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to submit application: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // UPDATE OPERATIONS
  // ============================================================

  /// Updates an existing application (only allowed when status is 'pending').
  Future<bool> updateApplication(Application application) async {
    if (application.id == null) return false;
    _setLoading(true);
    _clearMessages();

    try {
      await _supabase
          .from('applications')
          .update(application.toMap())
          .eq('id', application.id!);

      // Update local list without full re-fetch
      final index = _applications.indexWhere((a) => a.id == application.id);
      if (index != -1) {
        _applications[index] = application;
        notifyListeners();
      }

      _successMessage = 'Application updated successfully!';
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update application: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Updates only the status of an application — used by Admin.
  Future<bool> updateApplicationStatus(
      String applicationId, String status) async {
    _setLoading(true);
    _clearMessages();

    try {
      await _supabase
          .from('applications')
          .update({'status': status}).eq('id', applicationId);

      // Update local list
      final index = _applications.indexWhere((a) => a.id == applicationId);
      if (index != -1) {
        _applications[index] = _applications[index].copyWith(status: status);
        notifyListeners();
      }

      _successMessage =
          'Application ${status == 'approved' ? 'approved' : 'rejected'} successfully.';
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update status: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // DELETE OPERATION
  // ============================================================

  /// Deletes an application — students can only delete pending ones.
  Future<bool> deleteApplication(String applicationId) async {
    _setLoading(true);
    _clearMessages();

    try {
      await _supabase.from('applications').delete().eq('id', applicationId);

      // Remove from local list immediately (optimistic update)
      _applications.removeWhere((a) => a.id == applicationId);
      notifyListeners();

      _successMessage = 'Application deleted successfully.';
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete application: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // FILE UPLOAD
  // ============================================================

  /// Uploads a supporting document to Supabase Storage.
  /// Returns the public URL of the uploaded file, or null on failure.
  Future<String?> uploadDocument(
      Uint8List fileBytes, String fileName, String studentId) async {
    _setLoading(true);
    _clearMessages();
    try {
      final storedName =
          '${studentId}_${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final path = 'documents/$storedName';

      await _supabase.storage
          .from('application-documents')
          .uploadBinary(path, fileBytes);

      final publicUrl =
          _supabase.storage.from('application-documents').getPublicUrl(path);

      _setLoading(false);
      return publicUrl;
    } catch (e) {
      _setError('Failed to upload document: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  // ─── Helper methods ───────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }
}
