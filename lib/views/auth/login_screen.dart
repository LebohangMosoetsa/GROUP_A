/**
 * Student Numbers: 220031298, 220364473, 221003431, 223023603,220024412
 * Student Names  : NA Pesa  , LM Mosoetsa, D Hlalele, A Mbonambi, MP Lephole
 * Question: Authentication / Login Screen
 */

// ============================================================
// views/auth/login_screen.dart
// The login screen. Uses Provider to watch AuthViewModel.
// After successful login, routes user based on their role.
// ============================================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../utils/app_constants.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ─── Form key for validation ───────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ─── Controllers for text fields ──────────────────────────
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ─── Local UI state────────────────────────────────────────
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Login action──────────────────────────────────────────
  Future<void> _handleLogin() async {
    // Validate all form fields first
    if (!_formKey.currentState!.validate()) return;

    // Use read() because we're performing a one-time action, not watching
    final authVM = context.read<AuthViewModel>();
    authVM.clearError();

    final success = await authVM.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      // Route based on user role
      if (authVM.isAdmin) {
        context.go('/admin/dashboard');
      } else {
        context.go('/student/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),

                // ─── Logo and Title ─────────────────────────
                _buildHeader(),

                const SizedBox(height: 48),

                // ─── Login Form ─────────────────────────────
                _buildLoginForm(),

                const SizedBox(height: 24),

                // ─── Error Message ──────────────────────────
                // context.watch() is used here because we want the widget
                // to REBUILD whenever the error message changes
                Consumer<AuthViewModel>(
                  builder: (context, authVM, child) {
                    if (authVM.errorMessage == null) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authVM.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // ─── Login Button ────────────────────────────
                Consumer<AuthViewModel>(
                  builder: (context, authVM, child) {
                    return ElevatedButton(
                      onPressed: authVM.isLoading ? null : _handleLogin,
                      child: authVM.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text('Login'),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // ─── Info note ──────────────────────────────
                Text(
                  'Contact the IT Department if you do not have an account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header Widget─────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 52,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Student Assistant\nApplication System',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Central University of Technology',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // ─── Login Form Widget─────────────────────────────────────
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email field
          const Text(
            'Email Address',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: (_) => context.read<AuthViewModel>().clearError(),
            decoration: const InputDecoration(
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            // Validation logic
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Password field
          const Text(
            'Password',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: !_passwordVisible,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            onChanged: (_) => context.read<AuthViewModel>().clearError(),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
