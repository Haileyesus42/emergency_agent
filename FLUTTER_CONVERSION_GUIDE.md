# Emergency App Flutter Conversion - Quick Start Guide

## ✅ Completed Conversion

The entire HTML frontend has been successfully converted to Flutter!

### What Was Converted

**From HTML/CSS/JS:**
- `frontend/index.html` → Login page
- `frontend/profile.html` → Profile management screen
- `frontend/contacts.html` → Contacts management screen
- `frontend/app.js` → JavaScript API integration
- `frontend/style.css` → Web styling

**To Flutter/Dart:**
- `lib/screens/login_screen.dart` → Login screen with Material Design
- `lib/screens/profile_screen.dart` → Profile form with sections
- `lib/screens/contacts_screen.dart` → Contacts list and editor
- `lib/screens/home_screen.dart` → Main container with tabs
- `lib/services/api_service.dart` → API service with Provider
- `lib/models/` → Type-safe data models
- `lib/main.dart` → App entry point with theme

## 🚀 Run the App

### 1. Check Prerequisites
```bash
flutter doctor
```

Fix any issues shown in the output.

### 2. Install Dependencies
```bash
cd emergency_app
flutter pub get
```

### 3. Connect a Device
Connect an Android/iOS device or start an emulator.

```bash
flutter devices
```

### 4. Run the App
```bash
flutter run
```

Or specify a device:
```bash
flutter run -d <device-id>
```

### 5. For Web Version
```bash
flutter run -d chrome
```

## 📱 Testing the App

### Test Login
1. Launch the app
2. Use demo credentials:
   - Username: `haile` / Password: `1234`
   - Username: `traveler1` / Password: `1234`
3. You should see the home screen with Profile tab

### Test Profile Screen
1. Fill in profile fields (full name, address, phone, etc.)
2. Click "Save Changes"
3. You should see a success SnackBar

### Test Contacts Screen
1. Switch to "Contacts" tab
2. View current contacts list
3. Edit contact information
4. Click "Save Changes"
5. Verify updates are saved

### Test Emergency SOS
1. Click the warning icon (🚨) in the top-right corner
2. Confirm the SOS action
3. Trigger should be sent to backend webhook

### Test Logout
1. Click "Logout" tab
2. Confirm logout
3. Should return to login screen

## 🔧 Development Tips

### Hot Reload
When running `flutter run`, just save your files and changes appear instantly!

```
Press 'r' for hot reload
Press 'R' for hot restart
Press 'q' to quit
```

### Code Analysis
Check for errors before running:
```bash
flutter analyze
```

Format code automatically:
```bash
flutter format
```

### Debug Logging
Add print statements or use the Dart debugger in VS Code/Android Studio.

## 🛠️ Customization

### Change API URL
Edit `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'http://your-production-api.com';
```

### Customize Theme
Edit theme in `lib/main.dart`:
```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF667eea), // Change this color
  ),
)
```

### Add New Screens
1. Create file in `lib/screens/`
2. Add route in `lib/main.dart`
3. Import and navigate from existing screens

## 📦 Build for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
```

### iOS (requires Mac)
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Desktop (Windows/Linux/macOS)
```bash
flutter build windows --release
flutter build linux --release
flutter build macos --release
```

## 🐛 Troubleshooting

### Issue: Cannot connect to backend
- Check that backend is running on port 8000
- Verify API base URL in `lib/config/api_config.dart`
- Check CORS settings on backend if testing on web

### Issue: Token storage errors
- Clear secure storage manually by reinstalling the app
- Check platform-specific storage permissions

### Issue: Form validation not working
- Ensure validators are properly formatted
- Check FormKey is correctly assigned

### Issue: Provider errors
- Make sure ApiService is provided at root level in main.dart
- Use `listen: false` when accessing Provider without rebuild

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Widget Catalog](https://flutter.dev/docs/development/ui/widgets)
- [Dart Language Tours](https://dart.dev/guides/language/language-tour)

## 🎯 Next Steps

1. Run the app and verify all screens work
2. Test with your backend API
3. Customize colors/themes to match branding
4. Add additional features as needed
5. Build and deploy to production

## 📞 Support

For issues or questions:
- Check the README.md in the project root
- Review the Flutter documentation
- Check backend API endpoints are responding correctly

---

**Happy Coding! 🚀**
