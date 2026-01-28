# App Store & TestFlight Submission Guide

This document covers everything you need to submit tracktides to TestFlight and the App Store.

## Current Status

✅ **Ready:**
- Info.plist configuration (auto-generated)
- Bundle identifier: `com.tracktides.app`
- Version: 1.0 (Build 1)
- Privacy Manifest created (`PrivacyInfo.xcprivacy`)
- Project structure configured

⚠️ **Needs Attention:**
- App icon (1024x1024 PNG required)
- Apple Developer account ($99/year) - **Required for TestFlight**
- App Store Connect metadata
- Screenshots

---

## Prerequisites

### 1. Apple Developer Account

**Required for TestFlight and App Store submission.**

- Cost: $99/year
- Sign up: https://developer.apple.com/programs/enroll/
- Processing time: Usually 24-48 hours

**Note:** You cannot upload to TestFlight without a paid developer account. Free Apple IDs only support local device testing.

### 2. App Icon

Create a **1024x1024 PNG** with these requirements:
- No transparency
- No rounded corners (iOS handles that automatically)
- 72 DPI or higher
- RGB color space

**How to add:**
1. Open Xcode
2. Navigate to `tracktides/Assets.xcassets/AppIcon.appiconset`
3. Drag and drop your 1024x1024 PNG into the placeholder

**Quick tips:**
- Design should work at small sizes (60x60 on home screen)
- Test with a rounded corner overlay
- Avoid thin lines or small text

### 3. Code Signing Setup (After Getting Developer Account)

1. Open `tracktides.xcodeproj` in Xcode
2. Select the project in the navigator (blue icon)
3. Select the "tracktides" target
4. Go to "Signing & Capabilities" tab
5. Check "Automatically manage signing"
6. Select your Team (your developer account)
7. Xcode will create/download certificates and provisioning profiles

---

## Privacy Manifest

✅ **Already created:** `tracktides/PrivacyInfo.xcprivacy`

The privacy manifest declares:
- No user tracking
- No data collection
- No required reason API usage (for now)

**When to update:**
If you add any of these features in the future, uncomment and configure the relevant section in `PrivacyInfo.xcprivacy`:
- UserDefaults for storing user preferences
- File timestamp checks
- System boot time queries
- Disk space checks
- Network requests
- Location services
- Camera/Photo access

**Required Reason APIs:**
Apple requires you to declare why you use certain APIs. See: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api

---

## TestFlight Submission Steps

### Step 1: Prepare App

1. **Add app icon** (see section above)
2. **Update version/build** (if needed):
   - Version: `MARKETING_VERSION` in project settings
   - Build: `CURRENT_PROJECT_VERSION` in project settings
   - Or use command line:
     ```bash
     agvtool new-marketing-version 1.0.1
     agvtool next-version -all
     ```

3. **Test the app**:
   ```bash
   # Build and run in simulator
   xcodebuild -project tracktides.xcodeproj \
     -scheme tracktides \
     -destination 'platform=iOS Simulator,name=iPhone 16' \
     build
   ```

4. **Run checks**:
   ```bash
   make check  # Runs linting and formatting checks
   ```

### Step 2: Archive the App

1. Open `tracktides.xcodeproj` in Xcode
2. Select **Any iOS Device (arm64)** as the destination (top bar, next to play/stop buttons)
3. Go to **Product → Archive** (Cmd+Shift+B won't work, must use Archive)
4. Wait for build to complete
5. Xcode Organizer window will open automatically

### Step 3: Upload to App Store Connect

1. In the Organizer window, select your archive
2. Click **Distribute App**
3. Select **App Store Connect**
4. Click **Upload**
5. Accept defaults (automatic signing, include bitcode if asked)
6. Click **Upload**
7. Wait for upload to complete (may take 5-15 minutes)

### Step 4: Configure TestFlight in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Click **My Apps**
3. Click **+** to create a new app
4. Fill in:
   - Name: tracktides
   - Primary Language: English
   - Bundle ID: com.tracktides.app
   - SKU: (any unique identifier, e.g., "tracktides-ios")
   - User Access: Full Access
5. Save

6. Navigate to **TestFlight** tab
7. Wait for build to process (10-60 minutes)
8. Once processed, add test information:
   - What to test
   - Test notes for testers
   - Privacy policy URL (if applicable)

9. Add testers:
   - **Internal Testing**: Up to 100 Apple Developer Program members
   - **External Testing**: Up to 10,000 external testers (requires Apple review)

---

## App Store Submission Steps

After TestFlight testing is successful:

### 1. Prepare App Store Connect Listing

Go to https://appstoreconnect.apple.com → Your App:

**App Information:**
- Name: tracktides
- Subtitle: (optional, 30 chars)
- Category: (choose appropriate category)
- Content Rights: (if applicable)

**Pricing and Availability:**
- Price: Free or paid
- Countries: Select where app is available

**App Privacy:**
- Fill out privacy questionnaire
- Based on your `PrivacyInfo.xcprivacy` declarations
- For current app: "No data collected"

### 2. Screenshots (Required)

You need screenshots for:
- 6.9" iPhone (e.g., iPhone 16 Pro Max) - Required
- 6.7" iPhone (e.g., iPhone 15 Plus) - Required
- 6.5" iPhone (e.g., iPhone 11 Pro Max)
- 5.5" iPhone (e.g., iPhone 8 Plus)
- 12.9" iPad Pro
- 12.9" iPad Pro (2nd gen)

**Recommended approach:**
1. Run app on largest iPhone simulator (iPhone 16 Pro Max)
2. Take screenshots: Cmd+S in Simulator
3. Screenshots saved to Desktop
4. Upload to App Store Connect

**Tips:**
- You need 3-10 screenshots per device size
- Show key features
- Can add text/graphics overlay (use a tool like Screenshot Studio)
- First screenshot is most important (shown in search results)

### 3. App Review Information

- First Name, Last Name
- Phone Number
- Email
- Notes for reviewer (if app needs login, provide test credentials)
- Demo video (if app functionality isn't obvious)

### 4. Submit for Review

1. Create a new version (e.g., 1.0)
2. Select build from TestFlight
3. Fill in "What's New in This Version"
4. Save
5. Click **Submit for Review**
6. Review time: Usually 24-48 hours

---

## Version Updates (Future Releases)

### Increment Version Numbers

```bash
# Update marketing version (1.0 → 1.1)
agvtool new-marketing-version 1.1

# Increment build number (1 → 2)
agvtool next-version -all
```

Or manually in Xcode:
1. Select project → Target → General
2. Update "Version" and "Build"

### Quick Update Workflow

```bash
# 1. Make code changes
# 2. Run checks
make check

# 3. Update version
agvtool new-marketing-version 1.0.1
agvtool next-version -all

# 4. Archive in Xcode (Product → Archive)
# 5. Upload to App Store Connect
# 6. Submit new version
```

---

## Common Issues & Solutions

### "No signing certificate found"
- Make sure you have a paid Apple Developer account
- Enable "Automatically manage signing" in Xcode
- Select your team

### "App uses non-public API"
- Check for any private APIs
- Usually caused by third-party libraries
- Review Xcode warnings

### "Missing compliance documentation"
- If app uses encryption (most do), you need to declare it
- For HTTPS only: Select "No" for using encryption
- App Store Connect will ask during submission

### "Invalid Bundle"
- Check that bundle identifier matches App Store Connect
- Ensure all required icons are present
- Verify Info.plist has all required keys

### "Your app contains non-public API usage"
- Run `nm` on binary to find private APIs
- Often caused by third-party SDKs
- May need to update dependencies

---

## Testing Before Submission

### Local Testing Checklist

- [ ] App builds without errors
- [ ] App runs on simulator
- [ ] Test on physical device (if available)
- [ ] All features work as expected
- [ ] No crashes
- [ ] UI looks correct on different screen sizes
- [ ] Dark mode support (if applicable)
- [ ] Rotation handling (if applicable)

### Code Quality Checks

```bash
make check     # Run linting and formatting
make lint      # Just linting
make format    # Auto-format code
```

### Build in Release Mode

```bash
xcodebuild -project tracktides.xcodeproj \
  -scheme tracktides \
  -configuration Release \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

---

## Resources

- **App Store Connect:** https://appstoreconnect.apple.com
- **Developer Portal:** https://developer.apple.com
- **App Store Review Guidelines:** https://developer.apple.com/app-store/review/guidelines/
- **Human Interface Guidelines:** https://developer.apple.com/design/human-interface-guidelines/
- **TestFlight Documentation:** https://developer.apple.com/testflight/

---

## Quick Reference

| Task | Command/Action |
|------|----------------|
| Open project | `open tracktides.xcodeproj` |
| Run checks | `make check` |
| Archive | Xcode → Product → Archive |
| Update version | `agvtool new-marketing-version X.X` |
| Increment build | `agvtool next-version -all` |
| App Store Connect | https://appstoreconnect.apple.com |

---

## Next Steps

1. [ ] Get Apple Developer account
2. [ ] Create app icon (1024x1024 PNG)
3. [ ] Add app icon to Assets.xcassets
4. [ ] Configure signing in Xcode
5. [ ] Archive and upload to TestFlight
6. [ ] Test via TestFlight
7. [ ] Prepare App Store listing
8. [ ] Submit for review
