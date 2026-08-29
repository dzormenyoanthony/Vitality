import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/larger_numbers_provider.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../l10n/app_localizations.dart';
import '../../authentication/data/auth_providers.dart';
import '../../authentication/domain/credentials_validator.dart';
import '../../data_export/data/data_export_providers.dart';
import '../../data_export/presentation/data_export_share.dart';
import '../../onboarding/data/user_profile_providers.dart';
import 'settings_controller.dart';

/// Profile and settings (PROJECT_SPEC.md §24): preferred name, account
/// email, theme preference, a link into reminder management, saved
/// reports/data export, sign out, and account deletion.
///
/// Visual design matches `design_references/Settings.png`, with two
/// deliberate deviations from it, both pre-existing product decisions:
/// email editing stays out of scope (needs a re-authentication flow this
/// phase doesn't build — see [_ProfileCard]), and the Data section (Saved
/// reports, Export data) is kept even though the reference predates it,
/// since removing it would delete working functionality. "Manage
/// reminders" is likewise kept as a small supplementary link, styled to
/// stay out of the way of the card the reference actually specifies.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authStateChangesProvider).value?.uid;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: uid == null
          ? const LoadingIndicator()
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        tooltip: l10n.commonBack,
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.dashboard);
                          }
                        },
                      ),
                      Expanded(
                        child: Text(l10n.settingsTitle, style: theme.textTheme.headlineMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionLabel(l10n.settingsSectionProfile, color: AppColors.dashboardAccentTeal),
                  const SizedBox(height: AppSpacing.sm),
                  _ProfileCard(uid: uid),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionLabel(l10n.settingsSectionAppearance, color: AppColors.dashboardAccentTeal),
                  const SizedBox(height: AppSpacing.sm),
                  const _AppearanceCard(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.settingsManageReminders),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.reminders),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionLabel(l10n.settingsSectionData, color: AppColors.dashboardAccentTeal),
                  const SizedBox(height: AppSpacing.sm),
                  const _DataCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionLabel(l10n.settingsSectionAccount, color: AppColors.dashboardAccentCoral),
                  const SizedBox(height: AppSpacing.sm),
                  _AccountSection(uid: uid),
                ],
              ),
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;
    final email = ref.watch(authStateChangesProvider).value?.email;
    final profile = ref.watch(userProfileStreamProvider(widget.uid)).value;
    final saveState = ref.watch(settingsControllerProvider);
    final isSaving = saveState.isLoading;

    if (!_nameLoadedFromProfile && profile != null) {
      _nameController.text = profile.displayName;
      _nameLoadedFromProfile = true;
    }

    final displayName = profile?.displayName ?? '';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: accents.mintBackground,
                    child: Text(
                      initial,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: accents.mintForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName.isEmpty ? '—' : displayName,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (email != null)
                          Text(
                            email,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.settingsPreferredNameLabel, style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _nameController,
                enabled: !isSaving,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(color: AppColors.onboardingFieldBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(color: AppColors.onboardingFieldBorder),
                  ),
                  suffixIcon: IconButton(
                    tooltip: l10n.settingsSaveNameTooltip,
                    icon: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.edit_outlined, color: AppColors.dashboardAccentTeal),
                    onPressed: isSaving ? null : _save,
                  ),
                ),
                validator: CredentialsValidator.validatePreferredName,
              ),
              if (saveState.hasError) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  friendlyMessage(saveState.error!),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              if (email != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(l10n.settingsEmailLabel, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.onboardingFieldBorder),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  // Deliberately no edit affordance here (unlike the name
                  // field above) — changing the sign-in email needs a
                  // re-authentication flow this phase doesn't build, so
                  // showing an edit icon that does nothing would be fake
                  // functionality (CLAUDE.md §3).
                  child: Text(email, style: theme.textTheme.bodyLarge),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.settingsEmailCaption,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AppearanceCard extends ConsumerWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final largerNumbers = ref.watch(largerNumbersProvider);
    final systemIsDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final helperText = switch (themeMode) {
      ThemeMode.system => l10n.settingsThemeHelperSystem(
        systemIsDark ? l10n.settingsBrightnessDark : l10n.settingsBrightnessLight,
      ),
      ThemeMode.light => l10n.settingsThemeHelperLight,
      ThemeMode.dark => l10n.settingsThemeHelperDark,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _ThemeOptionCard(
                    icon: Icons.desktop_windows_outlined,
                    label: l10n.settingsThemeOptionSystem,
                    selected: themeMode == ThemeMode.system,
                    onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ThemeOptionCard(
                    icon: Icons.wb_sunny_outlined,
                    label: l10n.settingsThemeOptionLight,
                    selected: themeMode == ThemeMode.light,
                    onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ThemeOptionCard(
                    icon: Icons.dark_mode_outlined,
                    label: l10n.settingsThemeOptionDark,
                    selected: themeMode == ThemeMode.dark,
                    onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.settingsLargerNumbersTitle, style: theme.textTheme.titleMedium),
                      Text(
                        l10n.settingsLargerNumbersSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: largerNumbers,
                  onChanged: (value) => ref.read(largerNumbersProvider.notifier).setEnabled(value),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              helperText,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accents = theme.extension<AppAccentColors>() ?? AppAccentColors.light;

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? accents.mintBackground : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: selected ? accents.mintForeground : AppColors.onboardingFieldBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? accents.mintForeground : theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selected ? accents.mintForeground : theme.colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataCard extends ConsumerStatefulWidget {
  const _DataCard();

  @override
  ConsumerState<_DataCard> createState() => _DataCardState();
}

class _DataCardState extends ConsumerState<_DataCard> {
  bool _isExporting = false;

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await ref.read(dataExportServiceProvider).buildExport();
      if (!mounted) return;

      if (result.hasMissingFiles) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.settingsExportMissingTitle),
            content: Text(
              l10n.settingsExportMissingBody(
                result.missingReportFiles.join('\n'),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.commonContinue),
              ),
            ],
          ),
        );
        if (proceed != true || !mounted) return;
      }

      await shareDataExport(result);
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsExportFailed)),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.settingsSavedReportsTitle),
            subtitle: Text(l10n.settingsSavedReportsSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.savedReports),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.ios_share_outlined),
            title: Text(l10n.settingsExportDataTitle),
            subtitle: Text(l10n.settingsExportDataSubtitle),
            trailing: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _isExporting ? null : _exportData,
          ),
        ],
      ),
    );
  }
}

class _AccountSection extends ConsumerWidget {
  const _AccountSection({required this.uid});

  final String uid;

  Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsDeleteAccountTitle),
        content: Text(l10n.settingsDeleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(dialogContext).colorScheme.error),
            child: Text(l10n.commonDelete),
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isBusy = ref.watch(settingsControllerProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: isBusy ? null : () => ref.read(authRepositoryProvider).signOut(),
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
            side: const BorderSide(color: AppColors.onboardingFieldBorder),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            foregroundColor: theme.colorScheme.onSurface,
          ),
          icon: const Icon(Icons.logout),
          label: Text(l10n.settingsSignOut),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton.icon(
          onPressed: isBusy ? null : () => _confirmDeleteAccount(context, ref),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.errorContainer,
            foregroundColor: theme.colorScheme.onErrorContainer,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
          icon: isBusy
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                )
              : const Icon(Icons.delete_outline),
          label: Text(l10n.settingsDeleteAccount),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.settingsDeleteAccountCaption,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
