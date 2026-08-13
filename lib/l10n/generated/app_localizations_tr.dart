// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Subscription Hunter';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navStatistics => 'İstatistikler';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get actionSave => 'Kaydet';

  @override
  String get actionCancel => 'İptal';

  @override
  String get actionDelete => 'Sil';

  @override
  String get actionEdit => 'Düzenle';

  @override
  String get actionRetry => 'Tekrar dene';

  @override
  String get actionClose => 'Kapat';

  @override
  String get actionAdd => 'Ekle';

  @override
  String get actionUndo => 'Geri al';

  @override
  String get actionChange => 'Değiştir';

  @override
  String get addCustomSubscription => 'Özel abonelik oluştur';

  @override
  String get homeMonthlyTotal => 'Aylık';

  @override
  String get homeYearlyTotal => 'Yıllık';

  @override
  String get homeActiveCount => 'Aktif';

  @override
  String get homeUpcoming => 'Yaklaşan ödemeler';

  @override
  String get homeAllSubscriptions => 'Tüm abonelikler';

  @override
  String get homeSearchHint => 'Abonelik ara';

  @override
  String get homeEmptyTitle => 'Henüz abonelik yok';

  @override
  String get homeEmptyMessage =>
      'Her ay ne kadar harcadığını takip etmeye başlamak için ilk aboneliğini ekle.';

  @override
  String get homeEmptyAction => 'Abonelik ekle';

  @override
  String get homeNoUpcoming => 'Önümüzdeki 30 gün içinde ödeme yok.';

  @override
  String homeNoResults(String query) {
    return '\"$query\" ile eşleşen abonelik yok.';
  }

  @override
  String get dueToday => 'Bugün ödenecek';

  @override
  String get dueTomorrow => 'Yarın ödenecek';

  @override
  String dueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün sonra',
      one: '1 gün sonra',
    );
    return '$_temp0';
  }

  @override
  String get perMonth => 'aylık';

  @override
  String get perYear => 'yıllık';

  @override
  String get cycleWeekly => 'Haftalık';

  @override
  String get cycleMonthly => 'Aylık';

  @override
  String get cycleQuarterly => '3 Aylık';

  @override
  String get cycleYearly => 'Yıllık';

  @override
  String get addTitle => 'Abonelik ekle';

  @override
  String get editTitle => 'Aboneliği düzenle';

  @override
  String get addChoosePreset => 'Popüler servisler';

  @override
  String get addChoosePresetSubtitle =>
      'Bilgilerin otomatik dolması için bir servis seç.';

  @override
  String get addCustomService => 'Özel';

  @override
  String get addSearchServices => 'Servis ara';

  @override
  String get addDetailsSection => 'Detaylar';

  @override
  String get addReminderSection => 'Hatırlatma';

  @override
  String get fieldName => 'Ad';

  @override
  String get fieldPrice => 'Fiyat';

  @override
  String get fieldCurrency => 'Para birimi';

  @override
  String get fieldCycle => 'Ödeme döngüsü';

  @override
  String get fieldFirstPayment => 'İlk ödeme';

  @override
  String get fieldCategory => 'Kategori';

  @override
  String get fieldNotes => 'Notlar (isteğe bağlı)';

  @override
  String get fieldEndDate => 'Bitiş tarihi (isteğe bağlı)';

  @override
  String get reminderEnabled => 'Ödemeden önce hatırlat';

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün önce',
      one: '1 gün önce',
      zero: 'Ödeme günü',
    );
    return '$_temp0';
  }

  @override
  String get reminderTime => 'Hatırlatma saati';

  @override
  String get validationNameRequired => 'Bir ad gir';

  @override
  String get validationPriceRequired => 'Bir fiyat gir';

  @override
  String get validationPriceInvalid => 'Sıfırdan büyük geçerli bir tutar gir';

  @override
  String get detailNextPayment => 'Sonraki ödeme';

  @override
  String get detailLastPayment => 'Son ödeme';

  @override
  String get detailCostPerMonth => 'Aylık maliyet';

  @override
  String get detailCostPerYear => 'Yıllık maliyet';

  @override
  String get detailNotes => 'Notlar';

  @override
  String get detailStarted => 'Başlangıç';

  @override
  String get detailNeverBilled => 'Henüz ödeme alınmadı';

  @override
  String get deleteConfirmTitle => 'Abonelik silinsin mi?';

  @override
  String deleteConfirmMessage(String name) {
    return '$name kalıcı olarak silinecek. Bu işlem geri alınamaz.';
  }

  @override
  String deletedSnack(String name) {
    return '$name silindi';
  }

  @override
  String get savedSnack => 'Kaydedildi';

  @override
  String get statsTitle => 'İstatistikler';

  @override
  String get statsByCategory => 'Kategoriye göre harcama';

  @override
  String get statsMonthlyTrend => 'Son 6 ay';

  @override
  String get statsTotalMonthly => 'Aylık toplam';

  @override
  String get statsTotalYearly => 'Yıllık toplam';

  @override
  String get statsAveragePerService => 'Servis başına ortalama';

  @override
  String get statsEmpty => 'Harcama dağılımını görmek için bir abonelik ekle.';

  @override
  String get statsMostExpensive => 'En pahalı';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsAppearance => 'Görünüm';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsCurrency => 'Varsayılan para birimi';

  @override
  String get settingsNotifications => 'Bildirimler';

  @override
  String get settingsNotificationsEnabled => 'Ödeme hatırlatmaları';

  @override
  String get settingsNotificationsSubtitle =>
      'Abonelik yenilenmeden önce bildirim al';

  @override
  String get settingsNotificationsBlocked =>
      'Bildirimler sistem ayarlarından kapatılmış.';

  @override
  String get settingsData => 'Veriler';

  @override
  String get settingsEraseAll => 'Tüm verileri sil';

  @override
  String get settingsEraseConfirm =>
      'Tüm abonelikler silinsin mi? Bu işlem geri alınamaz.';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get settingsVersion => 'Sürüm';

  @override
  String get onboardingTitle1 => 'Tüm abonelikler tek yerde';

  @override
  String get onboardingBody1 =>
      'Ödediğin servisleri ekle, aylık ve yıllık gerçek maliyeti tek bakışta gör.';

  @override
  String get onboardingTitle2 => 'Hiçbir yenilemeyi kaçırma';

  @override
  String get onboardingBody2 =>
      'Her tahsilattan önce hatırlatma al; ücretsiz deneme sürprize dönüşmesin.';

  @override
  String get onboardingTitle3 => 'Paranın nereye gittiğini bil';

  @override
  String get onboardingBody3 =>
      'Kategori dağılımı ve aylık trendler neyin biriktiğini net gösterir.';

  @override
  String get onboardingConsentTitle => 'Başlamadan önce';

  @override
  String get onboardingConsentIntro => 'İki kısa adım, sonra hazırsın.';

  @override
  String get onboardingPrivacyLabel => 'Verilerimin işlenmesini kabul ediyorum';

  @override
  String get onboardingPrivacyDetail =>
      'Abonelikleriniz yalnızca bu cihazda saklanır. Hiçbir veri yüklenmez, hesap gerekmez ve analiz toplanmaz. Marka logoları Google\'ın favicon servisinden çekilir; oraya yalnızca servisin alan adı gider.';

  @override
  String get onboardingNotificationsTitle => 'Ödeme hatırlatmaları';

  @override
  String get onboardingNotificationsDetail =>
      'Abonelik yenilenmeden önce hatırlatabilmemiz için bildirimlere izin ver. Bunu sonradan Ayarlar\'dan değiştirebilirsin.';

  @override
  String get onboardingAllowNotifications => 'Bildirimlere izin ver';

  @override
  String get onboardingNotificationsGranted => 'Bildirimler açık';

  @override
  String get onboardingNotificationsSkipped => 'Hatırlatma olmadan devam et';

  @override
  String get onboardingNext => 'Devam';

  @override
  String get onboardingStart => 'Başla';

  @override
  String get onboardingConsentRequired =>
      'Devam etmek için veri bildirimini kabul et.';

  @override
  String get statsViewCategories => 'Kategoriler';

  @override
  String get statsViewTrend => 'Trend';

  @override
  String get settingsSupport => 'İletişim & Destek';

  @override
  String get settingsSupportSubtitle => 'Hata bildir veya öneride bulun';

  @override
  String settingsSupportUnavailable(String email) {
    return 'E-posta uygulaması bulunamadı. $email adresine yazabilirsin';
  }

  @override
  String get categoryStreaming => 'Yayın';

  @override
  String get categoryMusic => 'Müzik';

  @override
  String get categoryGaming => 'Oyun';

  @override
  String get categorySoftware => 'Yazılım';

  @override
  String get categoryAi => 'Yapay Zeka';

  @override
  String get categoryCloud => 'Bulut';

  @override
  String get categoryNews => 'Haber';

  @override
  String get categoryFitness => 'Spor';

  @override
  String get categoryEducation => 'Eğitim';

  @override
  String get categoryShopping => 'Alışveriş';

  @override
  String get categoryFinance => 'Finans';

  @override
  String get categoryOther => 'Diğer';

  @override
  String notificationTitle(String name) {
    return '$name yakında yenileniyor';
  }

  @override
  String notificationBodyToday(String name, String amount) {
    return '$name bugün $amount tahsil edecek.';
  }

  @override
  String notificationBodyUpcoming(String name, String amount, String date) {
    return '$name $date tarihinde $amount tahsil edecek.';
  }

  @override
  String get notificationChannelName => 'Ödeme hatırlatmaları';

  @override
  String get notificationChannelDescription =>
      'Abonelik yenilenmeden önceki hatırlatmalar';
}
