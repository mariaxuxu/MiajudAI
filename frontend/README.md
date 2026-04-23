# MiAjudAI Flutter App

Flutter mobile application for MiAjudAI - Intelligent Support App for people living alone.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- Firebase project
- Android SDK (for Android development)
- Xcode (for iOS development - optional)

### Installation

1. **Get Flutter dependencies**
```bash
cd frontend
flutter pub get
```

2. **Configure Firebase**
- Create a Firebase project at https://firebase.google.com
- Enable Authentication (Google/Apple)
- Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Place files in appropriate directories:
  - Android: `android/app/`
  - iOS: `ios/Runner/`

3. **Configure environment**
```bash
cp .env.example .env
```

Edit `.env` with your Firebase credentials:
- `FIREBASE_PROJECT_ID`
- `FIREBASE_WEB_API_KEY`
- `API_BASE_URL` (backend API URL)

4. **Run on emulator/device**
```bash
flutter run -v
```

---

## 📁 Project Structure

```
frontend/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── config/
│   │   ├── constants.dart        # Colors, sizes, strings
│   │   ├── routes.dart           # Navigation routes
│   │   └── firebase_config.dart  # Firebase initialization
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   └── auth/                 # Auth screens (Épico 2)
│   │       ├── login_screen.dart
│   │       ├── signup_screen.dart
│   │       └── onboarding_screen.dart
│   ├── widgets/
│   │   ├── common/               # Reusable widgets
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_textfield.dart
│   │   │   └── loading_widget.dart
│   │   ├── dashboard/            # Home dashboard widgets
│   │   └── chat/                 # Chat widgets
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── event_model.dart
│   │   ├── transaction_model.dart
│   │   └── message_model.dart
│   ├── services/
│   │   ├── api_service.dart      # HTTP client
│   │   ├── auth_service.dart     # Firebase auth
│   │   ├── user_service.dart     # User API calls
│   │   └── notification_service.dart
│   ├── providers/
│   │   ├── auth_provider.dart    # Auth state management
│   │   ├── user_provider.dart    # User data
│   │   └── chat_provider.dart    # Chat state
│   ├── utils/
│   │   ├── validators.dart       # Form validation
│   │   ├── app_colors.dart       # Color palette
│   │   └── formatters.dart       # Data formatters
│   └── l10n/
│       └── app_pt.arb            # Portuguese localization
├── android/                      # Android native code
├── ios/                          # iOS native code
├── test/                         # Unit & Widget tests
├── pubspec.yaml                  # Dependencies
├── .env.example                  # Environment template
└── README.md
```

---

## 📚 Available Commands

| Command | Purpose |
|---------|---------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run on emulator/device |
| `flutter run -v` | Run with verbose output |
| `flutter test` | Run all tests |
| `flutter build apk` | Build Android APK |
| `flutter build ios` | Build iOS app |
| `flutter clean` | Clean build files |
| `flutter analyze` | Analyze code |
| `flutter format lib/` | Format code |

---

## 🔐 Firebase Setup

### 1. Create Firebase Project
- Go to https://firebase.google.com
- Create a new project
- Enable Realtime Database (optional)

### 2. Setup Authentication
- Firebase Console > Authentication > Sign-in method
- Enable Google (required)
- Enable Apple (optional)
- Enable Email/Password (optional)

### 3. Get Configuration Files

**For Android:**
- Firebase Console > Project Settings > google-services.json
- Place in `android/app/google-services.json`

**For iOS:**
- Firebase Console > Project Settings > GoogleService-Info.plist
- Place in `ios/Runner/GoogleService-Info.plist`

### 4. Update Configuration
Edit `lib/config/firebase_config.dart` with your project values:
```dart
FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'miajudai-dev',
)
```

---

## 🎨 Design System

### Colors
- **Primary**: `#14746F` (Teal)
- **Secondary**: `#56AB91` (Green)
- **Accent**: `#FFB84D` (Amber)

See `lib/config/constants.dart` for complete palette.

### Typography
- **Display**: 32px bold
- **Headline**: 20-24px semi-bold
- **Body**: 14px regular
- **Caption**: 12px regular

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/screens/splash_screen_test.dart

# Generate coverage report
flutter test --coverage
```

---

## 📋 Épicos

### ✅ Épico 1: Setup Inicial (Sprint 1)
- [x] Flutter project structure
- [x] Pubspec.yaml with dependencies
- [x] Firebase configuration
- [x] Splash screen
- [x] Theme and constants
- [x] Basic routing

### 🔄 Épico 2: Autenticação (Sprints 2-3)
- [ ] Login screen with Google OAuth
- [ ] Signup screen
- [ ] Onboarding flow
- [ ] Emergency contact form
- [ ] Preferences configuration
- [ ] Authentication persistence

### 📅 Épico 3: Core Features (Sprints 4-6)
- [ ] Home dashboard
- [ ] Calendar screen
- [ ] Finance tracking
- [ ] Expense charts

### 💬 Épico 5: Chat with LLM (Sprints 7-9)
- [ ] Chat screen
- [ ] Agent selection
- [ ] Message history

---

## 🐛 Troubleshooting

### Firebase Connection Error
- Verify Firebase configuration files are in correct location
- Check `google-services.json` has correct project ID
- Ensure Firebase APIs are enabled

### Build Issues
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Emulator Issues
```bash
# List available emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch <emulator_id>
```

---

## 🤝 Contributing

1. Create feature branch: `git checkout -b feature/xxx`
2. Commit changes: `git commit -am 'Add feature'`
3. Push to branch: `git push origin feature/xxx`
4. Create Pull Request

---

## 📄 License

MIT

---

**Last Updated**: 2026-04-20
**Status**: Épico 1 - Setup Complete
