import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../constants/api_constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  String _selectedRole = 'user';

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to terms and conditions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final request = context.read<CookieRequest>();

      try {
        final response = await request.postJson(
          ApiConstants.registerUrl,
          jsonEncode({
            'username': _usernameController.text,
            'email': _emailController.text,
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
            'password1': _passwordController.text,
            'password2': _confirmPasswordController.text,
            'phone_number': _phoneController.text.isEmpty
                ? ''
                : _phoneController.text,
            'role': _selectedRole,
          }),
        );

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          if (response['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response['message'] ?? 'Registration successful!',
                ),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to login page
            Navigator.pop(context);
          } else {
            // Handle validation errors
            String errorMessage = response['message'] ?? 'Registration failed';

            if (response['errors'] != null) {
              final errors = response['errors'] as Map<String, dynamic>;
              final errorList = <String>[];
              errors.forEach((key, value) {
                if (value is List) {
                  errorList.addAll(value.cast<String>());
                }
              });
              if (errorList.isNotEmpty) {
                errorMessage = errorList.join('\n');
              }
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF5409DA), // primary-600
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Welcome Text
                  _buildHeader(),
                  const SizedBox(height: 40),

                  // Register Form Card
                  _buildRegisterCard(),
                  const SizedBox(height: 24),

                  // Login Link
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo/Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: const Icon(Icons.sports_soccer, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 24),

        // Welcome Text
        const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign up to start booking your favorite courts',
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Username Field
              _buildInputField(
                controller: _usernameController,
                label: 'Username',
                hintText: 'Enter your username',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // First Name Field
              _buildInputField(
                controller: _firstNameController,
                label: 'First Name',
                hintText: 'Enter your first name',
                prefixIcon: Icons.badge_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Last Name Field
              _buildInputField(
                controller: _lastNameController,
                label: 'Last Name',
                hintText: 'Enter your last name',
                prefixIcon: Icons.badge_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email Field
              _buildInputField(
                controller: _emailController,
                label: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password Field
              _buildInputField(
                controller: _passwordController,
                label: 'Password',
                hintText: 'Create a password',
                prefixIcon: Icons.lock_outline,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF5409DA).withOpacity(0.7),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Confirm Password Field
              _buildInputField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hintText: 'Re-enter your password',
                prefixIcon: Icons.lock_outline,
                obscureText: !_isConfirmPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF5409DA).withOpacity(0.7),
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Phone Number Field (Optional)
              _buildInputField(
                controller: _phoneController,
                label: 'Phone Number (Optional)',
                hintText: 'Enter your phone number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              // Role Selection
              _buildRoleSelector(),
              const SizedBox(height: 20),

              // Terms and Conditions Checkbox
              _buildTermsCheckbox(),
              const SizedBox(height: 24),

              // Register Button
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF5409DA),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(color: Color(0xFF5409DA)),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: const Color(0xFF5409DA).withOpacity(0.4),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: const Color(0xFF5409DA).withOpacity(0.7),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFF5409DA).withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFF5409DA).withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFF5409DA).withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF5409DA), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Type',
          style: TextStyle(
            color: Color(0xFF5409DA),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF5409DA).withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF5409DA).withOpacity(0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRole,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: const Color(0xFF5409DA).withOpacity(0.7),
              ),
              style: const TextStyle(color: Color(0xFF5409DA), fontSize: 14),
              items: const [
                DropdownMenuItem(value: 'user', child: Text('User/Penyewa')),
                DropdownMenuItem(
                  value: 'mitra',
                  child: Text('Mitra/Pemilik Lapangan'),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
            side: BorderSide(
              color: const Color(0xFF5409DA).withOpacity(0.5),
              width: 2,
            ),
            fillColor: MaterialStateProperty.resolveWith<Color>((
              Set<MaterialState> states,
            ) {
              if (states.contains(MaterialState.selected)) {
                return Colors.white;
              }
              return Colors.transparent;
            }),
            checkColor: const Color(0xFF5409DA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            children: [
              Text(
                'I agree to the ',
                style: TextStyle(
                  color: const Color(0xFF5409DA).withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Show terms and conditions
                },
                child: const Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    color: Color(0xFF5409DA),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                ' and ',
                style: TextStyle(
                  color: const Color(0xFF5409DA).withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Show privacy policy
                },
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Color(0xFF5409DA),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5409DA),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: const Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
