# Student Application Management System — GROUP_A2
# Technical Programming III (TPG316C)

# Group Members
# StudentNo Name        Contribution
220024412   MP Lephole  Developed application.dart — Application model class and Supabase CRUD operations
223064473   LM Mosoetsa Initial project setup — Flutter scaffolding, Supabase configuration, GitHub repo initialisation
220031298   NA Pesa     Developed login_screen.dart — Login UI, form validation and Supabase authentication
221003431   D Hlalele   Developed app_user.dart — User model class and user role/session handling
223023603   A Mbonambi  Developed admin_dashboard_screen.dart — Admin UI, application listing and navigation, did documentation file and edited supporting files where necessary

# Project Overview
The Student Application Management System is a cross-platform Flutter application that allows students to submit and track applications and administrators to review and manage them. The backend is powered by Supabase for authentication and database operations.

# Features
Supabase authentication (login & registration)
Student dashboard — submit and track applications
Admin dashboard — view and manage all applications
Form validation and error handling
Real-time data updates via Supabase


# Architecture
The application follows the MVVM (Model-View-ViewModel) pattern with Provider for state management.
lib/
├── models/
│   ├── app_user.dart               # User model 
│   └── application.dart            # Application model 
├── viewmodels/
│   ├── auth_viewmodel.dart         # Auth state management
│   └── application_viewmodel.dart  # Application state management
├── views/
│   ├── login_screen.dart           # Login UI 
│   ├── student/
│   │   ├── student_home_screen.dart
│   │   ├── application_form_screen.dart
│   │   └── application_detail_screen.dart
│   └── admin/
│       └── admin_dashboard_screen.dart  # Admin UI 
└── main.dart

# Concepts Applied (Units 1–5)
Unit Concept Implementation Unit 1 UI Design Flutter widgets, responsive layoutsUnit 2MVVM & ProviderChangeNotifier, Consumer, ChangeNotifierProvider Unit 3 Routing & NavigationNamed routes, role-based navigationUnit 4 Form Handling & ValidationForm, GlobalKey, validator callbacks Unit 5 Supabase Auth & CRUD signIn, signUp, select, insert, update, delete

# Getting Started
# Prerequisites
Flutter SDK installed
Supabase project set up

Run the app
bash flutter pub get
flutter run

# Repository
https://github.com/LebohangMosoetsa/GROUP_A.git

# Submission
Zipped project folder: GROUP_A.zip
GitHub repository link
PDF documentation submitted via Blackboard(ethuto)
