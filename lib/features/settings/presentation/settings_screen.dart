import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../authentication/data/auth_providers.dart';
import '../../authentication/domain/credentials_validator.dart';
import '../../onboarding/data/user_profile_providers.dart';
import 'settings_controller.dart';

/// Profile and settings (PROJECT_SPEC.md §24): preferred name, account
/// email, theme preference, a link into reminder management, sign out, and
/// account deletion. Privacy-policy content and email editing are
/// intentionally out of scope — the former needs a legal/market review that
/// hasn't happened yet (§25, §40), the latter needs a re-authentication
/// flow this phase doesn't build.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateChangesProvider).value?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: uid == null
          ? const LoadingIndicator()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text('Profile', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                _ProfileCard(uid: uid),
                const SizedBox(height: AppSpacing.lg),
                Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                const _PreferencesCard(),
                const SizedBox(height: AppSpacing.lg),
                Text('Account', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                _AccountCard(uid: uid),
              ],
            ),
    );
  }
}

class _ProfileCard extends ConsumerStatefulWidget {
  const _ProfileCard({required this.uid});

  final String uid;

  @override
  ConsumerState<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<_ProfileCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _nameLoadedFromProfile = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(settingsControllerProvider.notifier)
        .updateName(uid: widget.uid, displayName: _nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(authStateChangesProvider).value?.email;
    final profile = ref.watch(userProfileStreamProvider(widget.uid)).value;
    final saveState = ref.watch(settingsControllerProvider);
    final isSaving = saveState.isLoading;

    if (!_nameLoadedFromProfile && profile != null) {
      _nameController.text = profile.displayName;
      _nameLoadedFromProfile = true;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (email != null) ...[
                Text('Email', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(email, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.md),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      enabled: !isSaving,
                      decoration: const InputDecoration(labelText: 'Preferred name'),
                      validator: CredentialsValidator.validatePreferredName,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    tooltip: 'Save name',
                    icon: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    onPressed: isSaving ? null : _save,
                  ),
                ],
              ),
              if (saveState.hasError) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  friendlyMessage(saveState.error!),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PreferencesCard extends ConsumerWidget {
  const _PreferencesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('System')),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) =>
                      ref.read(themeModeProvider.notifier).setThemeMode(selection.first),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Manage reminders'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.reminders),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard({required this.uid});

  final String uid;

  Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text(
          'This permanently deletes your account and all locally stored '
          'blood pressure data and reminders. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(dialogContext).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(settingsControllerProvider.notifier).deleteAccount(uid);

    final state = ref.read(settingsControllerProvider);
    if (state.hasError && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyMessage(state.error!))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref.watch(settingsControllerProvider).isLoading;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: isBusy ? null : () => ref.read(authRepositoryProvider).signOut(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.delete_forever, color: colorScheme.error),
            title: Text('Delete account', style: TextStyle(color: colorScheme.error)),
            trailing: isBusy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: isBusy ? null : () => _confirmDeleteAccount(context, ref),
          ),
        ],
      ),
    );
  }
}
