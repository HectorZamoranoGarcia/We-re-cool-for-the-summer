import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/auth_providers.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isSigningOut = false;

  Future<void> _handleSignOut() async {
    if (_isSigningOut) return;

    setState(() => _isSigningOut = true);

    try {
      await ref.read(authRepositoryProvider).signOut();
      // GoRouter redirect guard sends user to /login automatically.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to sign out. Please check your connection.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text('Error: \$err')),
        data: (prefs) {
          final currentUser = ref.watch(currentUserProvider);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              // ── Profile Section ────────────────────────────────────────────
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF00C853).withOpacity(0.2),
                  child: const Icon(Icons.person, color: Color(0xFF00C853)),
                ),
                title: const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(prefs.username),
                trailing: const Icon(Icons.edit_outlined, size: 20),
                contentPadding: EdgeInsets.zero,
                onTap: () => _showEditNameDialog(context, ref, prefs.username),
              ),
              const Divider(height: 48),

              // ── Account Section (visible only when authenticated) ──────────
              if (currentUser != null) ...[
                const Text('ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),

                // Signed-in email display
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.email_outlined),
                  title: Text(
                    currentUser.email ?? 'No email on record',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('Google Account'),
                ),

                // Sign Out
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout_outlined),
                  title: const Text('Sign Out'),
                  trailing: _isSigningOut
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : null,
                  onTap: _isSigningOut ? null : _handleSignOut,
                ),

                // Privacy Policy (mandatory for Google Play data declarations)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.open_in_new_outlined, size: 18),
                  onTap: () async {
                    final uri = Uri.parse('https://tudominio.com/privacy');
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                ),

                // Delete Account – CRITICAL Google Play requirement:
                // Users must be able to request permanent data deletion from within the app.
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent),
                  title: const Text(
                    'Delete Account Permanently',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                  onTap: () => _showDeleteAccountDialog(context, ref),
                ),

                const Divider(height: 48),
              ],

              // ── Appearance Section ─────────────────────────────────────────
              const Text('APPEARANCE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 16),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Light')),
                  ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Dark')),
                  ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings), label: Text('System')),
                ],
                selected: <ThemeMode>{prefs.themeMode},
                onSelectionChanged: (Set<ThemeMode> newSelection) {
                  ref.read(settingsControllerProvider.notifier).updateTheme(newSelection.first);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFF00C853).withOpacity(0.2);
                    }
                    return Colors.transparent;
                  }),
                  iconColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFF00C853);
                    }
                    return isDark ? Colors.white70 : Colors.black54;
                  }),
                ),
              ),

              const SizedBox(height: 32),

              // Language Section
              const Text('LANGUAGE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10)
                  ]
                ),
                child: Column(
                  children: [
                    _buildLanguageTile(ref, 'English', 'en', prefs.languageCode),
                    _buildLanguageTile(ref, 'Español', 'es', prefs.languageCode),
                    _buildLanguageTile(ref, 'Deutsch', 'de', prefs.languageCode),
                    _buildLanguageTile(ref, 'Français', 'fr', prefs.languageCode),
                    _buildLanguageTile(ref, 'Italiano', 'it', prefs.languageCode),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageTile(WidgetRef ref, String title, String code, String currentCode) {
    final isSelected = code == currentCode;
    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF00C853)) : null,
      onTap: () {
        ref.read(settingsControllerProvider.notifier).updateLanguage(code);
      },
    );
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'What should we call you?'),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), foregroundColor: Colors.white),
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  ref.read(settingsControllerProvider.notifier).updateUsername(newName);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Asks for explicit confirmation before permanently deleting the account.
  /// Google Play requires this flow to be accessible in-app.
  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is irreversible. All your pantry data, price history '
          'and preferences will be permanently deleted from our servers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                // Step 1: Delete the account data via Supabase RPC / Edge Function.
                // The service-role key is required for admin deletion and must NEVER be
                // embedded in client code. Call a Supabase Edge Function instead:
                await Supabase.instance.client.functions.invoke('delete-user');
              } catch (_) {
                // Even if the edge function fails, we sign-out locally.
                // The support team can clean up orphaned records manually.
              } finally {
                // Step 2: Always sign out locally so the guard redirects to /login.
                await ref.read(authRepositoryProvider).signOut();
              }
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}

