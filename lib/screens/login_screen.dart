import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final phoneText = _phoneController.text.trim();
    if (phoneText.isEmpty) {
      setState(() {
        _errorMessage = 'Phone number cannot be empty';
      });
    } else if (phoneText.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phoneText)) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit phone number';
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OtpScreen(phoneNumber: phoneText)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Header
              Text(
                'Welcome to Rakta Bandhan',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Your help can save a life.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 48),

              // Country Code & Phone Input Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country Code Container
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '+91',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Phone TextField
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      onChanged: (val) {
                        if (_errorMessage != null) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter phone number',
                      ),
                    ),
                  ),
                ],
              ),

              // Inline Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  child: const Text('Continue'),
                ),
              ),

              const SizedBox(height: 24),

              // Consent Text
              Text(
                'By continuing, you consent to receive an OTP code to verify your phone number.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
