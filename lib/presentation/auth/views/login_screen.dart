import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/di/auth_providers.dart';

/// Full-screen login entry point presented to unauthenticated users.
///
/// Design philosophy: minimal, single call-to-action, no distractions.
/// The screen manages its own async state locally so the router stays clean.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signInWithGoogle() async {
    final hasGoogleConfig = (dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '').isNotEmpty;

    // As per user request: if there's no client ID, just print to console
    // instead of crashing or disabling the button.
    if (!hasGoogleConfig) {
      debugPrint('ℹ️ Google Sign-In button pressed, but GOOGLE_WEB_CLIENT_ID is missing in .env');
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithGoogle();
      // GoRouter's redirect guard will automatically navigate to /dashboard
      // when authStateProvider emits a signed-in event.
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Sign-in failed. Please try again or check console if Client ID is missing.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = const Color(0xFF00C853);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App logo/branding
              Icon(
                Icons.kitchen_rounded,
                size: 80,
                color: accent,
              ),
              const SizedBox(height: 24),
              Text(
                'PantryPro',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your offline-first pantry manager',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
              ),
              const SizedBox(height: 64),

              // Google Sign-In button (Always Active as requested)
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: const Icon(Icons.login_rounded),
                      label: const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

              // Error display
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],

              const SizedBox(height: 32),
              Text(
                'By continuing, you agree to our Privacy Policy.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

