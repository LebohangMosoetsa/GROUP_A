# Student Assistant Application System
## TPG316C — Technical Programming III | Group Assignment

---

## Project Overview

A Flutter mobile application that allows students to apply for Student Assistant positions within the IT Department. Administrative staff can review, approve, or reject applications through a secure admin portal.

**Tech Stack:** Flutter • Dart • Provider (MVVM) • GoRouter • Supabase

---

## Group Members

| Full Name | Student Number | Contribution |
|-----------|---------------|--------------|
| [Name 1]  | XXXXXXXXX     | [e.g. Auth + Login Screen] |
| [Name 2]  | XXXXXXXXX     | [e.g. Application Form] |
| Andiswa   | 223023603     | [e.g. Admin Dashboard] |
| [Name 4]  | XXXXXXXXX     | [e.g. Models + ViewModels] |
| [Name 5]  | XXXXXXXXX     | [e.g. Routing + Documentation] |

---

## Project Structure (MVVM Architecture)

```
lib/
├── models/                  ← Data layer (plain Dart classes)
│   ├── app_user.dart        ← User profile model
│   └── application.dart     ← Student Assistant application model
│
├── viewmodels/              ← Business logic layer (ChangeNotifier)
│   ├── auth_viewmodel.dart          ← Login, logout, user state
│   └── application_viewmodel.dart   ← CRUD operations on applications
│
├── views/                   ← UI layer (widgets that watch ViewModels)
│   ├── auth/
│   │   └── login_screen.dart        ← Shared login for all users
│   ├── student/
│   │   ├── student_home_screen.dart       ← Student dashboard (READ)
│   │   ├── application_form_screen.dart   ← Submit/edit form (CREATE/UPDATE)
│   │   └── application_detail_screen.dart ← Details + delete (READ/DELETE)
│   └── admin/
│       └── admin_dashboard_screen.dart    ← Admin portal (READ/UPDATE/DELETE)
│
├── utils/
│   └── app_constants.dart   ← Supabase config, theme, shared widgets
│
└── main.dart                ← App entry point, Provider + GoRouter setup
```

---

## Setup Instructions

### Step 1 — Flutter Environment

Ensure Flutter is installed and set up:
```bash
flutter doctor
```

### Step 2 — Clone & Install Dependencies

```bash
git clone <your-github-repo-url>
cd student_assistant_app
flutter pub get
```

### Step 3 — Supabase Project Setup

1. Go to [https://supabase.com](https://supabase.com) and create a new project.
2. Open the **SQL Editor** in your Supabase dashboard.
3. Paste the entire contents of `supabase_setup.sql` and click **Run**.
4. Go to **Storage** → create a bucket named `application-documents` (set to Public).

### Step 4 — Configure Supabase Credentials

Open `lib/utils/app_constants.dart` and replace the placeholder values:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

Find these in your Supabase dashboard under **Settings → API**.

### Step 5 — Create Test Users

In your Supabase Dashboard → **Authentication → Users**, create users manually:

**Student user:**
- Email: `student@cut.ac.za`
- Password: `student123`
- After creation, set `full_name` and `student_number` in the profiles table.

**Admin user:**
- Email: `admin@cut.ac.za`
- Password: `admin123`
- After creation, run this in the SQL Editor:
  ```sql
  UPDATE public.profiles SET role = 'admin' WHERE email = 'admin@cut.ac.za';
  ```

### Step 6 — Run the App

```bash
flutter run
```

### Step 7 — Before Submission (reduce file size)

```bash
flutter clean
```
Then zip the project folder.

---

## GitHub Commit Guidelines

Each member must commit their own work. Use meaningful commit messages:
```
git add .
git commit -m "feat: implement application form validation"
git push origin main
```

---

## Concepts Applied (Units 1–5)

| Concept | Where Applied |
|---------|--------------|
| Flutter Widgets & UI | All screens — StatelessWidget, StatefulWidget |
| setState() limitations (Unit 2) | Explained in comments; replaced with Provider |
| MVVM Architecture (Unit 2) | models/ viewmodels/ views/ folder structure |
| ChangeNotifier + Provider (Unit 2) | AuthViewModel, ApplicationViewModel |
| context.watch() / context.read() (Unit 2) | All views — watch for display, read for actions |
| GoRouter Navigation (Unit 3) | main.dart — named routes with redirect guards |
| Form handling & validation (Unit 4) | application_form_screen.dart |
| Supabase Authentication (Unit 5) | auth_viewmodel.dart — signInWithPassword |
| Supabase CRUD (Unit 5) | application_viewmodel.dart — all operations |
| Row Level Security (Unit 5) | supabase_setup.sql — data isolation per user |
| File Storage (Unit 5) | uploadDocument() — Supabase Storage bucket |
