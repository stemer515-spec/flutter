import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../models/client_profile.dart';
import '../models/exercise_library.dart';
import '../models/stretching_library.dart';
import '../models/rest_day.dart';
import 'package:intl/intl.dart';
import 'client_profile_screen.dart';
import '../utils/storage_helper.dart';
import '../utils/firebase_service.dart';
import '../utils/security_helper.dart';

class InstructorDashboard extends StatefulWidget {
  final List<Workout> workouts;
  final Function(Workout) onWorkoutAdded;
  final Function(Workout) onWorkoutUpdated;
  final Function(Workout) onWorkoutDeleted;
  final List<ClientProfile> clients;
  final Function(ClientProfile) onClientUpdated;
  final Function(ClientProfile, String)
  onClientCreated; // Added password parameter
  final Function(ClientProfile) onClientDeleted;
  final VoidCallback onLogout;
  final Function(RestDay) onRestDayAdded;

  const InstructorDashboard({
    super.key,
    required this.workouts,
    required this.onWorkoutAdded,
    required this.onWorkoutUpdated,
    required this.onWorkoutDeleted,
    required this.clients,
    required this.onClientUpdated,
    required this.onClientCreated,
    required this.onClientDeleted,
    required this.onLogout,
    required this.onRestDayAdded,
  });

  @override
  State<InstructorDashboard> createState() => _InstructorDashboardState();
}

class _InstructorDashboardState extends State<InstructorDashboard> {
  int _selectedIndex = 0;
  late Map<String, String> exerciseYoutubeLinks;
  late Map<String, String> stretchingYoutubeLinks;

  @override
  void initState() {
    super.initState();
    // Initialize with current exercise links
    exerciseYoutubeLinks = {};
    for (var exercise in exerciseLibrary) {
      exerciseYoutubeLinks[exercise.id] = exercise.youtubeUrl;
    }
    // Initialize with current stretching links
    stretchingYoutubeLinks = {};
    for (var stretch in stretchingLibrary) {
      stretchingYoutubeLinks[stretch.id] = stretch.youtubeUrl;
    }
  }

  void _changeInstructorPassword() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Instructor Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrent
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureCurrent = !obscureCurrent;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureNew = !obscureNew;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureConfirm = !obscureConfirm;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final currentPassword = currentPasswordController.text;
                final newPassword = newPasswordController.text;
                final confirmPassword = confirmPasswordController.text;

                // Verify current password
                const instructorPassword = '1234567890';
                final storedPassword = StorageHelper.getString(
                  'instructor_password',
                );

                bool isPasswordCorrect = false;
                if (storedPassword != null) {
                  // Verify against hashed password
                  isPasswordCorrect = SecurityHelper.verifyPassword(
                    currentPassword,
                    'instructor',
                    storedPassword,
                  );
                } else {
                  // Fall back to default password if no hash is stored
                  if (currentPassword == instructorPassword) {
                    isPasswordCorrect = true;
                  }
                }

                if (!isPasswordCorrect) {
                  print('❌ Password verification failed');
                  print('   Entered: $currentPassword');
                  print('   Stored hash: $storedPassword');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Current password is incorrect'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                print('✅ Current password verified successfully');

                if (newPassword.isEmpty || confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter both passwords'),
                    ),
                  );
                  return;
                }

                if (newPassword.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 6 characters'),
                    ),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }

                // Hash and save new password
                final hashedPassword = SecurityHelper.hashPassword(
                  newPassword,
                  'instructor',
                );
                StorageHelper.setString('instructor_password', hashedPassword);

                // Sync to Firebase
                FirebaseService.saveInstructorPassword(hashedPassword);

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully!'),
                    backgroundColor: Color(0xFF059669),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
              ),
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompactTabs = MediaQuery.sizeOf(context).width < 430;

    final List<Widget> screens = [
      _InstructorHome(
        workouts: widget.workouts,
        clients: widget.clients,
        onWorkoutReviewed: (workout) {
          widget.onWorkoutUpdated(workout);
          setState(() {}); // Refresh UI to remove from pending
        },
        onWorkoutDeleted: (workout) {
          widget.onWorkoutDeleted(workout);
          setState(() {}); // Refresh UI
        },
      ),
      _ClientManagement(
        clients: widget.clients,
        onClientUpdated: widget.onClientUpdated,
        onClientCreated: widget.onClientCreated,
        onClientDeleted: widget.onClientDeleted,
      ),
      _AddWorkoutForClient(
        onWorkoutAdded: widget.onWorkoutAdded,
        clients: widget.clients,
      ),
      _InstructorStats(workouts: widget.workouts, clients: widget.clients),
      _ExerciseLibraryManager(
        exerciseYoutubeLinks: exerciseYoutubeLinks,
        onLinksUpdated: () {
          setState(() {});
        },
      ),
      _StretchingLibraryManager(
        stretchingYoutubeLinks: stretchingYoutubeLinks,
        onLinksUpdated: () {
          setState(() {});
        },
      ),
      _RestDayScheduler(
        clients: widget.clients,
        onRestDayAdded: widget.onRestDayAdded,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Dashboard'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_reset),
            onPressed: _changeInstructorPassword,
            tooltip: 'Change Password',
          ),
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
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Clients'),
          NavigationDestination(icon: Icon(Icons.add_circle), label: 'Add'),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          NavigationDestination(icon: Icon(Icons.video_library), label: 'Ex'),
          NavigationDestination(
            icon: Icon(Icons.self_improvement),
            label: 'Stretch',
          ),
          NavigationDestination(icon: Icon(Icons.hotel), label: 'Rest'),
        ],
      ),
    );
  }
}

class _InstructorHome extends StatefulWidget {
  final List<Workout> workouts;
  final List<ClientProfile> clients;
  final Function(Workout) onWorkoutReviewed;
  final Function(Workout) onWorkoutDeleted;

  const _InstructorHome({
    required this.workouts,
    required this.clients,
    required this.onWorkoutReviewed,
    required this.onWorkoutDeleted,
  });

  @override
  State<_InstructorHome> createState() => _InstructorHomeState();
}

class _InstructorHomeState extends State<_InstructorHome> {
  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Workout _buildWorkoutWithSavedClientUpdates(Workout workout) {
    final updatedExercises = workout.exercises.map((exercise) {
      if (exercise.isCardio) {
        return exercise;
      }

      final weights = exercise.setWeights;
      if (weights == null || weights.isEmpty) {
        return exercise;
      }

      final normalizedWeights = List<double>.from(
        weights,
      ).map((value) => double.parse(value.toStringAsFixed(1))).toList();
      final avgWeight =
          normalizedWeights.reduce((a, b) => a + b) / normalizedWeights.length;

      return exercise.copyWith(
        sets: normalizedWeights.length,
        weight: double.parse(avgWeight.toStringAsFixed(1)),
        setWeights: normalizedWeights,
      );
    }).toList();

    return workout.copyWith(exercises: updatedExercises);
  }

  Workout _mergeUpdatedExercisesIntoWorkout({
    required Workout targetWorkout,
    required Workout sourceWorkout,
  }) {
    final mergedExercises = targetWorkout.exercises.map((targetExercise) {
      Exercise? sourceExercise;
      for (final candidate in sourceWorkout.exercises) {
        if (candidate.name.toLowerCase() == targetExercise.name.toLowerCase() &&
            candidate.isCardio == targetExercise.isCardio) {
          sourceExercise = candidate;
          break;
        }
      }

      if (sourceExercise == null) {
        return targetExercise;
      }

      if (sourceExercise.isCardio) {
        return targetExercise.copyWith(
          durationMinutes: sourceExercise.durationMinutes,
          distanceKm: sourceExercise.distanceKm,
        );
      }

      final sourceSetWeights = sourceExercise.setWeights;
      final normalizedSetWeights =
          sourceSetWeights == null || sourceSetWeights.isEmpty
          ? null
          : List<double>.from(
              sourceSetWeights,
            ).map((value) => double.parse(value.toStringAsFixed(1))).toList();

      return targetExercise.copyWith(
        sets: sourceExercise.sets,
        reps: sourceExercise.reps,
        weight: sourceExercise.weight,
        setWeights: normalizedSetWeights,
      );
    }).toList();

    return targetWorkout.copyWith(exercises: mergedExercises);
  }

  int _applyClientUpdatesToFutureWorkouts({
    required Workout sourceWorkout,
    required Workout normalizedSourceWorkout,
  }) {
    final sourceDate = _dateOnly(sourceWorkout.date);
    final futureWorkouts = widget.workouts.where((candidate) {
      if (candidate.id == sourceWorkout.id) {
        return false;
      }
      if (candidate.isCompleted) {
        return false;
      }
      if (candidate.clientName != sourceWorkout.clientName) {
        return false;
      }
      if (candidate.name != sourceWorkout.name) {
        return false;
      }
      return !_dateOnly(candidate.date).isBefore(sourceDate);
    }).toList();

    for (final futureWorkout in futureWorkouts) {
      final updatedFutureWorkout = _mergeUpdatedExercisesIntoWorkout(
        targetWorkout: futureWorkout,
        sourceWorkout: normalizedSourceWorkout,
      );
      widget.onWorkoutReviewed(updatedFutureWorkout);
    }

    return futureWorkouts.length;
  }

  int _countFutureWorkoutsToUpdate(Workout sourceWorkout) {
    final sourceDate = _dateOnly(sourceWorkout.date);
    return widget.workouts.where((candidate) {
      if (candidate.id == sourceWorkout.id) {
        return false;
      }
      if (candidate.isCompleted) {
        return false;
      }
      if (candidate.clientName != sourceWorkout.clientName) {
        return false;
      }
      if (candidate.name != sourceWorkout.name) {
        return false;
      }
      return !_dateOnly(candidate.date).isBefore(sourceDate);
    }).length;
  }

  Future<bool> _confirmFutureWorkoutUpdates({
    required BuildContext context,
    required Workout sourceWorkout,
    required int futureCount,
  }) async {
    final shouldApply = await showDialog<bool>(
      context: context,
      builder: (confirmContext) => AlertDialog(
        title: const Text('Apply updates to future workouts?'),
        content: Text(
          'This will update $futureCount upcoming "${sourceWorkout.name}" workout${futureCount == 1 ? '' : 's'} for ${sourceWorkout.clientName}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(confirmContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(confirmContext).pop(true),
            child: const Text('Apply Updates'),
          ),
        ],
      ),
    );

    return shouldApply == true;
  }

  @override
  Widget build(BuildContext context) {
    final pendingReviews = widget.workouts
        .where((w) => w.isCompleted && !w.isReviewedByInstructor)
        .toList();

    // Calculate active sessions (clients with uncompleted workouts)
    final activeClientNames = widget.workouts
        .where((w) => !w.isCompleted)
        .map((w) => w.clientName)
        .toSet()
        .length;

    // Calculate average attendance for current calendar week
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final workoutsThisWeek = widget.workouts.where((w) {
      return w.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          w.date.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();

    final completedThisWeek = workoutsThisWeek
        .where((w) => w.isCompleted)
        .length;
    final totalThisWeek = workoutsThisWeek.length;
    final avgAttendance = totalThisWeek > 0
        ? ((completedThisWeek / totalThisWeek) * 100).round()
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D4ED8).withOpacity(0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.dashboard,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, Instructor!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage clients, review sessions, and track progress.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Pending Reviews Notification
          if (pendingReviews.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF59E0B).withOpacity(0.1),
                    const Color(0xFFEF4444).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.notification_important,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${pendingReviews.length} Workout${pendingReviews.length > 1 ? 's' : ''} Awaiting Review',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF92400E),
                                  ),
                            ),
                            Text(
                              'Clients have completed workouts',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: const Color(0xFF92400E)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...pendingReviews.map(
                    (workout) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workout.clientName,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: const Color(0xFF6B7280),
                                      ),
                                ),
                                Text(
                                  workout.name,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${workout.exercises.length} exercises • ${DateFormat('MMM d').format(workout.date)}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: const Color(0xFF6B7280),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: () =>
                                _showWorkoutReview(context, workout),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFF59E0B),
                            ),
                            child: const Text('Review'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],

          // Quick Stats
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _StatCard(
                title: 'Total Clients',
                value: '${widget.clients.length}',
                icon: Icons.people,
                color: const Color(0xFF7C3AED),
              ),
              _StatCard(
                title: 'Workouts This Week',
                value: '${widget.workouts.length}',
                icon: Icons.fitness_center,
                color: const Color(0xFFF59E0B),
              ),
              _StatCard(
                title: 'Active Sessions',
                value: '$activeClientNames',
                icon: Icons.schedule,
                color: const Color(0xFF10B981),
              ),
              _StatCard(
                title: 'Avg Attendance',
                value: '$avgAttendance%',
                icon: Icons.trending_up,
                color: const Color(0xFFEF4444),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Recent Workouts
          _buildSectionHeader(
            context,
            title: 'Recent Client Workouts',
            icon: Icons.history,
          ),
          const SizedBox(height: 12),
          ...widget.workouts.take(5).map((workout) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${workout.clientName} • ${DateFormat('MMM d, yyyy').format(workout.date)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Chip(
                          label: Text('${workout.exercises.length} ex'),
                          backgroundColor: Colors.deepPurple[100],
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              _confirmDeleteWorkout(context, workout),
                          tooltip: 'Delete Workout',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _confirmDeleteWorkout(BuildContext context, Workout workout) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete Workout?'),
        content: Text(
          'Are you sure you want to delete "${workout.name}" for ${workout.clientName}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.onWorkoutDeleted(workout);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "${workout.name}"'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    Color iconColor = const Color(0xFF6B7280),
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  void _showWorkoutReview(BuildContext context, Workout workout) {
    final feedbackController = TextEditingController(
      text: workout.instructorReview ?? '',
    );
    bool applyToFutureWorkouts = false;
    final futureWorkoutCount = _countFutureWorkoutsToUpdate(workout);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.rate_review,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Review Workout',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              '${workout.clientName} • ${DateFormat('MMM d, yyyy').format(workout.date)}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Workout Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF7C3AED).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF7C3AED),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.fitness_center,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      workout.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              if (workout.notes != null &&
                                  workout.notes!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),
                                Text(
                                  'Workout Notes:',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: const Color(0xFF6B7280),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  workout.notes!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Exercises
                        Text(
                          'Exercises Completed',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ...workout.exercises.asMap().entries.map((entry) {
                          final index = entry.key;
                          final exercise = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF2563EB),
                                            Color(0xFF7C3AED),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        exercise.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    Chip(
                                      label: Text('${exercise.sets} sets'),
                                      backgroundColor: Colors.blue[50],
                                      labelStyle: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                    Chip(
                                      label: Text('${exercise.reps} reps'),
                                      backgroundColor: Colors.purple[50],
                                      labelStyle: TextStyle(
                                        fontSize: 12,
                                        color: Colors.purple[700],
                                      ),
                                    ),
                                    Chip(
                                      label: Text('${exercise.weight} kg'),
                                      backgroundColor: Colors.green[50],
                                      labelStyle: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                    if (exercise.setWeights != null &&
                                        exercise.setWeights!.isNotEmpty)
                                      Chip(
                                        label: Text(
                                          'Client avg ${(exercise.setWeights!.reduce((a, b) => a + b) / exercise.setWeights!.length).toStringAsFixed(1)} kg',
                                        ),
                                        backgroundColor: Colors.orange[50],
                                        labelStyle: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange[700],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 20),

                        // Client Feedback Section
                        if (workout.feedback != null &&
                            workout.feedback!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF10B981).withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.feedback,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Client Feedback',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF065F46),
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  workout.feedback!,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: const Color(0xFF1F2937),
                                        height: 1.5,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Feedback Section
                        Text(
                          'Instructor Feedback',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: feedbackController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Enter feedback for the client...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: applyToFutureWorkouts,
                          onChanged: (value) {
                            setDialogState(() {
                              applyToFutureWorkouts = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            'Apply to future workouts ($futureWorkoutCount)',
                          ),
                          subtitle: Text(
                            futureWorkoutCount > 0
                                ? 'Save these updated values to upcoming "${workout.name}" workouts for ${workout.clientName}'
                                : 'No upcoming workouts currently match this plan for ${workout.clientName}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () async {
                          final savedWorkout =
                              _buildWorkoutWithSavedClientUpdates(workout);
                          widget.onWorkoutReviewed(savedWorkout);

                          int futureUpdatedCount = 0;
                          if (applyToFutureWorkouts) {
                            final futureCount = _countFutureWorkoutsToUpdate(
                              workout,
                            );
                            if (futureCount > 0) {
                              final confirmed =
                                  await _confirmFutureWorkoutUpdates(
                                    context: dialogContext,
                                    sourceWorkout: workout,
                                    futureCount: futureCount,
                                  );
                              if (confirmed) {
                                futureUpdatedCount =
                                    _applyClientUpdatesToFutureWorkouts(
                                      sourceWorkout: workout,
                                      normalizedSourceWorkout: savedWorkout,
                                    );
                              }
                            }
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                futureUpdatedCount > 0
                                    ? 'Saved updates and applied to $futureUpdatedCount future workout${futureUpdatedCount == 1 ? '' : 's'}'
                                    : 'Saved ${workout.clientName}\'s updated weights and sets',
                              ),
                              backgroundColor: const Color(0xFF2563EB),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Save Client Updates'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () async {
                          final savedWorkout =
                              _buildWorkoutWithSavedClientUpdates(workout);

                          int futureUpdatedCount = 0;
                          if (applyToFutureWorkouts) {
                            final futureCount = _countFutureWorkoutsToUpdate(
                              workout,
                            );
                            if (futureCount > 0) {
                              final confirmed =
                                  await _confirmFutureWorkoutUpdates(
                                    context: dialogContext,
                                    sourceWorkout: workout,
                                    futureCount: futureCount,
                                  );
                              if (confirmed) {
                                futureUpdatedCount =
                                    _applyClientUpdatesToFutureWorkouts(
                                      sourceWorkout: workout,
                                      normalizedSourceWorkout: savedWorkout,
                                    );
                              }
                            }
                          }

                          // Update workout with review
                          final reviewedWorkout = savedWorkout.copyWith(
                            isReviewedByInstructor: true,
                            instructorReview: feedbackController.text,
                          );

                          widget.onWorkoutReviewed(reviewedWorkout);
                          Navigator.of(dialogContext).pop();

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    futureUpdatedCount > 0
                                        ? 'Reviewed ${workout.clientName}\'s workout • $futureUpdatedCount future updated'
                                        : 'Reviewed ${workout.clientName}\'s workout',
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                        ),
                        child: const Text('Submit Review'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClientManagement extends StatefulWidget {
  final List<ClientProfile> clients;
  final Function(ClientProfile) onClientUpdated;
  final Function(ClientProfile, String)
  onClientCreated; // Added password parameter
  final Function(ClientProfile) onClientDeleted;

  const _ClientManagement({
    required this.clients,
    required this.onClientUpdated,
    required this.onClientCreated,
    required this.onClientDeleted,
  });

  @override
  State<_ClientManagement> createState() => _ClientManagementState();
}

class _ClientManagementState extends State<_ClientManagement> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  void _showClientPRsDialog(BuildContext context, ClientProfile client) {
    final sortedPRs = client.strengthPRs.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${client.name} • Strength PRs'),
        content: SizedBox(
          width: 420,
          child: sortedPRs.isEmpty
              ? const Text('No PRs recorded yet.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: sortedPRs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = sortedPRs[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${entry.value.toStringAsFixed(1)} kg',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _createClient() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Client Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Client Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final username = _emailController.text.trim();
              final password = _passwordController.text;
              final name = _nameController.text.trim();

              if (username.isEmpty || password.isEmpty || name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              // Create new client profile
              final newClient = ClientProfile(
                username: username,
                email: '', // Email is now optional
                name: name,
                age: 0,
                heightCm: 0.0,
                weightKg: 0.0,
                fitnessGoals: '',
                trainingExperience: '',
                trainingLocation: '',
                hobbiesInterests: '',
                injuriesLimitations: '',
                strengthPRs: {},
                bodyMeasurementsCm: {},
              );

              // Save client and password through callback
              widget.onClientCreated(newClient, password);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Account created for $username\nPassword: $password',
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );

              _emailController.clear();
              _passwordController.clear();
              _nameController.clear();

              Navigator.pop(context);
            },
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleSuspension(BuildContext context, ClientProfile client) {
    final updatedClient = ClientProfile(
      username: client.username,
      email: client.email,
      name: client.name,
      age: client.age,
      heightCm: client.heightCm,
      weightKg: client.weightKg,
      fitnessGoals: client.fitnessGoals,
      smartGoals: client.smartGoals,
      trainingExperience: client.trainingExperience,
      trainingLocation: client.trainingLocation,
      hobbiesInterests: client.hobbiesInterests,
      injuriesLimitations: client.injuriesLimitations,
      profilePictureUrl: client.profilePictureUrl,
      isSuspended: !client.isSuspended,
      strengthPRs: client.strengthPRs,
      bodyMeasurementsCm: client.bodyMeasurementsCm,
    );

    widget.onClientUpdated(updatedClient);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedClient.isSuspended
              ? '${client.name}\'s account has been suspended'
              : '${client.name}\'s account has been reactivated',
        ),
        backgroundColor: updatedClient.isSuspended
            ? const Color(0xFFDC2626)
            : const Color(0xFF059669),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetPassword(BuildContext context, ClientProfile client) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Reset Password for ${client.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter new password:'),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              passwordController.dispose();
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPassword = passwordController.text;
              if (newPassword.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password cannot be empty'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Hash and save new password to storage
              final hashedPassword = SecurityHelper.hashPassword(
                newPassword,
                client.username,
              );
              StorageHelper.setString(
                'user_${client.username}',
                hashedPassword,
              );

              // Sync to Firebase immediately
              print(
                '🔄 Syncing password reset to Firebase for: ${client.username}',
              );
              FirebaseService.saveUser(client.username, hashedPassword);

              // Set flag to prompt password change on next login
              StorageHelper.setString(
                'password_reset_${client.username}',
                'true',
              );

              // Explicitly sync reset flag to Firebase to ensure cross-device sync
              FirebaseService.setString(
                'password_reset_${client.username}',
                'true',
              );
              print('✅ Password reset synced to Firebase');

              passwordController.dispose();
              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Password reset for ${client.name}\nNew password: $newPassword\nClient will be prompted to change password on next login.',
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 5),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );
  }

  void _deleteClient(BuildContext context, ClientProfile client) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to permanently delete ${client.name}\'s account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete client through callback
              widget.onClientDeleted(client);
              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${client.name}\'s account has been deleted'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Section
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF2563EB), const Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Client Management',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.clients.length} ${widget.clients.length == 1 ? 'client' : 'clients'} registered',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _createClient,
                  icon: const Icon(Icons.person_add, size: 20),
                  label: const Text(
                    'Create New Client',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Client List
        Expanded(
          child: widget.clients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No clients yet',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Create your first client account to get started',
                        style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.clients.length,
                  itemBuilder: (context, index) {
                    final client = widget.clients[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: client.isSuspended
                              ? Colors.red.withOpacity(0.3)
                              : const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Client Name Row
                            Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: client.isSuspended
                                          ? [Colors.red[300]!, Colors.red[500]!]
                                          : [
                                              const Color(0xFF2563EB),
                                              const Color(0xFF7C3AED),
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            (client.isSuspended
                                                    ? Colors.red
                                                    : const Color(0xFF2563EB))
                                                .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      client.name.isNotEmpty
                                          ? client.name
                                                .substring(0, 1)
                                                .toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    client.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      decoration: client.isSuspended
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: client.isSuspended
                                          ? const Color(0xFF9CA3AF)
                                          : const Color(0xFF1F2937),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (client.isSuspended)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Text(
                                      'SUSPENDED',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Info Row
                            Padding(
                              padding: const EdgeInsets.only(left: 72),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.fitness_center,
                                    size: 14,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      client.trainingExperience.isNotEmpty
                                          ? client.trainingExperience
                                          : 'Not set',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    client.trainingLocation == 'Gym'
                                        ? Icons.fitness_center
                                        : Icons.home,
                                    size: 14,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      client.trainingLocation.isNotEmpty
                                          ? client.trainingLocation
                                          : 'Not set',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.only(left: 72),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: client.strengthPRs.isEmpty
                                    ? Row(
                                        children: [
                                          Icon(
                                            Icons.trending_up,
                                            size: 14,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'No strength PRs yet',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Strength PRs (${client.strengthPRs.length})',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    _showClientPRsDialog(
                                                      context,
                                                      client,
                                                    ),
                                                style: TextButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 0,
                                                      ),
                                                  minimumSize: const Size(
                                                    60,
                                                    32,
                                                  ),
                                                ),
                                                child: const Text('View all'),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children:
                                                (client.strengthPRs.entries
                                                        .toList()
                                                      ..sort(
                                                        (a, b) => b.value
                                                            .compareTo(a.value),
                                                      ))
                                                    .take(3)
                                                    .map(
                                                      (entry) => Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFFEFF6FF,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          '${entry.key}: ${entry.value.toStringAsFixed(1)}kg',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Color(
                                                                  0xFF1E40AF,
                                                                ),
                                                              ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Action Buttons Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Suspend/Reactivate Button
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        (client.isSuspended
                                                ? const Color(0xFF059669)
                                                : const Color(0xFFDC2626))
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
                                    icon: Icon(
                                      client.isSuspended
                                          ? Icons.lock_open_rounded
                                          : Icons.block_rounded,
                                      size: 18,
                                    ),
                                    color: client.isSuspended
                                        ? const Color(0xFF059669)
                                        : const Color(0xFFDC2626),
                                    onPressed: () =>
                                        _toggleSuspension(context, client),
                                    tooltip: client.isSuspended
                                        ? 'Reactivate'
                                        : 'Suspend',
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Reset Password Button
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFF59E0B,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.lock_reset_rounded,
                                      size: 18,
                                    ),
                                    color: const Color(0xFFF59E0B),
                                    onPressed: () =>
                                        _resetPassword(context, client),
                                    tooltip: 'Reset Password',
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // View Profile Button
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF2563EB,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                    ),
                                    color: const Color(0xFF2563EB),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ClientProfileScreen(
                                                profile: client,
                                                onProfileUpdated:
                                                    (updatedProfile) {
                                                      widget.onClientUpdated(
                                                        updatedProfile,
                                                      );
                                                    },
                                              ),
                                        ),
                                      );
                                    },
                                    tooltip: 'View Profile',
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Delete Button
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.delete_rounded,
                                      size: 18,
                                    ),
                                    color: Colors.red,
                                    onPressed: () =>
                                        _deleteClient(context, client),
                                    tooltip: 'Delete',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _InstructorStats extends StatelessWidget {
  final List<Workout> workouts;
  final List<ClientProfile> clients;

  const _InstructorStats({required this.workouts, required this.clients});

  void _showFullWorkoutHistoryDialog(
    BuildContext context,
    String clientName,
    List<Workout> workouts,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$clientName • Workout History'),
        content: SizedBox(
          width: 520,
          child: workouts.isEmpty
              ? const Text('No previous workouts yet.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: workouts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  workout.name,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MMM d, y').format(workout.date),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            workout.exercises
                                .map(
                                  (exercise) => exercise.isCardio
                                      ? '${exercise.name} (${exercise.durationMinutes ?? 0} min${exercise.distanceKm != null ? ', ${exercise.distanceKm} km' : ''})'
                                      : '${exercise.name} (${exercise.sets}x${exercise.reps} @ ${exercise.weight}kg)',
                                )
                                .join(' • '),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[700]),
                          ),
                          if (workout.notes != null &&
                              workout.notes!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Comments: ${workout.notes!}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[800]),
                            ),
                          ],
                          if (workout.feedback != null &&
                              workout.feedback!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Client Feedback: ${workout.feedback!}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: const Color(0xFF065F46)),
                            ),
                          ],
                          if (workout.instructorReview != null &&
                              workout.instructorReview!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Instructor Review: ${workout.instructorReview!}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: const Color(0xFF1E40AF)),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFullPRHistoryDialog(
    BuildContext context,
    String clientName,
    Map<String, double> strengthPRs,
  ) {
    final sortedPRs = strengthPRs.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$clientName • PRs by Exercise'),
        content: SizedBox(
          width: 420,
          child: sortedPRs.isEmpty
              ? const Text('No PRs recorded yet.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: sortedPRs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = sortedPRs[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${entry.value.toStringAsFixed(1)} kg',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics & Performance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // Per-Client Analytics
          ...clients.map((client) {
            // Calculate actual stats for this client from workouts
            final clientWorkoutsList = workouts
                .where((w) => w.clientName == client.name)
                .toList();

            final sortedPRs = client.strengthPRs.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            final completedClientWorkouts = clientWorkoutsList
                .where((w) => w.isCompleted)
                .toList();

            final sortedCompletedClientWorkouts = List<Workout>.from(
              completedClientWorkouts,
            )..sort((a, b) => b.date.compareTo(a.date));

            final clientWorkouts = clientWorkoutsList.length;
            final completedCount = completedClientWorkouts.length;

            // Cardio totals from completed workouts
            int totalCardioMinutes = 0;
            double totalCardioDistance = 0.0;

            for (final workout in completedClientWorkouts) {
              totalCardioMinutes += workout.totalCardioMinutes;
              totalCardioDistance += workout.totalCardioDistanceKm;
            }

            // Weekly improvement (%): compare completed workouts in last 7 days vs previous 7 days
            final now = DateTime.now();
            final startOfThisWindow = DateTime(
              now.year,
              now.month,
              now.day,
            ).subtract(const Duration(days: 6));
            final startOfPreviousWindow = startOfThisWindow.subtract(
              const Duration(days: 7),
            );

            final completedThisWeek = completedClientWorkouts
                .where(
                  (w) =>
                      !w.date.isBefore(startOfThisWindow) &&
                      !w.date.isAfter(now),
                )
                .length;

            final completedPrevWeek = completedClientWorkouts
                .where(
                  (w) =>
                      !w.date.isBefore(startOfPreviousWindow) &&
                      w.date.isBefore(startOfThisWindow),
                )
                .length;

            double weeklyImprovementPercent;
            if (completedPrevWeek == 0 && completedThisWeek == 0) {
              weeklyImprovementPercent = 0;
            } else if (completedPrevWeek == 0) {
              weeklyImprovementPercent = 100;
            } else {
              weeklyImprovementPercent =
                  ((completedThisWeek - completedPrevWeek) /
                      completedPrevWeek) *
                  100;
            }

            final weeklyImprovementLabel =
                '${weeklyImprovementPercent >= 0 ? '+' : ''}${weeklyImprovementPercent.toStringAsFixed(0)}%';
            final weeklyImprovementColor = weeklyImprovementPercent > 0
                ? Colors.green
                : weeklyImprovementPercent < 0
                ? Colors.red
                : Colors.blueGrey;

            final clientPRCount = client.strengthPRs.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Client Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client.name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${client.trainingExperience} • ${client.trainingLocation}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          if (client.isSuspended)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.red, width: 1),
                              ),
                              child: const Text(
                                'SUSPENDED',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Client Stats Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.6,
                        children: [
                          _StatCardCompact(
                            label: 'Assigned',
                            value: '$clientWorkouts',
                            color: Colors.blue,
                          ),
                          _StatCardCompact(
                            label: 'Completed',
                            value: '$completedCount',
                            color: Colors.green,
                          ),
                          _StatCardCompact(
                            label: 'PRs',
                            value: '$clientPRCount',
                            color: Colors.orange,
                          ),
                          _StatCardCompact(
                            label: 'Weekly Improve',
                            value: weeklyImprovementLabel,
                            color: weeklyImprovementColor,
                          ),
                        ],
                      ),

                      // Cardio Stats (if any)
                      if (totalCardioMinutes > 0 ||
                          totalCardioDistance > 0) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.directions_run,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cardio: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              if (totalCardioMinutes > 0)
                                Text(
                                  '$totalCardioMinutes min',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              if (totalCardioMinutes > 0 &&
                                  totalCardioDistance > 0)
                                Text(
                                  '  •  ',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              if (totalCardioDistance > 0)
                                Text(
                                  '${totalCardioDistance.toStringAsFixed(1)} km',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Weight Progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Weight',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${client.weightKg?.toStringAsFixed(1) ?? 'N/A'} kg',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2563EB),
                                    ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Strength Goal',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                client.fitnessGoals.split(',').first,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),

                      if (client.strengthPRs.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Personal Records (By Exercise)',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                            ),
                            if (sortedPRs.length > 5)
                              TextButton(
                                onPressed: () => _showFullPRHistoryDialog(
                                  context,
                                  client.name,
                                  client.strengthPRs,
                                ),
                                child: const Text('View all'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...sortedPRs
                            .take(5)
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.key,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${entry.value.toStringAsFixed(1)} kg',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green[700],
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],

                      if (sortedCompletedClientWorkouts.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Previous Workouts',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                            ),
                            if (sortedCompletedClientWorkouts.length > 5)
                              TextButton(
                                onPressed: () => _showFullWorkoutHistoryDialog(
                                  context,
                                  client.name,
                                  sortedCompletedClientWorkouts,
                                ),
                                child: const Text('View all'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...sortedCompletedClientWorkouts
                            .take(5)
                            .map(
                              (workout) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            workout.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat(
                                            'MMM d, y',
                                          ).format(workout.date),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      workout.exercises
                                          .map(
                                            (exercise) => exercise.isCardio
                                                ? '${exercise.name} (${exercise.durationMinutes ?? 0} min${exercise.distanceKm != null ? ', ${exercise.distanceKm} km' : ''})'
                                                : '${exercise.name} (${exercise.sets}x${exercise.reps} @ ${exercise.weight}kg)',
                                          )
                                          .join(' • '),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey[700]),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (workout.notes != null &&
                                        workout.notes!.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        'Comments: ${workout.notes!}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.grey[800]),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    if (workout.feedback != null &&
                                        workout.feedback!.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        'Client Feedback: ${workout.feedback!}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: const Color(0xFF065F46),
                                            ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    if (workout.instructorReview != null &&
                                        workout
                                            .instructorReview!
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        'Instructor Review: ${workout.instructorReview!}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: const Color(0xFF1E40AF),
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                      ] else ...[
                        const SizedBox(height: 16),
                        Text(
                          'No previous workouts yet.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatCardCompact extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCardCompact({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddWorkoutForClient extends StatefulWidget {
  final Function(Workout) onWorkoutAdded;
  final List<ClientProfile> clients;

  const _AddWorkoutForClient({
    required this.onWorkoutAdded,
    required this.clients,
  });

  @override
  State<_AddWorkoutForClient> createState() => _AddWorkoutForClientState();
}

class _AddWorkoutForClientState extends State<_AddWorkoutForClient> {
  late TextEditingController _nameController;
  late TextEditingController _exerciseNameController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  late TextEditingController _notesController;
  late TextEditingController _clientNameController;
  late TextEditingController _durationController;
  late TextEditingController _distanceController;

  final List<Exercise> _exercises = [];
  DateTime _selectedDate = DateTime.now();
  String _selectedClient = 'All Clients';
  bool _isCardioExercise = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _exerciseNameController = TextEditingController();
    _setsController = TextEditingController();
    _repsController = TextEditingController();
    _weightController = TextEditingController();
    _notesController = TextEditingController();
    _clientNameController = TextEditingController();
    _durationController = TextEditingController();
    _distanceController = TextEditingController();
  }

  List<String> get _clients {
    final clientNames = widget.clients
        .map((c) => c.name.trim().isNotEmpty ? c.name : c.username)
        .where((name) => name.trim().isNotEmpty)
        .toSet()
        .toList();
    return ['All Clients', ...clientNames];
  }

  ClientProfile? _findClientBySelection(String selection) {
    for (final client in widget.clients) {
      final displayName = client.name.trim().isNotEmpty
          ? client.name
          : client.username;
      if (displayName == selection || client.username == selection) {
        return client;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _exerciseNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    _clientNameController.dispose();
    _durationController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  void _addExercise() {
    if (_exerciseNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter exercise name')),
      );
      return;
    }

    if (_isCardioExercise) {
      // Validate cardio fields
      if (_durationController.text.isEmpty &&
          _distanceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter duration or distance')),
        );
        return;
      }

      final exercise = Exercise(
        name: _exerciseNameController.text,
        sets: 1,
        reps: 1,
        weight: 0,
        isCardio: true,
        durationMinutes: _durationController.text.isEmpty
            ? null
            : int.parse(_durationController.text),
        distanceKm: _distanceController.text.isEmpty
            ? null
            : double.parse(_distanceController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      setState(() {
        _exercises.add(exercise);
      });

      _exerciseNameController.clear();
      _durationController.clear();
      _distanceController.clear();
      _notesController.clear();
    } else {
      // Validate strength training fields
      if (_setsController.text.isEmpty ||
          _repsController.text.isEmpty ||
          _weightController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all exercise fields')),
        );
        return;
      }

      final exercise = Exercise(
        name: _exerciseNameController.text,
        sets: int.parse(_setsController.text),
        reps: int.parse(_repsController.text),
        weight: double.parse(_weightController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      setState(() {
        _exercises.add(exercise);
      });

      _exerciseNameController.clear();
      _setsController.clear();
      _repsController.clear();
      _weightController.clear();
      _notesController.clear();
    }
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  void _submitWorkout() {
    if (_nameController.text.isEmpty || _exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add workout name and at least one exercise'),
        ),
      );
      return;
    }

    print('📋 Creating workout with ${_exercises.length} exercises');
    for (var i = 0; i < _exercises.length; i++) {
      print(
        '  Exercise $i: ${_exercises[i].name} - ${_exercises[i].sets}x${_exercises[i].reps} @ ${_exercises[i].weight}kg',
      );
    }

    final selectedClients = _selectedClient == 'All Clients'
        ? widget.clients
        : [
            _findClientBySelection(_selectedClient) ??
                ClientProfile(
                  username: _selectedClient,
                  email: '',
                  name: _selectedClient,
                ),
          ];

    if (selectedClients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No clients available for assignment')),
      );
      return;
    }

    int createdCount = 0;
    for (var i = 0; i < selectedClients.length; i++) {
      final client = selectedClients[i];
      final clientDisplayName = client.name.trim().isNotEmpty
          ? client.name
          : client.username;
      final assignmentKey = client.username.trim().isNotEmpty
          ? client.username
          : clientDisplayName;

      final workout = Workout(
        id: '${DateTime.now().millisecondsSinceEpoch}_$i',
        name: _nameController.text,
        date: _selectedDate,
        exercises: List.from(_exercises),
        notes: 'Assigned to: $clientDisplayName',
        clientName: assignmentKey,
      );

      widget.onWorkoutAdded(workout);
      createdCount++;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          createdCount == 1
              ? 'Workout "${_nameController.text}" assigned to ${selectedClients.first.name.trim().isNotEmpty ? selectedClients.first.name : selectedClients.first.username}'
              : 'Workout "${_nameController.text}" assigned to $createdCount clients',
        ),
      ),
    );

    // Reset form
    _nameController.clear();
    _exercises.clear();
    _selectedDate = DateTime.now();
    _selectedClient = 'All Clients';
    setState(() {});
  }

  String _getClientEmail(String clientName) {
    // Web-only feature - localStorage not available on mobile
    // This functionality is disabled for Android builds
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Workout for Client',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // Client Selection
          Text('Select Client', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _selectedClient,
            isExpanded: true,
            items: _clients
                .map(
                  (client) =>
                      DropdownMenuItem(value: client, child: Text(client)),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedClient = value ?? 'All Clients';
              });
            },
          ),
          const SizedBox(height: 16),

          // Workout Name
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Workout Name',
              hintText: 'e.g., Chest Day',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Date Selection
          ListTile(
            title: Text(
              'Date: ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                });
              }
            },
          ),
          const SizedBox(height: 24),

          // Exercises Section
          Text('Exercises', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),

          // Exercise Form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Exercise Type:',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Strength'),
                            icon: Icon(Icons.fitness_center),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('Cardio'),
                            icon: Icon(Icons.directions_run),
                          ),
                        ],
                        selected: {_isCardioExercise},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() {
                            _isCardioExercise = newSelection.first;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _exerciseNameController,
                    decoration: InputDecoration(
                      labelText: 'Exercise Name',
                      hintText: _isCardioExercise
                          ? 'e.g., Running'
                          : 'e.g., Bench Press',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_isCardioExercise)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final shouldStackFields = constraints.maxWidth < 700;

                        if (shouldStackFields) {
                          return Column(
                            children: [
                              TextField(
                                controller: _setsController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Sets',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _repsController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Reps',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Weight (kg)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _setsController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Sets',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _repsController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Reps',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Weight (kg)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Duration (min)',
                              hintText: 'Optional',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _distanceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Distance (km)',
                              hintText: 'Optional',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _addExercise,
                    child: const Text('Add Exercise'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Exercises List
          ..._exercises.asMap().entries.map((entry) {
            final idx = entry.key;
            final exercise = entry.value;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(
                  exercise.isCardio
                      ? Icons.directions_run
                      : Icons.fitness_center,
                  color: exercise.isCardio ? Colors.orange : Colors.blue,
                ),
                title: Text(exercise.name),
                subtitle: Text(
                  exercise.isCardio
                      ? '${exercise.durationMinutes != null ? "${exercise.durationMinutes} min" : ""}'
                            '${exercise.durationMinutes != null && exercise.distanceKm != null ? " • " : ""}'
                            '${exercise.distanceKm != null ? "${exercise.distanceKm} km" : ""}'
                      : '${exercise.sets} sets × ${exercise.reps} reps @ ${exercise.weight} kg',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeExercise(idx),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Submit Button
          FilledButton(
            onPressed: _submitWorkout,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.deepPurple,
            ),
            child: const SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(
                  'Assign Workout to Client',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseLibraryManager extends StatefulWidget {
  final Map<String, String> exerciseYoutubeLinks;
  final VoidCallback onLinksUpdated;

  const _ExerciseLibraryManager({
    required this.exerciseYoutubeLinks,
    required this.onLinksUpdated,
  });

  @override
  State<_ExerciseLibraryManager> createState() =>
      _ExerciseLibraryManagerState();
}

class _ExerciseLibraryManagerState extends State<_ExerciseLibraryManager> {
  late Map<String, TextEditingController> controllers;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _youtubeController;
  late TextEditingController _equipmentController;
  late TextEditingController _muscleGroupsController;
  String _selectedDifficulty = 'Beginner';
  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _categories = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
  ];

  @override
  void initState() {
    super.initState();
    controllers = {};
    for (var exercise in exerciseLibrary) {
      controllers[exercise.id] = TextEditingController(
        text: widget.exerciseYoutubeLinks[exercise.id] ?? exercise.youtubeUrl,
      );
    }
    _nameController = TextEditingController();
    _categoryController = TextEditingController();
    _youtubeController = TextEditingController();
    _equipmentController = TextEditingController();
    _muscleGroupsController = TextEditingController();
    _loadSavedExerciseLibrary();
  }

  Future<void> _loadSavedExerciseLibrary() async {
    await loadExerciseLibraryFromStorage();
    if (!mounted) return;

    for (var controller in controllers.values) {
      controller.dispose();
    }

    controllers = {};
    for (var exercise in exerciseLibrary) {
      controllers[exercise.id] = TextEditingController(
        text: widget.exerciseYoutubeLinks[exercise.id] ?? exercise.youtubeUrl,
      );
      widget.exerciseYoutubeLinks[exercise.id] = exercise.youtubeUrl;
    }

    setState(() {});
  }

  void _syncYoutubeLinksIntoLibrary() {
    final updatedExercises = exerciseLibrary.map((exercise) {
      final updatedUrl =
          widget.exerciseYoutubeLinks[exercise.id] ?? exercise.youtubeUrl;
      return exercise.copyWith(youtubeUrl: updatedUrl);
    }).toList();

    exerciseLibrary
      ..clear()
      ..addAll(updatedExercises);
  }

  Future<void> _saveAllExerciseChanges() async {
    _syncYoutubeLinksIntoLibrary();
    final saved = await saveExerciseLibraryToStorage();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Exercise library saved successfully!'
              : 'Unable to save exercise library',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: saved ? const Color(0xFF16A34A) : Colors.red,
      ),
    );

    widget.onLinksUpdated();
    setState(() {});
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    _nameController.dispose();
    _categoryController.dispose();
    _youtubeController.dispose();
    _equipmentController.dispose();
    _muscleGroupsController.dispose();
    super.dispose();
  }

  void _addNewExercise() {
    if (_formKey.currentState!.validate()) {
      final newExercise = ExerciseDemo(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        category: _categoryController.text,
        youtubeUrl: _youtubeController.text,
        equipment: _equipmentController.text,
        difficulty: _selectedDifficulty,
        muscleGroups: _muscleGroupsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        isCustom: true,
      );

      exerciseLibrary.add(newExercise);
      widget.exerciseYoutubeLinks[newExercise.id] = newExercise.youtubeUrl;
      controllers[newExercise.id] = TextEditingController(
        text: newExercise.youtubeUrl,
      );

      // Clear form
      _nameController.clear();
      _categoryController.clear();
      _youtubeController.clear();
      _equipmentController.clear();
      _muscleGroupsController.clear();
      _selectedDifficulty = 'Beginner';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exercise "${newExercise.name}" added successfully!'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );

      _saveAllExerciseChanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Exercise Videos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Update YouTube video links for each exercise in the library',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),
          ...exerciseLibrary.map((exercise) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1F2937),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                exercise.category,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: const Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ),
                        if (exercise.isCustom)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF7C3AED),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Custom',
                              style: TextStyle(
                                color: Color(0xFF7C3AED),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controllers[exercise.id],
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Paste YouTube video URL here',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                      ),
                      onChanged: (value) {
                        widget.exerciseYoutubeLinks[exercise.id] = value;
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF7C3AED).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF7C3AED),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add New Exercise',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Exercise Name',
                          hintText: 'e.g., Push-ups',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter exercise name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _categoryController.text.isEmpty
                            ? _categories.first
                            : _categoryController.text,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          _categoryController.text = value ?? '';
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _youtubeController,
                        decoration: InputDecoration(
                          labelText: 'YouTube URL',
                          hintText: 'https://www.youtube.com/watch?v=...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter YouTube URL';
                          }
                          if (!value.contains('youtube.com')) {
                            return 'Please enter a valid YouTube URL';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _equipmentController,
                        decoration: InputDecoration(
                          labelText: 'Equipment',
                          hintText: 'e.g., Dumbbells, Barbell',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter equipment';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDifficulty,
                        decoration: InputDecoration(
                          labelText: 'Difficulty Level',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _difficulties.map((difficulty) {
                          return DropdownMenuItem(
                            value: difficulty,
                            child: Text(difficulty),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDifficulty = value ?? 'Beginner';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _muscleGroupsController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Muscle Groups',
                          hintText:
                              'Separate with commas (e.g., Chest, Shoulders, Triceps)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter muscle groups';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _addNewExercise,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Add Exercise',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saveAllExerciseChanges,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Save All Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StretchingLibraryManager extends StatefulWidget {
  final Map<String, String> stretchingYoutubeLinks;
  final VoidCallback onLinksUpdated;

  const _StretchingLibraryManager({
    required this.stretchingYoutubeLinks,
    required this.onLinksUpdated,
  });

  @override
  State<_StretchingLibraryManager> createState() =>
      _StretchingLibraryManagerState();
}

class _StretchingLibraryManagerState extends State<_StretchingLibraryManager> {
  late Map<String, TextEditingController> controllers;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _youtubeController;
  late TextEditingController _durationController;
  late TextEditingController _descriptionController;
  String _selectedDifficulty = 'Beginner';
  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _categories = ['Upper Body', 'Lower Body', 'Full Body'];

  @override
  void initState() {
    super.initState();
    controllers = {};
    for (var stretch in stretchingLibrary) {
      controllers[stretch.id] = TextEditingController(
        text: widget.stretchingYoutubeLinks[stretch.id] ?? stretch.youtubeUrl,
      );
    }
    _nameController = TextEditingController();
    _categoryController = TextEditingController();
    _youtubeController = TextEditingController();
    _durationController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadSavedStretchingLibrary();
  }

  Future<void> _loadSavedStretchingLibrary() async {
    await loadStretchingLibraryFromStorage();
    if (!mounted) return;

    for (var controller in controllers.values) {
      controller.dispose();
    }

    controllers = {};
    for (var stretch in stretchingLibrary) {
      controllers[stretch.id] = TextEditingController(
        text: widget.stretchingYoutubeLinks[stretch.id] ?? stretch.youtubeUrl,
      );
      widget.stretchingYoutubeLinks[stretch.id] = stretch.youtubeUrl;
    }

    setState(() {});
  }

  void _syncYoutubeLinksIntoStretchingLibrary() {
    final updatedStretches = stretchingLibrary.map((stretch) {
      final updatedUrl =
          widget.stretchingYoutubeLinks[stretch.id] ?? stretch.youtubeUrl;
      return stretch.copyWith(youtubeUrl: updatedUrl);
    }).toList();

    stretchingLibrary
      ..clear()
      ..addAll(updatedStretches);
  }

  Future<void> _saveAllStretchingChanges() async {
    _syncYoutubeLinksIntoStretchingLibrary();
    final saved = await saveStretchingLibraryToStorage();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Stretching library saved successfully!'
              : 'Unable to save stretching library',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: saved ? const Color(0xFF16A34A) : Colors.red,
      ),
    );

    widget.onLinksUpdated();
    setState(() {});
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    _nameController.dispose();
    _categoryController.dispose();
    _youtubeController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addNewStretch() {
    if (_formKey.currentState!.validate()) {
      final newStretch = StretchingExercise(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        category: _categoryController.text,
        duration: _durationController.text,
        youtubeUrl: _youtubeController.text,
        description: _descriptionController.text,
        difficulty: _selectedDifficulty,
        isCustom: true,
      );

      stretchingLibrary.add(newStretch);
      widget.stretchingYoutubeLinks[newStretch.id] = newStretch.youtubeUrl;
      controllers[newStretch.id] = TextEditingController(
        text: newStretch.youtubeUrl,
      );

      _nameController.clear();
      _categoryController.clear();
      _youtubeController.clear();
      _durationController.clear();
      _descriptionController.clear();
      _selectedDifficulty = 'Beginner';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stretch "${newStretch.name}" added successfully!'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF059669),
        ),
      );

      _saveAllStretchingChanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Stretch Videos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Update YouTube video links and add custom stretches',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),
          ...stretchingLibrary.map((stretch) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stretch.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1F2937),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${stretch.category}  ${stretch.duration}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: const Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ),
                        if (stretch.isCustom)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF059669),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Custom',
                              style: TextStyle(
                                color: Color(0xFF059669),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controllers[stretch.id],
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Paste YouTube video URL here',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                      ),
                      onChanged: (value) {
                        widget.stretchingYoutubeLinks[stretch.id] = value;
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF059669).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add New Stretch',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Stretch Name',
                          hintText: 'e.g., Forward Fold',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter stretch name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _categoryController.text.isEmpty
                            ? _categories.first
                            : _categoryController.text,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          _categoryController.text = value ?? '';
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _durationController,
                        decoration: InputDecoration(
                          labelText: 'Duration',
                          hintText: 'e.g., 30 seconds',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter duration';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _youtubeController,
                        decoration: InputDecoration(
                          labelText: 'YouTube URL',
                          hintText: 'https://www.youtube.com/watch?v=...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter YouTube URL';
                          }
                          if (!value.contains('youtube.com')) {
                            return 'Please enter a valid YouTube URL';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Brief description of the stretch',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDifficulty,
                        decoration: InputDecoration(
                          labelText: 'Difficulty Level',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _difficulties.map((difficulty) {
                          return DropdownMenuItem(
                            value: difficulty,
                            child: Text(difficulty),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDifficulty = value ?? 'Beginner';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _addNewStretch,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Add Stretch',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saveAllStretchingChanges,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Save All Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestDayScheduler extends StatefulWidget {
  final List<ClientProfile> clients;
  final Function(RestDay) onRestDayAdded;

  const _RestDayScheduler({
    required this.clients,
    required this.onRestDayAdded,
  });

  @override
  State<_RestDayScheduler> createState() => _RestDaySchedulerState();
}

class _RestDaySchedulerState extends State<_RestDayScheduler> {
  String? _selectedClientName;
  DateTime? _selectedDate;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Normalize to midnight to avoid time comparison issues
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  void _scheduleRestDay() {
    if (_selectedClientName == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client and date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Normalize date to midnight to ensure calendar matching works
    final normalizedDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );

    final restDay = RestDay(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: normalizedDate,
      clientName: _selectedClientName!,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    print('📆 Creating rest day: ${restDay.date} for ${restDay.clientName}');
    print('   Selected date was: $_selectedDate');
    print('   Is future: ${restDay.date.isAfter(DateTime.now())}');

    widget.onRestDayAdded(restDay);

    // Reset form
    setState(() {
      _selectedClientName = null;
      _selectedDate = null;
      _notesController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rest day scheduled successfully'),
        backgroundColor: Color(0xFF059669),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF7C3AED).withOpacity(0.1),
              const Color(0xFF3B82F6).withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.hotel,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schedule Rest Days',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Plan recovery days for your clients',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Schedule Form Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Schedule New Rest Day',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Client Selection
                        DropdownButtonFormField<String>(
                          initialValue: _selectedClientName,
                          decoration: InputDecoration(
                            labelText: 'Select Client',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: widget.clients.map((client) {
                            return DropdownMenuItem(
                              value: client.name,
                              child: Text(client.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedClientName = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date Selection
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Rest Day Date',
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            child: Text(
                              _selectedDate != null
                                  ? DateFormat(
                                      'EEEE, MMMM d, yyyy',
                                    ).format(_selectedDate!)
                                  : 'Tap to select date',
                              style: TextStyle(
                                color: _selectedDate != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Notes Field
                        TextField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            labelText: 'Notes (Optional)',
                            hintText: 'Add any notes about this rest day...',
                            prefixIcon: const Icon(Icons.note),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),

                        // Schedule Button
                        FilledButton(
                          onPressed: _scheduleRestDay,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Schedule Rest Day',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Info Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: const Color(0xFF3B82F6),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'About Rest Days',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Rest days will appear in blue on the client\'s calendar\n'
                          '• Clients cannot schedule workouts on rest days\n'
                          '• Use notes to explain the reason for rest (recovery, injury prevention, etc.)\n'
                          '• Rest days are important for muscle recovery and preventing overtraining',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
