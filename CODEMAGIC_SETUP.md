# Codemagic CI/CD Setup Guide

## What I've Configured

I've created **3 workflows** for you:

### 1. **android-workflow** (Recommended for Testing)
- Builds APK (for direct installation) and AAB (for Google Play)
- Split APKs by ABI for smaller file sizes
- Fast and free on Codemagic
- **Best for:** Quick testing and distribution to Android users

### 2. **ios-workflow** (Requires Apple Developer Account)
- Builds IPA file for iOS
- Automatically uploads to TestFlight
- **Requires:** $99/year Apple Developer Account
- **Best for:** iOS app distribution

### 3. **all-platforms-workflow** (Build Everything)
- Builds both Android and iOS in one go
- Auto-triggers on push to `main` or `master` branch
- **Best for:** Production releases

---

## Setup Steps

### Step 1: Sign Up for Codemagic
1. Go to [codemagic.io](https://codemagic.io/signup)
2. Sign up with your GitHub/GitLab/Bitbucket account
3. **Free tier includes:**
   - 500 build minutes/month
   - Unlimited team size
   - macOS build machines

### Step 2: Connect Your Repository
1. In Codemagic dashboard, click **"Add application"**
2. Select your Git provider (GitHub recommended)
3. Choose this repository: `oil_mazout_tracker_application`
4. Codemagic will auto-detect the `codemagic.yaml` file

### Step 3: Configure Android Signing (Optional)
For production Android builds:
1. In Codemagic, go to **Teams** → **Code signing identities**
2. Upload your Android keystore file
3. Or use Codemagic to generate one for you
4. Reference it in the workflow as `keystore_reference`

**For testing:** You can skip this and use debug signing

### Step 4: Configure iOS (If Building for iOS)

#### A. Get Apple Developer Account
- Cost: $99/year
- Sign up at [developer.apple.com](https://developer.apple.com)

#### B. Connect App Store Connect
1. In Codemagic: **Teams** → **Integrations** → **App Store Connect**
2. Generate App Store Connect API key:
   - Log into [App Store Connect](https://appstoreconnect.apple.com)
   - Go to **Users and Access** → **Keys**
   - Create new API key (Admin access)
   - Download the `.p8` file
3. Upload to Codemagic with Issuer ID and Key ID

#### C. Set Up Code Signing
1. In Codemagic: **Teams** → **Code signing identities** → **iOS**
2. Option 1: **Automatic** (Recommended)
   - Connect your Apple Developer account
   - Codemagic manages certificates/profiles automatically
3. Option 2: **Manual**
   - Upload certificate (.p12) and provisioning profile

#### D. Update Bundle Identifier
Edit [codemagic.yaml](codemagic.yaml):
```yaml
BUNDLE_ID: "com.yourcompany.oilmazout"
bundle_identifier: com.yourcompany.oilmazout
PACKAGE_NAME: "com.yourcompany.oilmazout"
```

### Step 5: Update Notification Email
Edit [codemagic.yaml](codemagic.yaml):
```yaml
email:
  recipients:
    - your.email@example.com  # Change this!
```

---

## How to Build

### Method 1: Automatic (Recommended)
Push to `main` or `master` branch:
```bash
git add .
git commit -m "Trigger build"
git push origin master
```
The `all-platforms-workflow` will start automatically!

### Method 2: Manual Build
1. Go to Codemagic dashboard
2. Select your app
3. Click **"Start new build"**
4. Choose workflow:
   - `android-workflow` for Android only (fastest, free)
   - `ios-workflow` for iOS only (requires Apple account)
   - `all-platforms-workflow` for both
5. Click **"Start build"**

### Method 3: Via Codemagic UI
- Trigger builds from web interface
- Select specific branches
- Override environment variables

---

## Build Outputs

### Android
- **APK files** (for direct installation):
  - `app-armeabi-v7a-release.apk` (32-bit ARM, smaller)
  - `app-arm64-v8a-release.apk` (64-bit ARM, most devices)
  - `app-x86_64-release.apk` (Intel, emulators)
- **AAB file** (for Google Play):
  - `app-release.aab`

### iOS
- **IPA file** (for TestFlight/App Store):
  - `oil_mazout_tracker_application.ipa`

### Where to Download
1. After build completes, go to **Build artifacts**
2. Download files directly
3. Share APK/IPA with testers

---

## Distribution Options

### Android
1. **Direct Install** (Easiest)
   - Download APK from Codemagic
   - Share via email/drive/WhatsApp
   - Users: Enable "Install from unknown sources" → Install

2. **Google Play Internal Testing**
   - Upload AAB to Play Console
   - Add internal testers (up to 100)
   - Share link, users install from Play Store

3. **Google Play Beta**
   - Public or closed testing
   - Unlimited testers
   - Appears in Play Store

### iOS
1. **TestFlight** (Recommended)
   - Automatic upload from Codemagic
   - Add testers via email (up to 10,000)
   - Users install via TestFlight app
   - No jailbreak needed!

2. **Direct Install** (Complex)
   - Requires UDID registration (100 devices max)
   - Install via Xcode or third-party tools
   - Not recommended

---

## Cost Breakdown

### Free Option (Android Only)
- ✅ Codemagic: 500 free minutes/month
- ✅ Android: No developer account needed
- ✅ Distribution: Direct APK sharing (free)
- **Total: $0/month**

### iOS Testing Option
- ✅ Codemagic: 500 free minutes/month
- ❌ Apple Developer: $99/year
- ✅ TestFlight: Free for up to 10,000 testers
- **Total: $99/year (~$8.25/month)**

### Full Production Option
- ⚠️ Codemagic: $0-99/month (depends on build frequency)
- ❌ Apple Developer: $99/year
- ⚠️ Google Play: $25 one-time registration
- **Total: $124 first year, then $99/year + potential Codemagic costs**

---

## My Recommendation

### For You Right Now:

**Use `android-workflow` only** because:
1. ✅ **Completely FREE** - No Apple Developer account needed
2. ✅ **Fastest** - Android builds are quicker
3. ✅ **Easy distribution** - Share APK directly with users
4. ✅ **No hassle** - No code signing complexity
5. ✅ **500 free minutes/month** on Codemagic is plenty

### Later, if you want iOS:
- Get Apple Developer account ($99/year)
- Use `ios-workflow` to build IPA
- Distribute via TestFlight (free, professional)

### For Production:
- Use `all-platforms-workflow`
- Automate builds on every push
- Both platforms in one go

---

## Quick Start (Android Only)

1. **Sign up:** [codemagic.io/signup](https://codemagic.io/signup)
2. **Connect repo:** Add this application
3. **Start build:** Select `android-workflow`
4. **Wait ~10 minutes** ☕
5. **Download APK:** From build artifacts
6. **Share with users:** Via any method (email, drive, etc.)
7. **Install:** Enable unknown sources → Install APK

That's it! No Apple account, no certificates, no hassle.

---

## Troubleshooting

### Build fails with "No code signing"
- Android: Skip or upload keystore
- iOS: Complete Step 4 (iOS setup)

### "Bundle identifier mismatch"
- Update `BUNDLE_ID` in codemagic.yaml
- Must match iOS Xcode project settings

### "Insufficient build minutes"
- Free tier: 500 min/month
- Android build: ~8-10 minutes
- iOS build: ~15-20 minutes
- Upgrade to paid plan if needed

### APK won't install on device
- Enable "Install from unknown sources" in Android settings
- Try the `arm64-v8a` APK (works on most devices)

---

## Alternative: Just Use Android for Now

You already have:
- ✅ Working Android APK (63.4MB)
- ✅ Built locally on your machine
- ✅ No CI/CD needed for testing

**My honest advice:** 
- Keep building locally for now (it's working!)
- Use Codemagic only when you need:
  - Automated builds on every push
  - Team collaboration
  - iOS builds (when ready to pay $99/year)

The local APK you built is **perfectly fine** for testing and even production! Codemagic is just automation.

---

## Need Help?

- Codemagic Docs: [docs.codemagic.io](https://docs.codemagic.io)
- Flutter CI/CD Guide: [docs.flutter.dev/deployment/cd](https://docs.flutter.dev/deployment/cd)
- My recommendation: Start with Android workflow, it's the easiest path!
