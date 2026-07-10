# Firebase Setup Instructions for SIM Training App

## Step 1: Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Click "Add project" or "Create a project"
3. Name it "SIM Training App" (or your preferred name)
4. Disable Google Analytics (optional)
5. Click "Create project"

## Step 2: Add Android App
1. In your Firebase project, click the Android icon
2. Android package name: `com.simtraining.personaltrainingapp`
3. Click "Register app"
4. Download `google-services.json`
5. Place it in: `android/app/google-services.json`

## Step 3: Add Web App (for testing)
1. In Firebase project settings, click the Web icon (</>)
2. App nickname: "SIM Training Web"
3. Click "Register app"
4. Copy the `firebaseConfig` values
5. Update `lib/utils/firebase_service.dart` with your values:
   - apiKey
   - authDomain
   - databaseURL
   - projectId
   - storageBucket
   - messagingSenderId
   - appId

## Step 4: Enable Realtime Database
1. In Firebase console, go to "Build" → "Realtime Database"
2. Click "Create Database"
3. Choose location (us-central1 recommended)
4. Start in **TEST MODE** (we'll secure it later)
5. Click "Enable"

## Step 5: Set Database Rules (IMPORTANT for security)
In Realtime Database → Rules tab, replace with:

```json
{
  "rules": {
    "users": {
      "$username": {
        ".read": true,
        ".write": true
      }
    },
    "profiles": {
      "$username": {
        ".read": true,
        ".write": true
      }
    },
    "workouts": {
      ".read": true,
      ".write": true
    },
    "clientsList": {
      ".read": true,
      ".write": true
    },
    "storage": {
      ".read": true,
      ".write": true
    },
    "instructor": {
      ".read": true,
      ".write": true
    }
  }
}
```

Click "Publish"

## Step 6: Update Android Build Configuration
The android/app/build.gradle.kts file needs the Firebase plugin.

## Step 7: Build and Test
1. Run `flutter pub get`
2. Build the app
3. Test login and data sync

## Important Notes:
- Make sure your phone/emulator has internet connection
- Data will sync automatically when online
- App works offline using local storage
- Data syncs when connection is restored

## Security (Production):
Before releasing to production, update database rules to:
- Require authentication
- Validate data types
- Limit access by user roles
