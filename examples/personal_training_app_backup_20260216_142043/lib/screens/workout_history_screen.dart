import 'package:flutter/material.dart';
import '../models/workout.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  final List<Workout> workouts;

  const WorkoutHistoryScreen({super.key, required this.workouts});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  late List<Workout> workouts;
  final Map<String, TextEditingController> feedbackControllers = {};

  @override
  void initState() {
    super.initState();
    workouts = widget.workouts.where((w) => w.isCompleted).toList();
    for (var workout in workouts) {
      feedbackControllers[workout.id] = TextEditingController(
        text: workout.feedback ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (var controller in feedbackControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showAddExerciseDialog(BuildContext context, Workout workout) {
    final nameController = TextEditingController();
    final setsController = TextEditingController();
    final repsController = TextEditingController();
    final weightController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Exercise'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: setsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sets',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Reps',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final setsText = setsController.text.trim();
              final repsText = repsController.text.trim();
              final weightText = weightController.text.trim();

              if (name.isEmpty ||
                  setsText.isEmpty ||
                  repsText.isEmpty ||
                  weightText.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all required fields'),
                  ),
                );
                return;
              }

              try {
                final sets = int.parse(setsText);
                final reps = int.parse(repsText);
                final weight = double.parse(weightText);

                final newExercise = Exercise(
                  name: name,
                  sets: sets,
                  reps: reps,
                  weight: weight,
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                );

                final updatedExercises = [...workout.exercises, newExercise];
                final updatedWorkout = workout.copyWith(
                  exercises: updatedExercises,
                );

                setState(() {
                  final index = workouts.indexWhere((w) => w.id == workout.id);
                  if (index != -1) {
                    workouts[index] = updatedWorkout;
                  }
                });

                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exercise added successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Error adding exercise: $e')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedWorkouts = List<Workout>.from(workouts)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sortedWorkouts.length,
      itemBuilder: (context, index) {
        final workout = sortedWorkouts[index];
        final dateStr = DateFormat('MMM d, yyyy').format(workout.date);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ExpansionTile(
            title: Text(workout.name),
            subtitle: Text(dateStr),
            trailing: Chip(
              label: Text('${workout.exercises.length} exercises'),
              backgroundColor: Colors.blue[100],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exercises',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...workout.exercises.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final exercise = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${idx + 1}. ${exercise.name}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Vol: ${exercise.totalVolume.toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${exercise.sets} sets × ${exercise.reps} reps @ ${exercise.weight} kg',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (exercise.notes != null &&
                                exercise.notes!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Notes: ${exercise.notes}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddExerciseDialog(context, workout),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Exercise'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'Total Sets',
                          value: '${workout.totalSets}',
                        ),
                        _StatItem(
                          label: 'Total Reps',
                          value: '${workout.totalReps}',
                        ),
                        _StatItem(
                          label: 'Total Volume',
                          value:
                              '${workout.estimatedVolume.toStringAsFixed(0)} kg',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Feedback & Comments',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: feedbackControllers[workout.id],
                      maxLines: 3,
                      onChanged: (value) {
                        // Feedback can be updated and saved
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Add your feedback or comments about this workout...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
