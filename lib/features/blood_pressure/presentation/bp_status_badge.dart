import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/bp_classification.dart';

/// Displays a [BPClassification]'s category consistently everywhere it
/// appears — Dashboard, History, Trends, Reading detail, Reports
/// (PROJECT_SPEC.md §21, §26). Always pairs color with text and an icon,
/// never color alone, and never replaces the numeric reading it sits next
/// to (§22).
///
/// [onExplain] wires up "Why am I seeing this?" (§24) when provided; omit
/// it where that action doesn't make sense (e.g. a compact list row that
/// already links to a detail screen with its own explanation).
class BPStatusBadge extends StatelessWidget {
  const BPStatusBadge({
    super.key,
    required this.classification,
    this.onExplain,
    this.dense = false,
  });

  final BPClassification classification;
  final VoidCallback? onExplain;

  /// A smaller, icon+label-only presentation for tight spaces like a list
  /// row, instead of the padded pill form used elsewhere.
  final bool dense;

  (Color background, Color foreground, IconData icon) _stylesFor(
    BPCategory category,
    BPStatusColors colors,
  ) => switch (category) {
    BPCategory.normal => (colors.normalBackground, colors.normalForeground, Icons.check_circle_outline),
    BPCategory.elevated => (colors.elevatedBackground, colors.elevatedForeground, Icons.info_outline),
    BPCategory.higher => (colors.higherBackground, colors.higherForeground, Icons.warning_amber_outlined),
    BPCategory.high => (colors.highBackground, colors.highForeground, Icons.error_outline),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final colors = theme.extension<BPStatusColors>() ?? BPStatusColors.light;
    final (background, foreground, icon) = _stylesFor(classification.category, colors);
    final label = classification.category.label(l10n);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: dense ? 16 : 18, color: foreground),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: (dense ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (onExplain != null) ...[
          const SizedBox(width: 2),
          Icon(Icons.help_outline, size: dense ? 14 : 16, color: foreground),
        ],
      ],
    );

    final badge = Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: content,
    );

    if (onExplain == null) {
      return Semantics(label: l10n.bpStatusSemanticsLabel(label), child: badge);
    }
    return Semantics(
      label: l10n.bpStatusSemanticsLabelInteractive(label),
      button: true,
      child: InkWell(borderRadius: BorderRadius.circular(999), onTap: onExplain, child: badge),
    );
  }
}

/// Shows [classification]'s "Why am I seeing this?" explanation
/// (PROJECT_SPEC.md §24) in a bottom sheet, generated entirely from the
/// classification's own data.
void showBpExplanationSheet(BuildContext context, BPClassification classification) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.bpWhyAmISeeingThis, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(classification.explanation(l10n), style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    },
  );
}
