# Fit Diary — Cross-Platform Mobile (Flutter)

**Topic:** Fitness diary with workouts, nutrition tracking, and offline data sync.  
**Stack:** Flutter · Provider (MVVM) · Firestore · REST · SQLite · SharedPreferences

## Team & goals (for presentation)

| Item | Description |
|------|-------------|
| **Aim** | Help users track workouts, meals, and profile metrics on Android, iOS, Web, and desktop |
| **Goals** | Multi-source nutrition data, local favorites, profile persistence, offline cache, dark theme |
| **Architecture** | MVVM: **Views** (screens) → **ViewModels** (`FitnessProvider`, `ThemeProvider`) → **Repositories** → **Services** |

## Architecture (MVVM + Repository)

```
screens/          → UI (View)
providers/        → ViewModels (ChangeNotifier)
repositories/     → Data orchestration (online + offline)
services/         → Firestore, REST API, SQLite, cache, connectivity
models/           → Domain entities
```

**Data sources**

1. **Cloud Firestore** — `foods` collection (primary online)
2. **REST API** — JSONPlaceholder fallback (`ApiService`)
3. **SharedPreferences** — profile, theme, selected foods, food cache JSON
4. **SQLite** — favorite exercises (in-memory on Web)

## Setup

```bash
flutter pub get
flutter run -d chrome   # or android / ios / macos
```

### Firebase

1. Create a Firebase project and enable Firestore.
2. Add collection `foods` with documents:

| Field | Type |
|-------|------|
| name | string |
| calories | number |
| protein | number |
| fat | number |
| carbs | number |

3. Use FlutterFire CLI or existing `lib/firebase_options.dart` and platform config files.

### Without Firestore

The app falls back to REST API and cached data automatically.

## Features (grading checklist)

- Workout categories, plans carousel, exercise details
- Nutrition with macros, calorie balance, persisted food selection
- Favorites (SQLite / Web in-memory) with swipe-to-delete
- Profile (name, height, weight) + dark theme
- Offline banner and cached foods when offline
- Cached network images, page transitions, animated UI

## Tests

```bash
flutter test
flutter analyze
```

## Deployment

**Android**

```bash
flutter build apk --release
# Configure signing in android/app/build.gradle.kts (release keystore)
```

**iOS**

```bash
flutter build ios --release
# Open ios/Runner.xcworkspace in Xcode → Archive → App Store Connect
```

**Web**

```bash
flutter build web
```

## Presentation outline

1. Team, topic, aim, goals, plan  
2. Tech comparison: Flutter vs React Native vs native; Firestore vs REST vs SQLite  
3. MVVM diagram (see `lib/` structure above)  
4. Relevance: health/fitness tracking demand  
5. Mockups: run app — Workout / Nutrition / Favorites / Profile tabs  

## Maintenance

- Bump dependencies: `flutter pub outdated`  
- Seed Firestore `foods` for production nutrition catalog  
- Enable Firestore security rules before public release  
