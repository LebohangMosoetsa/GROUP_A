/**
 * Student Numbers: 223064473, 223023603, 221003431, 220031298, 220024412
 * Student Names  : LM Mosoetsa, A Mbonambi, D Hlalele, NA Pesa, MP Lephole
 * Question: Student Assistant Application Form (Create / Update Operation)
 */

// ============================================================
// views/student/application_form_screen.dart
// The application form — supports both creating a new application
// and editing an existing pending one. Demonstrates:
//   - Logical grouping of related fields
//   - Controlled input (dropdowns)
//   - Comprehensive validation
//   - File upload for supporting documents
// ============================================================

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/application.dart';
import '../../utils/app_constants.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ApplicationFormScreen extends StatefulWidget {
  /// If provided, the form is in EDIT mode for this application
  final Application? existingApplication;

  const ApplicationFormScreen({super.key, this.existingApplication});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // ─── Form field controllers and values ──────────────────────
  int? _yearOfStudy;
  String? _module1Level;
  String? _module1Code;
  bool _hasSecondModule = false;
  String? _module2Level;
  String? _module2Code;
  bool _eligibilityConfirmed = false;

  // ─── Web-compatible file variables ──────────────────────────
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  String? _existingDocumentUrl;

  bool get _isEditMode => widget.existingApplication != null;

  @override
  void initState() {
    super.initState();
    // If editing, pre-fill form fields with existing data
    if (_isEditMode) {
      final app = widget.existingApplication!;
      _yearOfStudy = app.yearOfStudy;
      _module1Level = app.module1Level;
      _module1Code = app.module1Code;
      _hasSecondModule = app.hasSecondModule;
      _module2Level = app.module2Level;
      _module2Code = app.module2Code;
      _eligibilityConfirmed = app.eligibilityConfirmed;
      _existingDocumentUrl = app.documentUrl;
    }
  }

  // ─── File picker (web-compatible) ───────────────────────────
  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // Required for web — loads bytes directly
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedFileBytes = result.files.single.bytes!;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  // ─── Submit / Update ────────────────────────────────────────
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_eligibilityConfirmed) {
      _showSnackBar('You must confirm your eligibility to submit.',
          isError: true);
      return;
    }

    final authVM = context.read<AuthViewModel>();
    final appVM = context.read<ApplicationViewModel>();
    final user = authVM.currentUser!;

    // Check for existing application — only one allowed (CREATE mode)
    if (!_isEditMode) {
      final exists = await appVM.hasExistingApplication(user.id);
      if (exists && mounted) {
        _showSnackBar(
          'You already have an existing application. You can only submit one.',
          isError: true,
        );
        return;
      }
    }

    // Upload document if a new file was selected
    String? documentUrl = _existingDocumentUrl;
    if (_selectedFileBytes != null) {
      documentUrl = await appVM.uploadDocument(
        _selectedFileBytes!,
        _selectedFileName!,
        user.id,
      );
    }

    final application = Application(
      id: _isEditMode ? widget.existingApplication!.id : null,
      studentId: user.id,
      studentName: user.fullName,
      studentNumber: user.studentNumber,
      yearOfStudy: _yearOfStudy!,
      module1Level: _module1Level!,
      module1Code: _module1Code!,
      hasSecondModule: _hasSecondModule,
      module2Level: _hasSecondModule ? _module2Level : null,
      module2Code: _hasSecondModule ? _module2Code : null,
      eligibilityConfirmed: _eligibilityConfirmed,
      documentUrl: documentUrl,
      status: _isEditMode ? widget.existingApplication!.status : 'pending',
    );

    bool success;
    if (_isEditMode) {
      success = await appVM.updateApplication(application);
    } else {
      success = await appVM.submitApplication(application);
    }

    if (success && mounted) {
      _showSnackBar(
        _isEditMode
            ? 'Application updated successfully!'
            : 'Application submitted successfully!',
      );
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) context.pop();
    } else if (appVM.errorMessage != null && mounted) {
      _showSnackBar(appVM.errorMessage!, isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : AppTheme.approvedColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Application' : 'Apply for SA Position'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, appVM, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Student Info
                      _sectionHeader(
                          'Student Information', Icons.person_outline),
                      const SizedBox(height: 12),
                      _buildYearOfStudyDropdown(),

                      const SizedBox(height: 24),

                      // Section 2: Module 1 (required)
                      _sectionHeader(
                          'Primary Module Application', Icons.book_outlined),
                      const SizedBox(height: 12),
                      _buildModule1LevelDropdown(),
                      const SizedBox(height: 16),
                      _buildModule1CodeDropdown(),

                      const SizedBox(height: 24),

                      // Section 3: Module 2 (optional)
                      _sectionHeader(
                          'Second Module (Optional)', Icons.add_box_outlined),
                      const SizedBox(height: 8),
                      _buildSecondModuleToggle(),
                      if (_hasSecondModule) ...[
                        const SizedBox(height: 16),
                        _buildModule2LevelDropdown(),
                        const SizedBox(height: 16),
                        _buildModule2CodeDropdown(),
                      ],

                      const SizedBox(height: 24),

                      // Section 4: Supporting Document
                      _sectionHeader('Supporting Documentation',
                          Icons.attach_file_outlined),
                      const SizedBox(height: 12),
                      _buildDocumentUploader(),

                      const SizedBox(height: 24),

                      // Section 5: Eligibility Confirmation
                      _sectionHeader(
                          'Eligibility Confirmation', Icons.verified_outlined),
                      const SizedBox(height: 12),
                      _buildEligibilityCheckbox(),

                      const SizedBox(height: 32),

                      // Submit / Update button
                      ElevatedButton(
                        onPressed: appVM.isLoading ? null : _handleSubmit,
                        child: appVM.isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(_isEditMode
                                ? 'Update Application'
                                : 'Submit Application'),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Loading overlay
              if (appVM.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.05),
                ),
            ],
          );
        },
      ),
    );
  }

  // ─── Section Header ─────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  // ─── Year of Study Dropdown ──────────────────────────────────
  Widget _buildYearOfStudyDropdown() {
    return DropdownButtonFormField<int>(
      value: _yearOfStudy,
      decoration: const InputDecoration(
        labelText: 'Current Year of Study *',
        prefixIcon: Icon(Icons.grade_outlined),
      ),
      hint: const Text('Select your year of study'),
      items: AppConstants.yearsOfStudy.map((year) {
        return DropdownMenuItem(
          value: year,
          child: Text('Year $year'),
        );
      }).toList(),
      onChanged: (val) => setState(() => _yearOfStudy = val),
      validator: (val) =>
          val == null ? 'Please select your year of study' : null,
    );
  }

  // ─── Module 1 Dropdowns ──────────────────────────────────────
  Widget _buildModule1LevelDropdown() {
    return DropdownButtonFormField<String>(
      value: _module1Level,
      decoration: const InputDecoration(
        labelText: 'Academic Level (Module 1) *',
        prefixIcon: Icon(Icons.layers_outlined),
      ),
      hint: const Text('Select academic level'),
      items: AppConstants.academicLevels.map((level) {
        return DropdownMenuItem(value: level, child: Text(level));
      }).toList(),
      onChanged: (val) {
        setState(() {
          _module1Level = val;
          _module1Code = null;
        });
      },
      validator: (val) =>
          val == null ? 'Please select an academic level' : null,
    );
  }

  Widget _buildModule1CodeDropdown() {
    final modules = _module1Level != null
        ? AppConstants.modulesByLevel[_module1Level!] ?? []
        : <String>[];

    return DropdownButtonFormField<String>(
      value: _module1Code,
      decoration: const InputDecoration(
        labelText: 'Module (Module 1) *',
        prefixIcon: Icon(Icons.menu_book_outlined),
      ),
      hint: Text(
        _module1Level == null ? 'Select a level first' : 'Select a module',
      ),
      items: modules.map((code) {
        return DropdownMenuItem(value: code, child: Text(code));
      }).toList(),
      onChanged: _module1Level == null
          ? null
          : (val) => setState(() => _module1Code = val),
      validator: (val) => val == null ? 'Please select a module' : null,
    );
  }

  // ─── Second Module Toggle ────────────────────────────────────
  Widget _buildSecondModuleToggle() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'Apply for a second module',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: const Text(
        'Students may apply to assist with a maximum of two modules.',
        style: TextStyle(fontSize: 12),
      ),
      value: _hasSecondModule,
      activeColor: AppTheme.primaryColor,
      onChanged: (val) {
        setState(() {
          _hasSecondModule = val;
          if (!val) {
            _module2Level = null;
            _module2Code = null;
          }
        });
      },
    );
  }

  // ─── Module 2 Dropdowns ──────────────────────────────────────
  Widget _buildModule2LevelDropdown() {
    return DropdownButtonFormField<String>(
      value: _module2Level,
      decoration: const InputDecoration(
        labelText: 'Academic Level (Module 2) *',
        prefixIcon: Icon(Icons.layers_outlined),
      ),
      hint: const Text('Select academic level'),
      items: AppConstants.academicLevels.map((level) {
        return DropdownMenuItem(value: level, child: Text(level));
      }).toList(),
      onChanged: (val) {
        setState(() {
          _module2Level = val;
          _module2Code = null;
        });
      },
      validator: _hasSecondModule
          ? (val) => val == null ? 'Please select a level for module 2' : null
          : null,
    );
  }

  Widget _buildModule2CodeDropdown() {
    final modules = _module2Level != null
        ? AppConstants.modulesByLevel[_module2Level!] ?? []
        : <String>[];

    return DropdownButtonFormField<String>(
      value: _module2Code,
      decoration: const InputDecoration(
        labelText: 'Module (Module 2) *',
        prefixIcon: Icon(Icons.menu_book_outlined),
      ),
      hint: Text(
          _module2Level == null ? 'Select a level first' : 'Select a module'),
      items: modules
          .where((m) => m != _module1Code)
          .map((code) => DropdownMenuItem(value: code, child: Text(code)))
          .toList(),
      onChanged: _module2Level == null
          ? null
          : (val) => setState(() => _module2Code = val),
      validator: _hasSecondModule
          ? (val) => val == null ? 'Please select a module' : null
          : null,
    );
  }

  // ─── Document Uploader ───────────────────────────────────────
  Widget _buildDocumentUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload proof of your academic results (PDF only)',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickDocument,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedFileName != null
                    ? AppTheme.approvedColor
                    : Colors.grey.shade400,
                width: 1.5,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(
                  _selectedFileName != null
                      ? Icons.check_circle_rounded
                      : Icons.upload_file_outlined,
                  color: _selectedFileName != null
                      ? AppTheme.approvedColor
                      : Colors.grey.shade500,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedFileName != null
                        ? _selectedFileName!
                        : _existingDocumentUrl != null
                            ? 'Document already uploaded (tap to replace)'
                            : 'Tap to select PDF document',
                    style: TextStyle(
                      color: _selectedFileName != null
                          ? AppTheme.approvedColor
                          : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Browse',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Eligibility Checkbox ────────────────────────────────────
  Widget _buildEligibilityCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _eligibilityConfirmed
            ? Colors.green.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _eligibilityConfirmed
              ? Colors.green.shade300
              : Colors.orange.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'I confirm that I meet the minimum eligibility requirements for the Student Assistant position.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            value: _eligibilityConfirmed,
            activeColor: AppTheme.primaryColor,
            onChanged: (val) =>
                setState(() => _eligibilityConfirmed = val ?? false),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 48),
            child: Text(
              'Note: Eligibility is verified by administrative staff. This confirmation does not guarantee approval.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
