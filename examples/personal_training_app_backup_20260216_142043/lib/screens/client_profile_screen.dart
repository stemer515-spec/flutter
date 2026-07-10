import 'package:flutter/material.dart';
import '../models/client_profile.dart';
import '../utils/storage_helper.dart';

class ClientProfileScreen extends StatefulWidget {
  final ClientProfile profile;
  final Function(ClientProfile) onProfileUpdated;

  const ClientProfileScreen({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  BoxDecoration _sectionDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _waistController;
  late TextEditingController _chestController;
  late TextEditingController _hipsController;
  late TextEditingController _armController;
  late TextEditingController _backController;
  late TextEditingController _goalsController;
  late TextEditingController _smartGoalsController;
  late TextEditingController _hobbiesController;
  late TextEditingController _injuriesController;
  late String _selectedExperience;
  late String _selectedLocation;
  late String? _profilePictureUrl;
  bool _workoutNotificationsEnabled = true;

  final List<String> _experienceLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  final List<String> _trainingLocations = ['Home', 'Gym'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _ageController = TextEditingController(
      text: widget.profile.age?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: widget.profile.heightCm?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.profile.weightKg?.toString() ?? '',
    );
    _waistController = TextEditingController(
      text: widget.profile.bodyMeasurementsCm['waist']?.toString() ?? '',
    );
    _chestController = TextEditingController(
      text: widget.profile.bodyMeasurementsCm['chest']?.toString() ?? '',
    );
    _hipsController = TextEditingController(
      text: widget.profile.bodyMeasurementsCm['hips']?.toString() ?? '',
    );
    _armController = TextEditingController(
      text: widget.profile.bodyMeasurementsCm['arm']?.toString() ?? '',
    );
    _backController = TextEditingController(
      text: widget.profile.bodyMeasurementsCm['back']?.toString() ?? '',
    );
    _goalsController = TextEditingController(text: widget.profile.fitnessGoals);
    _smartGoalsController = TextEditingController(
      text: widget.profile.smartGoals,
    );
    _hobbiesController = TextEditingController(
      text: widget.profile.hobbiesInterests,
    );
    _injuriesController = TextEditingController(
      text: widget.profile.injuriesLimitations,
    );
    _selectedExperience = widget.profile.trainingExperience.isNotEmpty
        ? widget.profile.trainingExperience
        : 'Beginner';
    _selectedLocation = widget.profile.trainingLocation.isNotEmpty
        ? widget.profile.trainingLocation
        : 'Gym';
    _profilePictureUrl = widget.profile.profilePictureUrl;
    _workoutNotificationsEnabled =
        (StorageHelper.getString(
              'workout_notifications_${widget.profile.username}',
            ) ??
            'true') ==
        'true';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _waistController.dispose();
    _chestController.dispose();
    _hipsController.dispose();
    _armController.dispose();
    _backController.dispose();
    _goalsController.dispose();
    _smartGoalsController.dispose();
    _hobbiesController.dispose();
    _injuriesController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    print('💾 Saving profile...');
    print('   Weight text: "${_weightController.text}"');
    print('   Parsed weight: ${double.tryParse(_weightController.text)}');
    print('   Height text: "${_heightController.text}"');
    print('   Parsed height: ${double.tryParse(_heightController.text)}');
    print('   Age text: "${_ageController.text}"');
    print('   Parsed age: ${int.tryParse(_ageController.text)}');

    final bodyMeasurements = <String, double>{};
    final waist = double.tryParse(_waistController.text);
    final chest = double.tryParse(_chestController.text);
    final hips = double.tryParse(_hipsController.text);
    final arm = double.tryParse(_armController.text);
    final back = double.tryParse(_backController.text);

    if (waist != null && waist > 0) {
      bodyMeasurements['waist'] = waist;
    }
    if (chest != null && chest > 0) {
      bodyMeasurements['chest'] = chest;
    }
    if (hips != null && hips > 0) {
      bodyMeasurements['hips'] = hips;
    }
    if (arm != null && arm > 0) {
      bodyMeasurements['arm'] = arm;
    }
    if (back != null && back > 0) {
      bodyMeasurements['back'] = back;
    }

    final updatedProfile = ClientProfile(
      username: widget.profile.username,
      email: widget.profile.email,
      name: _nameController.text,
      age: int.tryParse(_ageController.text),
      heightCm: double.tryParse(_heightController.text),
      weightKg: double.tryParse(_weightController.text),
      fitnessGoals: _goalsController.text,
      smartGoals: _smartGoalsController.text,
      trainingExperience: _selectedExperience,
      trainingLocation: _selectedLocation,
      hobbiesInterests: _hobbiesController.text,
      injuriesLimitations: _injuriesController.text,
      profilePictureUrl: _profilePictureUrl,
      isSuspended: widget.profile.isSuspended,
      strengthPRs: widget.profile.strengthPRs, // Preserve existing PRs
      bodyMeasurementsCm: bodyMeasurements,
      illnessDays: widget.profile.illnessDays,
    );

    print('✅ Profile object created with weight: ${updatedProfile.weightKg}');
    widget.onProfileUpdated(updatedProfile);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF059669),
      ),
    );
  }

  void _uploadProfilePicture() {
    // Web-only feature - file upload not available on mobile
    // final input = html.FileUploadInputElement()
    //   ..accept = 'image/*'
    //   ..click();

    // input.onChange.listen((e) {
    //   final files = input.files;
    //   if (files!.isNotEmpty) {
    //     final file = files[0];
    //     final reader = html.FileReader();
    //     reader.onLoad.listen((_) {
    //       setState(() {
    //         _profilePictureUrl = reader.result as String;
    //       });
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(
    //           content: Text('Profile picture updated!'),
    //           duration: Duration(seconds: 1),
    //           backgroundColor: Color(0xFF2563EB),
    //         ),
    //       );
    //     });
    //     reader.readAsDataUrl(file);
    //   }
    // });
  }

  void _removeProfilePicture() {
    setState(() {
      _profilePictureUrl = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture removed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Profile'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                    color: const Color(0xFF1D4ED8).withOpacity(0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Profile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Update your personal information and training details',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.92),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile Picture Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2563EB),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _profilePictureUrl != null
                        ? ClipOval(
                            child: Image.network(
                              _profilePictureUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipOval(
                            child: Container(
                              color: const Color(0xFFF3F4F6),
                              child: const Icon(
                                Icons.person,
                                size: 70,
                                color: Color(0xFFD1D5DB),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '@${widget.profile.username}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _uploadProfilePicture,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Upload Photo'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                        ),
                      ),
                      if (_profilePictureUrl != null)
                        OutlinedButton.icon(
                          onPressed: _removeProfilePicture,
                          icon: const Icon(Icons.delete),
                          label: const Text('Remove'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFDC2626)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Personal Information Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _sectionDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    icon: Icons.person,
                    title: 'Personal Information',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'Your full name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ageController,
                          decoration: InputDecoration(
                            labelText: 'Age',
                            hintText: 'e.g., 28',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _heightController,
                          decoration: InputDecoration(
                            labelText: 'Height (cm)',
                            hintText: 'e.g., 180',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _weightController,
                          decoration: InputDecoration(
                            labelText: 'Weight (kg)',
                            hintText: 'e.g., 75',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Body Measurements Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _sectionDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    icon: Icons.straighten,
                    title: 'Body Measurements (cm)',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track measurements over time for fat-loss progress.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final shouldStackFields = constraints.maxWidth < 700;

                      final waistField = TextField(
                        controller: _waistController,
                        decoration: InputDecoration(
                          labelText: 'Waist',
                          hintText: 'e.g., 82',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      );

                      final chestField = TextField(
                        controller: _chestController,
                        decoration: InputDecoration(
                          labelText: 'Chest',
                          hintText: 'e.g., 98',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      );

                      final hipsField = TextField(
                        controller: _hipsController,
                        decoration: InputDecoration(
                          labelText: 'Hips',
                          hintText: 'e.g., 95',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      );

                      final armField = TextField(
                        controller: _armController,
                        decoration: InputDecoration(
                          labelText: 'Arm',
                          hintText: 'e.g., 34',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      );

                      final backField = TextField(
                        controller: _backController,
                        decoration: InputDecoration(
                          labelText: 'Back',
                          hintText: 'e.g., 102',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      );

                      if (shouldStackFields) {
                        return Column(
                          children: [
                            waistField,
                            const SizedBox(height: 12),
                            chestField,
                            const SizedBox(height: 12),
                            hipsField,
                            const SizedBox(height: 12),
                            armField,
                            const SizedBox(height: 12),
                            backField,
                          ],
                        );
                      }

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: waistField),
                              const SizedBox(width: 12),
                              Expanded(child: chestField),
                              const SizedBox(width: 12),
                              Expanded(child: hipsField),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: armField),
                              const SizedBox(width: 12),
                              Expanded(child: backField),
                              const SizedBox(width: 12),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Strength PRs Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _sectionDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    icon: Icons.trending_up,
                    title: 'Strength PRs',
                  ),
                  const SizedBox(height: 10),
                  if (widget.profile.strengthPRs.isEmpty)
                    Text(
                      'No PRs recorded yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          (widget.profile.strengthPRs.entries.toList()
                                ..sort((a, b) => b.value.compareTo(a.value)))
                              .map(
                                (entry) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFBFDBFE),
                                    ),
                                  ),
                                  child: Text(
                                    '${entry.key}: ${entry.value.toStringAsFixed(1)} kg',
                                    style: const TextStyle(
                                      color: Color(0xFF1E40AF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Training Information Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _sectionDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    icon: Icons.fitness_center,
                    title: 'Training Information',
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedExperience,
                    decoration: InputDecoration(
                      labelText: 'Training Experience Level',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _experienceLevels.map((level) {
                      return DropdownMenuItem(value: level, child: Text(level));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedExperience = value ?? 'Beginner';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedLocation,
                    decoration: InputDecoration(
                      labelText: 'Training Location',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(
                        _selectedLocation == 'Home'
                            ? Icons.home
                            : Icons.fitness_center,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    items: _trainingLocations.map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Row(
                          children: [
                            Icon(
                              location == 'Home'
                                  ? Icons.home
                                  : Icons.fitness_center,
                              size: 18,
                              color: const Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 8),
                            Text(location),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value ?? 'Gym';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _goalsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Fitness Goals',
                      hintText:
                          'e.g., Build muscle, Lose weight, Increase endurance',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _smartGoalsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'SMART Goals',
                      hintText:
                          'Specific, Measurable, Achievable, Relevant, Time-bound goals',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Additional Information Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _sectionDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    icon: Icons.info,
                    title: 'Additional Information',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _hobbiesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Hobbies & Interests',
                      hintText: 'e.g., Running, Swimming, Yoga, Hiking',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _injuriesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Injuries or Limitations',
                      hintText:
                          'e.g., Lower back pain, Right knee injury, Limited shoulder mobility',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: _sectionDecoration(),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Workout Notifications'),
                subtitle: const Text(
                  'Notify me when a new workout is uploaded (while app is open).',
                ),
                value: _workoutNotificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _workoutNotificationsEnabled = value;
                  });
                  StorageHelper.setString(
                    'workout_notifications_${widget.profile.username}',
                    value ? 'true' : 'false',
                  );
                },
                activeThumbColor: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 28),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saveProfile,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Save Profile Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2563EB), size: 18),
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
}
