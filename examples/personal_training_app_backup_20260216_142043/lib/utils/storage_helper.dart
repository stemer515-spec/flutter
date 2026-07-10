import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

class StorageHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      print('✅ SharedPreferences initialized successfully');
      
      // Initialize Firebase
      await FirebaseService.initialize();
    } catch (e) {
      print('❌ Error initializing storage: $e');
      rethrow;
    }
  }

  static String? getString(String key) {
    if (_prefs == null) {
      print(
        '⚠️ Warning: SharedPreferences not initialized, returning null for key: $key',
      );
      return null;
    }
    return _prefs?.getString(key);
  }

  static Future<bool> setString(String key, String value) async {
    if (_prefs == null) {
      print('⚠️ Warning: SharedPreferences not initialized');
      return false;
    }
    
    // Save to local storage
    final localResult = await _prefs?.setString(key, value) ?? false;
    
    // Sync to Firebase in background
    FirebaseService.setString(key, value).catchError((e) {
      print('Firebase sync error: $e');
    });
    
    return localResult;
  }

  static Future<bool> remove(String key) async {
    if (_prefs == null) {
      print('⚠️ Warning: SharedPreferences not initialized');
      return false;
    }
    
    // Remove from local storage
    final localResult = await _prefs?.remove(key) ?? false;
    
    // Remove from Firebase in background
    FirebaseService.remove(key).catchError((e) {
      print('Firebase sync error: $e');
    });
    
    return localResult;
  }

  static Set<String> getKeys() {
    if (_prefs == null) {
      print('⚠️ Warning: SharedPreferences not initialized');
      return {};
    }
    return _prefs?.getKeys() ?? {};
  }
  
  // Sync from Firebase to local storage
  static Future<void> syncFromFirebase() async {
    try {
      print('🔄 Syncing data from Firebase...');
      
      // Sync user passwords
      final keys = getKeys();
      for (var key in keys) {
        if (key.startsWith('user_')) {
          final username = key.substring(5);
          final firebasePassword = await FirebaseService.getUser(username);
          if (firebasePassword != null) {
            await _prefs?.setString(key, firebasePassword);
          }
        }
      }
      
      print('✅ Firebase sync completed');
    } catch (e) {
      print('Error syncing from Firebase: $e');
    }
  }
}
