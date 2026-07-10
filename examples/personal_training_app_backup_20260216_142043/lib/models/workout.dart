class Workout {
  final String id;
  final String name;
  final DateTime date;
  final List<Exercise> exercises;
  final String? notes;
  final String? feedback; // Client's feedback after completing workout
  final String? instructorReview; // Instructor's review notes
  final String clientName;
  final bool isCompleted;
  final bool isReviewedByInstructor;
  final bool isReviewAcknowledged; // Whether client has acknowledged the review

  Workout({
    required this.id,
    required this.name,
    required this.date,
    required this.exercises,
    this.notes,
    this.feedback,
    this.instructorReview,
    this.clientName = 'Alex Johnson',
    this.isCompleted = false,
    this.isReviewedByInstructor = false,
    this.isReviewAcknowledged = false,
  });

  int get totalSets =>
      exercises.where((ex) => !ex.isCardio).fold(0, (sum, ex) => sum + ex.sets);
  int get totalReps => exercises
      .where((ex) => !ex.isCardio)
      .fold(0, (sum, ex) => sum + (ex.reps * ex.sets));
  double get estimatedVolume => exercises
      .where((ex) => !ex.isCardio)
      .fold(0.0, (sum, ex) => sum + (ex.weight * ex.reps * ex.sets));

  // Cardio-specific analytics
  int get totalCardioMinutes => exercises
      .where((ex) => ex.isCardio && ex.durationMinutes != null)
      .fold(0, (sum, ex) => sum + ex.durationMinutes!);
  double get totalCardioDistanceKm => exercises
      .where((ex) => ex.isCardio && ex.distanceKm != null)
      .fold(0.0, (sum, ex) => sum + ex.distanceKm!);
  int get cardioExerciseCount => exercises.where((ex) => ex.isCardio).length;
  int get strengthExerciseCount => exercises.where((ex) => !ex.isCardio).length;

  Duration get duration => const Duration(minutes: 60); // Default estimate

  Workout copyWith({
    String? id,
    String? name,
    DateTime? date,
    List<Exercise>? exercises,
    String? notes,
    String? feedback,
    String? instructorReview,
    String? clientName,
    bool? isCompleted,
    bool? isReviewedByInstructor,
    bool? isReviewAcknowledged,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      feedback: feedback ?? this.feedback,
      instructorReview: instructorReview ?? this.instructorReview,
      clientName: clientName ?? this.clientName,
      isCompleted: isCompleted ?? this.isCompleted,
      isReviewedByInstructor:
          isReviewedByInstructor ?? this.isReviewedByInstructor,
      isReviewAcknowledged: isReviewAcknowledged ?? this.isReviewAcknowledged,
    );
  }
}

class Exercise {
  final String name;
  final int sets;
  final int reps;
  final double weight; // in kg (default/recommended weight)
  final String? notes;
  final int? restSeconds;
  final List<double>? setWeights; // Actual weight used per set during workout

  // Cardio-specific fields
  final bool isCardio; // True if this is a cardio exercise
  final int? durationMinutes; // Duration for cardio exercises
  final double? distanceKm; // Distance for cardio exercises (in kilometers)

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    this.notes,
    this.restSeconds = 60,
    this.setWeights,
    this.isCardio = false,
    this.durationMinutes,
    this.distanceKm,
  });

  double get volumePerSet => isCardio ? 0 : weight * reps;
  double get totalVolume {
    // Cardio exercises don't have volume
    if (isCardio) return 0;

    // If setWeights are recorded, use them for accurate volume calculation
    if (setWeights != null && setWeights!.isNotEmpty) {
      double total = 0;
      for (var weight in setWeights!) {
        total += weight * reps;
      }
      return total;
    }
    // Otherwise use the default weight
    return weight * reps * sets;
  }

  Exercise copyWith({
    String? name,
    int? sets,
    int? reps,
    double? weight,
    String? notes,
    int? restSeconds,
    List<double>? setWeights,
    bool? isCardio,
    int? durationMinutes,
    double? distanceKm,
  }) {
    return Exercise(
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      restSeconds: restSeconds ?? this.restSeconds,
      setWeights: setWeights ?? this.setWeights,
      isCardio: isCardio ?? this.isCardio,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}
