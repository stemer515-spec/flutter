import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../models/rest_day.dart';
import 'package:intl/intl.dart';

class TrainingCalendar extends StatefulWidget {
  final List<Workout> workouts;
  final List<RestDay> restDays;

  const TrainingCalendar({
    super.key,
    required this.workouts,
    this.restDays = const [],
  });

  @override
  State<TrainingCalendar> createState() => _TrainingCalendarState();
}

class _TrainingCalendarState extends State<TrainingCalendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    // Get the weekday of the first day (1 = Monday, 7 = Sunday)
    final firstWeekday = firstDay.weekday;

    // Calculate days to show from previous month
    final daysFromPrevMonth = firstWeekday - 1;

    List<DateTime> days = [];

    // Add days from previous month
    for (int i = daysFromPrevMonth; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }

    // Add days of current month
    for (int i = 0; i < lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i + 1));
    }

    // Add days from next month to complete the grid
    final remainingDays = 42 - days.length; // 6 weeks * 7 days
    for (int i = 1; i <= remainingDays; i++) {
      days.add(DateTime(month.year, month.month + 1, i));
    }

    return days;
  }

  List<Workout> _getWorkoutsForDay(DateTime day) {
    return widget.workouts.where((workout) {
      return workout.date.year == day.year &&
          workout.date.month == day.month &&
          workout.date.day == day.day;
    }).toList();
  }

  bool _isRestDay(DateTime day) {
    return widget.restDays.any((restDay) {
      return restDay.date.year == day.year &&
          restDay.date.month == day.month &&
          restDay.date.day == day.day;
    });
  }

  String _getCardioDetails(Exercise exercise) {
    final parts = <String>[];
    if (exercise.durationMinutes != null && exercise.durationMinutes! > 0) {
      parts.add('${exercise.durationMinutes} min');
    }
    if (exercise.distanceKm != null && exercise.distanceKm! > 0) {
      parts.add('${exercise.distanceKm!.toStringAsFixed(1)} km');
    }
    return parts.isEmpty ? 'Cardio exercise' : parts.join(' • ');
  }

  RestDay? _getRestDayForDay(DateTime day) {
    try {
      return widget.restDays.firstWhere((restDay) {
        return restDay.date.year == day.year &&
            restDay.date.month == day.month &&
            restDay.date.day == day.day;
      });
    } catch (e) {
      return null;
    }
  }

  void _showWorkoutDetails(
    BuildContext context,
    DateTime day,
    List<Workout> workouts,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                      Icons.fitness_center,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Workout Overview',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE, MMMM d, yyyy').format(day),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  shrinkWrap: true,
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Workout name and status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      // Show cardio icon if workout contains cardio exercises
                                      if (workout.cardioExerciseCount > 0) ...[
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFFFF6B6B,
                                            ).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.directions_run,
                                            size: 18,
                                            color: Color(0xFFFF6B6B),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              workout.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Color(0xFF2563EB),
                                              ),
                                            ),
                                            // Show workout type indicator
                                            if (workout.cardioExerciseCount >
                                                    0 &&
                                                workout.strengthExerciseCount >
                                                    0)
                                              const Text(
                                                'Mixed (Cardio + Strength)',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF6B7280),
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              )
                                            else if (workout
                                                    .cardioExerciseCount >
                                                0)
                                              const Text(
                                                'Cardio Workout',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFFFF6B6B),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              )
                                            else if (workout
                                                    .strengthExerciseCount >
                                                0)
                                              const Text(
                                                'Strength Training',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF2563EB),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: workout.isCompleted
                                        ? const Color(
                                            0xFF059669,
                                          ).withValues(alpha: 0.1)
                                        : const Color(
                                            0xFFF59E0B,
                                          ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        workout.isCompleted
                                            ? Icons.check_circle
                                            : Icons.schedule,
                                        size: 16,
                                        color: workout.isCompleted
                                            ? const Color(0xFF059669)
                                            : const Color(0xFFF59E0B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        workout.isCompleted
                                            ? 'Completed'
                                            : 'Scheduled',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: workout.isCompleted
                                              ? const Color(0xFF059669)
                                              : const Color(0xFFF59E0B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),

                            // Cardio stats if present
                            if (workout.cardioExerciseCount > 0) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFF6B6B,
                                  ).withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFFF6B6B,
                                    ).withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.favorite,
                                      size: 16,
                                      color: Color(0xFFFF6B6B),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        workout.totalCardioMinutes > 0 &&
                                                workout.totalCardioDistanceKm >
                                                    0
                                            ? '${workout.totalCardioMinutes} min • ${workout.totalCardioDistanceKm.toStringAsFixed(1)} km'
                                            : workout.totalCardioMinutes > 0
                                            ? '${workout.totalCardioMinutes} minutes'
                                            : workout.totalCardioDistanceKm > 0
                                            ? '${workout.totalCardioDistanceKm.toStringAsFixed(1)} km'
                                            : 'Cardio exercises',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFFF6B6B),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Exercise list header
                            Row(
                              children: [
                                const Icon(
                                  Icons.list,
                                  size: 18,
                                  color: Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Exercises (${workout.exercises.length})',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Exercises
                            ...workout.exercises.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final exercise = entry.value;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: exercise.isCardio
                                      ? const Color(
                                          0xFFFF6B6B,
                                        ).withValues(alpha: 0.05)
                                      : const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: exercise.isCardio
                                        ? const Color(
                                            0xFFFF6B6B,
                                          ).withValues(alpha: 0.3)
                                        : const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: exercise.isCardio
                                            ? const Color(
                                                0xFFFF6B6B,
                                              ).withValues(alpha: 0.1)
                                            : const Color(
                                                0xFF2563EB,
                                              ).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: exercise.isCardio
                                            ? const Icon(
                                                Icons.directions_run,
                                                size: 14,
                                                color: Color(0xFFFF6B6B),
                                              )
                                            : Text(
                                                '${idx + 1}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2563EB),
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exercise.name,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: exercise.isCardio
                                                  ? const Color(0xFFFF6B6B)
                                                  : const Color(0xFF1F2937),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            exercise.isCardio
                                                ? _getCardioDetails(exercise)
                                                : '${exercise.sets} sets × ${exercise.reps} reps @ ${exercise.weight}kg',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: exercise.isCardio
                                                  ? const Color(
                                                      0xFFFF6B6B,
                                                    ).withValues(alpha: 0.8)
                                                  : const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            // Instructor review (if completed and reviewed)
                            if (workout.isCompleted &&
                                workout.isReviewedByInstructor &&
                                workout.instructorReview != null) ...[
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.rate_review,
                                    size: 18,
                                    color: Color(0xFF7C3AED),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Instructor Feedback',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7C3AED),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF7C3AED,
                                  ).withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF7C3AED,
                                    ).withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  workout.instructorReview!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  border: Border(
                    top: BorderSide(color: const Color(0xFFE5E7EB)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Close',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRestDayDialog(BuildContext context, DateTime day, RestDay restDay) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          DateFormat('MMMM d, yyyy').format(day),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hotel, color: const Color(0xFF3B82F6), size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Rest Day',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
            if (restDay.notes != null && restDay.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                restDay.notes!,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(_currentMonth);
    final monthName = DateFormat('MMMM yyyy').format(_currentMonth);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header with month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
                color: const Color(0xFF2563EB),
              ),
              Text(
                monthName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
                color: const Color(0xFF2563EB),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isCurrentMonth = day.month == _currentMonth.month;
              final isToday =
                  day.year == DateTime.now().year &&
                  day.month == DateTime.now().month &&
                  day.day == DateTime.now().day;
              final workouts = _getWorkoutsForDay(day);
              final isRestDay = _isRestDay(day);
              final restDay = _getRestDayForDay(day);
              final hasWorkout = workouts.isNotEmpty;
              final hasCompletedWorkout = workouts.any((w) => w.isCompleted);
              final hasScheduledWorkout = workouts.any((w) => !w.isCompleted);

              return GestureDetector(
                onTap: () {
                  if (hasWorkout) {
                    _showWorkoutDetails(context, day, workouts);
                  } else if (isRestDay && restDay != null) {
                    _showRestDayDialog(context, day, restDay);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? const Color(0xFF2563EB)
                        : isRestDay
                        ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
                        : hasCompletedWorkout
                        ? const Color(0xFF059669).withValues(alpha: 0.1)
                        : hasScheduledWorkout
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isRestDay
                        ? Border.all(color: const Color(0xFF3B82F6), width: 2)
                        : hasWorkout
                        ? Border.all(
                            color: hasCompletedWorkout
                                ? const Color(0xFF059669)
                                : const Color(0xFFF59E0B),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: hasWorkout || isRestDay
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday
                              ? Colors.white
                              : isCurrentMonth
                              ? const Color(0xFF1F2937)
                              : const Color(0xFFD1D5DB),
                        ),
                      ),
                      if (hasWorkout)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isToday
                                ? Colors.white
                                : hasCompletedWorkout
                                ? const Color(0xFF059669)
                                : const Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        )
                      else if (isRestDay)
                        Icon(
                          Icons.hotel,
                          size: 12,
                          color: isToday
                              ? Colors.white
                              : const Color(0xFF3B82F6),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
