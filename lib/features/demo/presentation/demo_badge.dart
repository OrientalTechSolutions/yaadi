import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/demo_controller.dart';
import '../application/demo_providers.dart';
import '../domain/demo_household.dart';

/// A permanent "Demo" label for the app bar while demo data is shown.
class DemoBadge extends ConsumerWidget {
  const DemoBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(showingDemoProvider)) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.tertiaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            AppLocalizations.of(context).demoBadge,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: colors.onTertiaryContainer),
          ),
        ),
      ),
    );
  }
}

/// The strip above every screen while demo data is shown.
///
/// On the web it carries the privacy notice: in full on the household
/// picker, and as one line with Details above the app's own screens, which
/// need the room more. On a phone it names the household, says changes are
/// not kept, and leads back to the user's own items.
class DemoNotice extends ConsumerWidget {
  const DemoNotice({super.key, this.compact = false});

  /// One line and a Details button instead of the full web notice.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final household = ref.watch(demoHouseholdProvider);
    final web = ref.watch(isWebDemoProvider);
    if (!web && household == null) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: colors.onSurfaceVariant);
    final notSaving = web && ref.watch(demoNotSavingProvider);
    final fullNotice = webDemoNoticeText(l10n, notSaving: notSaving);

    final Widget text;
    final Widget? action;
    if (!web) {
      text = Text(
        l10n.phoneDemoNotice(householdName(l10n, household!)),
        style: style,
      );
      action = TextButton(
        onPressed: ref.watch(demoControllerProvider)
            ? null
            : ref.read(demoControllerProvider.notifier).clear,
        child: Text(l10n.leaveDemo),
      );
    } else if (compact) {
      text = Text(
        notSaving ? l10n.webDemoNotSaving : l10n.webDemoNoticeShort,
        style: style,
        maxLines: notSaving ? 2 : 1,
        overflow: TextOverflow.ellipsis,
      );
      action = TextButton(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(fullNotice),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).closeButtonLabel),
              ),
            ],
          ),
        ),
        child: Text(l10n.demoNoticeDetails),
      );
    } else {
      text = Text(fullNotice, style: style);
      action = null;
    }

    return Material(
      color: colors.surfaceContainerHighest,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            16,
            8,
            action == null ? 16 : 8,
            8,
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: colors.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(child: text),
              ?action,
            ],
          ),
        ),
      ),
    );
  }
}

/// The web demo's privacy notice (ARCHITECTURE.md section 8), and whether
/// this browser is saving it at all.
String webDemoNoticeText(AppLocalizations l10n, {required bool notSaving}) =>
    [l10n.webDemoNotice, if (notSaving) l10n.webDemoNotSaving].join(' ');

String householdName(AppLocalizations l10n, DemoHousehold household) =>
    switch (household) {
      DemoHousehold.khan => l10n.householdKhan,
      DemoHousehold.taylor => l10n.householdTaylor,
    };

String householdDescription(AppLocalizations l10n, DemoHousehold household) =>
    switch (household) {
      DemoHousehold.khan => l10n.householdKhanDescription,
      DemoHousehold.taylor => l10n.householdTaylorDescription,
    };
