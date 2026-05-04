# WaterWatch App - Setup & Installation Guide

## 📋 Prerequisites

- Flutter SDK 3.11.4 or higher
- Dart SDK (comes with Flutter)
- Firebase CLI installed
- Google account for Firebase Console access

## 🚀 Getting Started

### 1. Clone & Setup the Project

```bash
git clone <repository-url>
cd water_watch
flutter pub get
```

### 2. Firebase Configuration

#### a. Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Name it "WaterWatch"
4. Enable Google Analytics (optional)
5. Create the project

#### b. Add Firebase to Your App

**Using FlutterFire CLI (Recommended):**

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Run the configuration command
flutterfire configure
```

This will:
- Detect your Flutter platforms (Android, iOS, Web, etc.)
- Create Firebase apps for each platform
- Generate `firebase_options.dart` automatically

**Manual Configuration:**

1. In Firebase Console:
   - Go to Project Settings
   - Add Android app (package: `com.example.water_watch`)
   - Add iOS app (bundle ID: `com.example.waterWatch`)
   - Add Web app (if needed)
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

2. Update [firebase_options.dart](firebase_options.dart) with your credentials

#### c. Enable Firebase Services

In Firebase Console:
1. **Authentication**
   - Go to Authentication > Sign-in method
   - Enable "Email/Password"

2. **Cloud Firestore**
   - Go to Firestore Database
   - Create database in production mode
   - Use the security rules from [firestore.rules](firestore.rules)

3. **Cloud Messaging**
   - Go to Cloud Messaging
   - Copy Server Key (for sending notifications)

### 3. Configure Firestore Rules

1. In Firebase Console > Firestore Database > Rules tab
2. Replace with contents from [firestore.rules](firestore.rules)
3. Click "Publish"

### 4. Create Firestore Indexes (if needed)

If you get composite index errors while running the app:
1. Check the error message
2. Click the link in the error to create the index
3. Or manually create in Firebase Console > Firestore > Indexes

## 📱 Run the App

### Android
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

### Web
```bash
flutter run -d chrome
```

## 🔧 Project Structure

```
lib/
├── main.dart              # App entry point
├── firebase_options.dart  # Firebase configuration
├── models/               # Data models
│   ├── user_model.dart
│   ├── announcement_model.dart
│   └── read_status_model.dart
├── services/             # Firebase services
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── notification_service.dart
├── providers/            # State management
│   ├── auth_provider.dart
│   └── announcement_provider.dart
├── screens/              # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── client/
│   │   └── client_home_screen.dart
│   └── admin/
│       └── admin_dashboard_screen.dart
├── widgets/              # Reusable widgets
│   └── announcement_card.dart
├── theme/               # Theme configuration
│   └── app_theme.dart
└── utils/               # Constants and utilities
    └── constants.dart
```

## 🎨 Design System

- **Primary Color:** Light Blue (#4DA8DA)
- **Background:** Light Gray (#FAFAFA)
- **Surface:** White (#FFFFFF)
- **Text:** Dark Gray (#212121)

## 📊 Database Structure

### Firestore Collections

**users**
```
{
  userId: string,
  name: string,
  email: string,
  role: 'admin' | 'client',
  area: string (optional),
  createdAt: timestamp
}
```

**announcements**
```
{
  id: string,
  title: string,
  description: string,
  area: string,
  startTime: timestamp,
  endTime: timestamp,
  createdBy: string (userId),
  createdAt: timestamp,
  isActive: boolean
}
```

**read_status**
```
{
  id: string (userId-announcementId),
  userId: string,
  announcementId: string,
  isRead: boolean,
  readAt: timestamp
}
```

## 🔐 User Roles

### Admin
- Create, edit, delete announcements
- Send push notifications
- View analytics dashboard
- Tag announcements by area

### Client
- View announcements in real-time
- Filter announcements by area
- Receive push notifications
- Mark announcements as read

## ✨ Features

- ✅ Firebase Authentication (Email/Password)
- ✅ Real-time Firestore updates
- ✅ Push notifications with FCM
- ✅ Area-based filtering
- ✅ Search functionality
- ✅ Admin dashboard with analytics
- ✅ Read/unread status tracking
- ✅ Automatic cleanup of old announcements (30+ days)
- ✅ Minimalist UI design
- ✅ Offline persistence (Firestore enabled)

## 🚨 Troubleshooting

### Firebase initialization error
- Ensure `firebase_options.dart` has correct credentials
- Run `flutterfire configure` again

### Firestore permission denied errors
- Check that security rules are correctly deployed
- Ensure user is authenticated before accessing Firestore

### Push notifications not working
- Enable Firebase Cloud Messaging
- Check app manifest (Android) and configuration (iOS)
- Ensure device has internet connection

### Cold start issues
- Enable Firestore offline persistence
- Pre-warm Firebase connection

## 📝 Environment Setup

### Android Setup
1. Minimum SDK: 21
2. Target SDK: 34
3. Add `google-services.json` to `android/app/`

### iOS Setup
1. Minimum iOS: 11.0
2. Add `GoogleService-Info.plist` to Xcode project
3. Enable Push Notifications capability

## 🔄 Auto-Cleanup Task

The app includes an automatic cleanup function that removes announcements older than 30 days. This can be:
- Manually triggered from admin dashboard
- Configured as a scheduled Cloud Function (optional)

## 🧪 Testing

### Test Admin Account
```
Email: admin@test.com
Password: Test123456
Role: Admin
```

### Test Client Account
```
Email: client@test.com
Password: Test123456
Role: Client
Area: Binuangan
```

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Cloud Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)

## 🤝 Support

For issues or questions:
1. Check Firebase Console for errors
2. Enable verbose logging: `flutter run -v`
3. Review Firestore/Auth error messages
4. Check Flutter/Firebase documentation

## 📄 License

This project is licensed under the MIT License.
