import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

class FirebaseService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCZo87fb6es_XzacIj-sJNWxS5KtpvNXiM",
          authDomain: "sim-training-55d86.firebaseapp.com",
          databaseURL: "https://sim-training-55d86-default-rtdb.firebaseio.com",
          projectId: "sim-training-55d86",
          storageBucket: "sim-training-55d86.firebasestorage.app",
          messagingSenderId: "1050830167472",
          appId: "1:1050830167472:web:825a1a286346b376318a75",
        ),
      );
      _initialized = true;
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('⚠️ Firebase initialization error: $e');
      // Continue without Firebase - app will work locally only
    }
  }

  // Real-time streams for listening to changes
  static Stream<DatabaseEvent> watchClientProfile(String username) {
    return _database.ref('profiles/$username').onValue;
  }

  static Stream<DatabaseEvent> watchWorkout(String workoutId) {
    return _database.ref('workouts/$workoutId').onValue;
  }

  static Stream<DatabaseEvent> watchAllWorkouts() {
    return _database.ref('workouts').onValue;
  }

  static Stream<DatabaseEvent> watchClientsList() {
    return _database.ref('clientsList').onValue;
  }

  // User authentication data
  static Future<void> saveUser(String username, String password) async {
    try {
      await _database.ref('users/$username').set({
        'password': password,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving user to Firebase: $e');
    }
  }

  static Future<String?> getUser(String username) async {
    try {
      final snapshot = await _database.ref('users/$username/password').get();
      if (snapshot.exists) {
        return snapshot.value as String;
      }
    } catch (e) {
      print('Error getting user from Firebase: $e');
    }
    return null;
  }

  // Client profiles
  static Future<void> saveClientProfile(
    String username,
    Map<String, dynamic> profile,
  ) async {
    try {
      await _database.ref('profiles/$username').set({
        ...profile,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving profile to Firebase: $e');
    }
  }

  static Future<Map<String, dynamic>?> getClientProfile(String username) async {
    try {
      final snapshot = await _database.ref('profiles/$username').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
    } catch (e) {
      print('Error getting profile from Firebase: $e');
    }
    return null;
  }

  // Workouts
  static Future<void> saveWorkout(
    String workoutId,
    Map<String, dynamic> workout,
  ) async {
    try {
      print(
        '🔥 Firebase: Saving workout $workoutId to path: workouts/$workoutId',
      );
      print('🔥 Firebase: Client name: ${workout['clientName']}');
      await _database.ref('workouts/$workoutId').set({
        ...workout,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('🔥 Firebase: Workout saved successfully');
    } catch (e) {
      print('Error saving workout to Firebase: $e');
    }
  }

  static Future<void> deleteWorkout(String workoutId) async {
    try {
      print('🔥 Firebase: Deleting workout $workoutId');
      await _database.ref('workouts/$workoutId').remove();
      print('✅ Firebase: Workout deleted successfully');
    } catch (e) {
      print('❌ Error deleting workout from Firebase: $e');
    }
  }

  static Future<Map<String, dynamic>?> getWorkout(String workoutId) async {
    try {
      final snapshot = await _database.ref('workouts/$workoutId').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
    } catch (e) {
      print('Error getting workout from Firebase: $e');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getAllWorkouts() async {
    try {
      final snapshot = await _database.ref('workouts').get();
      if (snapshot.exists) {
        final workoutsMap = Map<String, dynamic>.from(snapshot.value as Map);
        return workoutsMap.entries
            .map((e) => {'id': e.key, ...Map<String, dynamic>.from(e.value)})
            .toList();
      }
    } catch (e) {
      print('Error getting all workouts from Firebase: $e');
    }
    return [];
  }

  // Client list
  static Future<void> saveClientsList(List<String> clients) async {
    try {
      await _database.ref('clientsList').set(clients);
    } catch (e) {
      print('Error saving clients list to Firebase: $e');
    }
  }

  static Future<List<String>> getClientsList() async {
    try {
      final snapshot = await _database.ref('clientsList').get();
      if (snapshot.exists) {
        return List<String>.from(snapshot.value as List);
      }
    } catch (e) {
      print('Error getting clients list from Firebase: $e');
    }
    return [];
  }

  // Generic key-value storage
  static Future<void> setString(String key, String value) async {
    try {
      await _database.ref('storage/$key').set(value);
    } catch (e) {
      print('Error setting value in Firebase: $e');
    }
  }

  static Future<String?> getString(String key) async {
    try {
      final snapshot = await _database.ref('storage/$key').get();
      if (snapshot.exists) {
        return snapshot.value as String;
      }
    } catch (e) {
      print('Error getting value from Firebase: $e');
    }
    return null;
  }

  static Future<void> remove(String key) async {
    try {
      await _database.ref('storage/$key').remove();
    } catch (e) {
      print('Error removing value from Firebase: $e');
    }
  }

  // Instructor password
  static Future<void> saveInstructorPassword(String password) async {
    try {
      await _database.ref('instructor/password').set(password);
    } catch (e) {
      print('Error saving instructor password to Firebase: $e');
    }
  }

  static Future<String?> getInstructorPassword() async {
    try {
      final snapshot = await _database.ref('instructor/password').get();
      if (snapshot.exists) {
        return snapshot.value as String;
      }
    } catch (e) {
      print('Error getting instructor password from Firebase: $e');
    }
    return null;
  }

  // Rest Day methods
  static Future<void> saveRestDay(Map<String, dynamic> restDayData) async {
    try {
      final restDayId = restDayData['id'];
      await _database.ref('restDays/$restDayId').set(restDayData);
      print('✅ Rest day $restDayId saved to Firebase');
    } catch (e) {
      print('⚠️ Error saving rest day to Firebase: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllRestDays() async {
    try {
      final snapshot = await _database.ref('restDays').get();
      if (snapshot.exists) {
        final restDaysData = snapshot.value as Map<dynamic, dynamic>;
        return restDaysData.values
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {
      print('⚠️ Error loading rest days from Firebase: $e');
    }
    return [];
  }

  static Stream<DatabaseEvent> watchAllRestDays() {
    return _database.ref('restDays').onValue;
  }

  static Future<void> deleteRestDay(String restDayId) async {
    try {
      await _database.ref('restDays/$restDayId').remove();
      print('✅ Rest day $restDayId deleted from Firebase');
    } catch (e) {
      print('⚠️ Error deleting rest day from Firebase: $e');
    }
  }
}
