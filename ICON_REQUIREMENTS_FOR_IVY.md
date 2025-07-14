# 🎨 App Icon Requirements for Ivy (UI Agent)

## 🚨 CRITICAL: Missing App Icons

The build infrastructure is complete, but **actual app icon images are missing**. The asset catalog structure exists but contains no images.

---

## 📋 Required Actions for Ivy

### **1. Master Icon Design**
Create a **1024x1024 PNG** master icon with:
- **Bible/Christian theme** - Open book, cross, or dove
- **Modern, clean design** - Flat or gradient style
- **Readable at small sizes** - Test at 40x40px
- **No text/words** - Icons only
- **High contrast** - Works on light and dark backgrounds

### **2. Technical Specifications**

#### **File Format Requirements:**
- **Format:** PNG with transparency
- **Color Space:** sRGB
- **Bit Depth:** 24-bit (no alpha) or 32-bit (with alpha)
- **Master Size:** 1024x1024 pixels minimum

#### **Design Guidelines:**
- **No transparency** for iOS marketing icon (1024x1024)
- **Avoid very thin lines** - minimum 2px stroke width
- **Safe area:** Keep important elements 10% inside edges
- **Corner radius:** Don't add - system handles this

### **3. Generated Sizes Needed**

#### **iOS (iPhone/iPad):**
- 40x40, 60x60 (notification)
- 58x58, 87x87 (settings)
- 80x80, 120x120 (spotlight)
- 120x120, 180x180 (app icon)
- 1024x1024 (App Store)

#### **macOS:**
- 16x16, 32x32 (Finder)
- 32x32, 64x64 (toolbar)
- 128x128, 256x256 (dock)
- 256x256, 512x512 (Finder)
- 512x512, 1024x1024 (high res)

#### **watchOS:**
- 48x48, 55x55 (notification)
- 58x58, 87x87 (companion)
- 80x80, 88x88, 100x100 (app launcher)
- 172x172, 196x196, 216x216 (quick look)
- 1024x1024 (App Store)

#### **visionOS:**
- 1024x1024@2x (App Store)

---

## 🛠️ Implementation Steps

### **Step 1: Create Master Icon**
Place your 1024x1024 master icon at:
```
Resources/AppIcon-Master.png
```

### **Step 2: Generate All Sizes**
Run the icon generation script:
```bash
chmod +x Scripts/generate-app-icons.sh
./Scripts/generate-app-icons.sh Resources/AppIcon-Master.png
```

### **Step 3: Update Asset Catalog**
The script will generate all required sizes and update:
```
Resources/Assets.xcassets/AppIcon.appiconset/
```

### **Step 4: Verify in Xcode**
1. Open `Leavn.xcodeproj`
2. Navigate to `Resources/Assets.xcassets/AppIcon`
3. Verify all icon slots are filled
4. Test in simulator

---

## 🎯 Design Inspiration

### **Bible App Themes:**
- 📖 **Open Book:** Classic, immediately recognizable
- ✝️ **Stylized Cross:** Clean, geometric interpretation
- 🕊️ **Dove:** Peace, Holy Spirit symbolism
- 📜 **Scroll:** Ancient scripture reference
- 💡 **Light/Lamp:** "Thy word is a lamp unto my feet"

### **Color Schemes:**
- **Primary:** Deep blue (#2C5282) + Gold (#D69E2E)
- **Warm:** Burgundy (#9C4221) + Cream (#FFF8DC)
- **Modern:** Dark slate (#2D3748) + Bright accent
- **Classic:** Navy (#1A365D) + White/Silver

### **Style References:**
- Apple's native apps (clean, minimal)
- Bible Gateway app (open book concept)
- YouVersion app (modern, approachable)
- Logos Bible app (scholarly, professional)

---

## 🔧 Tools & Resources

### **Design Tools:**
- **Sketch** - Vector design, export multiple sizes
- **Figma** - Free, web-based, great for icons
- **Adobe Illustrator** - Professional vector graphics
- **SF Symbols** - Apple's system icons for reference

### **Icon Resources:**
- **Apple HIG** - Human Interface Guidelines for icons
- **iOS App Icon Template** - Pre-made Sketch/Figma templates
- **Icon8** - Reference library for icon styles
- **The Noun Project** - Simple, clean icon inspiration

### **Testing Tools:**
- **Icon Preview** - macOS app for testing icon appearance
- **iOS Simulator** - Test how icons look on device
- **Xcode** - Asset catalog validation

---

## 🚫 Common Mistakes to Avoid

1. **Text in icons** - Won't be readable at small sizes
2. **Too much detail** - Simplify for clarity
3. **Wrong aspect ratio** - Must be perfect square
4. **Low resolution** - Start with 1024x1024 minimum
5. **Inconsistent style** - Keep design coherent across sizes
6. **Ignoring safe areas** - Important elements too close to edges
7. **Not testing small sizes** - Check readability at 40x40px

---

## ⚡ Quick Start Command

Once you have the master icon ready:

```bash
# Place your icon at Resources/AppIcon-Master.png, then run:
make icons

# Or manually:
./Scripts/generate-app-icons.sh Resources/AppIcon-Master.png
```

---

## 📞 Support

If you need technical assistance with:
- Asset catalog structure
- Build integration
- Icon validation
- Xcode configuration

Contact **Storm** (Build/Test/QA Agent) for build-related issues.

For design feedback and UI/UX guidance, coordinate with the design team.

---

**Status:** 🔴 **BLOCKING** - App cannot ship without icons  
**Priority:** 🚨 **CRITICAL**  
**Assigned:** Ivy (UI Agent)  
**Dependencies:** None - ready for implementation