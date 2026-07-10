import 'package:flutter/material.dart';
import '../utils/storage_helper.dart';

class LoginScreen extends StatefulWidget {
  final Function(String) onRoleSelected; // 'client' or 'instructor'
  final Function(String)?
  onClientLogin; // Called with email when client logs in

  const LoginScreen({
    super.key,
    required this.onRoleSelected,
    this.onClientLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _clientUsernameController = TextEditingController();
  final _clientPasswordController = TextEditingController();
  final _instructorEmailController = TextEditingController();
  final _instructorPasswordController = TextEditingController();
  bool _obscureClientPassword = true;
  bool _obscureInstructorPassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() {
    final rememberMe = StorageHelper.getString('rememberMe') == 'true';

    if (rememberMe) {
      setState(() {
        _rememberMe = true;
        _clientUsernameController.text =
            StorageHelper.getString('clientUsername') ?? '';
        _clientPasswordController.text =
            StorageHelper.getString('clientPassword') ?? '';
      });

      // Auto-login if credentials are saved
      if (_clientUsernameController.text.isNotEmpty &&
          _clientPasswordController.text.isNotEmpty) {
        Future.delayed(Duration.zero, () {
          widget.onRoleSelected('client');
        });
      }
    }
  }

  void _saveCredentials() {
    if (_rememberMe) {
      StorageHelper.setString('rememberMe', 'true');
      StorageHelper.setString('clientUsername', _clientUsernameController.text);
      StorageHelper.setString('clientPassword', _clientPasswordController.text);
    } else {
      StorageHelper.remove('rememberMe');
      StorageHelper.remove('clientUsername');
      StorageHelper.remove('clientPassword');
    }
  }

  @override
  void dispose() {
    _clientUsernameController.dispose();
    _clientPasswordController.dispose();
    _instructorEmailController.dispose();
    _instructorPasswordController.dispose();
    super.dispose();
  }

  void _clientLogin() {
    final username = _clientUsernameController.text.trim();
    final password = _clientPasswordController.text;

    print('🔐 DEBUG: Client login attempt - Username: $username');

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    // Check if account exists and password matches
    final storedPassword = StorageHelper.getString('user_$username');
    print('🔍 DEBUG: Looking for key: user_$username');
    print('🔍 DEBUG: Stored password: $storedPassword');
    print('🔍 DEBUG: Entered password: $password');
    if (storedPassword != null) {
      if (storedPassword == password) {
        _saveCredentials();

        // Check if this is first login
        final isFirstLogin =
            StorageHelper.getString('first_login_$username') != 'false';

        if (isFirstLogin) {
          // Show password change dialog for first login
          _showFirstLoginPasswordChange(username);
        } else {
          widget.onClientLogin?.call(username);
          widget.onRoleSelected('client');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account not found. Please sign up first.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showFirstLoginPasswordChange(String username) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('First Login - Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please set a new password for your account.',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
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
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirm ? Icons.visibility : Icons.visibility_off,
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
          actions: [
            FilledButton(
              onPressed: () {
                final newPassword = newPasswordController.text;
                final confirmPassword = confirmPasswordController.text;

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

                // Update password and mark first login as complete
                StorageHelper.setString('user_$username', newPassword);
                StorageHelper.setString('first_login_$username', 'false');

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully!'),
                    backgroundColor: Color(0xFF059669),
                  ),
                );

                // Update saved credentials if remember me is enabled
                if (_rememberMe) {
                  StorageHelper.setString('clientPassword', newPassword);
                }

                widget.onClientLogin?.call(username);
                widget.onRoleSelected('client');
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

  void _instructorLogin() {
    // Hardcoded instructor credentials
    const instructorEmail = 'merianstephen@sim.com';
    const instructorPassword = '1234567890';

    if (_instructorEmailController.text.isEmpty ||
        _instructorPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    // Check for stored password first, fall back to default
    final storedPassword =
        StorageHelper.getString('instructor_password') ?? instructorPassword;

    if (_instructorEmailController.text == instructorEmail &&
        _instructorPasswordController.text == storedPassword) {
      widget.onRoleSelected('instructor');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid instructor credentials'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Smart Training Platform',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2563EB).withOpacity(0.1),
                          const Color(0xFF7C3AED).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2563EB).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '"The hardest part of any workout is turning up"',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // CLIENT LOGIN SECTION
            Text(
              'Client Login',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),

            // Username Field
            TextField(
              controller: _clientUsernameController,
              decoration: const InputDecoration(
                hintText: 'Username',
                prefixIcon: Icon(Icons.person, color: Color(0xFF6B7280)),
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            TextField(
              controller: _clientPasswordController,
              obscureText: _obscureClientPassword,
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF6B7280)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureClientPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: const Color(0xFF6B7280),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureClientPassword = !_obscureClientPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password Field (only in signup mode)
            // Remember Me Checkbox
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFF2563EB),
                ),
                Text(
                  'Remember me',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Client Login Button
            FilledButton(
              onPressed: _clientLogin,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Login as Client',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 40),

            // DIVIDER
            const Divider(thickness: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 32),

            // INSTRUCTOR LOGIN SECTION
            Text(
              'Instructor Login',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5B21B6),
              ),
            ),
            const SizedBox(height: 12),

            // Instructor Email
            TextField(
              controller: _instructorEmailController,
              decoration: const InputDecoration(
                hintText: 'Instructor email',
                prefixIcon: Icon(Icons.email, color: Color(0xFF6B7280)),
                isDense: true,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),

            // Instructor Password
            TextField(
              controller: _instructorPasswordController,
              obscureText: _obscureInstructorPassword,
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF6B7280)),
                isDense: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureInstructorPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: const Color(0xFF6B7280),
                  ),
                  iconSize: 20,
                  onPressed: () {
                    setState(() {
                      _obscureInstructorPassword = !_obscureInstructorPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Instructor Login Button
            FilledButton(
              onPressed: _instructorLogin,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
              child: const Text(
                'Login as Instructor',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
