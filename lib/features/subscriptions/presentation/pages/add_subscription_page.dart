import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/constants/currencies.dart';
import '../../../../core/constants/preset_catalog.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/providers/settings_providers.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../../../shared/widgets/subscription_logo.dart';
import '../../domain/billing_cycle.dart';
import '../../domain/subscription.dart';
import '../../domain/subscription_category.dart';
import '../providers/subscription_providers.dart';

/// Create or edit a subscription.
///
/// Laid out as a few widely spaced sections rather than one dense column. Two
/// structural decisions carry most of the weight:
///
/// * The service picker collapses to a one-line summary once chosen. A
///   35-tile grid left expanded pushed every field below the fold.
/// * Save lives in a fixed bottom bar, so it is reachable at any scroll
///   position and with the keyboard open.
class AddSubscriptionPage extends ConsumerStatefulWidget {
  const AddSubscriptionPage({this.editingId, super.key});

  /// When set the page edits an existing subscription instead of creating one.
  final String? editingId;

  @override
  ConsumerState<AddSubscriptionPage> createState() =>
      _AddSubscriptionPageState();
}

class _AddSubscriptionPageState extends ConsumerState<AddSubscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _presetSearchController = TextEditingController();

  PresetService? _preset;
  String _presetQuery = '';

  /// True once the user has committed to a service - a preset or an explicit
  /// "custom" - which is what collapses the picker.
  bool _serviceChosen = false;

  late String _currencyCode;
  BillingCycle _cycle = BillingCycle.monthly;
  SubscriptionCategory _category = SubscriptionCategory.other;
  DateTime _anchorDate = DateTime.now();
  int _brandColor = 0xFF6750A4;

  bool _reminderEnabled = true;
  int _reminderDaysBefore = 1;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 10, minute: 0);

  Subscription? _editing;
  bool _initialised = false;
  bool _saving = false;

  bool get _isEditing => widget.editingId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;

    _currencyCode = ref.read(currencyCodeProvider);

    if (widget.editingId != null) {
      final existing = ref.read(subscriptionByIdProvider(widget.editingId!));
      if (existing != null) _loadFrom(existing);
      _serviceChosen = true;
    }
  }

  void _loadFrom(Subscription subscription) {
    _editing = subscription;
    _nameController.text = subscription.name;
    _priceController.text = subscription.price.toStringAsFixed(2);
    _notesController.text = subscription.notes ?? '';
    _currencyCode = subscription.currencyCode;
    _cycle = subscription.billingCycle;
    _category = subscription.category;
    _anchorDate = subscription.anchorDate;
    _brandColor = subscription.brandColor;
    _reminderEnabled = subscription.reminderEnabled;
    _reminderDaysBefore = subscription.reminderDaysBefore;
    _reminderTime = TimeOfDay(
      hour: subscription.reminderHour,
      minute: subscription.reminderMinute,
    );
    _preset = PresetCatalog.byId(subscription.presetId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _presetSearchController.dispose();
    super.dispose();
  }

  void _applyPreset(PresetService preset) {
    HapticFeedback.selectionClick();
    setState(() {
      _preset = preset;
      _serviceChosen = true;
      _nameController.text = preset.name;
      _category = preset.category;
      _brandColor = preset.brandColor;
      _cycle = preset.defaultCycle;

    });
    FocusScope.of(context).unfocus();
  }

  void _chooseCustom() {
    HapticFeedback.selectionClick();
    setState(() {
      _preset = null;
      _serviceChosen = true;
      _nameController.clear();
      _brandColor = AppPalette.seed.toARGB32();
    });
  }

  void _reopenPicker() {
    setState(() {
      _serviceChosen = false;
      _presetQuery = '';
      _presetSearchController.clear();
    });
  }

  Future<void> _pickAnchorDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _anchorDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) setState(() => _anchorDate = picked);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      // Validation errors can sit above the fold behind a fixed save bar.
      await Scrollable.ensureVisible(
        _formKey.currentContext!,
        duration: const Duration(milliseconds: 250),
      );
      return;
    }

    setState(() => _saving = true);
    // Fire-and-forget: awaiting a haptic would delay the save behind a
    // platform round-trip for no benefit.
    unawaited(HapticFeedback.mediumImpact());

    final price = _parsePrice(_priceController.text)!;
    final now = DateTime.now();
    final actions = ref.read(subscriptionActionsProvider);
    final notes = _notesController.text.trim();

    if (_editing != null) {
      await actions.update(
        _editing!.copyWith(
          name: _nameController.text.trim(),
          price: price,
          currencyCode: _currencyCode,
          billingCycle: _cycle,
          anchorDate: _anchorDate,
          category: _category,
          brandColor: _brandColor,
          presetId: _preset?.id,
          logoAsset: _preset?.logoAsset,
          logoUrl: _preset?.logoUrl,
          notes: notes.isEmpty ? null : notes,
          reminderEnabled: _reminderEnabled,
          reminderDaysBefore: _reminderDaysBefore,
          reminderHour: _reminderTime.hour,
          reminderMinute: _reminderTime.minute,
          updatedAt: now,
        ),
      );
    } else {
      await actions.add(
        Subscription(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          price: price,
          currencyCode: _currencyCode,
          billingCycle: _cycle,
          anchorDate: _anchorDate,
          category: _category,
          brandColor: _brandColor,
          presetId: _preset?.id,
          logoAsset: _preset?.logoAsset,
          logoUrl: _preset?.logoUrl,
          notes: notes.isEmpty ? null : notes,
          reminderEnabled: _reminderEnabled,
          reminderDaysBefore: _reminderDaysBefore,
          reminderHour: _reminderTime.hour,
          reminderMinute: _reminderTime.minute,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    if (!mounted) return;
    final message = context.l10n.savedSnack;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Accepts both "12.99" and "12,99" - Turkish and Russian keyboards produce
  /// a comma, and `double.parse` rejects it.
  static double? _parsePrice(String raw) {
    final normalised = raw.trim().replaceAll(',', '.');
    final value = double.tryParse(normalised);
    if (value == null || value <= 0 || !value.isFinite) return null;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editTitle : l10n.addTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          // Keyed so tests drag this list specifically: the preset grid nested
          // inside is also a Scrollable, and `.first` would target that.
          key: const Key('add-form-scroll'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _serviceChosen
                  ? _ChosenServiceRow(
                      preset: _preset,
                      fallbackName: _nameController.text,
                      brandColor: _brandColor,
                      onChange: _isEditing ? null : _reopenPicker,
                    )
                  : _ServicePicker(
                      controller: _presetSearchController,
                      query: _presetQuery,
                      onQueryChanged: (v) => setState(() => _presetQuery = v),
                      onPresetSelected: _applyPreset,
                      onCustomSelected: _chooseCustom,
                    ),
            ),

            // Nothing below matters until a service is picked, so the first
            // screen stays a single clear decision.
            if (_serviceChosen) ...[
              _FormSection(
                icon: Icons.tune_rounded,
                title: l10n.addDetailsSection,
                children: [
                  _Labeled(
                    label: l10n.fieldName,
                    child: TextFormField(
                      key: const Key('field-name'),
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      style: context.text.titleMedium,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.label_outline_rounded),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? l10n.validationNameRequired
                          : null,
                    ),
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _Labeled(
                          label: l10n.fieldPrice,
                          child: TextFormField(
                            key: const Key('field-price'),
                            controller: _priceController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            style: context.text.titleMedium,
                            decoration: InputDecoration(
                              prefixText:
                                  '${Currencies.symbolOf(_currencyCode)}  ',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.validationPriceRequired;
                              }
                              return _parsePrice(value) == null
                                  ? l10n.validationPriceInvalid
                                  : null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: _Labeled(
                          label: l10n.fieldCurrency,
                          child: DropdownButtonFormField<String>(
                            key: const Key('field-currency'),
                            initialValue: _currencyCode,
                            isExpanded: true,
                            items: [
                              for (final currency in Currencies.all)
                                DropdownMenuItem(
                                  value: currency.code,
                                  child: Text(
                                    '${currency.symbol} ${currency.code}',
                                  ),
                                ),
                            ],
                            onChanged: (value) => setState(
                              () => _currencyCode = value ?? _currencyCode,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Chips rather than a dropdown: four options fit on one row
                  // and the current choice stays visible without tapping.
                  _Labeled(
                    label: l10n.fieldCycle,
                    child: Wrap(
                      key: const Key('field-cycle'),
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final cycle in BillingCycle.values)
                          ChoiceChip(
                            label: Text(cycle.label(l10n)),
                            selected: _cycle == cycle,
                            onSelected: (_) {
                              HapticFeedback.selectionClick();
                              setState(() => _cycle = cycle);
                            },
                          ),
                      ],
                    ),
                  ),

                  _Labeled(
                    label: l10n.fieldCategory,
                    child: DropdownButtonFormField<SubscriptionCategory>(
                      key: const Key('field-category'),
                      initialValue: _category,
                      isExpanded: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(_category.icon),
                      ),
                      items: [
                        for (final category in SubscriptionCategory.values)
                          DropdownMenuItem(
                            value: category,
                            child: Text(category.label(l10n)),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _category = value ?? _category),
                    ),
                  ),

                  _Labeled(
                    label: l10n.fieldFirstPayment,
                    child: _TappableField(
                      value: DateFormat.yMMMMd(
                        context.localeName,
                      ).format(_anchorDate),
                      icon: Icons.event_outlined,
                      onTap: _pickAnchorDate,
                    ),
                  ),

                  _Labeled(
                    label: l10n.fieldNotes,
                    child: TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                    ),
                  ),
                ],
              ),

              _FormSection(
                icon: Icons.notifications_active_outlined,
                title: l10n.addReminderSection,
                children: [
                  SwitchListTile(
                    key: const Key('field-reminder-toggle'),
                    contentPadding: EdgeInsets.zero,
                    value: _reminderEnabled,
                    onChanged: (value) =>
                        setState(() => _reminderEnabled = value),
                    title: Text(l10n.reminderEnabled),
                  ),
                  if (_reminderEnabled) ...[
                    _Labeled(
                      label: l10n.addReminderSection,
                      child: DropdownButtonFormField<int>(
                        key: const Key('field-reminder-days'),
                        initialValue: _reminderDaysBefore,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.alarm_rounded),
                        ),
                        items: [
                          for (final days in const [0, 1, 2, 3, 5, 7])
                            DropdownMenuItem(
                              value: days,
                              child: Text(l10n.reminderDaysBefore(days)),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _reminderDaysBefore = value ?? 1),
                      ),
                    ),
                    _Labeled(
                      label: l10n.reminderTime,
                      child: _TappableField(
                        value: _reminderTime.format(context),
                        icon: Icons.schedule_outlined,
                        onTap: _pickReminderTime,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),

      // Fixed rather than at the end of the scroll view: the form is long, and
      // a save button the user has to hunt for is a dead end.
      bottomNavigationBar: _serviceChosen
          ? _SaveBar(onSave: _saving ? null : _save, busy: _saving)
          : null,
    );
  }
}

/// Titled group of fields, evenly spaced.
class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: context.colors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title.toUpperCase(),
                style: context.text.labelMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        SoftCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.xl),
                children[i],
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

/// A field with its label sitting *above* it rather than inside the border.
///
/// Material's floating label is drawn into a notch cut in the outline, which
/// collided badly with this form's filled, fully-rounded fields: the focused
/// field's label appeared to sit on top of the border. Moving the label out
/// removes the problem by construction, keeps every row the same height, and
/// matches the label already used above the billing-cycle chips.
class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.xs,
          bottom: AppSpacing.sm,
        ),
        child: Text(
          label,
          style: context.text.labelMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child,
    ],
  );
}

/// Persistent save bar pinned to the bottom of the screen.
class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.onSave, required this.busy});

  final VoidCallback? onSave;
  final bool busy;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.md,
      AppSpacing.lg,
      AppSpacing.md,
    ),
    decoration: BoxDecoration(
      color: context.colors.surface,
      border: Border(
        top: BorderSide(
          color: context.colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
    ),
    child: SafeArea(
      top: false,
      child: FilledButton.icon(
        key: const Key('save-button'),
        onPressed: onSave,
        icon: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check_rounded),
        label: Text(context.l10n.actionSave),
      ),
    ),
  );
}

/// Search field + preset grid + "custom" escape hatch.
class _ServicePicker extends StatelessWidget {
  const _ServicePicker({
    required this.controller,
    required this.query,
    required this.onQueryChanged,
    required this.onPresetSelected,
    required this.onCustomSelected,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<PresetService> onPresetSelected;
  final VoidCallback onCustomSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final presets = PresetCatalog.search(query);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
            bottom: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.addChoosePreset,
                style: context.text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.addChoosePresetSubtitle,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        TextField(
          controller: controller,
          onChanged: onQueryChanged,
          decoration: InputDecoration(
            hintText: l10n.addSearchServices,
            prefixIcon: const Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (presets.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            child: Center(
              child: Text(
                l10n.homeNoResults(query),
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          // Grouped under category headings: 75 services in one flat grid is
          // a wall of icons with no way to orient yourself.
          for (final entry
              in PresetCatalog.groupByCategory(presets).entries) ...[
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xs,
                top: AppSpacing.sm,
                bottom: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    entry.key.icon,
                    size: 16,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    entry.key.label(l10n).toUpperCase(),
                    style: context.text.labelSmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: AppSpacing.lg,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.74,
              ),
              itemCount: entry.value.length,
              itemBuilder: (context, index) {
                final preset = entry.value[index];
                return InkWell(
                  key: Key('preset-${preset.id}'),
                  borderRadius: BorderRadius.circular(AppSpacing.lg),
                  onTap: () => onPresetSelected(preset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SubscriptionLogo(
                        monogram: preset.monogram,
                        brandColor: preset.brandColor,
                        assetPath: preset.logoAsset,
                        logoUrl: preset.logoUrl,
                        size: 52,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          preset.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelSmall,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        const SizedBox(height: AppSpacing.xl),
        OutlinedButton.icon(
          key: const Key('preset-custom'),
          onPressed: onCustomSelected,
          icon: const Icon(Icons.edit_outlined),
          label: Text(l10n.addCustomSubscription),
        ),
      ],
    );
  }
}

/// Compact summary of the chosen service, replacing the grid.
class _ChosenServiceRow extends StatelessWidget {
  const _ChosenServiceRow({
    required this.preset,
    required this.fallbackName,
    required this.brandColor,
    required this.onChange,
  });

  final PresetService? preset;
  final String fallbackName;
  final int brandColor;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name =
        preset?.name ??
        (fallbackName.trim().isEmpty ? l10n.addCustomService : fallbackName);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: SoftCard(
        child: Row(
          children: [
            SubscriptionLogo(
              monogram:
                  preset?.monogram ??
                  (name.isEmpty ? '?' : name.substring(0, 1).toUpperCase()),
              brandColor: brandColor,
              assetPath: preset?.logoAsset ?? 'assets/logos/custom.svg',
              logoUrl: preset?.logoUrl,
              size: 48,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleMedium,
              ),
            ),
            if (onChange != null)
              TextButton(
                key: const Key('change-service'),
                onPressed: onChange,
                child: Text(l10n.actionChange),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 260.ms).slideY(begin: -0.06);
  }
}

/// Read-only field that opens a picker. Its label is supplied by [_Labeled].
class _TappableField extends StatelessWidget {
  const _TappableField({
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppSpacing.lg),
    child: InputDecorator(
      decoration: InputDecoration(suffixIcon: Icon(icon)),
      child: Text(value, style: context.text.bodyLarge),
    ),
  );
}
