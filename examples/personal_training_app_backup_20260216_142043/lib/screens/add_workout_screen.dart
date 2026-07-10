import 'package:flutter/material.dart';
import '../models/workout.dart';

class AddWorkoutScreen extends StatefulWidget {
  final Function(Workout) onWorkoutAdded;

  const AddWorkoutScreen({super.key, required this.onWorkoutAdded});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _exerciseNameController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  late TextEditingController _notesController;
  late TextEditingController _durationController;
  late TextEditingController _distanceController;

  final List<Exercise> _exercises = [];
  DateTime _selectedDate = DateTime.now();
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
    _durationController = TextEditingController();
    _distanceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _exerciseNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
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
        _exerciseNameController.clear();
        _durationController.clear();
        _distanceController.clear();
        _notesController.clear();
      });
    } else {
      // Validate strength training fields
      if (_setsController.text.isEmpty ||
          _repsController.text.isEmpty ||
          _weightController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all exercise fields')),
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
        _exerciseNameController.clear();
        _setsController.clear();
        _repsController.clear();
        _weightController.clear();
        _notesController.clear();
      });
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
          content: Text('Please enter workout name and add exercises'),
        ),
      );
      return;
    }

    final workout = Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      date: _selectedDate,
      exercises: List.from(_exercises),
    );

    widget.onWorkoutAdded(workout);
    _nameController.clear();
    setState(() {
      _exercises.clear();
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New Workout',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Date: ${_selectedDate.toString().split(' ')[0]}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Change'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Add Exercises', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
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
                                decoration: InputDecoration(
                                  labelText: 'Sets',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _repsController,
                                decoration: InputDecoration(
                                  labelText: 'Reps',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _weightController,
                                decoration: InputDecoration(
                                  labelText: 'Weight (kg)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _setsController,
                                decoration: InputDecoration(
                                  labelText: 'Sets',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _repsController,
                                decoration: InputDecoration(
                                  labelText: 'Reps',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _weightController,
                                decoration: InputDecoration(
                                  labelText: 'Weight (kg)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
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
                            decoration: InputDecoration(
                              labelText: 'Duration (min)',
                              hintText: 'Optional',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _distanceController,
                            decoration: InputDecoration(
                              labelText: 'Distance (km)',
                              hintText: 'Optional',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addExercise,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Exercise'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_exercises.isNotEmpty) ...[
            Text(
              'Exercises Added (${_exercises.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
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
                        : '${exercise.sets}x${exercise.reps} @ ${exercise.weight} kg',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeExercise(idx),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitWorkout,
                child: const Text('Save Workout'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
