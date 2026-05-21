# Emergency Agent Flutter App

Complete Flutter conversion of the HTML frontend for the Umojee Emergency Management System.

## 🎯 Features

### Screens Implemented
1. **Login Screen** - User authentication with demo accounts
2. **Home Screen** - Main container with navigation tabs
3. **Profile Screen** - User profile management
4. **Contacts Screen** - Emergency contacts management

### Key Features
- ✅ Material 3 design matching web frontend
- ✅ Secure token storage (flutter_secure_storage)
- ✅ Pull-to-refresh on all data screens
- ✅ Form validation with error feedback
- ✅ Loading states with progress indicators
- ✅ Success/error notifications (SnackBar)
- ✅ Emergency SOS button with confirmation
- ✅ Tab-based navigation
- ✅ Responsive layout

## 📦 Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  http: ^1.1.0                          # API calls
  flutter_secure_storage: ^9.0.0       # Secure token storage
  provider: ^6.1.1                     # State management
  google_fonts: ^6.1.0                 # Typography
  url_launcher: ^6.2.0                 # External links
  geolocator: ^10.1.0                  # Location services
  geocoding: ^2.1.1                    # Address lookup
  cupertino_icons: ^1.0.2             # iOS icons
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Android Studio / VS Code with Flutter extensions
- Android SDK / iOS SDK for emulator

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd emergency_agent/emergency_app
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
# For connected device or emulator
flutter run

# For web
flutter run -d chrome

# For Android APK
flutter build apk --release

# For iOS
flutter build ios --release
```

## 📱 Demo Accounts

- **User 1:** haile / 1234
- **User 2:** traveler1 / 1234

## 🎨 Design System

### Color Palette
- Primary: `#667eea` (Purple blue)
- Secondary: `#764ba2` (Purple)
- Success: `#10b981` (Green)
- Error: `#ef4444` (Red)

### Typography
- Font Family: Inter
- Heading sizes: 17px - 24px
- Body text: 11px - 14px
- Labels: 10px - 12px

## 🏗️ Project Structure

```
lib/
├── main.dart                       # App entry point & routing
├── config/
│   └── api_config.dart            # API configuration
├── models/
│   ├── user_model.dart            # User data model
│   └── contact_model.dart         # Contact data model
├── services/
│   └── api_service.dart           # API service layer (ChangeNotifier)
└── screens/
    ├── login_screen.dart          # Login UI
    ├── home_screen.dart           # Main container with tabs
    ├── profile_screen.dart        # Profile form
    └── contacts_screen.dart       # Contacts list & forms
```

## 🔧 Configuration

### API Configuration
Edit `lib/config/api_config.dart` to change the base URL:

```dart
class ApiConfig {
  static const String baseUrl = 'http://your-backend-url';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
```

### Backend Integration
The app integrates with the FastAPI backend at:
- `/auth/login` - User authentication
- `/user/profile` - Profile management
- `/user/emergency-contacts/` - Contact management
- `/emergency/webhook` - Emergency SOS trigger

## 🔄 State Management

Uses the **Provider** pattern with `ChangeNotifier`:
- `ApiService` manages all API state
- Access via `Provider.of<ApiService>(context, listen: false)`
- Automatic UI updates on state changes

## 🔐 Security Features

- Secure token storage using platform-native keychain/keystore
- No hardcoded credentials
- Session management with automatic logout
- HTTPS support for API calls

## 🐛 Debugging

Enable verbose logging:
```bash
flutter run --verbose
```

Check for issues:
```bash
flutter analyze
flutter doctor
```

## 📊 Build Commands

| Platform | Command |
|----------|---------|
| Android APK | `flutter build apk --release` |
| Android App Bundle | `flutter build appbundle --release` |
| iOS | `flutter build ios --release` |
| Web | `flutter build web --release` |
| Linux | `flutter build linux --release` |
| Windows | `flutter build windows --release` |
| macOS | `flutter build macos --release` |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Icons from [Cupertino Icons](https://api.flutter.dev/flutter/cupertino/CupertinoIcons-class.html)
- Fonts from [Google Fonts](https://fonts.google.com/)
