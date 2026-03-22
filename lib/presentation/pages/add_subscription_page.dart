import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subscription_tracker/core/constants/app_constants.dart';
import 'package:subscription_tracker/core/constants/currencies.dart';
import 'package:subscription_tracker/core/localization/localization_helper.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/presentation/providers/subscription_providers.dart';
import 'package:subscription_tracker/presentation/providers/theme_provider.dart';
import 'package:uuid/uuid.dart';

class AddSubscriptionPage extends ConsumerStatefulWidget {
  const AddSubscriptionPage({
    Key? key,
    this.subscription,
    this.onSaved,
  }) : super(key: key);
  final Subscription? subscription;
  final VoidCallback? onSaved;

  @override
  ConsumerState<AddSubscriptionPage> createState() => _AddSubscriptionPageState();
}

class _AddSubscriptionPageState extends ConsumerState<AddSubscriptionPage> {
  late TextEditingController _titleController;
  late TextEditingController _costController;
  late TextEditingController _typeController;
  late TextEditingController _notesController;
  late int _selectedBillingDay;
  late String _selectedCurrency;
  late int _selectedNotificationDaysBefore;
  late bool _notificationsEnabled;
  late DateTime _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _hasEndDate = false;
  String? _selectedImagePath;
  String? _tempImagePath;
  bool _isLoading = false;
  late LocalizationHelper l10n;
  late BillingCycle _selectedBillingCycle;

  // Common subscription types for suggestion - Apple inspired
  final List<String> _subscriptionTypes = [
    '🎬 film',
    '🎵 Music',
    '🎮 Gaming',
    '☁️ Cloud Storage',
    '💻 Software',
    '🛠️ Utility',
    '💪 Fitness',
    '📚 Education',
    '📰 News',
    '🍕 Food',
    '🏥 Health',
    '🚗 Transport',
    '🏠 Home',
  ];

  @override
  void initState() {
    super.initState();
    final language = ref.read(languageProvider);
    l10n = LocalizationHelper(language);

    if (widget.subscription != null) {
      _titleController = TextEditingController(text: widget.subscription!.title);
      _costController = TextEditingController(text: widget.subscription!.cost.toString());
      _typeController = TextEditingController(text: widget.subscription!.icon);
      _notesController = TextEditingController(text: widget.subscription!.notes ?? '');
      _selectedBillingDay = widget.subscription!.billingDay;
      _selectedCurrency = widget.subscription!.currency;
      _selectedNotificationDaysBefore = widget.subscription!.notificationDaysBefore;
      _notificationsEnabled = widget.subscription!.notificationsEnabled;
      _selectedStartDate = widget.subscription!.startDate;
      _selectedImagePath = widget.subscription!.imagePath;
      _selectedBillingCycle = widget.subscription!.billingCycle;
      _hasEndDate = false;
      _selectedEndDate = null;
    } else {
      _titleController = TextEditingController();
      _costController = TextEditingController();
      _typeController = TextEditingController();
      _notesController = TextEditingController();
      _selectedBillingDay = 1;
      _selectedCurrency = 'TRY';
      _selectedNotificationDaysBefore = 1;
      _notificationsEnabled = true;
      _selectedStartDate = DateTime.now();
      _selectedBillingCycle = BillingCycle.monthly;
      _hasEndDate = false;
      _selectedEndDate = null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    _typeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        if (!mounted) return;
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 70,
          maxWidth: 300,
          maxHeight: 300,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Edit Photo',
              toolbarColor: Colors.blueAccent,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: true,
            ),
            IOSUiSettings(
              title: 'Edit Photo',
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
            ),
            WebUiSettings(context: context),
          ],
        );

        if (croppedFile != null) {
          if (kIsWeb) {
            setState(() {
              _selectedImagePath = croppedFile.path;
              _tempImagePath = null;
            });
            return;
          }

          // Save to app documents directory
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = '${const Uuid().v4()}.jpg';
          final savedImage = await File(croppedFile.path).copy('${appDir.path}/$fileName');

          // Delete only previously created temp image from this page session.
          if (_tempImagePath != null && _tempImagePath != savedImage.path) {
            final previousTempFile = File(_tempImagePath!);
            if (previousTempFile.existsSync()) {
              previousTempFile.deleteSync();
            }
          }

          setState(() {
            _selectedImagePath = savedImage.path;
            _tempImagePath = savedImage.path;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveSubscription() async {
    if (_titleController.text.isEmpty || _costController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.subscriptionName} ${l10n.save.toLowerCase()} gerekli')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cost = double.parse(_costController.text);
      
      final icon = _typeController.text.isEmpty ? 'Other' : _typeController.text;

      // Get global notification time from settings
      final appSettings = Hive.box('app_settings');
      final notificationHour = appSettings.get('defaultNotificationHour', defaultValue: 10) as int;
      final notificationMinute = appSettings.get('defaultNotificationMinute', defaultValue: 0) as int;

      final subscription = Subscription(
        id: widget.subscription?.id ?? const Uuid().v4(),
        title: _titleController.text,
        cost: cost,
        billingDay: _selectedBillingDay,
        icon: icon,
        createdAt: widget.subscription?.createdAt ?? DateTime.now(),
        currency: _selectedCurrency,
        notificationHour: notificationHour,
        notificationMinute: notificationMinute,
        notificationDaysBefore: _selectedNotificationDaysBefore,
        notificationsEnabled: _notificationsEnabled,
        startDate: _selectedStartDate,
        billingCycle: _selectedBillingCycle,
        imagePath: _selectedImagePath,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        endDate: _hasEndDate ? _selectedEndDate : null,
      );

      if (widget.subscription != null) {
        final updateUseCase = await ref.read(updateSubscriptionProvider.future);
        await updateUseCase(subscription);
      } else {
        final addUseCase = await ref.read(addSubscriptionProvider.future);
        await addUseCase(subscription);
      }

      // Schedule notification with custom hour (don't await - fire and forget)
      final notificationService = ref.read(notificationServiceProvider);
      // Fire-and-forget; suppress linter warning
      // ignore: unawaited_futures
      notificationService.scheduleSubscriptionReminder(
        subscriptionId: subscription.id,
        subscriptionTitle: subscription.title,
        billingDay: subscription.billingDay,
        notificationHour: notificationHour,
        notificationMinute: notificationMinute,
        notificationDaysBefore: _selectedNotificationDaysBefore,
        enabled: _notificationsEnabled,
      );

      if (mounted) {
        // Reset form for new subscriptions
        if (widget.subscription == null) {
          _titleController.clear();
          _costController.clear();
          _typeController.clear();
          _notesController.clear();
          setState(() {
            _isLoading = false;
            _selectedBillingDay = 1;
            _selectedCurrency = 'TRY';
            _selectedNotificationDaysBefore = 1;
            _notificationsEnabled = true;
            _selectedStartDate = DateTime.now();
          });
        } else {
          setState(() => _isLoading = false);
        }
        
        // Call callback if provided
        widget.onSaved?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.savedWithCheck,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 1500),
          ),
        );
        
        // Navigate back to previous screen after successful save
        // Use a short delay to ensure the SnackBar is visible
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context, true); // Return true to indicate success
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.addSubscription),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                context: context,
                title: 'Temel Bilgiler',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 176,
                        decoration: BoxDecoration(
                          color: _selectedImagePath == null
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          image: _selectedImagePath != null
                              ? DecorationImage(
                                  image: _buildSelectedImageProvider(_selectedImagePath!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImagePath == null
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_rounded,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      size: 30,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.addPhoto,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.edit_rounded, size: 18),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.subscriptionName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      onChanged: (value) => setState(() {}),
                      decoration: _inputDecoration(
                        context,
                        hintText: 'Netflix, Spotify, Adobe...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.notes,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        context,
                        hintText: l10n.addSubscriptionNote,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.cost,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _costController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration(
                        context,
                        hintText: '0.00',
                      ).copyWith(
                        suffixIconConstraints: const BoxConstraints(minWidth: 96),
                        suffixIcon: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCurrency,
                            isDense: true,
                            borderRadius: BorderRadius.circular(12),
                            items: supportedCurrencies
                                .map(
                                  (currency) => DropdownMenuItem<String>(
                                    value: currency.code,
                                    child: Text(currency.code),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedCurrency = value);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildSectionCard(
                context: context,
                title: 'Detaylar',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Abonelik Kategorisi',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _subscriptionTypes.map((category) {
                        final isSelected = _typeController.text == category;
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _typeController.text = selected ? category : '';
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _typeController,
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration(
                        context,
                        labelText: 'Özel Kategori',
                        hintText: 'Örn: Video Editör, Tasarım...',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Start Date Picker
                    Text(l10n.startDate, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedStartDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (pickedDate != null) {
                          setState(() => _selectedStartDate = pickedDate);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedStartDate.day}/${_selectedStartDate.month}/${_selectedStartDate.year}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const Icon(Icons.calendar_today, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(l10n.paymentCycle, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<BillingCycle>(
                      initialValue: _selectedBillingCycle,
                      items: [
                        DropdownMenuItem(
                          value: BillingCycle.monthly,
                          child: Text(l10n.monthly),
                        ),
                        DropdownMenuItem(
                          value: BillingCycle.yearly,
                          child: Text(l10n.yearly),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedBillingCycle = value);
                        }
                      },
                      decoration: _inputDecoration(context),
                    ),
                    const SizedBox(height: 16),

                    Text(l10n.billingDay, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedBillingDay,
                      items: AppConstants.billingDays
                          .map((day) => DropdownMenuItem(value: day, child: Text('Day $day')))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedBillingDay = value);
                        }
                      },
                      decoration: _inputDecoration(context),
                    ),
                    const SizedBox(height: 16),

                    // Subscription End Date Option
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.subscriptionHasEndDate,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.subscriptionEndDateHint,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Switch(
                                value: _hasEndDate,
                                onChanged: (value) {
                                  setState(() {
                                    _hasEndDate = value;
                                    _selectedEndDate = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_hasEndDate) ...[
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedEndDate ?? DateTime.now().add(const Duration(days: 30)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                                );
                                if (picked != null) {
                                  setState(() => _selectedEndDate = picked);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedEndDate != null
                                          ? '${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}'
                                          : l10n.selectDate,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.grey[600],
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(l10n.notificationSettings, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: Text(l10n.enableNotifications),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value ?? true);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_notificationsEnabled) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.remind,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedNotificationDaysBefore,
                        items: [
                          DropdownMenuItem(value: 1, child: Text(l10n.oneDayBefore)),
                          DropdownMenuItem(value: 2, child: Text(l10n.twoDaysBefore)),
                          DropdownMenuItem(value: 3, child: Text(l10n.threeDaysBefore)),
                          DropdownMenuItem(value: 4, child: Text(l10n.fourDaysBefore)),
                          DropdownMenuItem(value: 5, child: Text(l10n.fiveDaysBefore)),
                          DropdownMenuItem(value: 6, child: Text(l10n.sixDaysBefore)),
                          DropdownMenuItem(value: 7, child: Text(l10n.oneWeekBefore)),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedNotificationDaysBefore = value);
                          }
                        },
                        decoration: _inputDecoration(context),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Bildirim saati Ayarlar sayfasından düzenlenebilir',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSubscription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                        : Text(
                          l10n.save,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required Widget child,
  }) => Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );

  ImageProvider _buildSelectedImageProvider(String path) {
    if (kIsWeb) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    String? hintText,
    String? labelText,
  }) => InputDecoration(
      hintText: hintText,
      labelText: labelText,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.2,
        ),
      ),
    );
}
