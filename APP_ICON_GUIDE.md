# App Icon Guide

## Requirements

- **Size:** 1024x1024 pixels
- **Format:** PNG (no transparency)
- **Color Space:** RGB
- **Resolution:** 72 DPI or higher
- **Shape:** Square (no rounded corners - iOS handles that)

## Design Tips

### Do's ✅
- Use a simple, recognizable design
- Ensure it looks good at small sizes (60x60 home screen icon)
- Use bold colors and clear shapes
- Test with iOS rounded corners overlay
- Make it stand out on various backgrounds
- Consider the icon's appearance in different contexts (home screen, Settings, App Store)

### Don'ts ❌
- Don't use transparency
- Don't add rounded corners (iOS does this automatically)
- Don't use tiny text or thin lines
- Don't use photos of real objects (unless simplified)
- Don't try to pack too much detail

## Quick Icon Ideas

For tracktides, consider:
- Wave/tide icon with tracking elements
- Abstract ocean wave pattern
- Stylized T with wave motifs
- Liquid/water droplet design
- Chart/graph with wave pattern

## Design Tools

### Free:
- **Figma** (web-based): figma.com
- **Canva** (web-based): canva.com
- **GIMP** (desktop): gimp.org

### Paid:
- **Sketch** (macOS): sketch.com
- **Adobe Illustrator**: adobe.com
- **Affinity Designer**: affinity.serif.com

### Icon Generators:
- **App Icon Generator** (web): appicon.co - Upload 1024x1024, generates all sizes
- **MakeAppIcon** (web): makeappicon.com
- **Icon.Kitchen** (web): icon.kitchen

## Adding to Project

1. Open Xcode
2. Navigate to `tracktides/Assets.xcassets`
3. Click on `AppIcon`
4. Drag and drop your 1024x1024 PNG into the "App Store iOS" slot
5. Xcode will generate all required sizes automatically

## Alternative: Generate All Sizes

If you want to generate all icon sizes manually:

```bash
# Using imagemagick (install with: brew install imagemagick)
magick input-1024.png -resize 20x20 icon-20@1x.png
magick input-1024.png -resize 40x40 icon-20@2x.png
magick input-1024.png -resize 60x60 icon-20@3x.png
# ... etc for all sizes
```

But Xcode will do this automatically if you provide the 1024x1024 version.

## Testing Your Icon

### In Simulator:
1. Build and run the app (Cmd+R)
2. Press Home (Cmd+Shift+H)
3. Check how the icon looks on the home screen

### On Device:
1. Archive and install via TestFlight
2. Check icon on actual home screen
3. Test on different wallpapers
4. Check in Spotlight search results
5. Check in Settings app

## Icon Template

You can use this as a starting point:

```
┌─────────────────────────┐
│                         │
│                         │
│      [Your Logo]        │
│         or              │
│    [Your Symbol]        │
│                         │
│                         │
└─────────────────────────┘
     1024 × 1024 px
```

## Common Mistakes

1. **Using transparency** - Will cause rejection
2. **Adding rounded corners** - iOS handles this, your image should be square
3. **Using text** - Hard to read at small sizes
4. **Too much detail** - Simplify for visibility
5. **Wrong dimensions** - Must be exactly 1024x1024

## Apple's Guidelines

Full Human Interface Guidelines for app icons:
https://developer.apple.com/design/human-interface-guidelines/app-icons

## Current Status

- Location: `tracktides/Assets.xcassets/AppIcon.appiconset/`
- Status: ⚠️ Placeholder (needs 1024x1024 PNG)

Replace the placeholder before submitting to TestFlight or App Store.
