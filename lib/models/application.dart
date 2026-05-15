/**
 * Student Numbers: XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX
 * Student Names  : [Group Member Names Here]
 * Question: Application Model
 */

// ============================================================
// models/application.dart
// Represents a Student Assistant Application (data layer)
// ============================================================

class Application {
  final String? id;
  final String studentId;
  final String studentName;
  final String studentNumber;
  final int yearOfStudy;

  // Module 1 (required)
  final String module1Level;
  final String module1Code;

  // Module 2 (optional)
  final bool hasSecondModule;
  final String? module2Level;
  final String? module2Code;

  // Eligibility & documents
  final bool eligibilityConfirmed;
  final String? documentUrl;

  // Status managed by admin
  final String status; // 'pending' | 'approved' | 'rejected'

  final DateTime? createdAt;

  const Application({
    this.id,
    required this.studentId,
    required this.studentName,
    required this.studentNumber,
    required this.yearOfStudy,
    required this.module1Level,
    required this.module1Code,
    this.hasSecondModule = false,
    this.module2Level,
    this.module2Code,
    required this.eligibilityConfirmed,
    this.documentUrl,
    this.status = 'pending',
    this.createdAt,
  });

  /// Creates an Application from a Supabase JSON map
  factory Application.fromMap(Map<String, dynamic> map) {
    return Application(
      id: map['id'] as String?,
      studentId: map['student_id'] as String,
      studentName: map['student_name'] as String? ?? 'Unknown',
      studentNumber: map['student_number'] as String? ?? 'N/A',
      yearOfStudy: map['year_of_study'] as int,
      module1Level: map['module1_level'] as String,
      module1Code: map['module1_code'] as String,
      hasSecondModule: map['has_second_module'] as bool? ?? false,
      module2Level: map['module2_level'] as String?,
      module2Code: map['module2_code'] as String?,
      eligibilityConfirmed: map['eligibility_confirmed'] as bool? ?? false,
      documentUrl: map['document_url'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  /// Converts Application to a map for Supabase insert/update
  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'student_number': studentNumber,
      'year_of_study': yearOfStudy,
      'module1_level': module1Level,
      'module1_code': module1Code,
      'has_second_module': hasSecondModule,
      'module2_level': hasSecondModule ? module2Level : null,
      'module2_code': hasSecondModule ? module2Code : null,
      'eligibility_confirmed': eligibilityConfirmed,
      'document_url': documentUrl,
      'status': status,
    };
  }

  /// Creates a copy of this Application with updated fields
  Application copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? studentNumber,
    int? yearOfStudy,
    String? module1Level,
    String? module1Code,
    bool? hasSecondModule,
    String? module2Level,
    String? module2Code,
    bool? eligibilityConfirmed,
    String? documentUrl,
    String? status,
    DateTime? createdAt,
  }) {
    return Application(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentNumber: studentNumber ?? this.studentNumber,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      module1Level: module1Level ?? this.module1Level,
      module1Code: module1Code ?? this.module1Code,
      hasSecondModule: hasSecondModule ?? this.hasSecondModule,
      module2Level: module2Level ?? this.module2Level,
      module2Code: module2Code ?? this.module2Code,
      eligibilityConfirmed: eligibilityConfirmed ?? this.eligibilityConfirmed,
      documentUrl: documentUrl ?? this.documentUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
