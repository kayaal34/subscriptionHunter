import 'dart:io';

import 'package:flutter/cupertino.dart';
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
          ],
        );

        if (croppedFile != null) {
          // Save to app documents directory
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = '${const Uuid().v4()}.jpg';
          final savedImage = await File(croppedFile.path).copy('${appDir.path}/$fileName');

          setState(() {
            _selectedImagePath = savedImage.path;
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
        // Reset form
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
        
        // Call callback if provided
        widget.onSaved?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '✓ Kaydedildi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _selectedImagePath != null ? null : Colors.black,
                      shape: BoxShape.circle,
                      image: _selectedImagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_selectedImagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _selectedImagePath == null
                        ? Center(
                            child: _typeController.text.isNotEmpty
                                ? Text(
                                    _typeController.text[0],
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : _titleController.text.isNotEmpty
                                    ? Text(
                                        _titleController.text[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.add_a_photo,
                                        color: Colors.white, size: 40),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: _pickImage,
                  child: Text(l10n.category == "Kategori" ? "Fotoğraf Ekle" : "Add Photo"),
                ),
              ),
              const SizedBox(height: 24),

              // Title Field
              Text(l10n.subscriptionName,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Netflix, Spotify, Adobe...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 24),

              // Type/Category Field - Bubble Chips (Apple Style)
              Text(l10n.category, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._subscriptionTypes.map((category) {
                    final isSelected = _typeController.text == category;
                    return FilterChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _typeController.text = selected ? category : '';
                        });
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Colors.blue.shade500,
                      side: BorderSide(
                        color: isSelected ? Colors.blue.shade500 : Colors.grey.shade300,
                      ),
                    );
                  }),
                  // Custom category input
                  ActionChip(
                    label: const Text(
                      '+ Custom',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onPressed: () {
                      _showCustomCategoryDialog(context);
                    },
                    backgroundColor: Colors.grey.shade100,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Price Field with Currency
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.cost,
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _costController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.currency, style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCurrency,
                          items: supportedCurrencies
                              .map((currency) => DropdownMenuItem(
                                    value: currency.code,
                                    child: Text(currency.code),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedCurrency = value);
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
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
              const SizedBox(height: 24),

              // Billing Cycle Selection
              // Payment Cycle Selection
              Text('Ödeme Döngüsü', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<BillingCycle>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    value: _selectedBillingCycle,
                    items: [
                      DropdownMenuItem(
                        value: BillingCycle.monthly,
                        child: Text('Aylık'),
                      ),
                      DropdownMenuItem(
                        value: BillingCycle.yearly,
                        child: Text('Yıllık'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedBillingCycle = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Billing Day Picker
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 24),

              // Subscription End Date Option
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
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
                                'Abonelik Bitiş Tarihi Belli mi?',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Aboneliğin belirli bir tarihte bitişi varsa açın',
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
                              if (value) {
                                _selectedEndDate = DateTime.now().add(const Duration(days: 30));
                              } else {
                                _selectedEndDate = null;
                              }
                            });
                          },
                          activeThumbColor: Colors.blue,
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
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedEndDate != null
                                  ? '${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}'
                                  : 'Tarih Seçin',
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
              const SizedBox(height: 24),

              // Notification Settings
              Text(l10n.notificationSettings,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
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
                Text('Hatırlat',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<int>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      value: _selectedNotificationDaysBefore,
                      items: [
                        DropdownMenuItem(
                          value: 1,
                          child: Text('1 gün önce')
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('2 gün önce')
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('3 gün önce')
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text('4 gün önce')
                        ),
                        DropdownMenuItem(
                          value: 5,
                          child: Text('5 gün önce')
                        ),
                        DropdownMenuItem(
                          value: 6,
                          child: Text('6 gün önce')
                        ),
                        DropdownMenuItem(
                          value: 7,
                          child: Text('1 hafta önce')
                        ),
                      ].toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedNotificationDaysBefore = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Info text about global notification time
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bildirim saati Ayarlar sayfasından düzenlenebilir',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Notes Field
              Text('Not', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Abonelik hakkında not ekle...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 32),

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
                      : const Text(
                          'Kaydet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32), // Bottom padding
            ],
          ),
        ),
      );

  void _showCustomCategoryDialog(BuildContext context) {
    final customController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Özel Kategori Ekle'),
        content: TextField(
          controller: customController,
          decoration: InputDecoration(
            hintText: 'Örn: Video Editör, Tasarım...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (customController.text.isNotEmpty) {
                setState(() {
                  _typeController.text = customController.text;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }
}
