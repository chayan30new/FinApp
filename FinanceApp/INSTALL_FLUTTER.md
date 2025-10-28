# 📦 Complete Flutter Installation Guide

## ⚡ Quick Installation Steps

### Step 1️⃣: Download Flutter

**Option A: Direct Download (Recommended)**
1. Click this link: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.3-stable.zip
2. Save the file (it's about 1 GB)

**Option B: From Flutter Website**
1. Visit: https://docs.flutter.dev/get-started/install/windows
2. Click "Download Flutter SDK" button

---

### Step 2️⃣: Extract Flutter

1. **Find your downloaded ZIP file** (usually in Downloads folder)
2. **Right-click** on `flutter_windows_3.24.3-stable.zip`
3. **Select** "Extract All..."
4. **Extract to**: `C:\src\` (I've already created this folder for you)
5. **Result**: You should have `C:\src\flutter\` folder with `bin`, `lib`, etc.

⚠️ **IMPORTANT**: Do NOT extract to `C:\Program Files\` - it causes permission issues!

---

### Step 3️⃣: Add Flutter to PATH

**Method 1: Using the Script (Easy)**
```powershell
.\install-flutter.ps1
```

**Method 2: Manual (If script doesn't work)**
1. Press `Win + X` → Select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables" button
4. Under "User variables for [YourName]", find "Path"
5. Click "Edit"
6. Click "New"
7. Type: `C:\src\flutter\bin`
8. Click "OK" on all dialogs

---

### Step 4️⃣: Verify Installation

1. **Close this terminal completely**
2. **Open a NEW PowerShell** (important!)
3. Run:
```powershell
flutter --version
```

You should see something like:
```
Flutter 3.24.3 • channel stable
```

---

### Step 5️⃣: Install Git (Required)

Flutter needs Git to work.

1. Download: https://git-scm.com/download/win
2. Install with default settings
3. Restart terminal

---

### Step 6️⃣: Run Flutter Doctor

In a new terminal:
```powershell
flutter doctor
```

This checks what's installed and what's missing.

Expected output:
```
[✓] Flutter (3.24.3)
[✗] Android toolchain - Android SDK not found
[✗] Visual Studio - not installed
[!] Android Studio - not installed
```

---

### Step 7️⃣: Install Android Studio

1. **Download**: https://developer.android.com/studio
2. **Install** with default settings
3. **During installation**, make sure these are checked:
   - ✅ Android SDK
   - ✅ Android SDK Platform
   - ✅ Android Virtual Device

4. **After installation**:
   - Open Android Studio
   - Complete the setup wizard
   - It will download Android SDK automatically

---

### Step 8️⃣: Accept Android Licenses

In terminal:
```powershell
flutter doctor --android-licenses
```

Press `y` to accept each license.

---

### Step 9️⃣: Create Android Emulator

1. **Open Android Studio**
2. Click **"More Actions"** → **"Virtual Device Manager"**
3. Click **"Create Device"**
4. Select **"Pixel 4"** (or any phone)
5. Click **"Next"**
6. Select **"UpsideDownCake"** (latest Android version)
7. Click **"Next"** → **"Finish"**

---

### Step 🔟: Final Check

```powershell
flutter doctor
```

Should show:
```
[✓] Flutter
[✓] Android toolchain
[✓] Android Studio
```

---

## 🚀 Run Your App!

Once everything is ✓, navigate to your project:

```powershell
cd "C:\Users\cagarwal\OneDrive - Amadeus Workplace\Desktop\FinanceApp"
flutter pub get
flutter run
```

---

## 📋 Checklist

Use this to track your progress:

- [ ] **Step 1**: Downloaded Flutter ZIP
- [ ] **Step 2**: Extracted to C:\src\flutter
- [ ] **Step 3**: Added to PATH
- [ ] **Step 4**: Verified with `flutter --version` in NEW terminal
- [ ] **Step 5**: Installed Git
- [ ] **Step 6**: Ran `flutter doctor`
- [ ] **Step 7**: Installed Android Studio
- [ ] **Step 8**: Accepted licenses with `flutter doctor --android-licenses`
- [ ] **Step 9**: Created Android emulator
- [ ] **Step 10**: All checks pass in `flutter doctor`
- [ ] **Step 11**: Ran `flutter pub get` in project
- [ ] **Step 12**: Ran `flutter run`

---

## 🐛 Troubleshooting

### "Flutter command not found" after installation
**Solution**: 
- Close ALL terminals and VS Code
- Open NEW terminal
- Try again

### "Unable to locate Android SDK"
**Solution**:
```powershell
flutter config --android-sdk "C:\Users\[YourName]\AppData\Local\Android\Sdk"
```

### "cmdline-tools not installed"
**Solution**:
1. Open Android Studio
2. Settings → Appearance & Behavior → System Settings → Android SDK
3. SDK Tools tab
4. Check "Android SDK Command-line Tools"
5. Click "Apply"

### Build fails with Gradle error
**Solution**:
```powershell
cd android
.\gradlew clean
cd ..
flutter clean
flutter pub get
```

---

## ⏱️ Time Estimate

- Download Flutter: 5-10 minutes (depending on internet)
- Extract & Setup: 2 minutes
- Install Android Studio: 15-20 minutes
- Create Emulator: 5 minutes
- **Total**: ~30-40 minutes

---

## 🎯 What to Do NOW

1. **If Flutter ZIP is downloading**: Wait for it to finish, then extract to C:\src
2. **If you have the ZIP**: Extract it to C:\src\flutter
3. **If Flutter is extracted**: Run `.\install-flutter.ps1` script
4. **After PATH is set**: Close terminal, open new one, run `flutter --version`

---

## 📞 Quick Links

- **Flutter Download**: https://docs.flutter.dev/get-started/install/windows
- **Git Download**: https://git-scm.com/download/win
- **Android Studio**: https://developer.android.com/studio
- **Flutter Docs**: https://docs.flutter.dev

---

## ✅ Success Indicators

You'll know it worked when:
1. `flutter --version` shows version number
2. `flutter doctor` shows mostly green checkmarks
3. `flutter run` compiles and launches your app

---

**Need help? Check the output of `flutter doctor` and follow its suggestions!**
