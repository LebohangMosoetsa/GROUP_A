/** 
 * Studnet Numbers: 221003431, 223023603, 223064473, 220031298, 220024412
 * Student Names: D Hlalele, A Mbonambi, LM Mosoetsa, NA Pesa, MP Lephole
 * Question: AppUser Models
 */

//==============================================================================
//model/app_user.dart
//Represents a system user (student or admin)
//==============================================================================

class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String studentNumber;
  final String role; //'student'| 'admin'

  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.studentNumber,
    required this.role,
  });

  bool get isAdmin => role == 'admin';
  bool get isStudent => role == 'student';

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      fullName: map['full_name'] as String? ?? 'Unknown',
      studentNumber: map['student_number'] as String? ?? 'N/A',
      role: map['role'] as String? ?? 'student',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'emal': email,
      'full_name': fullName,
      'student_number': studentNumber,
      'role': role,
    };
  }
}
