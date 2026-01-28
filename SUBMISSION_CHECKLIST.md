# TestFlight & App Store Submission Checklist

Quick reference checklist for submitting tracktides to TestFlight and the App Store.

## Status: Ready for Developer Account ✅

All technical requirements are in place. You just need:
1. Apple Developer account ($99/year) - **Required for TestFlight**
2. App icon (1024x1024 PNG)

---

## What's Already Done ✅

### 1. Privacy Manifest
- **File:** `tracktides/PrivacyInfo.xcprivacy`
- **Status:** Created and added to Xcode project
- **Declares:** No tracking, no data collection
- **Note:** Update if you add features that use required reason APIs

### 2. Project Configuration
- **Bundle ID:** `com.tracktides.app`
- **Version:** 1.0 (Build 1)
- **Deployment Target:** iOS 26.0+
- **Swift Version:** 6.0 with strict concurrency checking
- **Code Signing:** Configured (needs your team after getting dev account)

### 3. Build Settings
- Strict concurrency checking enabled
- Warnings treated as errors
- Automatic Info.plist generation

### 4. Documentation
- ✅ `APP_STORE_SUBMISSION.md` - Complete submission guide
- ✅ `APP_ICON_GUIDE.md` - App icon requirements and design tips
- ✅ `CLAUDE.md` - Updated with submission references

### 5. Build Verification
- ✅ Project builds successfully
- ✅ No compiler errors
- ✅ Privacy manifest included in build

---

## Next Steps

### Immediate (Before Submission)

- [ ] **Get Apple Developer Account**
  - Go to: https://developer.apple.com/programs/enroll/
  - Cost: $99/year (required for TestFlight)
  - Processing time: 24-48 hours

- [ ] **Create App Icon**
  - Size: 1024x1024 PNG
  - No transparency, no rounded corners
  - See `APP_ICON_GUIDE.md` for design tips
  - Add to: `tracktides/Assets.xcassets/AppIcon.appiconset`

### After Getting Developer Account

- [ ] **Configure Code Signing in Xcode**
  1. Open `tracktides.xcodeproj`
  2. Select project → Target → Signing & Capabilities
  3. Enable "Automatically manage signing"
  4. Select your team

- [ ] **Test Build**
  ```bash
  xcodebuild -project tracktides.xcodeproj \
    -scheme tracktides \
    -destination 'platform=iOS Simulator,name=iPhone 17' \
    build
  ```

- [ ] **Archive for TestFlight**
  1. Open Xcode
  2. Select "Any iOS Device (arm64)" as destination
  3. Product → Archive
  4. Distribute App → App Store Connect → Upload

### In App Store Connect

- [ ] **Create App Listing**
  - Name: tracktides
  - Bundle ID: com.tracktides.app
  - SKU: tracktides-ios (or similar)

- [ ] **Configure TestFlight**
  - Add test information
  - Add internal testers (up to 100)
  - Or add external testers (up to 10,000, requires Apple review)

- [ ] **Prepare for App Store** (after TestFlight testing)
  - App description
  - Keywords
  - Screenshots (multiple device sizes required)
  - Privacy policy URL (if needed)
  - Support URL

---

## Quick Commands

```bash
# Verify project builds
make check

# Build for simulator
xcodebuild -project tracktides.xcodeproj \
  -scheme tracktides \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build

# Open in Xcode
open tracktides.xcodeproj

# Update version number
agvtool new-marketing-version 1.1

# Increment build number
agvtool next-version -all
```

---

## Important Notes

### Developer Account Required
**You cannot upload to TestFlight without a paid Apple Developer account.**
- Free accounts only support local device testing
- TestFlight requires App Store Connect access
- App Store Connect requires paid membership

### App Icon Required
The app currently has a placeholder icon. You must add a real 1024x1024 PNG before submission to TestFlight or App Store.

### Privacy Manifest
The privacy manifest is already configured for the current app (no tracking, no data collection). If you add features that:
- Track users
- Use required reason APIs (UserDefaults, file timestamps, etc.)
- Collect user data
- Access device capabilities

Update `tracktides/PrivacyInfo.xcprivacy` accordingly.

---

## Resources

- **Full Guide:** `APP_STORE_SUBMISSION.md`
- **Icon Guide:** `APP_ICON_GUIDE.md`
- **App Store Connect:** https://appstoreconnect.apple.com
- **Developer Portal:** https://developer.apple.com
- **App Store Guidelines:** https://developer.apple.com/app-store/review/guidelines/

---

## Support

If you encounter issues:
1. Check `APP_STORE_SUBMISSION.md` for detailed troubleshooting
2. Review Apple's documentation
3. Check Xcode's error messages
4. Ensure all files are saved and project is clean built

**Current Status:** Ready to submit once you have:
- ✅ Apple Developer account
- ✅ App icon (1024x1024 PNG)
