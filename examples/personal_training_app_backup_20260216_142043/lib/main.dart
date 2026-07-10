// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'models/workout.dart';
import 'models/client_profile.dart';
import 'models/rest_day.dart';
import 'models/exercise_library.dart';
import 'models/stretching_library.dart';
import 'screens/home_screen.dart';
import 'screens/workout_history_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/login_screen.dart';
import 'screens/instructor_dashboard.dart';
import 'screens/exercise_library_screen.dart';
import 'screens/stretching_screen.dart';
import 'screens/client_profile_screen.dart';
import 'screens/illness_day_screen.dart';
import 'utils/storage_helper.dart';
import 'utils/firebase_service.dart';
import 'utils/security_helper.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  print('🚀 Starting app...');
  WidgetsFlutterBinding.ensureInitialized();
  print('✅ Flutter binding initialized');

  try {
    await StorageHelper.init();
    print('✅ Storage initialized successfully');
    await loadExerciseLibraryFromStorage();
    print('✅ Exercise library loaded from storage');
    await loadStretchingLibraryFromStorage();
    print('✅ Stretching library loaded from storage');
  } catch (e) {
    print('❌ Error initializing storage: $e');
    // Continue anyway - app can work without storage
  }

  print('🎨 Running app...');
  runApp(const PersonalTrainingApp());
}

class PersonalTrainingApp extends StatelessWidget {
  const PersonalTrainingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIM Training Partner',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        typography: Typography.material2021(),
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: false,
          scrolledUnderElevation: 0,
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          foregroundColor: const Color(0xFF1F2937),
          titleTextStyle: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shadowColor: Colors.black.withOpacity(0.06),
          margin: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            elevation: 0,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: const Size(64, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1F2937),
            side: BorderSide(color: colorScheme.outlineVariant),
            minimumSize: const Size(64, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            minimumSize: const Size(64, 44),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF1F5F9),
          selectedColor: colorScheme.primary.withOpacity(0.14),
          disabledColor: const Color(0xFFE5E7EB),
          side: BorderSide.none,
          labelStyle: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
          floatingLabelStyle: TextStyle(color: colorScheme.primary),
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        ),
        dividerTheme: const DividerThemeData(
          thickness: 1,
          color: Color(0xFFE5E7EB),
          space: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1F2937),
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 2,
          height: 72,
          surfaceTintColor: Colors.transparent,
          indicatorColor: colorScheme.primaryContainer.withOpacity(0.65),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? const Color(0xFF1D4ED8)
                  : const Color(0xFF6B7280),
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 22,
              color: selected
                  ? const Color(0xFF1D4ED8)
                  : const Color(0xFF6B7280),
            );
          }),
        ),
      ),
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  String? _userRole; // 'client', 'instructor', or null
  String? _currentUserEmail;
  late ClientProfile _clientProfile;
  late List<ClientProfile> _allClients;
  late List<Workout> _workouts;
  late List<RestDay> _restDays;

  // Firebase stream subscriptions
  StreamSubscription? _workoutsSubscription;
  StreamSubscription? _clientsSubscription;
  StreamSubscription? _restDaysSubscription;

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Set<String> _knownWorkoutIds = <String>{};
  int _workoutNotificationId = 1000;

  @override
  void initState() {
    super.initState();

    _initializeLocalNotifications();

    // Initialize Firebase and sync critical data
    FirebaseService.initialize().then((_) {
      // Keep Firebase warm; role-specific sync happens after login.
    });

    // Initialize workouts and rest days
    _workouts = [];
    _restDays = [];

    _clientProfile = ClientProfile(
      username: '',
      email: '',
      name: '',
      age: 0,
      heightCm: 0,
      weightKg: 0,
      fitnessGoals: '',
      trainingExperience: '',
      trainingLocation: '',
      hobbiesInterests: '',
      injuriesLimitations: '',
      strengthPRs: {},
      bodyMeasurementsCm: {},
    );

    // Initialize with empty clients list
    _allClients = [];

    // Don't set up listeners here - wait until after login
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(settings);

    final androidImplementation = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.requestNotificationsPermission();

    final iosImplementation = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _showNewWorkoutNotification(Workout workout) async {
    const androidDetails = AndroidNotificationDetails(
      'new_workout_channel',
      'New Workouts',
      channelDescription: 'Notifications for newly uploaded workouts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      _workoutNotificationId++,
      'New workout uploaded',
      '${workout.name} is ready for you.',
      details,
    );
  }

  bool _areWorkoutNotificationsEnabled() {
    if (_currentUserEmail == null) return true;
    final value = StorageHelper.getString(
      'workout_notifications_$_currentUserEmail',
    );
    return (value ?? 'true') == 'true';
  }

  bool _matchesClientIdentity(
    String? assignedClientName, {
    ClientProfile? profile,
    String? loginEmail,
  }) {
    final assigned = assignedClientName?.trim().toLowerCase();
    if (assigned == null || assigned.isEmpty) return false;

    final identities = _buildClientIdentityKeys(
      profile: profile,
      loginEmail: loginEmail,
    );
    return identities.contains(assigned);
  }

  Set<String> _buildClientIdentityKeys({
    ClientProfile? profile,
    String? loginEmail,
  }) {
    final effectiveProfile = profile ?? _clientProfile;
    final effectiveLoginEmail = loginEmail ?? _currentUserEmail;

    final identities = <String>{};

    void addIdentity(String? value) {
      final normalized = value?.trim().toLowerCase();
      if (normalized != null && normalized.isNotEmpty) {
        identities.add(normalized);
      }
    }

    addIdentity(effectiveLoginEmail);
    addIdentity(effectiveProfile.username);
    addIdentity(effectiveProfile.email);
    addIdentity(effectiveProfile.name);

    final email = effectiveLoginEmail?.trim().toLowerCase();
    if (email != null && email.contains('@')) {
      addIdentity(email.split('@').first);
    }

    final profileEmail = effectiveProfile.email.trim().toLowerCase();
    if (profileEmail.isNotEmpty && profileEmail.contains('@')) {
      addIdentity(profileEmail.split('@').first);
    }

    return identities;
  }

  @override
  void dispose() {
    _workoutsSubscription?.cancel();
    _clientsSubscription?.cancel();
    _restDaysSubscription?.cancel();
    super.dispose();
  }

  Future<void> _syncInstructorPasswordFromFirebase() async {
    try {
      final firebasePassword = await FirebaseService.getInstructorPassword();
      if (firebasePassword != null) {
        final localPassword = StorageHelper.getString('instructor_password');
        if (localPassword != firebasePassword) {
          print('🔄 Syncing instructor password from Firebase');
          await StorageHelper.setString(
            'instructor_password',
            firebasePassword,
          );
          print('✅ Instructor password synced from Firebase');
        }
      }
    } catch (e) {
      print('⚠️ Error syncing instructor password: $e');
    }
  }

  void _setupFirebaseListeners() {
    // Cancel any existing subscriptions first to prevent duplicates
    _workoutsSubscription?.cancel();
    _clientsSubscription?.cancel();
    _restDaysSubscription?.cancel();

    print('🔄 Setting up Firebase listeners...');

    // Listen for workout changes
    _workoutsSubscription = FirebaseService.watchAllWorkouts().listen(
      (event) {
        if (event.snapshot.value != null) {
          print('🔄 Firebase: Workouts updated, syncing to local...');
          _syncWorkoutsFromFirebase(event.snapshot.value);
        }
      },
      onError: (error) {
        print('❌ Firebase workouts listener error: $error');
      },
    );

    // Listen for clients list changes
    _clientsSubscription = FirebaseService.watchClientsList().listen(
      (event) {
        if (event.snapshot.value != null && _userRole == 'instructor') {
          print('🔄 Firebase: Clients list updated, reloading...');
          _loadAllClients();
        }
      },
      onError: (error) {
        print('❌ Firebase clients listener error: $error');
      },
    );

    // Listen for rest days changes
    _restDaysSubscription = FirebaseService.watchAllRestDays().listen(
      (event) {
        if (event.snapshot.value != null) {
          print('🔄 Firebase: Rest days updated, syncing to local...');
          _syncRestDaysFromFirebase(event.snapshot.value);
        }
      },
      onError: (error) {
        print('❌ Firebase rest days listener error: $error');
      },
    );

    print('✅ Firebase listeners active');
  }

  void _syncWorkoutsFromFirebase(dynamic firebaseData) {
    try {
      final workoutsMap = Map<String, dynamic>.from(firebaseData as Map);
      final firebaseWorkouts = <Workout>[];

      print('🔄 Syncing ${workoutsMap.length} workouts from Firebase');
      print(
        '👤 User role: $_userRole, Client name: ${_clientProfile.name}, Email: $_currentUserEmail',
      );

      for (final entry in workoutsMap.entries) {
        final workoutData = Map<String, dynamic>.from(entry.value);
        final workoutClientName = workoutData['clientName'] ?? '';

        // If this is a client view, only show workouts assigned to this client
        if (_userRole == 'client') {
          print(
            '🔍 Checking workout "${workoutData['name']}" for client: $workoutClientName',
          );
          if (!_matchesClientIdentity(workoutClientName)) {
            print('⏭️ Skipping workout - not for this client');
            continue; // Skip workouts not belonging to this client
          }
          print('✅ Including workout for client');
        }

        print('🔍 Syncing workout: ${workoutData['name']}');
        print('🔍 Exercises data: ${workoutData['exercises']}');

        final exercises = <Exercise>[];
        try {
          final exercisesData = workoutData['exercises'];
          if (exercisesData != null && exercisesData is List) {
            for (var e in exercisesData) {
              try {
                final exercise = Exercise(
                  name: e['name']?.toString() ?? '',
                  sets: (e['sets'] is int)
                      ? e['sets']
                      : (int.tryParse(e['sets']?.toString() ?? '0') ?? 0),
                  reps: (e['reps'] is int)
                      ? e['reps']
                      : (int.tryParse(e['reps']?.toString() ?? '0') ?? 0),
                  weight: (e['weight'] is double)
                      ? e['weight']
                      : ((e['weight'] is int)
                            ? (e['weight'] as int).toDouble()
                            : double.tryParse(e['weight']?.toString() ?? '0') ??
                                  0.0),
                  notes: e['notes']?.toString(),
                  // Parse cardio fields from Firebase
                  isCardio: e['isCardio'] ?? false,
                  durationMinutes: e['durationMinutes'],
                  distanceKm: e['distanceKm'] != null
                      ? (e['distanceKm'] is double
                            ? e['distanceKm']
                            : double.tryParse(
                                e['distanceKm']?.toString() ?? '',
                              ))
                      : null,
                );
                exercises.add(exercise);
              } catch (exErr) {
                print('❌ Error parsing exercise in sync: $exErr');
              }
            }
          }
        } catch (exError) {
          print('❌ Error parsing exercises in sync: $exError');
        }

        print('✅ Total parsed ${exercises.length} exercises in sync');

        final workout = Workout(
          id: workoutData['id'] ?? entry.key,
          name: workoutData['name'] ?? '',
          date: DateTime.fromMillisecondsSinceEpoch(workoutData['date'] ?? 0),
          exercises: exercises,
          clientName: workoutData['clientName'] ?? '',
          notes: workoutData['notes'],
          isCompleted: workoutData['isCompleted'] ?? false,
          isReviewedByInstructor:
              workoutData['isReviewedByInstructor'] ?? false,
          feedback: workoutData['feedback'],
          instructorReview: workoutData['instructorReview'],
          isReviewAcknowledged: workoutData['isReviewAcknowledged'] ?? false,
        );

        firebaseWorkouts.add(workout);

        // Also save to local storage for offline access
        _saveWorkoutToLocalOnly(workout);
      }

      print('✅ Synced ${firebaseWorkouts.length} workouts for this user');

      final previousWorkoutIds = Set<String>.from(_knownWorkoutIds);
      final latestWorkoutIds = firebaseWorkouts.map((w) => w.id).toSet();
      final newWorkoutIds = latestWorkoutIds.difference(previousWorkoutIds);

      if (_userRole == 'client' &&
          newWorkoutIds.isNotEmpty &&
          _areWorkoutNotificationsEnabled()) {
        for (final workout in firebaseWorkouts) {
          if (newWorkoutIds.contains(workout.id)) {
            _showNewWorkoutNotification(workout);
          }
        }
      }

      _knownWorkoutIds
        ..clear()
        ..addAll(latestWorkoutIds);

      // Update state if workouts changed
      if (mounted) {
        setState(() {
          _workouts = firebaseWorkouts;
        });
      }
    } catch (e) {
      print('❌ Error syncing workouts from Firebase: $e');
    }
  }

  void _saveWorkoutToLocalOnly(Workout workout) {
    // Save to localStorage without triggering Firebase sync again
    final exercisesJson = workout.exercises
        .map(
          (e) =>
              '${e.name}|${e.sets}|${e.reps}|${e.weight}|${e.notes ?? ''}|${e.isCardio}|${e.durationMinutes ?? ''}|${e.distanceKm ?? ''}',
        )
        .join(';;');

    final workoutJson =
        '${workout.id}|${workout.name}|${workout.date.millisecondsSinceEpoch}|${workout.clientName}|${workout.notes ?? ''}|$exercisesJson|${workout.isCompleted}|${workout.isReviewedByInstructor}|${workout.feedback ?? ''}|${workout.instructorReview ?? ''}|${workout.isReviewAcknowledged}';

    StorageHelper.setString('workout_${workout.id}', workoutJson);
    _indexWorkoutForLocalClientKeys(workout);
  }

  void _indexWorkoutForLocalClientKeys(Workout workout) {
    final assignedRaw = workout.clientName.trim();
    if (assignedRaw.isEmpty) {
      return;
    }

    final keys = <String>{assignedRaw, assignedRaw.toLowerCase()};
    if (assignedRaw.contains('@')) {
      final localPart = assignedRaw.split('@').first;
      keys.add(localPart);
      keys.add(localPart.toLowerCase());
    }

    for (final key in keys) {
      if (key.trim().isEmpty) {
        continue;
      }

      final workoutListKey = 'workouts_$key';
      final workoutList = StorageHelper.getString(workoutListKey) ?? '';
      final workoutIds = workoutList.isEmpty
          ? <String>[]
          : workoutList.split(',').where((id) => id.isNotEmpty).toList();

      if (!workoutIds.contains(workout.id)) {
        workoutIds.add(workout.id);
        StorageHelper.setString(workoutListKey, workoutIds.join(','));
      }
    }
  }

  void _syncRestDaysFromFirebase(dynamic firebaseData) {
    try {
      final restDaysMap = Map<String, dynamic>.from(firebaseData as Map);
      final firebaseRestDays = <RestDay>[];

      print('🔄 Syncing ${restDaysMap.length} rest days from Firebase');
      print(
        '👤 User role: $_userRole, Client name: ${_clientProfile.name}, Email: $_currentUserEmail',
      );

      for (final entry in restDaysMap.entries) {
        try {
          final restDayData = Map<String, dynamic>.from(entry.value);
          final restDayClientName = restDayData['clientName'] ?? '';

          // If this is a client view, only show rest days assigned to this client
          if (_userRole == 'client') {
            print('🔍 Checking rest day for client: $restDayClientName');
            print('   My profile name: ${_clientProfile.name}');
            print('   My email: $_currentUserEmail');
            print('   Rest day client: $restDayClientName');

            if (!_matchesClientIdentity(restDayClientName)) {
              print('⏭️ Skipping rest day - not for this client');
              continue; // Skip rest days not belonging to this client
            }
            print('✅ Including rest day for client');
          }

          final parsedDate = DateTime.parse(
            restDayData['date'] ?? DateTime.now().toIso8601String(),
          );
          // Normalize to midnight for calendar matching
          final normalizedDate = DateTime(
            parsedDate.year,
            parsedDate.month,
            parsedDate.day,
          );

          final restDay = RestDay(
            id: restDayData['id'] ?? entry.key,
            date: normalizedDate,
            clientName: restDayClientName,
            notes: restDayData['notes'],
          );

          print(
            '📅 Rest day parsed: ${restDay.date} for ${restDay.clientName}',
          );
          print('   Is future date: ${restDay.date.isAfter(DateTime.now())}');

          firebaseRestDays.add(restDay);

          // Save to local storage for offline access
          _saveRestDayToLocalOnly(restDay);
        } catch (e) {
          print('❌ Error parsing rest day ${entry.key}: $e');
        }
      }

      print('✅ Synced ${firebaseRestDays.length} rest days for this user');

      // Update state if rest days changed
      if (mounted) {
        setState(() {
          _restDays = firebaseRestDays;
        });
      }
    } catch (e) {
      print('❌ Error syncing rest days from Firebase: $e');
    }
  }

  void _saveRestDayToLocalOnly(RestDay restDay) {
    // Save to localStorage without triggering Firebase sync again
    final restDayJson =
        '${restDay.id}|${restDay.date.millisecondsSinceEpoch}|${restDay.clientName}|${restDay.notes ?? ''}';

    StorageHelper.setString('restday_${restDay.id}', restDayJson);
  }

  String _serializeBodyMeasurements(Map<String, double> measurements) {
    if (measurements.isEmpty) return '';
    return measurements.entries.map((e) => '${e.key}:${e.value}').join(',');
  }

  Map<String, double> _deserializeBodyMeasurements(String? serialized) {
    if (serialized == null || serialized.isEmpty) return {};

    final measurements = <String, double>{};
    for (final entry in serialized.split(',')) {
      final parts = entry.split(':');
      if (parts.length != 2) continue;
      final value = double.tryParse(parts[1]);
      if (value != null) {
        measurements[parts[0]] = value;
      }
    }
    return measurements;
  }

  void _loadUserData(String username) async {
    _currentUserEmail = username;

    StorageHelper.setString(
      'workout_notifications_$username',
      StorageHelper.getString('workout_notifications_$username') ?? 'true',
    );

    print('🔄 Loading data for client: $username');

    // First, try to load profile from Firebase
    try {
      final firebaseProfile = await FirebaseService.getClientProfile(username);
      if (firebaseProfile != null) {
        print('✅ Loaded profile from Firebase');
        // Save to local storage for offline access
        StorageHelper.setString(
          'profile_email_$username',
          firebaseProfile['email'] ?? '',
        );
        StorageHelper.setString(
          'profile_name_$username',
          firebaseProfile['name'] ?? '',
        );
        StorageHelper.setString(
          'profile_age_$username',
          firebaseProfile['age']?.toString() ?? '0',
        );
        StorageHelper.setString(
          'profile_height_$username',
          firebaseProfile['heightCm']?.toString() ?? '0',
        );
        StorageHelper.setString(
          'profile_weight_$username',
          firebaseProfile['weightKg']?.toString() ?? '0',
        );
        StorageHelper.setString(
          'profile_goals_$username',
          firebaseProfile['fitnessGoals'] ?? '',
        );
        StorageHelper.setString(
          'profile_smart_goals_$username',
          firebaseProfile['smartGoals'] ?? '',
        );
        StorageHelper.setString(
          'profile_experience_$username',
          firebaseProfile['trainingExperience'] ?? '',
        );
        StorageHelper.setString(
          'profile_location_$username',
          firebaseProfile['trainingLocation'] ?? '',
        );
        StorageHelper.setString(
          'profile_hobbies_$username',
          firebaseProfile['hobbiesInterests'] ?? '',
        );
        StorageHelper.setString(
          'profile_limitations_$username',
          firebaseProfile['injuriesLimitations'] ?? '',
        );

        if (firebaseProfile['bodyMeasurementsCm'] != null) {
          final measurements =
              (firebaseProfile['bodyMeasurementsCm'] as Map<dynamic, dynamic>)
                  .map(
                    (key, value) => MapEntry(
                      key.toString(),
                      (value is double)
                          ? value
                          : double.tryParse(value.toString()) ?? 0.0,
                    ),
                  );
          StorageHelper.setString(
            'profile_measurements_$username',
            _serializeBodyMeasurements(measurements),
          );
        }

        // Save PRs if they exist in Firebase
        if (firebaseProfile['strengthPRs'] != null) {
          final prsMap =
              firebaseProfile['strengthPRs'] as Map<dynamic, dynamic>;
          final prsJson = prsMap.entries
              .map((e) => '${e.key}:${e.value}')
              .join(',');
          StorageHelper.setString('profile_prs_$username', prsJson);
        }
      }
    } catch (e) {
      print('⚠️ Could not load profile from Firebase: $e');
    }

    // Load PRs from localStorage
    Map<String, double> loadedPRs = {};
    final prsString = StorageHelper.getString('profile_prs_$username') ?? '';
    if (prsString.isNotEmpty) {
      try {
        final prsEntries = prsString.split(',');
        for (var entry in prsEntries) {
          final parts = entry.split(':');
          if (parts.length == 2) {
            final exerciseName = parts[0];
            final weight = double.tryParse(parts[1]);
            if (weight != null) {
              loadedPRs[exerciseName] = weight;
            }
          }
        }
        print('✅ Loaded ${loadedPRs.length} PRs from localStorage');
      } catch (e) {
        print('⚠️ Error parsing PRs: $e');
      }
    }

    // Load user profile from local storage (either just synced or cached)
    final loadedProfile = ClientProfile(
      username: username,
      email: StorageHelper.getString('profile_email_$username') ?? '',
      name: StorageHelper.getString('profile_name_$username') ?? username,
      age:
          int.tryParse(
            StorageHelper.getString('profile_age_$username') ?? '0',
          ) ??
          0,
      heightCm:
          double.tryParse(
            StorageHelper.getString('profile_height_$username') ?? '0',
          ) ??
          0.0,
      weightKg:
          double.tryParse(
            StorageHelper.getString('profile_weight_$username') ?? '0',
          ) ??
          0.0,
      fitnessGoals: StorageHelper.getString('profile_goals_$username') ?? '',
      smartGoals:
          StorageHelper.getString('profile_smart_goals_$username') ?? '',
      trainingExperience:
          StorageHelper.getString('profile_experience_$username') ?? '',
      trainingLocation:
          StorageHelper.getString('profile_location_$username') ?? '',
      hobbiesInterests:
          StorageHelper.getString('profile_hobbies_$username') ?? '',
      injuriesLimitations:
          StorageHelper.getString('profile_limitations_$username') ?? '',
      strengthPRs: loadedPRs,
      bodyMeasurementsCm: _deserializeBodyMeasurements(
        StorageHelper.getString('profile_measurements_$username') ?? '',
      ),
    );

    // Load all workouts from Firebase for this client
    final userWorkouts = <Workout>[];
    try {
      final allWorkouts = await FirebaseService.getAllWorkouts();
      print('🔄 Loaded ${allWorkouts.length} workouts from Firebase');

      // Filter workouts for this specific client
      final clientWorkouts = allWorkouts.where((w) {
        return _matchesClientIdentity(
          w['clientName']?.toString(),
          profile: loadedProfile,
          loginEmail: username,
        );
      }).toList();

      print(
        '✅ Found ${clientWorkouts.length} workouts for client: ${loadedProfile.name}',
      );

      for (final workoutData in clientWorkouts) {
        try {
          print('🔍 Loading workout: ${workoutData['name']}');
          print(
            '🔍 Exercises data type: ${workoutData['exercises'].runtimeType}',
          );
          print('🔍 Exercises data: ${workoutData['exercises']}');

          final exercises = <Exercise>[];
          try {
            final exercisesData = workoutData['exercises'];
            if (exercisesData != null) {
              if (exercisesData is List) {
                for (var e in exercisesData) {
                  try {
                    final exercise = Exercise(
                      name: e['name']?.toString() ?? '',
                      sets: (e['sets'] is int)
                          ? e['sets']
                          : (int.tryParse(e['sets']?.toString() ?? '0') ?? 0),
                      reps: (e['reps'] is int)
                          ? e['reps']
                          : (int.tryParse(e['reps']?.toString() ?? '0') ?? 0),
                      weight: (e['weight'] is double)
                          ? e['weight']
                          : ((e['weight'] is int)
                                ? (e['weight'] as int).toDouble()
                                : double.tryParse(
                                        e['weight']?.toString() ?? '0',
                                      ) ??
                                      0.0),
                      notes: e['notes']?.toString(),
                    );
                    exercises.add(exercise);
                    print(
                      '✅ Added exercise: ${exercise.name} ${exercise.sets}x${exercise.reps} @ ${exercise.weight}kg',
                    );
                  } catch (exerciseError) {
                    print(
                      '❌ Error parsing individual exercise: $exerciseError',
                    );
                    print('Exercise data: $e');
                  }
                }
              } else {
                print(
                  '⚠️ Exercises data is not a List: ${exercisesData.runtimeType}',
                );
              }
            } else {
              print('⚠️ Exercises data is null');
            }
          } catch (exError) {
            print('❌ Error parsing exercises: $exError');
          }

          print(
            '✅ Total parsed ${exercises.length} exercises for workout ${workoutData['name']}',
          );

          final workout = Workout(
            id: workoutData['id'] ?? '',
            name: workoutData['name'] ?? '',
            date: DateTime.fromMillisecondsSinceEpoch(workoutData['date'] ?? 0),
            exercises: exercises,
            clientName: workoutData['clientName'] ?? '',
            notes: workoutData['notes'],
            isCompleted: workoutData['isCompleted'] ?? false,
            isReviewedByInstructor:
                workoutData['isReviewedByInstructor'] ?? false,
            feedback: workoutData['feedback'],
            instructorReview: workoutData['instructorReview'],
            isReviewAcknowledged: workoutData['isReviewAcknowledged'] ?? false,
          );

          userWorkouts.add(workout);
          // Save to local storage for offline access
          _saveWorkoutToLocalOnly(workout);
        } catch (e) {
          print('❌ Error parsing workout: $e');
        }
      }
    } catch (e) {
      print('⚠️ Could not load workouts from Firebase: $e');
      print('📦 Falling back to local storage...');

      // Fallback to local storage
      final workoutListKey = 'workouts_$username';
      final workoutIds =
          StorageHelper.getString(
            workoutListKey,
          )?.split(',').where((id) => id.isNotEmpty).toList() ??
          [];

      for (final workoutId in workoutIds) {
        final storageKey = 'workout_$workoutId';
        final workoutData = StorageHelper.getString(storageKey);
        if (workoutData != null && workoutData.isNotEmpty) {
          try {
            final workout = _deserializeWorkout(workoutData);
            userWorkouts.add(workout);
          } catch (e) {
            print('❌ Error loading workout $workoutId: $e');
          }
        }
      }
    }

    if (userWorkouts.isEmpty) {
      print('📦 No workouts from Firebase, checking local storage fallback...');
      final identityKeys = _buildClientIdentityKeys(
        profile: loadedProfile,
        loginEmail: username,
      );
      final lookupKeys = <String>{...identityKeys, username};
      if (loadedProfile.username.trim().isNotEmpty) {
        lookupKeys.add(loadedProfile.username);
      }
      if (loadedProfile.name.trim().isNotEmpty) {
        lookupKeys.add(loadedProfile.name);
      }
      if (loadedProfile.email.trim().isNotEmpty) {
        lookupKeys.add(loadedProfile.email);
        if (loadedProfile.email.contains('@')) {
          lookupKeys.add(loadedProfile.email.split('@').first);
        }
      }
      final seenWorkoutIds = <String>{};

      for (final rawIdentity in lookupKeys) {
        final identity = rawIdentity.trim();
        if (identity.isEmpty) {
          continue;
        }

        final workoutListKey = 'workouts_$identity';
        final workoutIds =
            StorageHelper.getString(
              workoutListKey,
            )?.split(',').where((id) => id.isNotEmpty).toList() ??
            [];

        for (final workoutId in workoutIds) {
          if (!seenWorkoutIds.add(workoutId)) {
            continue;
          }

          final storageKey = 'workout_$workoutId';
          final workoutData = StorageHelper.getString(storageKey);
          if (workoutData != null && workoutData.isNotEmpty) {
            try {
              final workout = _deserializeWorkout(workoutData);
              if (_matchesClientIdentity(
                workout.clientName,
                profile: loadedProfile,
                loginEmail: username,
              )) {
                userWorkouts.add(workout);
              }
            } catch (e) {
              print('❌ Error loading workout $workoutId from fallback: $e');
            }
          }
        }
      }
    }

    print('✅ Loaded ${userWorkouts.length} total workouts for $username');

    _knownWorkoutIds
      ..clear()
      ..addAll(userWorkouts.map((w) => w.id));

    // Load rest days from Firebase for this client
    final userRestDays = <RestDay>[];
    try {
      final allRestDays = await FirebaseService.getAllRestDays();
      print('🔄 Loaded ${allRestDays.length} rest days from Firebase');

      // Filter rest days for this specific client
      final clientRestDays = allRestDays.where((rd) {
        return _matchesClientIdentity(
          rd['clientName']?.toString(),
          profile: loadedProfile,
          loginEmail: username,
        );
      }).toList();

      print(
        '✅ Found ${clientRestDays.length} rest days for client: ${loadedProfile.name}',
      );

      for (final restDayData in clientRestDays) {
        try {
          final dateStr = restDayData['date'];
          DateTime restDayDate;

          // Parse date with fallback
          if (dateStr != null && dateStr.toString().isNotEmpty) {
            try {
              restDayDate = DateTime.parse(dateStr);
            } catch (e) {
              print('⚠️ Invalid date format: $dateStr, using current date');
              restDayDate = DateTime.now();
            }
          } else {
            print('⚠️ No date provided, using current date');
            restDayDate = DateTime.now();
          }

          // Normalize to midnight for calendar matching
          final normalizedDate = DateTime(
            restDayDate.year,
            restDayDate.month,
            restDayDate.day,
          );

          final restDay = RestDay(
            id: restDayData['id'] ?? '',
            date: normalizedDate,
            clientName: restDayData['clientName'] ?? '',
            notes: restDayData['notes'],
          );

          userRestDays.add(restDay);
          // Save to local storage for offline access
          _saveRestDayToLocalOnly(restDay);
        } catch (e) {
          print('❌ Error parsing rest day: $e');
        }
      }
    } catch (e) {
      print('⚠️ Could not load rest days from Firebase: $e');
      print('📦 Falling back to local storage...');

      // Fallback to local storage
      final restDaysList = StorageHelper.getString('all_restdays') ?? '';
      if (restDaysList.isNotEmpty) {
        final restDayIds = restDaysList
            .split(',')
            .where((id) => id.isNotEmpty)
            .toList();

        for (final restDayId in restDayIds) {
          final storageKey = 'restday_$restDayId';
          final restDayStr = StorageHelper.getString(storageKey);
          if (restDayStr != null && restDayStr.isNotEmpty) {
            try {
              final parts = restDayStr.split('|');
              if (parts.length >= 3) {
                final clientName = parts[2];
                // Only load rest days for this client
                if (_matchesClientIdentity(
                  clientName,
                  profile: loadedProfile,
                  loginEmail: username,
                )) {
                  final restDay = RestDay(
                    id: parts[0],
                    date: DateTime.fromMillisecondsSinceEpoch(
                      int.parse(parts[1]),
                    ),
                    clientName: clientName,
                    notes: parts.length > 3 && parts[3].isNotEmpty
                        ? parts[3]
                        : null,
                  );
                  userRestDays.add(restDay);
                }
              }
            } catch (e) {
              print('❌ Error loading rest day $restDayId: $e');
            }
          }
        }
      }
    }

    if (userRestDays.isEmpty) {
      print(
        '📦 No rest days from Firebase, checking local storage fallback...',
      );
      final restDaysList = StorageHelper.getString('all_restdays') ?? '';
      if (restDaysList.isNotEmpty) {
        final restDayIds = restDaysList
            .split(',')
            .where((id) => id.isNotEmpty)
            .toList();

        for (final restDayId in restDayIds) {
          final storageKey = 'restday_$restDayId';
          final restDayStr = StorageHelper.getString(storageKey);
          if (restDayStr != null && restDayStr.isNotEmpty) {
            try {
              final parts = restDayStr.split('|');
              if (parts.length >= 3) {
                final clientName = parts[2];
                if (_matchesClientIdentity(
                  clientName,
                  profile: loadedProfile,
                  loginEmail: username,
                )) {
                  final restDay = RestDay(
                    id: parts[0],
                    date: DateTime.fromMillisecondsSinceEpoch(
                      int.parse(parts[1]),
                    ),
                    clientName: clientName,
                    notes: parts.length > 3 && parts[3].isNotEmpty
                        ? parts[3]
                        : null,
                  );
                  userRestDays.add(restDay);
                }
              }
            } catch (e) {
              print('❌ Error loading rest day $restDayId from fallback: $e');
            }
          }
        }
      }
    }

    print('✅ Loaded ${userRestDays.length} total rest days for $username');

    // Update state with loaded profile, workouts, and rest days
    setState(() {
      _clientProfile = loadedProfile;
      _workouts = userWorkouts;
      _restDays = userRestDays;
    });

    // Now set up Firebase listeners for real-time updates
    print('🔄 Setting up Firebase listeners for client: ${loadedProfile.name}');
    _setupFirebaseListeners();
  }

  Workout _deserializeWorkout(String jsonStr) {
    // Split only the first 8 pipes to separate workout metadata from exercises
    // Format: id|name|timestamp|clientName|notes|exercisesJson|isCompleted|isReviewedByInstructor|feedback
    // But exercisesJson contains pipes too, so we can't split everything

    final firstPipeIndex = jsonStr.indexOf('|');
    if (firstPipeIndex == -1) {
      print('❌ DEBUG: No pipe found in workout data');
      return Workout(
        id: '',
        name: 'Workout',
        date: DateTime.now(),
        exercises: [],
      );
    }

    final id = jsonStr.substring(0, firstPipeIndex);
    var remaining = jsonStr.substring(firstPipeIndex + 1);

    final secondPipeIndex = remaining.indexOf('|');
    if (secondPipeIndex == -1) {
      return Workout(
        id: id,
        name: remaining,
        date: DateTime.now(),
        exercises: [],
      );
    }

    final name = remaining.substring(0, secondPipeIndex);
    remaining = remaining.substring(secondPipeIndex + 1);

    final thirdPipeIndex = remaining.indexOf('|');
    if (thirdPipeIndex == -1) {
      return Workout(id: id, name: name, date: DateTime.now(), exercises: []);
    }

    final dateStr = remaining.substring(0, thirdPipeIndex);
    remaining = remaining.substring(thirdPipeIndex + 1);

    final fourthPipeIndex = remaining.indexOf('|');
    if (fourthPipeIndex == -1) {
      return Workout(
        id: id,
        name: name,
        date: DateTime.fromMillisecondsSinceEpoch(int.tryParse(dateStr) ?? 0),
        exercises: [],
      );
    }

    final clientName = remaining.substring(0, fourthPipeIndex);
    remaining = remaining.substring(fourthPipeIndex + 1);

    final fifthPipeIndex = remaining.indexOf('|');
    if (fifthPipeIndex == -1) {
      return Workout(
        id: id,
        name: name,
        date: DateTime.fromMillisecondsSinceEpoch(int.tryParse(dateStr) ?? 0),
        clientName: clientName,
        exercises: [],
      );
    }

    final notes = remaining.substring(0, fifthPipeIndex);
    remaining = remaining.substring(fifthPipeIndex + 1);

    // Now find the next double semicolon or the last |true/false pattern to identify where exercises end
    // Format of remaining: exercisesJson|isCompleted|isReviewedByInstructor|feedback|instructorReview|isReviewAcknowledged
    // We need to find the last five pipes
    final lastPipes = <int>[];
    for (int i = remaining.length - 1; i >= 0; i--) {
      if (remaining[i] == '|') {
        lastPipes.add(i);
        if (lastPipes.length == 5) break;
      }
    }

    String exercisesStr = '';
    bool isCompleted = false;
    bool isReviewedByInstructor = false;
    bool isReviewAcknowledged = false;
    String? feedback;
    String? instructorReview;

    if (lastPipes.length >= 5) {
      // We found 5 pipes from the end
      final lastPipeIdx = lastPipes[0]; // Before isReviewAcknowledged
      final secondLastPipeIdx = lastPipes[1]; // Before instructorReview
      final thirdLastPipeIdx = lastPipes[2]; // Before feedback
      final fourthLastPipeIdx = lastPipes[3]; // Before isReviewedByInstructor
      final fifthLastPipeIdx = lastPipes[4]; // Before isCompleted

      exercisesStr = remaining.substring(0, fifthLastPipeIdx);
      isCompleted =
          remaining.substring(fifthLastPipeIdx + 1, fourthLastPipeIdx) ==
          'true';
      isReviewedByInstructor =
          remaining.substring(fourthLastPipeIdx + 1, thirdLastPipeIdx) ==
          'true';

      feedback = remaining.substring(thirdLastPipeIdx + 1, secondLastPipeIdx);
      if (feedback.isEmpty) feedback = null;

      instructorReview = remaining.substring(
        secondLastPipeIdx + 1,
        lastPipeIdx,
      );
      if (instructorReview.isEmpty) instructorReview = null;

      isReviewAcknowledged = remaining.substring(lastPipeIdx + 1) == 'true';
    } else if (lastPipes.length >= 4) {
      // Fallback for old format without isReviewAcknowledged
      final lastPipeIdx = lastPipes[0];
      final secondLastPipeIdx = lastPipes[1];
      final thirdLastPipeIdx = lastPipes[2];
      final fourthLastPipeIdx = lastPipes[3];

      exercisesStr = remaining.substring(0, fourthLastPipeIdx);
      isCompleted =
          remaining.substring(fourthLastPipeIdx + 1, thirdLastPipeIdx) ==
          'true';
      isReviewedByInstructor =
          remaining.substring(thirdLastPipeIdx + 1, secondLastPipeIdx) ==
          'true';

      feedback = remaining.substring(secondLastPipeIdx + 1, lastPipeIdx);
      if (feedback.isEmpty) feedback = null;

      instructorReview = remaining.substring(lastPipeIdx + 1);
      if (instructorReview.isEmpty) instructorReview = null;
    } else if (lastPipes.length >= 3) {
      // Even older format
      final lastPipeIdx = lastPipes[0];
      final secondLastPipeIdx = lastPipes[1];
      final thirdLastPipeIdx = lastPipes[2];

      exercisesStr = remaining.substring(0, thirdLastPipeIdx);
      isCompleted =
          remaining.substring(thirdLastPipeIdx + 1, secondLastPipeIdx) ==
          'true';
      isReviewedByInstructor =
          remaining.substring(secondLastPipeIdx + 1, lastPipeIdx) == 'true';

      feedback = remaining.substring(lastPipeIdx + 1);
      if (feedback.isEmpty) feedback = null;
    } else if (lastPipes.length >= 2) {
      // Even older format
      final lastPipeIdx = lastPipes[0];
      final secondLastPipeIdx = lastPipes[1];

      exercisesStr = remaining.substring(0, secondLastPipeIdx);
      isCompleted =
          remaining.substring(secondLastPipeIdx + 1, lastPipeIdx) == 'true';
      isReviewedByInstructor = remaining.substring(lastPipeIdx + 1) == 'true';
    } else {
      exercisesStr = remaining;
    }

    print('🔍 DEBUG: Deserializing workout - ID: $id, Name: $name');
    print('🔍 DEBUG: Exercises string: $exercisesStr');

    final exercises = <Exercise>[];
    if (exercisesStr.isNotEmpty &&
        exercisesStr != 'true' &&
        exercisesStr != 'false') {
      final exercisesList = exercisesStr.split(';;');
      print('🔍 DEBUG: Parsing ${exercisesList.length} exercises');
      for (final exStr in exercisesList) {
        if (exStr.isNotEmpty) {
          final exParts = exStr.split('|');
          print('🔍 DEBUG: Exercise parts (${exParts.length}): $exParts');
          if (exParts.length >= 4) {
            final exercise = Exercise(
              name: exParts[0],
              sets: int.tryParse(exParts[1]) ?? 0,
              reps: int.tryParse(exParts[2]) ?? 0,
              weight: double.tryParse(exParts[3]) ?? 0.0,
              notes: exParts.length > 4 && exParts[4].isNotEmpty
                  ? exParts[4]
                  : null,
              // Parse cardio fields if present (added for cardio support)
              isCardio: exParts.length > 5 && exParts[5] == 'true',
              durationMinutes: exParts.length > 6 && exParts[6].isNotEmpty
                  ? int.tryParse(exParts[6])
                  : null,
              distanceKm: exParts.length > 7 && exParts[7].isNotEmpty
                  ? double.tryParse(exParts[7])
                  : null,
            );
            exercises.add(exercise);
            print(
              '✅ DEBUG: Added exercise: ${exercise.name} ${exercise.isCardio ? "(Cardio)" : "${exercise.sets}x${exercise.reps} @ ${exercise.weight}kg"}',
            );
          }
        }
      }
    }
    print('✅ DEBUG: Total exercises parsed: ${exercises.length}');

    final date = DateTime.fromMillisecondsSinceEpoch(
      int.tryParse(dateStr) ?? 0,
    );

    return Workout(
      id: id,
      name: name,
      date: date,
      exercises: exercises,
      notes: notes,
      feedback: feedback,
      instructorReview: instructorReview,
      clientName: clientName,
      isCompleted: isCompleted,
      isReviewedByInstructor: isReviewedByInstructor,
      isReviewAcknowledged: isReviewAcknowledged,
    );
  }

  void _loadAllClients() async {
    var clientsList = StorageHelper.getString('clients_list') ?? '';

    // Refresh clients list from Firebase first so instructor has latest assignments
    try {
      final firebaseClients = await FirebaseService.getClientsList();
      if (firebaseClients.isNotEmpty) {
        final normalizedUsernames = firebaseClients
            .map((u) => u.trim())
            .where((u) => u.isNotEmpty)
            .toSet()
            .toList();
        clientsList = normalizedUsernames.join(',');
        StorageHelper.setString('clients_list', clientsList);
      }
    } catch (e) {
      print('⚠️ Could not refresh clients list from Firebase: $e');
    }

    if (clientsList.isEmpty) {
      setState(() {
        _allClients = [];
      });
      return;
    }

    final usernames = clientsList.split(',');
    final clients = <ClientProfile>[];

    for (final username in usernames) {
      if (username.trim().isEmpty) {
        continue;
      }

      final normalizedUsername = username.trim();

      // Try to load PRs from Firebase first, fall back to localStorage
      Map<String, double> clientPRs = {};

      // Load from Firebase to get latest PRs
      try {
        final firebaseProfile = await FirebaseService.getClientProfile(
          normalizedUsername,
        );
        if (firebaseProfile != null) {
          StorageHelper.setString(
            'profile_email_$normalizedUsername',
            firebaseProfile['email'] ?? '',
          );
          StorageHelper.setString(
            'profile_name_$normalizedUsername',
            firebaseProfile['name'] ?? normalizedUsername,
          );

          if (firebaseProfile['strengthPRs'] != null) {
            final prsMap =
                firebaseProfile['strengthPRs'] as Map<dynamic, dynamic>;
            clientPRs = prsMap.map(
              (key, value) => MapEntry(
                key.toString(),
                (value is double)
                    ? value
                    : double.tryParse(value.toString()) ?? 0.0,
              ),
            );
            print(
              '📊 Loaded ${clientPRs.length} PRs for $normalizedUsername from Firebase',
            );

            // Update localStorage with latest PRs from Firebase
            final prsJson = clientPRs.entries
                .map((e) => '${e.key}:${e.value}')
                .join(',');
            StorageHelper.setString('profile_prs_$normalizedUsername', prsJson);
          }
        }
      } catch (e) {
        print(
          '⚠️ Could not load PRs from Firebase for $normalizedUsername: $e',
        );

        // Fall back to localStorage
        final prsString =
            StorageHelper.getString('profile_prs_$normalizedUsername') ?? '';
        if (prsString.isNotEmpty) {
          try {
            final prsEntries = prsString.split(',');
            for (var entry in prsEntries) {
              final parts = entry.split(':');
              if (parts.length == 2) {
                final exerciseName = parts[0];
                final weight = double.tryParse(parts[1]);
                if (weight != null) {
                  clientPRs[exerciseName] = weight;
                }
              }
            }
            print(
              '📊 Loaded ${clientPRs.length} PRs for $normalizedUsername from localStorage',
            );
          } catch (e) {
            print('⚠️ Error parsing PRs for $normalizedUsername: $e');
          }
        }
      }

      final profile = ClientProfile(
        username: normalizedUsername,
        email:
            StorageHelper.getString('profile_email_$normalizedUsername') ?? '',
        name:
            StorageHelper.getString('profile_name_$normalizedUsername') ??
            normalizedUsername,
        age:
            int.tryParse(
              StorageHelper.getString('profile_age_$normalizedUsername') ?? '0',
            ) ??
            0,
        heightCm:
            double.tryParse(
              StorageHelper.getString('profile_height_$normalizedUsername') ??
                  '0',
            ) ??
            0.0,
        weightKg:
            double.tryParse(
              StorageHelper.getString('profile_weight_$normalizedUsername') ??
                  '0',
            ) ??
            0.0,
        fitnessGoals:
            StorageHelper.getString('profile_goals_$normalizedUsername') ?? '',
        smartGoals:
            StorageHelper.getString(
              'profile_smart_goals_$normalizedUsername',
            ) ??
            '',
        trainingExperience:
            StorageHelper.getString('profile_experience_$normalizedUsername') ??
            '',
        trainingLocation:
            StorageHelper.getString('profile_location_$normalizedUsername') ??
            '',
        hobbiesInterests:
            StorageHelper.getString('profile_hobbies_$normalizedUsername') ??
            '',
        injuriesLimitations:
            StorageHelper.getString(
              'profile_limitations_$normalizedUsername',
            ) ??
            '',
        profilePictureUrl: StorageHelper.getString(
          'profile_picture_$normalizedUsername',
        ),
        isSuspended:
            StorageHelper.getString('profile_suspended_$normalizedUsername') ==
            'true',
        strengthPRs: clientPRs,
        bodyMeasurementsCm: _deserializeBodyMeasurements(
          StorageHelper.getString('profile_measurements_$normalizedUsername') ??
              '',
        ),
      );
      clients.add(profile);
    }

    setState(() {
      _allClients = clients;
    });
  }

  void _loadAllWorkouts() {
    final allWorkouts = <Workout>[];

    // Get all registered client emails
    final clientsList = StorageHelper.getString('clients_list') ?? '';
    if (clientsList.isEmpty) {
      setState(() {
        _workouts = [];
      });
      return;
    }

    final usernames = clientsList.split(',');
    print(
      '🔍 DEBUG: Loading workouts for instructor from ${usernames.length} clients',
    );

    for (final username in usernames) {
      if (username.isEmpty) continue;

      // Get workout IDs for this client
      final workoutListKey = 'workouts_$username';
      final workoutIds =
          StorageHelper.getString(
            workoutListKey,
          )?.split(',').where((id) => id.isNotEmpty).toList() ??
          [];
      print('🔍 DEBUG: Client $username has ${workoutIds.length} workouts');

      for (final workoutId in workoutIds) {
        final storageKey = 'workout_$workoutId';
        final workoutData = StorageHelper.getString(storageKey);
        if (workoutData != null && workoutData.isNotEmpty) {
          try {
            final workout = _deserializeWorkout(workoutData);
            allWorkouts.add(workout);
            print(
              '✅ DEBUG: Loaded workout: ${workout.name} for ${workout.clientName}',
            );
          } catch (e) {
            print('❌ DEBUG: Error loading workout $workoutId: $e');
          }
        }
      }
    }

    print(
      '✅ DEBUG: Total workouts loaded for instructor: ${allWorkouts.length}',
    );

    setState(() {
      _workouts = allWorkouts;
    });
  }

  Future<void> _saveWorkoutToStorage(Workout workout) async {
    print('💾 _saveWorkoutToStorage called for: ${workout.name}');
    print('💾 Workout has ${workout.exercises.length} exercises');

    // Serialize workout (including cardio fields)
    final exercisesJson = workout.exercises
        .map(
          (e) =>
              '${e.name}|${e.sets}|${e.reps}|${e.weight}|${e.notes ?? ''}|${e.isCardio}|${e.durationMinutes ?? ''}|${e.distanceKm ?? ''}',
        )
        .join(';;');

    print('💾 Serialized exercises: $exercisesJson');

    final workoutJson =
        '${workout.id}|${workout.name}|${workout.date.millisecondsSinceEpoch}|${workout.clientName}|${workout.notes ?? ''}|$exercisesJson|${workout.isCompleted}|${workout.isReviewedByInstructor}|${workout.feedback ?? ''}|${workout.instructorReview ?? ''}|${workout.isReviewAcknowledged}';

    print(
      '💾 Saving workout ${workout.id} (${workout.name}) for client: ${workout.clientName}',
    );

    // Save to localStorage
    await StorageHelper.setString('workout_${workout.id}', workoutJson);
    _indexWorkoutForLocalClientKeys(workout);
    print('✅ Saved to localStorage');

    // Sync to Firebase
    try {
      final exercisesForFirebase = workout.exercises
          .map(
            (e) => {
              'name': e.name,
              'sets': e.sets,
              'reps': e.reps,
              'weight': e.weight,
              'notes': e.notes ?? '',
              'isCardio': e.isCardio,
              'durationMinutes': e.durationMinutes,
              'distanceKm': e.distanceKm,
            },
          )
          .toList();

      print(
        '🔥 Preparing to save ${exercisesForFirebase.length} exercises to Firebase',
      );

      await FirebaseService.saveWorkout(workout.id, {
        'id': workout.id,
        'name': workout.name,
        'date': workout.date.millisecondsSinceEpoch,
        'clientName': workout.clientName,
        'notes': workout.notes ?? '',
        'exercises': exercisesForFirebase,
        'isCompleted': workout.isCompleted,
        'isReviewedByInstructor': workout.isReviewedByInstructor,
        'feedback': workout.feedback ?? '',
        'instructorReview': workout.instructorReview ?? '',
        'isReviewAcknowledged': workout.isReviewAcknowledged,
      });

      final verification = await FirebaseService.getWorkout(workout.id);
      if (verification == null) {
        throw Exception('Firebase workout verification failed after save');
      }

      print(
        '✅ Synced workout ${workout.id} to Firebase successfully with ${exercisesForFirebase.length} exercises',
      );
    } catch (e) {
      print('❌ Failed to sync workout to Firebase: $e');
      rethrow;
    }
  }

  Future<void> _saveRestDayToStorage(RestDay restDay) async {
    // Serialize rest day
    final restDayJson =
        '${restDay.id}|${restDay.date.millisecondsSinceEpoch}|${restDay.clientName}|${restDay.notes ?? ''}';

    print('💾 Saving rest day ${restDay.id} for client: ${restDay.clientName}');

    // Save to localStorage
    await StorageHelper.setString('restday_${restDay.id}', restDayJson);

    // Update global rest days list
    final existingList = StorageHelper.getString('all_restdays') ?? '';
    final existingIds = existingList.isEmpty
        ? <String>[]
        : existingList.split(',').where((id) => id.isNotEmpty).toList();

    if (!existingIds.contains(restDay.id)) {
      existingIds.add(restDay.id);
      await StorageHelper.setString('all_restdays', existingIds.join(','));
    }

    print('✅ Saved rest day to localStorage');
  }

  Future<void> _loadAllRestDays() async {
    print('📥 Loading all rest days from localStorage...');

    // Get all rest day IDs from global list
    final restDaysList = StorageHelper.getString('all_restdays') ?? '';
    if (restDaysList.isEmpty) {
      setState(() {
        _restDays = [];
      });
      return;
    }

    final loadedRestDays = <RestDay>[];
    final restDayIds = restDaysList
        .split(',')
        .where((id) => id.isNotEmpty)
        .toList();

    for (final restDayId in restDayIds) {
      final storageKey = 'restday_$restDayId';
      final restDayStr = StorageHelper.getString(storageKey);
      if (restDayStr != null && restDayStr.isNotEmpty) {
        try {
          final parts = restDayStr.split('|');
          if (parts.length >= 3) {
            final restDay = RestDay(
              id: parts[0],
              date: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[1])),
              clientName: parts[2],
              notes: parts.length > 3 && parts[3].isNotEmpty ? parts[3] : null,
            );
            loadedRestDays.add(restDay);
          }
        } catch (e) {
          print('⚠️ Error parsing rest day $restDayId: $e');
        }
      }
    }

    setState(() {
      _restDays = loadedRestDays;
    });
    print('✅ Loaded ${loadedRestDays.length} rest days');
  }

  @override
  Widget build(BuildContext context) {
    if (_userRole == null) {
      return LoginScreen(
        onRoleSelected: (role) {
          setState(() {
            _userRole = role;
          });
          // Load all clients when instructor logs in
          if (role == 'instructor') {
            _syncInstructorPasswordFromFirebase();
            _loadAllClients();
            _loadAllWorkouts();
            _loadAllRestDays();
            // Set up Firebase listeners for instructor
            _setupFirebaseListeners();
          }
        },
        onClientLogin: (email) {
          _loadUserData(email);
        },
      );
    } else if (_userRole == 'instructor') {
      return InstructorDashboard(
        workouts: _workouts,
        onWorkoutAdded: (workout) {
          print('📥 Received workout in main.dart: ${workout.name}');
          print('📥 Exercise count: ${workout.exercises.length}');

          setState(() {
            _workouts.add(workout);
          });

          // Save the new workout to storage (async, but don't block)
          _saveWorkoutToStorage(workout)
              .then((_) {
                print('✅ Workout saved successfully');
              })
              .catchError((e) {
                print('❌ Error saving workout: $e');
              });

          // Find the client's username from the workout assignment key
          final normalizedAssignedClient = workout.clientName
              .trim()
              .toLowerCase();
          var clientUsername = _allClients.firstWhere(
            (c) {
              final normalizedName = c.name.trim().toLowerCase();
              final normalizedUsername = c.username.trim().toLowerCase();
              final normalizedEmail = c.email.trim().toLowerCase();

              return normalizedAssignedClient == normalizedUsername ||
                  normalizedAssignedClient == normalizedName ||
                  normalizedAssignedClient == normalizedEmail;
            },
            orElse: () => ClientProfile(
              username: '',
              email: '',
              name: '',
              age: 0,
              heightCm: 0,
              weightKg: 0,
              fitnessGoals: '',
              trainingExperience: '',
              trainingLocation: '',
              hobbiesInterests: '',
              injuriesLimitations: '',
              strengthPRs: {},
              bodyMeasurementsCm: {},
            ),
          ).username;

          if (clientUsername.trim().isEmpty) {
            clientUsername = workout.clientName.trim();
          }

          final clientIdentityKeys = <String>{
            workout.clientName.trim().toLowerCase(),
          };

          if (clientUsername.trim().isNotEmpty) {
            clientIdentityKeys.add(clientUsername.trim().toLowerCase());
          }

          for (final client in _allClients) {
            final normalizedName = client.name.trim().toLowerCase();
            final normalizedUsername = client.username.trim().toLowerCase();
            final normalizedEmail = client.email.trim().toLowerCase();

            if (normalizedAssignedClient == normalizedName ||
                normalizedAssignedClient == normalizedUsername ||
                normalizedAssignedClient == normalizedEmail) {
              clientIdentityKeys.add(normalizedUsername);
              clientIdentityKeys.add(normalizedName);
              clientIdentityKeys.add(normalizedEmail);
              if (normalizedEmail.contains('@')) {
                clientIdentityKeys.add(normalizedEmail.split('@').first);
              }
            }
          }

          for (final identity in clientIdentityKeys) {
            if (identity.isEmpty) continue;
            final workoutListKey = 'workouts_$identity';
            final workoutList = StorageHelper.getString(workoutListKey) ?? '';
            final workoutIds = workoutList.isEmpty
                ? <String>[]
                : workoutList.split(',');
            if (!workoutIds.contains(workout.id)) {
              workoutIds.add(workout.id);
              StorageHelper.setString(workoutListKey, workoutIds.join(','));
            }
          }

          // Reload to ensure consistency
          _loadAllWorkouts();
        },
        onWorkoutUpdated: (updatedWorkout) {
          setState(() {
            final index = _workouts.indexWhere(
              (w) => w.id == updatedWorkout.id,
            );
            if (index != -1) {
              _workouts[index] = updatedWorkout;
            }
          });
          // Save updated workout (async)
          _saveWorkoutToStorage(updatedWorkout)
              .then((_) {
                print('✅ Workout updated successfully');
              })
              .catchError((e) {
                print('❌ Error updating workout: $e');
              });
        },
        onWorkoutDeleted: (workout) {
          setState(() {
            _workouts.removeWhere((w) => w.id == workout.id);
          });

          // Delete from local storage
          StorageHelper.remove('workout_${workout.id}').then((_) {
            print('✅ Workout deleted from local storage');
          });

          // Delete from Firebase
          FirebaseService.deleteWorkout(workout.id)
              .then((_) {
                print('✅ Workout deleted from Firebase');
              })
              .catchError((e) {
                print('❌ Error deleting workout from Firebase: $e');
              });
        },
        clients: _allClients,
        onClientUpdated: (updatedClient) {
          // Save updated profile to localStorage
          final username = updatedClient.username;
          final prsJson = updatedClient.strengthPRs.entries
              .map((e) => '${e.key}:${e.value}')
              .join(',');
          StorageHelper.setString(
            'profile_email_$username',
            updatedClient.email,
          );
          StorageHelper.setString('profile_name_$username', updatedClient.name);
          StorageHelper.setString(
            'profile_age_$username',
            updatedClient.age?.toString() ?? '0',
          );
          StorageHelper.setString(
            'profile_height_$username',
            updatedClient.heightCm?.toString() ?? '0',
          );
          StorageHelper.setString(
            'profile_weight_$username',
            updatedClient.weightKg?.toString() ?? '0',
          );
          StorageHelper.setString(
            'profile_goals_$username',
            updatedClient.fitnessGoals,
          );
          StorageHelper.setString(
            'profile_smart_goals_$username',
            updatedClient.smartGoals,
          );
          StorageHelper.setString(
            'profile_experience_$username',
            updatedClient.trainingExperience,
          );
          StorageHelper.setString(
            'profile_location_$username',
            updatedClient.trainingLocation,
          );
          StorageHelper.setString(
            'profile_hobbies_$username',
            updatedClient.hobbiesInterests,
          );
          StorageHelper.setString(
            'profile_limitations_$username',
            updatedClient.injuriesLimitations,
          );
          StorageHelper.setString(
            'profile_measurements_$username',
            _serializeBodyMeasurements(updatedClient.bodyMeasurementsCm),
          );
          StorageHelper.setString('profile_prs_$username', prsJson);
          StorageHelper.setString(
            'profile_suspended_$username',
            updatedClient.isSuspended.toString(),
          );
          if (updatedClient.profilePictureUrl != null) {
            StorageHelper.setString(
              'profile_picture_$username',
              updatedClient.profilePictureUrl!,
            );
          }

          // Sync to Firebase
          FirebaseService.saveClientProfile(username, {
            'email': updatedClient.email,
            'name': updatedClient.name,
            'age': updatedClient.age,
            'heightCm': updatedClient.heightCm,
            'weightKg': updatedClient.weightKg,
            'fitnessGoals': updatedClient.fitnessGoals,
            'smartGoals': updatedClient.smartGoals,
            'trainingExperience': updatedClient.trainingExperience,
            'trainingLocation': updatedClient.trainingLocation,
            'hobbiesInterests': updatedClient.hobbiesInterests,
            'injuriesLimitations': updatedClient.injuriesLimitations,
            'bodyMeasurementsCm': updatedClient.bodyMeasurementsCm,
            'strengthPRs': updatedClient.strengthPRs,
            'isSuspended': updatedClient.isSuspended,
            'profilePictureUrl': updatedClient.profilePictureUrl,
          });

          // Reload all clients from localStorage to get latest data
          _loadAllClients();
        },
        onClientCreated: (newClient, password) {
          // Save new client to localStorage
          final username = newClient.username;

          print('🔑 Creating client account - Username: $username');

          // Hash password before saving
          final hashedPassword = SecurityHelper.hashPassword(
            password,
            username,
          );

          // Save hashed password for login authentication
          StorageHelper.setString('user_$username', hashedPassword);
          print('✅ Saved hashed password for: $username');

          // Sync to Firebase
          FirebaseService.saveUser(username, hashedPassword);

          // Save profile data
          StorageHelper.setString('profile_email_$username', newClient.email);
          StorageHelper.setString('profile_name_$username', newClient.name);
          StorageHelper.setString(
            'profile_age_$username',
            newClient.age?.toString() ?? '0',
          );
          StorageHelper.setString(
            'profile_height_$username',
            newClient.heightCm?.toString() ?? '0',
          );
          StorageHelper.setString(
            'profile_weight_$username',
            newClient.weightKg?.toString() ?? '0',
          );
          StorageHelper.setString(
            'profile_goals_$username',
            newClient.fitnessGoals,
          );
          StorageHelper.setString(
            'profile_smart_goals_$username',
            newClient.smartGoals,
          );
          StorageHelper.setString(
            'profile_experience_$username',
            newClient.trainingExperience,
          );
          StorageHelper.setString(
            'profile_location_$username',
            newClient.trainingLocation,
          );
          StorageHelper.setString(
            'profile_hobbies_$username',
            newClient.hobbiesInterests,
          );
          StorageHelper.setString(
            'profile_limitations_$username',
            newClient.injuriesLimitations,
          );
          StorageHelper.setString('profile_measurements_$username', '');
          StorageHelper.setString('profile_prs_$username', '');

          // Add to clients list
          final clientsList = StorageHelper.getString('clients_list') ?? '';
          final updatedList = clientsList.isEmpty
              ? username
              : '$clientsList,$username';
          StorageHelper.setString('clients_list', updatedList);

          // Sync client profile to Firebase
          FirebaseService.saveClientProfile(username, {
            'email': newClient.email,
            'name': newClient.name,
            'age': newClient.age,
            'heightCm': newClient.heightCm,
            'weightKg': newClient.weightKg,
            'fitnessGoals': newClient.fitnessGoals,
            'smartGoals': newClient.smartGoals,
            'trainingExperience': newClient.trainingExperience,
            'trainingLocation': newClient.trainingLocation,
            'hobbiesInterests': newClient.hobbiesInterests,
            'injuriesLimitations': newClient.injuriesLimitations,
            'bodyMeasurementsCm': newClient.bodyMeasurementsCm,
            'strengthPRs': newClient.strengthPRs,
          });

          // Sync clients list to Firebase
          final usernames = updatedList
              .split(',')
              .where((u) => u.isNotEmpty)
              .toList();
          FirebaseService.saveClientsList(usernames);

          // Reload all clients from localStorage to show new client
          _loadAllClients();
        },
        onClientDeleted: (clientToDelete) {
          // Delete client from localStorage
          final username = clientToDelete.username;

          // Remove password
          StorageHelper.remove('user_$username');

          // Remove profile data
          StorageHelper.remove('profile_email_$username');
          StorageHelper.remove('profile_name_$username');
          StorageHelper.remove('profile_age_$username');
          StorageHelper.remove('profile_height_$username');
          StorageHelper.remove('profile_weight_$username');
          StorageHelper.remove('profile_goals_$username');
          StorageHelper.remove('profile_smart_goals_$username');
          StorageHelper.remove('profile_experience_$username');
          StorageHelper.remove('profile_location_$username');
          StorageHelper.remove('profile_hobbies_$username');
          StorageHelper.remove('profile_limitations_$username');
          StorageHelper.remove('profile_measurements_$username');
          StorageHelper.remove('profile_prs_$username');
          StorageHelper.remove('profile_picture_$username');
          StorageHelper.remove('profile_suspended_$username');

          // Remove from clients list
          final clientsList = StorageHelper.getString('clients_list') ?? '';
          final usernames = clientsList
              .split(',')
              .where((u) => u.isNotEmpty)
              .toList();
          usernames.remove(username);
          final updatedList = usernames.join(',');
          StorageHelper.setString('clients_list', updatedList);

          // Reload all clients from localStorage to update UI
          _loadAllClients();
        },
        onRestDayAdded: (restDay) {
          setState(() {
            _restDays.add(restDay);
          });

          // Save rest day to local storage
          _saveRestDayToStorage(restDay)
              .then((_) {
                print('✅ Rest day saved successfully');
              })
              .catchError((e) {
                print('❌ Error saving rest day: $e');
              });

          // Save rest day to Firebase
          FirebaseService.saveRestDay({
            'id': restDay.id,
            'date': restDay.date.toIso8601String(),
            'clientName': restDay.clientName,
            'notes': restDay.notes,
          });
        },
        onLogout: () {
          setState(() {
            _userRole = null;
            _knownWorkoutIds.clear();
          });
        },
      );
    } else {
      print(
        '📱 Building MainNavigation with ${_restDays.length} rest days in state',
      );
      for (var rd in _restDays) {
        print('  🗓️ Rest day in state: ${rd.clientName} on ${rd.date}');
      }

      return MainNavigation(
        onLogout: () {
          print('🚪 Logging out client...');
          setState(() {
            _userRole = null;
            _currentUserEmail = null;
            _knownWorkoutIds.clear();
          });
          print(
            '✅ Client logged out, _userRole=$_userRole, _currentUserEmail=$_currentUserEmail',
          );
        },
        currentUserEmail: _currentUserEmail,
        clientProfile: _clientProfile,
        workouts: _workouts,
        restDays: _restDays,
        onWorkoutUpdated: (updatedWorkout) {
          setState(() {
            final index = _workouts.indexWhere(
              (w) => w.id == updatedWorkout.id,
            );
            if (index != -1) {
              _workouts[index] = updatedWorkout;
            }
          });
          // Save updated workout (async)
          _saveWorkoutToStorage(updatedWorkout)
              .then((_) {
                print('✅ Client workout updated successfully');
              })
              .catchError((e) {
                print('❌ Error updating client workout: $e');
              });
        },
        onPRsUpdated: (newPRs) {
          print('🏆 New PRs received in main.dart:');
          for (var entry in newPRs.entries) {
            print('   ${entry.key}: ${entry.value} kg');
          }

          setState(() {
            // Merge new PRs with existing PRs
            _clientProfile.strengthPRs.addAll(newPRs);
          });

          print('✅ PRs updated in client profile');

          if (context.mounted) {
            final prCount = newPRs.length;
            final snackMessage = prCount == 1
                ? '🏆 New PR saved: ${newPRs.keys.first}'
                : '🏆 $prCount new PRs saved successfully!';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(snackMessage),
                duration: const Duration(seconds: 2),
                backgroundColor: const Color(0xFF059669),
              ),
            );
          }

          // Save PRs to localStorage
          if (_currentUserEmail != null) {
            // Convert Map to JSON string for storage
            final prsJson = _clientProfile.strengthPRs.entries
                .map((e) => '${e.key}:${e.value}')
                .join(',');
            StorageHelper.setString('profile_prs_$_currentUserEmail', prsJson);

            // Sync PRs to Firebase
            print('🔄 Syncing PRs to Firebase...');
            FirebaseService.saveClientProfile(_currentUserEmail!, {
                  'email': _clientProfile.email,
                  'name': _clientProfile.name,
                  'age': _clientProfile.age,
                  'heightCm': _clientProfile.heightCm,
                  'weightKg': _clientProfile.weightKg,
                  'fitnessGoals': _clientProfile.fitnessGoals,
                  'smartGoals': _clientProfile.smartGoals,
                  'trainingExperience': _clientProfile.trainingExperience,
                  'trainingLocation': _clientProfile.trainingLocation,
                  'hobbiesInterests': _clientProfile.hobbiesInterests,
                  'injuriesLimitations': _clientProfile.injuriesLimitations,
                  'bodyMeasurementsCm': _clientProfile.bodyMeasurementsCm,
                  'strengthPRs': _clientProfile.strengthPRs,
                })
                .then((_) {
                  print('✅ PRs synced to Firebase');
                  // Trigger clientsList update to notify instructor
                  return FirebaseService.touchClientsList();
                })
                .then((_) {
                  print('✅ Instructor notified of PR update');
                })
                .catchError((e) {
                  print('⚠️ Error syncing PRs to Firebase: $e');
                });
          }
        },
        onProfileUpdated: (profile) {
          print('📝 Profile update received in main.dart');
          print('   Weight: ${profile.weightKg}');
          print('   Height: ${profile.heightCm}');
          print('   Age: ${profile.age}');

          setState(() {
            _clientProfile = profile;
          });

          print('✅ State updated with new profile');

          // Save to localStorage if we have an email
          if (_currentUserEmail != null) {
            final prsJson = profile.strengthPRs.entries
                .map((e) => '${e.key}:${e.value}')
                .join(',');
            StorageHelper.setString(
              'profile_name_$_currentUserEmail',
              profile.name,
            );
            StorageHelper.setString(
              'profile_age_$_currentUserEmail',
              profile.age?.toString() ?? '0',
            );
            StorageHelper.setString(
              'profile_height_$_currentUserEmail',
              profile.heightCm?.toString() ?? '0.0',
            );
            StorageHelper.setString(
              'profile_weight_$_currentUserEmail',
              profile.weightKg?.toString() ?? '0.0',
            );
            StorageHelper.setString(
              'profile_goals_$_currentUserEmail',
              profile.fitnessGoals,
            );
            StorageHelper.setString(
              'profile_smart_goals_$_currentUserEmail',
              profile.smartGoals,
            );
            StorageHelper.setString(
              'profile_experience_$_currentUserEmail',
              profile.trainingExperience,
            );
            StorageHelper.setString(
              'profile_location_$_currentUserEmail',
              profile.trainingLocation,
            );
            StorageHelper.setString(
              'profile_hobbies_$_currentUserEmail',
              profile.hobbiesInterests,
            );
            StorageHelper.setString(
              'profile_limitations_$_currentUserEmail',
              profile.injuriesLimitations,
            );
            StorageHelper.setString(
              'profile_measurements_$_currentUserEmail',
              _serializeBodyMeasurements(profile.bodyMeasurementsCm),
            );
            StorageHelper.setString('profile_prs_$_currentUserEmail', prsJson);

            // Sync complete profile to Firebase for cross-device access
            print('🔄 Syncing profile to Firebase...');
            print('   Email: $_currentUserEmail');
            print('   Weight to sync: ${profile.weightKg}');

            FirebaseService.saveClientProfile(_currentUserEmail!, {
                  'email': profile.email,
                  'name': profile.name,
                  'age': profile.age,
                  'heightCm': profile.heightCm,
                  'weightKg': profile.weightKg,
                  'fitnessGoals': profile.fitnessGoals,
                  'smartGoals': profile.smartGoals,
                  'trainingExperience': profile.trainingExperience,
                  'trainingLocation': profile.trainingLocation,
                  'hobbiesInterests': profile.hobbiesInterests,
                  'injuriesLimitations': profile.injuriesLimitations,
                  'bodyMeasurementsCm': profile.bodyMeasurementsCm,
                  'strengthPRs': profile.strengthPRs,
                })
                .then((_) {
                  print('✅ Client profile synced to Firebase');
                })
                .catchError((e) {
                  print('⚠️ Error syncing profile to Firebase: $e');
                });
          }
        },
      );
    }
  }
}

class MainNavigation extends StatefulWidget {
  final VoidCallback onLogout;
  final String? currentUserEmail;
  final ClientProfile clientProfile;
  final Function(ClientProfile) onProfileUpdated;
  final List<Workout> workouts;
  final List<RestDay> restDays;
  final Function(Workout) onWorkoutUpdated;
  final Function(Map<String, double>) onPRsUpdated;

  const MainNavigation({
    super.key,
    required this.onLogout,
    required this.currentUserEmail,
    required this.clientProfile,
    required this.onProfileUpdated,
    required this.workouts,
    this.restDays = const [],
    required this.onWorkoutUpdated,
    required this.onPRsUpdated,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Remove local _workouts list, use widget.workouts instead
  /*final List<Workout> _workouts = [
    Workout(
      id: '1',
      name: 'Chest Day',
      date: DateTime.now(),
      exercises: [
        Exercise(
          name: 'Bench Press',
          sets: 4,
          reps: 8,
          weight: 185,
          notes: 'Felt strong',
        ),
        Exercise(
          name: 'Incline Dumbbell Press',
          sets: 3,
          reps: 10,
          weight: 80,
          notes: '',
        ),
      ],
    ),
    Workout(
      id: '2',
      name: 'Back and Biceps',
      date: DateTime.now().subtract(const Duration(days: 1)),
      exercises: [
        Exercise(
          name: 'Deadlifts',
          sets: 3,
          reps: 5,
          weight: 225,
          notes: 'Good form',
        ),
        Exercise(
          name: 'Barbell Rows',
          sets: 4,
          reps: 6,
          weight: 185,
          notes: '',
        ),
      ],
    ),
  ];*/

  @override
  Widget build(BuildContext context) {
    print(
      '🏗️ MainNavigation building with ${widget.restDays.length} rest days',
    );
    for (var rd in widget.restDays) {
      print('  📆 Rest day in MainNavigation: ${rd.clientName} on ${rd.date}');
    }

    final isCompactTabs = MediaQuery.sizeOf(context).width < 430;

    final List<Widget> screens = [
      HomeScreen(
        workouts: widget.workouts,
        restDays: widget.restDays,
        clientProfile: widget.clientProfile,
        onWorkoutUpdated: widget.onWorkoutUpdated,
        onPRsUpdated: widget.onPRsUpdated,
      ),
      ClientProfileScreen(
        profile: widget.clientProfile,
        onProfileUpdated: widget.onProfileUpdated,
      ),
      WorkoutHistoryScreen(workouts: widget.workouts),
      ProgressScreen(
        workouts: widget.workouts,
        clientProfile: widget.clientProfile,
        onProfileUpdated: widget.onProfileUpdated,
      ),
      const ExerciseLibraryScreen(),
      const StretchingScreen(),
      IllnessDayScreen(
        profile: widget.clientProfile,
        onProfileUpdated: widget.onProfileUpdated,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        height: isCompactTabs ? 64 : 72,
        labelBehavior: isCompactTabs
            ? NavigationDestinationLabelBehavior.onlyShowSelected
            : NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(
            icon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Ex'),
          NavigationDestination(
            icon: Icon(Icons.self_improvement),
            label: 'Stretch',
          ),
          NavigationDestination(icon: Icon(Icons.sick), label: 'Illness'),
        ],
      ),
    );
  }
}
