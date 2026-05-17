import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class SetPasswordScreen extends StatelessWidget {
  const SetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Scaffold automatically uses scaffoldBackgroundColor from the active theme
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Back'),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              Center(
                child: Text(
                  'Set New Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Set your new password',
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurface.withOpacity(0.5),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 36),

              const AppTextField(
                hint: 'Enter Your New Password',
                isPassword: true,
              ),
              const SizedBox(height: 14),

              const AppTextField(
                hint: 'Confirm Password',
                isPassword: true,
              ),
              const SizedBox(height: 8),

              Text(
                'At least 1 number or a special character',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withOpacity(0.5),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Password updated successfully!'),
                      backgroundColor: cs.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (_) => false);
                  });
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}