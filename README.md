# Fit Diary — Cross-Platform Mobile (Flutter)

**Topic:** Fitness diary with workouts, nutrition tracking, and offline data sync.  
**Stack:** Flutter · Provider (MVVM) · Firebase Auth · Firestore · REST · SharedPreferences

## Team & goals (for presentation)

| Item | Description |
|------|-------------|
| **Aim** | Help users track workouts, meals, and profile metrics on Android, iOS, Web, and desktop |
| **Goals** | Auth per user, cloud favorites, nutrition sync, profile, offline cache, dark theme |
| **Architecture** | MVVM: **Views** → **ViewModels** (`AuthProvider`, `FitnessProvider`, `ThemeProvider`) → **Repositories** → **Services** |

## Architecture (MVVM + Repository)

```
screens/          → UI (View)
providers/        → ViewModels (ChangeNotifier)
repositories/     → Data orchestration (online + offline)
services/         → Firestore, REST API, SQLite, cache, connectivity
models/           → Domain entities
```

**Firebase roles**

| Service | Purpose |
|---------|---------|
| **Firebase Auth** | Email/password login; session per user |
| **Cloud Firestore** | `foods` — nutrition catalog; `users/{uid}/favorites` — favorite workouts per account |

**Other data**

- **REST API** — JSONPlaceholder fallback for foods
- **SharedPreferences** — profile, theme, selected foods, food cache

## Setup

```bash
flutter pub get
flutter run -d chrome   # or android / ios / macos
```

### Firebase

1. In [Firebase Console](https://console.firebase.google.com) → project `fitdiary-58fb1`:
   - **Authentication** → Sign-in method → enable **Email/Password**
   - **Firestore** → create database (test mode for development)
2. Collection `foods` (nutrition catalog):

| Field | Type |
|-------|------|
| name | string |
| calories | number |
| protein | number |
| fat | number |
| carbs | number |

3. Favorites are stored per user at `users/{userId}/favorites/{docId}` with fields `title`, `imageUrl`, `createdAt`.
4. Recommended Firestore rules (production):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /foods/{doc} {
      allow read: if request.auth != null;
    }
    match /users/{userId}/favorites/{favoriteId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

5. Use existing `lib/firebase_options.dart` and platform config files.

### Without Firestore

The app falls back to REST API and cached data automatically.

## Features (grading checklist)

- Workout categories, plans carousel, exercise details
- Nutrition with macros, calorie balance, persisted food selection
- **Login / Register** (Firebase Auth) — required to use the app
- **Favorites** in Firestore per account, swipe-to-delete
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
