# Fish Freshness Detection Mobile App - Design Document

## 1. System Architecture

### 1.1 Overview
```
┌─────────────────────────────────────────────────┐
│         User Mobile Device (Phone)              │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────────────────────────────────┐   │
│  │       Flutter UI Layer                    │   │
│  │  (Camera Screen, Result Screen)           │   │
│  └──────────────────────────────────────────┘   │
│                      ↓                          │
│  ┌──────────────────────────────────────────┐   │
│  │   Image Processing Layer                 │   │
│  │  (Resize, Normalize, Format)             │   │
│  └──────────────────────────────────────────┘   │
│                      ↓                          │
│  ┌──────────────────────────────────────────┐   │
│  │   ML Inference Layer (tflite_flutter)    │   │
│  │  - Load fish_model.tflite                │   │
│  │  - Run predictions                       │   │
│  │  - Parse results                         │   │
│  └──────────────────────────────────────────┘   │
│                      ↓                          │
│  ┌──────────────────────────────────────────┐   │
│  │   Result Processing & Display            │   │
│  │  - Format output                         │   │
│  │  - Show confidence                       │   │
│  │  - Display recommendations               │   │
│  └──────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 1.2 Key Components

| Component | Technology | Purpose |
|-----------|-----------|---------|
| UI Framework | Flutter/Dart | Cross-platform mobile UI |
| Camera | camera package | Live video capture |
| ML Inference | tflite_flutter | Run AI model predictions |
| Image Processing | image package | Format & resize images |
| State Management | Provider | Manage app state |
| Storage | shared_preferences | Store scan history |

---

## 2. App Flow & Navigation

### 2.1 User Journey
```
App Launch
    ↓
Permission Request (Camera)
    ↓
Home Screen
    ├─→ Tap "Scan Fish" → Camera Screen
    │       ↓
    │   Capture Photo
    │       ↓
    │   AI Analysis (Real-time)
    │       ↓
    │   Result Screen
    │       ├─→ View Confidence
    │       ├─→ View History
    │       └─→ Scan Again
    │
    ├─→ View History
    │
    └─→ Settings
```

### 2.2 Screens

#### Screen 1: Home Screen
- App title & logo
- Large "Scan Fish" button
- "View History" option
- Settings icon
- Brief info about the app

#### Screen 2: Camera Screen
- Live camera preview
- Capture button
- Cancel button
- Optional: Guidelines/frame overlay

#### Screen 3: Analysis Screen (Loading)
- Processing indicator
- "Analyzing fish freshness..."
- Cancel option

#### Screen 4: Result Screen
- Large result display (Fresh / Not Fresh)
- Confidence percentage
- Visual indicators (color-coded)
- Recommendations based on result
- "Scan Again" button
- "Save to History" option

#### Screen 5: History Screen
- List of past scans
- Timestamp for each scan
- Result & confidence
- Delete option

#### Screen 6: Settings Screen
- About app
- Model info
- Clear history
- Camera permissions

---

## 3. Data Models

### 3.1 Scan Result
```dart
class ScanResult {
  final String classification;  // "fresh" or "not_fresh"
  final double freshConfidence;
  final double notFreshConfidence;
  final DateTime timestamp;
  final String? imagePath;
}
```

### 3.2 Scan History
```dart
class ScanHistory {
  final List<ScanResult> scans;
  
  void addScan(ScanResult scan);
  void clearHistory();
  List<ScanResult> getScansFromDate(DateTime date);
}
```

### 3.3 Model Metadata
```dart
class ModelMetadata {
  final String modelName = "fish_model.tflite";
  final String labelsFile = "fish_labels.txt";
  final List<String> labels = ["fresh", "not_fresh"];
  final int inputSize = 224;
  final int inputChannels = 3;
}
```

---

## 4. UI/UX Design

### 4.1 Color Scheme
- **Fresh**: Green (#4CAF50) - Indicates fresh fish
- **Not Fresh**: Red (#F44336) - Indicates spoiled fish
- **Primary**: Blue (#2196F3) - Main app color
- **Background**: Light Gray (#F5F5F5)
- **Text**: Dark Gray (#212121)

### 4.2 Visual Indicators

**Fresh Fish**
- 🟢 Green circle/badge
- "✓ Fresh" text
- Positive message

**Not Fresh Fish**
- 🔴 Red circle/badge
- "✗ Not Fresh" text
- Warning message

### 4.3 Typography
- **Headers**: Bold, 24-28sp
- **Body**: Regular, 14-16sp
- **Buttons**: Bold, 16sp

### 4.4 Layout Principles
- **Vertical Stack**: Simple, focused design
- **Large Touch Targets**: Minimum 48dp for buttons
- **Clear CTAs**: Primary action always visible
- **Responsive**: Works on phones (3.5"-6.7")

---

## 5. Technical Architecture

### 5.1 Project Structure
```
fish_freshness_app/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── models/
│   │   ├── scan_result.dart
│   │   └── model_metadata.dart
│   ├── providers/
│   │   ├── fish_detector_provider.dart
│   │   └── history_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── camera_screen.dart
│   │   ├── result_screen.dart
│   │   ├── history_screen.dart
│   │   └── settings_screen.dart
│   ├── services/
│   │   ├── fish_detector_service.dart
│   │   ├── camera_service.dart
│   │   └── storage_service.dart
│   └── widgets/
│       ├── result_display.dart
│       ├── confidence_meter.dart
│       └── scan_history_item.dart
├── assets/
│   ├── fish_model.tflite
│   ├── fish_labels.txt
│   └── images/
│       ├── app_logo.png
│       └── icons/
├── pubspec.yaml
└── android/
    └── app/
        └── src/main/AndroidManifest.xml
```

### 5.2 Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.0
  image: ^4.0.0
  tflite_flutter: ^0.10.0
  provider: ^6.0.0
  shared_preferences: ^2.0.0
  intl: ^0.18.0
  permission_handler: ^11.0.0
```

### 5.3 Permission Requirements

**Android**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
```

**iOS**
```xml
NSCameraUsageDescription
```

---

## 6. ML Model Integration

### 6.1 Model Loading
```dart
final interpreter = await Interpreter.fromAsset('assets/fish_model.tflite');
```

### 6.2 Input Processing
- Image size: 224×224 pixels
- Channels: RGB (3)
- Data type: Float32
- Normalization: [0, 1]

### 6.3 Inference Process
```
1. Capture image from camera
2. Resize to 224×224
3. Convert to RGB (if needed)
4. Normalize pixels [0-1]
5. Create input tensor
6. Run interpreter.run(input, output)
7. Get predictions: [fresh_score, not_fresh_score]
8. Get max score and class
9. Display result
```

### 6.4 Output Interpretation
```dart
// Output: List<List<double>> with shape [1, 2]
// [0] = Fresh confidence
// [1] = Not Fresh confidence

double freshScore = output[0][0];
double notFreshScore = output[0][1];
double maxConfidence = max(freshScore, notFreshScore);

if (freshScore > notFreshScore) {
  result = "Fresh";
} else {
  result = "Not Fresh";
}
```

---

## 7. Performance Considerations

### 7.1 Optimization Targets
- **Inference Time**: < 500ms per image
- **Model Load Time**: < 2 seconds
- **Memory Usage**: < 50MB
- **Battery**: Minimal drain

### 7.2 Performance Strategy
- Load model once on app startup
- Cache interpreter
- Use image compression
- Run inference in background thread
- Limit camera resolution to 480×640 for preview

### 7.3 Real-time Optimization
- Process frames at 2-5 FPS (not every frame)
- Skip frames if previous inference still running
- Use image scaling for faster processing

---

## 8. Error Handling & Edge Cases

### 8.1 Error Scenarios
1. **Camera not available** → Show message, disable scan
2. **Model loading fails** → Show error, retry
3. **Permission denied** → Request permission
4. **Invalid image** → Retry capture
5. **Inference error** → Fallback message

### 8.2 Edge Cases
- Image too dark
- Image too blurry
- Image doesn't contain fish
- Multiple fish in frame
- Very small/large fish

---

## 9. State Management Flow

### 9.1 App States
```
┌─────────────────┐
│   App Loading   │
└────────┬────────┘
         ↓
┌─────────────────┐
│  Ready (Home)   │
└────────┬────────┘
         ↓
┌─────────────────┐
│  Scanning       │
└────────┬────────┘
         ↓
┌─────────────────┐
│  Analyzing      │
└────────┬────────┘
         ↓
┌─────────────────┐
│  Result Ready   │
└─────────────────┘
```

### 9.2 State Variables
- `isLoading`: bool
- `currentResult`: ScanResult?
- `scanHistory`: List<ScanResult>
- `cameraInitialized`: bool
- `modelLoaded`: bool

---

## 10. Deployment Targets

### 10.1 Android
- Minimum SDK: Android 21 (5.0)
- Target SDK: Android 33+
- CPU: ARM64

### 10.2 iOS
- Minimum: iOS 11.0
- Target: iOS 15+

---

## 11. Security & Privacy

### 11.1 Data Privacy
- All processing happens on-device
- No data sent to servers
- No internet connection required
- History stored locally only

### 11.2 Permissions
- Camera: Only accessed when scanning
- Storage: Local device only
- No network permissions

---

## 12. Scalability & Future Enhancements

### Phase 1 (MVP)
- ✅ Camera capture
- ✅ Fish freshness detection
- ✅ Result display
- ✅ Basic history

### Phase 2 (Enhancement)
- Fish species detection
- Quality rating (1-5 stars)
- Price estimation
- Export reports

### Phase 3 (Advanced)
- Cloud sync option
- Multiple models support
- Batch processing
- Analytics dashboard

---

## 13. Testing Strategy

### 13.1 Unit Tests
- Model inference
- Data validation
- Result parsing

### 13.2 Integration Tests
- Camera integration
- Model loading
- Screen navigation

### 13.3 UI Tests
- Screen rendering
- Button interactions
- Data display

---

## Summary

This design provides:
- ✅ Clean, modular architecture
- ✅ Fast, responsive UI
- ✅ Efficient ML inference
- ✅ Offline-first approach
- ✅ Scalable & maintainable code
- ✅ Focus on speed & accuracy

**Next Step**: Generate requirements based on this design, then implement!
