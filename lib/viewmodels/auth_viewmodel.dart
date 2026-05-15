/// Student Numbers: 223064473, 223023603, 221003431, 220031298, 220024412
/// Student Names  : LM Mosoetsa, A Mbonambi, D Hlalele, NA Pesa, MP Lephole
/// Question: Auth ViewModel
library;

// ============================================================
// viewmodels/auth_viewmodel.dart
// Handles authentication state and Supabase Auth operations.
// Extends ChangeNotifier so Provider can notify the UI of changes.
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

class AuthViewModel extends ChangeNotifier {
  // ─── Private state ───────────────────────────────────────────
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // ─── Public getters (View layer reads these) ─────────────────
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // ─── Supabase client reference ────────────────────────────────
  final SupabaseClient _supabase = Supabase.instance.client;

  // ─── Constructor: restore session if one exists ───────────────
  AuthViewModel() {
    _restoreSession();
  }

  /// Called on startup — checks if a user is already logged in
  Future<void> _restoreSession() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _loadUserProfile(session.user.id);
    }
  }

  // ─── LOGIN ────────────────────────────────────────────────────
  /// Authenticates a user with email and password via Supabase Auth.
  /// Returns true on success, false on failure.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        _setLoading(false);
        return true;
      }

      _setError('Login failed. Please check your credentials.');
      _setLoading(false);
      return false;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // ─── LOAD USER PROFILE ────────────────────────────────────────
  /// Fetches the user's profile (role, name, etc.) from Supabase.
  Future<void> _loadUserProfile(String userId) async {
    try {
      final data =
          await _supabase.from('profiles').select().eq('id', userId).single();

      _currentUser = AppUser.fromMap(data);
      notifyListeners(); // Notify all listening widgets to rebuild
    } catch (e) {
      _setError('Failed to load user profile.');
    }
  }

  // ─── LOGOUT ───────────────────────────────────────────────────
  /// Signs out the current user and clears all state.
  Future<void> logout() async {
    _setLoading(true);
    await _supabase.auth.signOut();
    _currentUser = null;
    _setLoading(false);
    notifyListeners();
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

  void _clearError() {
    _errorMessage = null;
  }

  /// Clears any error message (called by the View when user starts typing)
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
