import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../core/ids.dart';
import '../../../core/money/money.dart';
import '../../../core/money/money_format.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../../core/time/time_format.dart';
import '../../../core/widgets/auto_direction_field.dart';
import '../../../core/widgets/content_list_view.dart';
import '../../../core/widgets/messenger.dart';
import '../../../core/widgets/user_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../demo/application/demo_providers.dart';
import '../../demo/presentation/demo_badge.dart';
import '../../settings/application/settings_controller.dart';
import '../application/items_controller.dart';
import '../domain/item.dart';
import '../domain/item_category.dart';
import '../domain/item_draft.dart';
import '../domain/item_kind.dart';
import '../domain/recurrence.dart';
import '../domain/reference.dart';
import 'item_labels.dart';
import 'reference_view.dart';

/// Adds an item, or edits [item].
class ItemEditorScreen extends ConsumerStatefulWidget {
  const ItemEditorScreen({super.key, this.item});

  final Item? item;

  @override
  ConsumerState<ItemEditorScreen> createState() => _ItemEditorScreenState();
}

class _ItemEditorScreenState extends ConsumerState<ItemEditorScreen> {
  late final ItemDraft _initial;

  /// Everything except the text fields, which live in their controllers.
  late ItemDraft _draft;

  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _notes;
  late final TextEditingController _reference;

  final _titleFocus = FocusNode();
  final _amountFocus = FocusNode();

  /// Where Save scrolls to when a picker field needs fixing.
  final _fieldKeys = {
    for (final field in [
      DraftField.dueOn,
      DraftField.until,
      DraftField.doseTimes,
    ])
      field: GlobalKey(),
  };

  /// Once the user picks a category, changing the kind stops replacing it.
  late bool _categoryChosen;

  var _showProblems = false;
  var _saving = false;
  var _leaving = false;

  @override
  void initState() {
    super.initState();
    final currency = ref.read(appSettingsProvider).householdCurrency;
    final item = widget.item;
    _initial = item == null
        ? ItemDraft.blank(currency: currency)
        : ItemDraft.of(item, currency: currency);
    _draft = _initial;
    _categoryChosen = item != null;
    _title = TextEditingController(text: _initial.title);
    _amount = TextEditingController(text: _initial.amountText);
    _notes = TextEditingController(text: _initial.notes);
    _reference = TextEditingController(text: _initial.reference);
    for (final controller in [_title, _amount, _notes, _reference]) {
      // Keeps the discard check and live problems current while typing.
      controller.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    for (final controller in [_title, _amount, _notes, _reference]) {
      controller.dispose();
    }
    _titleFocus.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  ItemDraft get _current => _draft.copyWith(
    title: _title.text,
    amountText: _amount.text,
    notes: _notes.text,
    reference: _reference.text,
  );

  void _update(ItemDraft draft) => setState(() => _draft = draft);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = _current;
    final problems = _showProblems
        ? draft.validate(l10n.localeName)
        : const <DraftField, DraftProblem>{};
    final original = widget.item;

    String? problem(DraftField field) =>
        _problemText(l10n, field, problems[field], draft.currency);

    return PopScope(
      canPop: _leaving || draft == _initial,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(original == null ? l10n.addItem : l10n.editItem),
          actions: const [DemoBadge()],
        ),
        body: ContentListView(
          maxWidth: 640,
          bottom: 32,
          children: [
            _KindPicker(kind: draft.kind, onChanged: _changeKind),
            const SizedBox(height: 20),
            AutoDirectionField(
              controller: _title,
              focusNode: _titleFocus,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                LengthLimitingTextInputFormatter(ItemLimits.titleMax),
              ],
              decoration: InputDecoration(
                labelText: l10n.fieldTitle,
                hintText: _titleHint(l10n, draft.kind),
                errorText: problem(DraftField.title),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ItemCategory>(
              // The draft owns the value; a new key shows a changed one.
              key: ValueKey(draft.category),
              initialValue: draft.category,
              isExpanded: true,
              itemHeight: null,
              decoration: InputDecoration(labelText: l10n.fieldCategory),
              items: [
                for (final category in ItemCategory.values)
                  DropdownMenuItem(
                    value: category,
                    child: Text(l10n.categoryLabel(category)),
                  ),
              ],
              onChanged: (category) {
                if (category == null) return;
                _categoryChosen = true;
                _update(_draft.copyWith(category: category));
              },
            ),
            if (draft.kind == ItemKind.bill)
              _AmountSection(
                amount: _amount,
                focusNode: _amountFocus,
                draft: draft,
                errorText: problem(DraftField.amount),
                onChanged: _update,
              ),
            _WhenSection(
              draft: draft,
              original: original,
              problem: problem,
              fieldKeys: _fieldKeys,
              onChanged: _update,
              pickDate: _pickDate,
              pickTime: _pickTime,
            ),
            _DetailsSection(
              notes: _notes,
              reference: _reference,
              notesError: problem(DraftField.notes),
              referenceError: problem(DraftField.reference),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(l10n.save),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _changeKind(ItemKind kind) => _update(
    _draft.copyWith(
      kind: kind,
      category: _categoryChosen ? null : defaultCategoryFor(kind),
      repeat: kind == ItemKind.medicine
          ? RepeatRule.doses
          : _draft.repeat == RepeatRule.doses
          ? RepeatRule.none
          : null,
    ),
  );

  Future<LocalDate?> _pickDate(LocalDate? current) async {
    final LocalDate initial = current ?? ref.read(todayProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.toDateTime(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked == null || !mounted) return null;
    return LocalDate.fromDateTime(picked);
  }

  Future<int?> _pickTime(int? current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current == null
          ? const TimeOfDay(hour: 9, minute: 0)
          : TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked == null || !mounted) return null;
    return picked.hour * 60 + picked.minute;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    if (_current.validate(locale).isNotEmpty) {
      _reportProblems();
      return;
    }
    if (_reference.text.trim().isEmpty) {
      final misplaced = findMisplacedNumber(
        title: _title.text,
        notes: _notes.text,
      );
      if (misplaced != null) {
        final move = await _offerToMove(misplaced);
        if (move == null || !mounted) return;
        if (move) {
          final field = misplaced.field == NumberField.title ? _title : _notes;
          field.text = misplaced.removeFrom(field.text);
          _reference.text = misplaced.value;
          if (_current.validate(locale).isNotEmpty) {
            _reportProblems();
            return;
          }
        }
      }
    }

    setState(() => _saving = true);
    final messenger = Messenger.of(context);
    final navigator = Navigator.of(context);
    final controller = ref.read(itemsControllerProvider.notifier);
    final original = widget.item;
    final item = _current.toItem(
      locale: locale,
      now: ref.read(clockProvider)(),
      original: original,
      id: original == null ? ref.read(idGeneratorProvider)() : null,
    );

    final result = await controller.save(item, isNew: original == null);
    if (!mounted) return;
    switch (result) {
      case ItemWritten(:final undo):
        setState(() => _leaving = true);
        navigator.pop();
        messenger.showUndo(
          original == null ? l10n.added : l10n.saved,
          () async {
            if (await controller.undo(undo) is! ItemWritten) {
              messenger.show(l10n.undoRefused);
            }
          },
        );
      case ItemStale():
        setState(() => _saving = false);
        messenger.show(l10n.saveConflict);
      case ItemNotWritten():
        setState(() => _saving = false);
        messenger.show(l10n.notSaved);
    }
  }

  /// Shows what is wrong, says so to screen readers, whose focus is still
  /// on Save far below the errors, and takes them to the first field.
  void _reportProblems() {
    final l10n = AppLocalizations.of(context);
    final problems = _current.validate(l10n.localeName);
    setState(() => _showProblems = true);
    SemanticsService.sendAnnouncement(
      View.of(context),
      l10n.editorProblems(problems.length),
      Directionality.of(context),
    );
    final first = DraftField.values.firstWhere(problems.containsKey);
    switch (first) {
      case DraftField.title:
        _titleFocus.requestFocus();
      case DraftField.amount:
        _amountFocus.requestFocus();
      case _:
        final target = _fieldKeys[first]?.currentContext;
        if (target != null) {
          Scrollable.ensureVisible(
            target,
            alignment: 0.3,
            duration: const Duration(milliseconds: 200),
          );
        }
    }
  }

  /// Null when the dialog was dismissed: nothing is saved yet.
  Future<bool?> _offerToMove(MisplacedNumber misplaced) {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.misplacedTitle),
        content: Text(
          misplaced.field == NumberField.title
              ? l10n.misplacedInTitle
              : l10n.misplacedInNotes,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.misplacedKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.misplacedMove),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.keepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    if ((discard ?? false) && mounted) {
      setState(() => _leaving = true);
      Navigator.of(context).pop();
    }
  }

  static String _titleHint(AppLocalizations l10n, ItemKind kind) =>
      switch (kind) {
        ItemKind.bill => l10n.titleHintBill,
        ItemKind.appointment => l10n.titleHintAppointment,
        ItemKind.expiry => l10n.titleHintExpiry,
        ItemKind.medicine => l10n.titleHintMedicine,
        ItemKind.task => l10n.titleHintTask,
      };

  static String? _problemText(
    AppLocalizations l10n,
    DraftField field,
    DraftProblem? problem,
    String currency,
  ) => switch (problem) {
    null => null,
    DraftProblem.required => switch (field) {
      DraftField.title => l10n.problemTitleRequired,
      DraftField.doseTimes => l10n.problemDoseTimesRequired,
      _ => l10n.problemDateRequired,
    },
    DraftProblem.tooLong => l10n.problemTooLong,
    DraftProblem.invalidAmount => l10n.problemAmount(
      formatMoneyInput(
        Money(
          CurrencyInfo.of(currency).inputFractionDigits == 0 ? 425000 : 1250,
          currency,
        ),
      ),
    ),
    DraftProblem.beforeStart => l10n.problemEndBeforeStart,
  };
}

/// Bill, appointment, expiry date, medicine or task.
class _KindPicker extends StatelessWidget {
  const _KindPicker({required this.kind, required this.onChanged});

  final ItemKind kind;
  final ValueChanged<ItemKind> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(l10n.fieldKind),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in ItemKind.values)
              ChoiceChip(
                // The fill shows the choice; a checkmark would cover the icon.
                showCheckmark: false,
                avatar: Icon(kindIcon(option)),
                label: Text(l10n.kindLabel(option)),
                selected: kind == option,
                onSelected: (_) => onChanged(option),
              ),
          ],
        ),
      ],
    );
  }
}

/// A bill's amount, its currency and whether it changes each time.
class _AmountSection extends StatelessWidget {
  const _AmountSection({
    required this.amount,
    required this.focusNode,
    required this.draft,
    required this.errorText,
    required this.onChanged,
  });

  final TextEditingController amount;
  final FocusNode focusNode;
  final ItemDraft draft;
  final String? errorText;
  final ValueChanged<ItemDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = draft.currency;
    final info = CurrencyInfo.of(currency);
    final latin = latinFieldStyles(context);
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 112,
              child: DropdownButtonFormField<String>(
                key: ValueKey(currency),
                initialValue: currency,
                isExpanded: true,
                itemHeight: null,
                decoration: InputDecoration(labelText: l10n.fieldCurrency),
                items: [
                  for (final option in {
                    ...CurrencyInfo.supported.map((info) => info.code),
                    currency,
                  })
                    DropdownMenuItem(
                      value: option,
                      child: Text(CurrencyInfo.of(option).symbol),
                    ),
                ],
                onChanged: (code) {
                  if (code != null) onChanged(draft.copyWith(currency: code));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: amount,
                focusNode: focusNode,
                textDirection: TextDirection.ltr,
                textAlign: alignWithLayout(context),
                style: latin.style,
                strutStyle: latin.strutStyle,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: info.inputFractionDigits > 0,
                ),
                decoration: InputDecoration(
                  labelText: l10n.fieldAmount,
                  labelStyle: latin.labelStyle,
                  // Only needed while the field is empty.
                  hintText: l10n.amountHint,
                  hintStyle: latin.labelStyle,
                  hintMaxLines: 2,
                  errorText: errorText,
                  errorMaxLines: 2,
                ),
              ),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: !draft.isFixedAmount,
          onChanged: (varies) =>
              onChanged(draft.copyWith(amountIsFixed: !varies)),
          title: Text(l10n.amountVariesSwitch),
          subtitle: Text(l10n.amountVariesHint),
        ),
      ],
    );
  }
}

/// The date, whether a repeating item's later dates move with it, the time
/// or medicine times, how it repeats and when it ends.
class _WhenSection extends StatelessWidget {
  const _WhenSection({
    required this.draft,
    required this.original,
    required this.problem,
    required this.fieldKeys,
    required this.onChanged,
    required this.pickDate,
    required this.pickTime,
  });

  final ItemDraft draft;
  final Item? original;
  final String? Function(DraftField field) problem;
  final Map<DraftField, GlobalKey> fieldKeys;
  final ValueChanged<ItemDraft> onChanged;
  final Future<LocalDate?> Function(LocalDate? current) pickDate;
  final Future<int?> Function(int? current) pickTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kind = draft.kind;
    final original = this.original;
    final preview = draft.recurrenceFor(original);
    final offerMoveSeries =
        original != null &&
        original.recurrence.repeats &&
        original.doseTimes == null &&
        draft.effectiveRepeat == original.recurrence.rule &&
        draft.dueOn != original.dueOn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        _PickerField(
          key: fieldKeys[DraftField.dueOn],
          icon: Icons.event_outlined,
          label: _dateLabel(l10n, kind),
          value: _formatDate(l10n, draft.dueOn),
          placeholder: l10n.chooseDate,
          errorText: problem(DraftField.dueOn),
          onTap: () async {
            final date = await pickDate(draft.dueOn);
            if (date == null) return;
            // Back on the original date there is nothing to move, and a
            // switch left on would re-anchor the series to it.
            onChanged(
              draft.copyWith(
                dueOn: date,
                moveSeries: date == original?.dueOn ? false : null,
              ),
            );
          },
          onClear: kind.requiresDate || draft.dueOn == null
              ? null
              : () => onChanged(
                  draft.copyWith(
                    dueOn: null,
                    dueMinute: null,
                    repeat: RepeatRule.none,
                  ),
                ),
        ),
        if (offerMoveSeries)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: draft.moveSeries,
            onChanged: (move) => onChanged(draft.copyWith(moveSeries: move)),
            title: Text(l10n.moveSeriesTitle),
            subtitle: Text(
              l10n.moveSeriesHint(
                l10n.describeRepeat(original.recurrence.withUntil(null)),
              ),
            ),
          ),
        if (takesTimeOfDay(kind) && draft.dueOn != null) ...[
          const SizedBox(height: 16),
          _PickerField(
            icon: Icons.schedule_outlined,
            label: l10n.fieldTime,
            value: switch (draft.dueMinute) {
              null => null,
              final minute => formatMinute(minute, l10n.localeName),
            },
            placeholder: l10n.noTime,
            onTap: () async {
              final minute = await pickTime(draft.dueMinute);
              if (minute != null) onChanged(draft.copyWith(dueMinute: minute));
            },
            onClear: draft.dueMinute == null
                ? null
                : () => onChanged(draft.copyWith(dueMinute: null)),
          ),
        ],
        if (kind == ItemKind.medicine) ...[
          const SizedBox(height: 20),
          _DoseTimes(
            key: fieldKeys[DraftField.doseTimes],
            minutes: draft.doseMinutes,
            errorText: problem(DraftField.doseTimes),
            onAdd: () async {
              final minute = await pickTime(null);
              if (minute == null) return;
              final minutes = {...draft.doseMinutes, minute}.toList()..sort();
              onChanged(draft.copyWith(doseMinutes: minutes));
            },
            onRemove: (minute) => onChanged(
              draft.copyWith(
                doseMinutes: [
                  for (final m in draft.doseMinutes)
                    if (m != minute) m,
                ],
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<RepeatRule>(
            key: ValueKey((kind, draft.effectiveRepeat)),
            initialValue: draft.effectiveRepeat,
            isExpanded: true,
            itemHeight: null,
            decoration: InputDecoration(
              labelText: l10n.fieldRepeat,
              helperText: preview != null && preview.repeats
                  ? l10n.describeRepeat(preview.withUntil(null))
                  : null,
              helperMaxLines: 2,
            ),
            items: [
              for (final rule in repeatRulesFor(kind))
                DropdownMenuItem(
                  value: rule,
                  child: Text(l10n.repeatRuleLabel(rule)),
                ),
            ],
            onChanged: (rule) {
              if (rule != null) onChanged(draft.copyWith(repeat: rule));
            },
          ),
        ],
        if (draft.repeats) ...[
          const SizedBox(height: 16),
          _PickerField(
            key: fieldKeys[DraftField.until],
            icon: Icons.event_busy_outlined,
            label: kind == ItemKind.medicine
                ? l10n.fieldLastDay
                : l10n.fieldEndsOn,
            value: _formatDate(l10n, draft.until),
            placeholder: l10n.noEndDate,
            errorText: problem(DraftField.until),
            onTap: () async {
              final date = await pickDate(draft.until ?? draft.dueOn);
              if (date != null) onChanged(draft.copyWith(until: date));
            },
            onClear: draft.until == null
                ? null
                : () => onChanged(draft.copyWith(until: null)),
          ),
        ],
      ],
    );
  }

  static String? _formatDate(AppLocalizations l10n, LocalDate? date) =>
      date == null
      ? null
      : DateFormat.yMMMEd(l10n.localeName).format(date.toDateTime());

  static String _dateLabel(AppLocalizations l10n, ItemKind kind) =>
      switch (kind) {
        ItemKind.bill => l10n.fieldDueDate,
        ItemKind.appointment => l10n.fieldDate,
        ItemKind.expiry => l10n.fieldExpiresOn,
        ItemKind.medicine => l10n.fieldFirstDay,
        ItemKind.task => l10n.fieldDateOptional,
      };
}

/// Notes and the hidden Reference number.
class _DetailsSection extends ConsumerWidget {
  const _DetailsSection({
    required this.notes,
    required this.reference,
    required this.notesError,
    required this.referenceError,
  });

  final TextEditingController notes;
  final TextEditingController reference;
  final String? notesError;
  final String? referenceError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const SizedBox(height: 16),
        AutoDirectionField(
          controller: notes,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines: 2,
          maxLines: 6,
          inputFormatters: [
            LengthLimitingTextInputFormatter(ItemLimits.notesMax),
          ],
          decoration: InputDecoration(
            labelText: l10n.fieldNotes,
            alignLabelWithHint: true,
            errorText: notesError,
          ),
        ),
        const SizedBox(height: 16),
        ReferenceField(
          controller: reference,
          helperText: ref.watch(isWebDemoProvider)
              ? l10n.referenceDemoHint
              : l10n.referenceHint,
          errorText: referenceError,
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 8, bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// A field that opens a picker instead of a keyboard: dates and times.
class _PickerField extends StatelessWidget {
  const _PickerField({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.onClear,
    this.errorText,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final value = this.value;
    final errorText = this.errorText;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            // Replacing the InkWell's own node must not take it out of the
            // keyboard and switch-access order.
            focusable: true,
            label: errorText == null
                ? label
                : l10n.fieldWithProblem(label, errorText),
            value: value ?? placeholder,
            excludeSemantics: true,
            onTap: onTap,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  errorText: errorText,
                  prefixIcon: Icon(icon),
                ),
                child: Text(
                  value ?? placeholder,
                  style: value == null
                      ? theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )
                      : theme.textTheme.bodyLarge,
                ),
              ),
            ),
          ),
        ),
        if (onClear != null)
          IconButton(
            tooltip: l10n.clearField(label),
            icon: const Icon(Icons.close),
            onPressed: onClear,
          ),
      ],
    );
  }
}

class _DoseTimes extends StatelessWidget {
  const _DoseTimes({
    super.key,
    required this.minutes,
    required this.errorText,
    required this.onAdd,
    required this.onRemove,
  });

  final List<int> minutes;
  final String? errorText;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final errorText = this.errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(l10n.fieldDoseTimes),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final minute in minutes)
              InputChip(
                label: Text(formatMinute(minute, l10n.localeName)),
                onDeleted: () => onRemove(minute),
                deleteButtonTooltipMessage: l10n.removeTime(
                  formatMinute(minute, l10n.localeName),
                ),
              ),
            if (minutes.length < DoseTimes.maxDoses)
              ActionChip(
                avatar: const Icon(Icons.add),
                label: Text(l10n.addTime),
                onPressed: onAdd,
              ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 8),
            child: Text(
              errorText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 8),
          child: Text(
            l10n.doseTimesNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
