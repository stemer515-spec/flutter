class ClientProfile {
  String username; // Client's username for login
  String email; // Client's email address
  String name;
  int? age;
  double? heightCm; // Height in centimeters
  double? weightKg; // Weight in kilograms
  String fitnessGoals; // e.g., "Build muscle, Lose weight"
  String smartGoals; // SMART goals for focused progression
  String trainingExperience; // e.g., "Beginner", "Intermediate", "Advanced"
  String trainingLocation; // "Home" or "Gym"
  String hobbiesInterests;
  String injuriesLimitations;
  String? profilePictureUrl; // URL or path to profile picture
  bool isSuspended; // Account suspension status
  Map<String, double> strengthPRs; // Map of exercise name to PR weight in kg
  Map<String, double> bodyMeasurementsCm; // e.g., waist/chest/hips in cm
  List<DateTime> illnessDays; // List of dates when client was ill

  ClientProfile({
    required this.username,
    required this.email,
    required this.name,
    this.age,
    this.heightCm,
    this.weightKg,
    this.fitnessGoals = '',
    this.smartGoals = '',
    this.trainingExperience = 'Beginner',
    this.trainingLocation = 'Gym',
    this.hobbiesInterests = '',
    this.injuriesLimitations = '',
    this.profilePictureUrl,
    this.isSuspended = false,
    Map<String, double>? strengthPRs,
    Map<String, double>? bodyMeasurementsCm,
    List<DateTime>? illnessDays,
  }) : strengthPRs = strengthPRs ?? {},
       bodyMeasurementsCm = bodyMeasurementsCm ?? {},
       illnessDays = illnessDays ?? [];
}
