# HESTORIA
Learn English. Play. Improve.

## Run
```
flutter pub get
flutter run
```

## Firebase setup (progress saved per user)
1. Create a Firebase project (free Spark plan).
2. In the console enable **Authentication > Anonymous** and create a **Firestore** database.
3. Publish the rules in `firestore.rules`.
4. In the project folder run:
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This overwrites `lib/firebase_options.dart`. Until then the app works offline-only.
5. If Android build complains about minSdk, set `minSdk = 23` in `android/app/build.gradle(.kts)`.

## Progression rules
- Everyone starts at A1; levels can't be chosen.
- A level unlocks only after the previous level's final test is passed (>= 70%).
- Lessons are sequential (>= 60% to complete); the final test opens after all lessons.
- Rules live in `lib/features/progress/progress_model.dart`; content in `lib/features/learn/domain/content.dart`.
