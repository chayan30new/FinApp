# 🚀 QUICK START GUIDE

## ⚡ Installation Steps (First Time Setup)

### Step 1: Install Flutter SDK

1. **Download Flutter**
   - Visit: https://docs.flutter.dev/get-started/install/windows
   - Download the latest stable release ZIP file

2. **Extract Flutter**
   ```
   Extract to: C:\src\flutter
   (Avoid C:\Program Files\ - may cause permission issues)
   ```

3. **Update System PATH**
   - Press `Win + X` → Select "System"
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - Under "User variables", find "Path" and click "Edit"
   - Click "New" and add: `C:\src\flutter\bin`
   - Click "OK" on all dialogs

4. **Verify Installation**
   ```powershell
   # Open NEW PowerShell window (to reload PATH)
   flutter --version
   ```

### Step 2: Install Required Tools

1. **Install Git** (if not already installed)
   - Download: https://git-scm.com/download/win
   - Install with default settings

2. **Install Android Studio**
   - Download: https://developer.android.com/studio
   - Install with default settings
   - During setup, ensure these are checked:
     - Android SDK
     - Android SDK Platform
     - Android Virtual Device

3. **Accept Android Licenses**
   ```powershell
   flutter doctor --android-licenses
   # Type 'y' to accept all licenses
   ```

4. **Verify Setup**
   ```powershell
   flutter doctor
   ```
   You should see checkmarks (✓) for most items.

### Step 3: Set Up the Project

1. **Navigate to Project Directory**
   ```powershell
   cd "C:\Users\cagarwal\OneDrive - Amadeus Workplace\Desktop\FinanceApp"
   ```

2. **Get Dependencies**
   ```powershell
   flutter pub get
   ```
   This downloads all required packages (takes 1-2 minutes first time).

3. **Verify Project**
   ```powershell
   flutter analyze
   ```
   Should show no issues.

### Step 4: Run the App

#### Option A: Using Android Emulator (Recommended)

1. **Create Android Virtual Device**
   ```powershell
   # Open Android Studio
   # Tools → Device Manager → Create Device
   # Select: Pixel 4 (or any phone)
   # System Image: Latest Android (API 33 or higher)
   # Finish
   ```

2. **Start Emulator**
   - In Android Studio: Device Manager → Click ▶️ Play button
   - Or from command line:
   ```powershell
   flutter emulators
   flutter emulators --launch <emulator_id>
   ```

3. **Run App**
   ```powershell
   flutter run
   ```

#### Option B: Using Chrome (Web - Quick Test)

```powershell
flutter run -d chrome
```

#### Option C: Using Physical Android Device

1. **Enable Developer Options on Phone**
   - Settings → About Phone
   - Tap "Build Number" 7 times
   
2. **Enable USB Debugging**
   - Settings → Developer Options
   - Turn on "USB Debugging"

3. **Connect Phone & Run**
   ```powershell
   flutter devices  # Verify phone is detected
   flutter run
   ```

## 🎯 Common Commands

```powershell
# Install dependencies
flutter pub get

# Run app in debug mode
flutter run

# Run app on specific device
flutter run -d chrome
flutter run -d windows
flutter run -d <device_id>

# List available devices
flutter devices

# Build release APK (Android)
flutter build apk --release

# Build app bundle (for Play Store)
flutter build appbundle

# Clean build files
flutter clean

# Check for issues
flutter doctor
flutter analyze

# Run tests
flutter test

# Hot reload (while app is running)
# Press 'r' in terminal

# Hot restart (while app is running)
# Press 'R' in terminal

# Quit running app
# Press 'q' in terminal
```

## 🎨 Using VS Code

### Install Extensions (Already Done!)
- ✅ Flutter
- ✅ Dart

### Debug in VS Code

1. **Open Project in VS Code**
   ```powershell
   code .
   ```

2. **Start Debugging**
   - Press `F5`
   - Or: Run → Start Debugging
   - Select device when prompted

3. **Hot Reload While Debugging**
   - Save any file (Ctrl+S) → Auto hot reload
   - Or: Click ⚡ icon in debug toolbar

### Useful VS Code Shortcuts

| Action | Shortcut |
|--------|----------|
| Quick Fix | `Ctrl + .` |
| Format Document | `Shift + Alt + F` |
| Show Widget Tree | `Ctrl + Shift + P` → "Flutter: Open Widget Inspector" |
| Organize Imports | `Shift + Alt + O` |
| Go to Definition | `F12` |
| Rename Symbol | `F2` |

## 🐛 Troubleshooting

### Issue: "Flutter command not found"
**Solution**: 
- Add Flutter to PATH (see Step 1.3)
- Restart terminal/VS Code
- Open NEW terminal window

### Issue: "Android licenses not accepted"
**Solution**:
```powershell
flutter doctor --android-licenses
# Press 'y' for each license
```

### Issue: "No devices found"
**Solutions**:
- Start an emulator first
- Or connect physical device with USB debugging
- Or use Chrome: `flutter run -d chrome`

### Issue: "Version solving failed"
**Solution**:
```powershell
flutter clean
flutter pub get
```

### Issue: "Gradle build failed"
**Solution**:
```powershell
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: App builds but crashes immediately
**Solution**:
- Check logs: `flutter logs`
- Ensure minimum Android SDK version is met
- Clear app data on device/emulator

### Issue: Hot reload not working
**Solution**:
- Do full restart: Press 'R' in terminal
- Or restart app: `flutter run`

## 📖 Next Steps

1. **Explore the Code**
   - `lib/main.dart` - App entry point
   - `lib/screens/` - UI screens
   - `lib/utils/calculations.dart` - XIRR/CAGR logic

2. **Customize the App**
   - Change app name in `pubspec.yaml`
   - Update app icon
   - Modify color scheme in `main.dart`

3. **Read Documentation**
   - `APP_SUMMARY.md` - Complete feature overview
   - `USER_GUIDE.md` - How to use the app
   - `SETUP_GUIDE.md` - Detailed setup instructions

4. **Test the App**
   ```powershell
   flutter test
   ```

5. **Build for Release**
   ```powershell
   # Android APK
   flutter build apk --release
   # Find APK at: build\app\outputs\flutter-apk\app-release.apk
   
   # Install on connected device
   flutter install
   ```

## 🎓 Learning Resources

- **Flutter Docs**: https://docs.flutter.dev
- **Dart Docs**: https://dart.dev/guides
- **Flutter Cookbook**: https://docs.flutter.dev/cookbook
- **Material Design**: https://m3.material.io
- **Flutter YouTube**: https://www.youtube.com/c/flutterdev

## 💡 Tips

1. **Use Hot Reload** - Save time by not rebuilding the entire app
2. **Check Flutter Doctor** - Run regularly to ensure setup is correct
3. **Read Error Messages** - Flutter provides helpful error descriptions
4. **Use DevTools** - `flutter pub global activate devtools && flutter pub global run devtools`
5. **Keep Flutter Updated** - `flutter upgrade` (check monthly)

## ✅ Pre-Flight Checklist

Before running the app for the first time:

- [ ] Flutter installed and in PATH
- [ ] `flutter doctor` shows no critical issues
- [ ] Android Studio installed (for emulator)
- [ ] Android licenses accepted
- [ ] Emulator created or device connected
- [ ] VS Code with Flutter/Dart extensions
- [ ] Ran `flutter pub get` in project directory
- [ ] No errors from `flutter analyze`

## 🎉 Ready to Go!

Everything is set up! Just run:

```powershell
flutter run
```

And watch your investment tracker come to life! 🚀📱

---

**Need Help?** Check:
1. APP_SUMMARY.md - Complete project overview
2. USER_GUIDE.md - How to use the app features
3. SETUP_GUIDE.md - Detailed installation guide
4. Flutter docs - https://docs.flutter.dev

**Happy Coding!** 💻✨
