# WaterWatch - Water Interruption Announcement App

A **Flutter mobile application** that enables administrators to post water interruption announcements and allows clients to receive real-time updates via push notifications.

## 🎯 Key Features

### 🔹 Admin Features
- Create, edit, and delete water interruption announcements
- Tag announcements by area/location
- Send push notifications to all users or specific areas
- View admin dashboard with analytics
- Statistics: total announcements, active users, announcements per area

### 🔹 Client Features
- View water interruption announcements in real-time
- Filter announcements by area
- Receive instant push notifications
- Mark announcements as read/unread
- Search announcements by keyword
- Pull-to-refresh for latest updates

### 🔹 General Features
- Firebase Authentication (Email/Password login)
- Real-time Firestore database synchronization
- Firebase Cloud Messaging (FCM) for push notifications
- Minimalist UI with light blue color scheme
- Offline support with Firestore persistence
- Automatic cleanup of old announcements (30+ days)
- Dark mode support (optional)
- Area-based notification subscriptions

## 📱 Screens

1. **Login/Register Screen** - User authentication with role selection
2. **Client Home Screen** - Real-time announcement list with filters and search
3. **Admin Dashboard** - Create/manage announcements and view stats
4. **Create/Edit Announcement** - Full-featured announcement editor with date/time pickers
5. **Announcement Details** - Detailed view of individual announcements

## 🎨 Design

- **Style:** Minimalist and clean
- **Primary Color:** Light Blue (#4DA8DA)
- **Background:** White (#FFFFFF) / Light Gray (#FAFAFA)
- **Typography:** Clear and readable hierarchy
- **Spacing:** Generous white space for visual clarity

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
├── services/                 # Firebase services
├── providers/                # Provider state management
├── screens/                  # UI screens
├── widgets/                  # Reusable widgets
├── theme/                    # Theme configuration
└── utils/                    # Constants and utilities
```

### Technologies Used
- **Framework:** Flutter (latest stable)
- **State Management:** Provider
- **Backend:** Firebase
  - Authentication
  - Cloud Firestore
  - Cloud Messaging (FCM)
  - Storage (optional)
- **Database:** Firestore (NoSQL)

## 🗂️ Firestore Collections

### users
```json
{
  "userId": "string",
  "name": "string",
  "email": "string",
  "role": "admin|client",
  "area": "string (optional)",
  "createdAt": "timestamp"
}
```

### announcements
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "area": "string",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "createdBy": "string (adminId)",
  "createdAt": "timestamp",
  "isActive": "boolean"
}
```

### read_status
```json
{
  "id": "string (userId-announcementId)",
  "userId": "string",
  "announcementId": "string",
  "isRead": "boolean",
  "readAt": "timestamp"
}
```

## 🔐 Security

- **Authentication:** Firebase Email/Password auth with role-based access
- **Firestore Rules:** Implemented security rules restrict:
  - Admins can create/edit/delete announcements
  - Clients can only read announcements
  - Users can only access their own data
  - Public read access to announcements

## 🚀 Getting Started

### Prerequisites
- Flutter 3.11.4+
- Firebase CLI
- Google account

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd water_watch
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Run configuration
   flutterfire configure
   ```

4. **Set up Firestore rules**
   - Copy rules from `firestore.rules` to Firebase Console

5. **Run the app**
   ```bash
   flutter run
   ```

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed setup instructions.

## 📊 Dashboard Analytics

The admin dashboard displays:
- Total announcements count
- Active announcements (currently ongoing)
- User statistics
- Quick access to create new announcements

## 🔔 Notifications

- **Topic-based:** Notifications sent to area-specific topics
- **Real-time:** Instant delivery via FCM
- **Persistent:** Notifications survive app closure
- **Customizable:** Include title, message, and timestamp

## 🧹 Auto-Cleanup

Announcements older than 30 days are automatically removed from the database to:
- Minimize storage usage
- Keep database lean and performant
- Prevent data bloat

## 🌙 Dark Mode

The app includes dark mode support with the same minimalist aesthetic inverted for reduced eye strain.

## 📈 Future Enhancements

- [ ] User report interruptions feature
- [ ] Admin approval system for reports
- [ ] Map view for announcements
- [ ] Advanced analytics dashboard
- [ ] Email notifications
- [ ] SMS notifications
- [ ] Multiple language support
- [ ] Offline announcement sync

## 🤝 Contributing

Contributions are welcome! Please follow the existing code style and submit pull requests.

## 📝 License

This project is licensed under the MIT License.

## 📞 Support

For issues or questions:
1. Check the [SETUP_GUIDE.md](SETUP_GUIDE.md)
2. Review Firebase Console logs
3. Enable verbose mode: `flutter run -v`

## 🎯 Project Status

✅ **Completed Features:**
- Authentication system
- Real-time announcements
- Admin dashboard
- FCM integration
- Firestore integration
- Search and filtering
- Read/unread tracking
- Auto-cleanup

🔄 **In Progress:**
- Mobile optimization
- Testing suite
- Performance optimization

---

**Built with ❤️ using Flutter and Firebase**
