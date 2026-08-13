// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Subscription Hunter';

  @override
  String get navHome => 'Главная';

  @override
  String get navStatistics => 'Статистика';

  @override
  String get navSettings => 'Настройки';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionEdit => 'Изменить';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get actionAdd => 'Добавить';

  @override
  String get actionUndo => 'Отменить';

  @override
  String get actionChange => 'Изменить';

  @override
  String get addCustomSubscription => 'Создать свою подписку';

  @override
  String get homeMonthlyTotal => 'В месяц';

  @override
  String get homeYearlyTotal => 'В год';

  @override
  String get homeActiveCount => 'Активные';

  @override
  String get homeUpcoming => 'Ближайшие платежи';

  @override
  String get homeAllSubscriptions => 'Все подписки';

  @override
  String get homeSearchHint => 'Поиск подписок';

  @override
  String get homeEmptyTitle => 'Подписок пока нет';

  @override
  String get homeEmptyMessage =>
      'Добавьте первую подписку, чтобы отслеживать ежемесячные расходы.';

  @override
  String get homeEmptyAction => 'Добавить подписку';

  @override
  String get homeNoUpcoming => 'В ближайшие 30 дней платежей нет.';

  @override
  String homeNoResults(String query) {
    return 'Нет подписок по запросу «$query».';
  }

  @override
  String get dueToday => 'Платёж сегодня';

  @override
  String get dueTomorrow => 'Платёж завтра';

  @override
  String dueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Через $count дня',
      many: 'Через $count дней',
      few: 'Через $count дня',
      one: 'Через $count день',
    );
    return '$_temp0';
  }

  @override
  String get perMonth => 'в месяц';

  @override
  String get perYear => 'в год';

  @override
  String get cycleWeekly => 'Еженедельно';

  @override
  String get cycleMonthly => 'Ежемесячно';

  @override
  String get cycleQuarterly => 'Раз в квартал';

  @override
  String get cycleYearly => 'Ежегодно';

  @override
  String get addTitle => 'Добавить подписку';

  @override
  String get editTitle => 'Изменить подписку';

  @override
  String get addChoosePreset => 'Популярные сервисы';

  @override
  String get addChoosePresetSubtitle =>
      'Выберите сервис, чтобы поля заполнились автоматически.';

  @override
  String get addCustomService => 'Свой';

  @override
  String get addSearchServices => 'Поиск сервисов';

  @override
  String get addDetailsSection => 'Детали';

  @override
  String get addReminderSection => 'Напоминание';

  @override
  String get fieldName => 'Название';

  @override
  String get fieldPrice => 'Цена';

  @override
  String get fieldCurrency => 'Валюта';

  @override
  String get fieldCycle => 'Период оплаты';

  @override
  String get fieldFirstPayment => 'Первый платёж';

  @override
  String get fieldCategory => 'Категория';

  @override
  String get fieldNotes => 'Заметки (необязательно)';

  @override
  String get fieldEndDate => 'Дата окончания (необязательно)';

  @override
  String get reminderEnabled => 'Напомнить перед платежом';

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'За $count дня',
      many: 'За $count дней',
      few: 'За $count дня',
      one: 'За $count день',
      zero: 'В день платежа',
    );
    return '$_temp0';
  }

  @override
  String get reminderTime => 'Время напоминания';

  @override
  String get validationNameRequired => 'Введите название';

  @override
  String get validationPriceRequired => 'Введите цену';

  @override
  String get validationPriceInvalid => 'Введите корректную сумму больше нуля';

  @override
  String get detailNextPayment => 'Следующий платёж';

  @override
  String get detailLastPayment => 'Последний платёж';

  @override
  String get detailCostPerMonth => 'Стоимость в месяц';

  @override
  String get detailCostPerYear => 'Стоимость в год';

  @override
  String get detailNotes => 'Заметки';

  @override
  String get detailStarted => 'Начало';

  @override
  String get detailNeverBilled => 'Платежей ещё не было';

  @override
  String get deleteConfirmTitle => 'Удалить подписку?';

  @override
  String deleteConfirmMessage(String name) {
    return '$name будет удалена навсегда. Это действие необратимо.';
  }

  @override
  String deletedSnack(String name) {
    return '$name удалена';
  }

  @override
  String get savedSnack => 'Сохранено';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get statsByCategory => 'Расходы по категориям';

  @override
  String get statsMonthlyTrend => 'Последние 6 месяцев';

  @override
  String get statsTotalMonthly => 'Всего в месяц';

  @override
  String get statsTotalYearly => 'Всего в год';

  @override
  String get statsAveragePerService => 'В среднем на сервис';

  @override
  String get statsEmpty =>
      'Добавьте подписку, чтобы увидеть структуру расходов.';

  @override
  String get statsMostExpensive => 'Самая дорогая';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsCurrency => 'Валюта по умолчанию';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsNotificationsEnabled => 'Напоминания о платежах';

  @override
  String get settingsNotificationsSubtitle =>
      'Уведомлять перед продлением подписки';

  @override
  String get settingsNotificationsBlocked =>
      'Уведомления отключены в настройках системы.';

  @override
  String get settingsData => 'Данные';

  @override
  String get settingsEraseAll => 'Удалить все данные';

  @override
  String get settingsEraseConfirm =>
      'Удалить все подписки? Это действие необратимо.';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get settingsVersion => 'Версия';

  @override
  String get onboardingTitle1 => 'Все подписки в одном месте';

  @override
  String get onboardingBody1 =>
      'Добавьте сервисы и сразу видите реальную стоимость в месяц и в год.';

  @override
  String get onboardingTitle2 => 'Не пропустите продление';

  @override
  String get onboardingBody2 =>
      'Напоминание перед каждым списанием — пробный период не станет сюрпризом.';

  @override
  String get onboardingTitle3 => 'Понимайте, куда уходят деньги';

  @override
  String get onboardingBody3 =>
      'Разбивка по категориям и помесячный тренд показывают, что накапливается.';

  @override
  String get onboardingConsentTitle => 'Перед началом';

  @override
  String get onboardingConsentIntro => 'Два коротких шага — и всё готово.';

  @override
  String get onboardingPrivacyLabel => 'Я согласен с обработкой моих данных';

  @override
  String get onboardingPrivacyDetail =>
      'Подписки хранятся только на этом устройстве. Ничего не выгружается, аккаунт не нужен, аналитика не собирается. Логотипы брендов загружаются через сервис фавиконов Google, туда передаётся только доменное имя сервиса.';

  @override
  String get onboardingNotificationsTitle => 'Напоминания о платежах';

  @override
  String get onboardingNotificationsDetail =>
      'Разрешите уведомления, чтобы напомнить вам перед продлением подписки. Это можно изменить позже в настройках.';

  @override
  String get onboardingAllowNotifications => 'Разрешить уведомления';

  @override
  String get onboardingNotificationsGranted => 'Уведомления включены';

  @override
  String get onboardingNotificationsSkipped => 'Продолжить без напоминаний';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get onboardingConsentRequired =>
      'Примите уведомление о данных, чтобы продолжить.';

  @override
  String get statsViewCategories => 'Категории';

  @override
  String get statsViewTrend => 'Тренд';

  @override
  String get settingsSupport => 'Связь и поддержка';

  @override
  String get settingsSupportSubtitle =>
      'Сообщить о проблеме или предложить идею';

  @override
  String settingsSupportUnavailable(String email) {
    return 'Почтовое приложение не найдено. Напишите на $email';
  }

  @override
  String get privacyTitle => 'Политика конфиденциальности';

  @override
  String get privacyUpdated => 'Последнее обновление: 13 августа 2026 г.';

  @override
  String get privacyIntro =>
      'Subscription Hunter работает без аккаунта и не отправляет ваши данные куда-либо. Здесь описано, что именно приложение хранит, что покидает ваше устройство и чего оно не делает.';

  @override
  String get privacyStorageTitle => 'Что хранит приложение';

  @override
  String get privacyStorageBody =>
      'Всё, что вы вводите - названия подписок, цены, даты списаний, категории, заметки и настройки напоминаний - записывается в файл базы данных в приватном хранилище приложения на вашем устройстве. Нет аккаунта, нет входа, нет облачной синхронизации. Мы никогда не получаем копию.';

  @override
  String get privacyNetworkTitle => 'Что покидает устройство';

  @override
  String get privacyNetworkBody =>
      'Только одно: чтобы показать логотип бренда, приложение запрашивает у сервиса фавиконов Google значок публичного сайта, например netflix.com. В запросе передаётся только доменное имя сервиса - ни цен подписок, ни персональных данных, ни идентификаторов вас или вашего устройства. Без сети приложение рисует цветную плитку и работает как обычно.';

  @override
  String get privacyNotificationsTitle => 'Уведомления';

  @override
  String get privacyNotificationsBody =>
      'Напоминания о платежах планируются системой будильников самого устройства. Они формируются локально из введённых вами данных и никогда не проходят через сервер.';

  @override
  String get privacySupportTitle => 'Если вы обращаетесь в поддержку';

  @override
  String get privacySupportBody =>
      'Кнопка поддержки открывает ваше почтовое приложение с письмом, которое вы можете прочитать и изменить перед отправкой. В него заранее подставлены версия приложения и версия Android, чтобы проблему можно было воспроизвести. Если вы отправите письмо, мы получим ваш адрес и текст и используем их только для ответа.';

  @override
  String get privacyNoTrackingTitle => 'Чего приложение не делает';

  @override
  String get privacyNoTrackingBody =>
      'Никакой аналитики, рекламы, отслеживания или профилирования, никаких сторонних маркетинговых SDK, никакой продажи или передачи данных. Продавать нечего - данные к нам просто не попадают.';

  @override
  String get privacyControlTitle => 'Ваш контроль над данными';

  @override
  String get privacyControlBody =>
      'Вы можете удалить всё в любой момент через пункт Удалить все данные в настройках. Удаление приложения также безвозвратно стирает его базу и настройки с устройства. Поскольку копии нигде больше нет, удаление происходит сразу и окончательно.';

  @override
  String get privacyChildrenTitle => 'Дети';

  @override
  String get privacyChildrenBody =>
      'Приложение является универсальным инструментом учёта расходов, не предназначено для детей младше 13 лет, и данные от них сознательно не собираются.';

  @override
  String get privacyContactTitle => 'Контакты';

  @override
  String privacyContactBody(String email) {
    return 'Вопросы по этой политике можно отправить на $email.';
  }

  @override
  String get settingsPrivacy => 'Политика конфиденциальности';

  @override
  String get settingsPrivacySubtitle =>
      'Что хранится и что покидает устройство';

  @override
  String get privacyViewOnline => 'Открыть онлайн';

  @override
  String get categoryStreaming => 'Стриминг';

  @override
  String get categoryMusic => 'Музыка';

  @override
  String get categoryGaming => 'Игры';

  @override
  String get categorySoftware => 'Софт';

  @override
  String get categoryAi => 'ИИ';

  @override
  String get categoryCloud => 'Облако';

  @override
  String get categoryNews => 'Новости';

  @override
  String get categoryFitness => 'Фитнес';

  @override
  String get categoryEducation => 'Обучение';

  @override
  String get categoryShopping => 'Покупки';

  @override
  String get categoryFinance => 'Финансы';

  @override
  String get categoryOther => 'Другое';

  @override
  String notificationTitle(String name) {
    return '$name скоро продлится';
  }

  @override
  String notificationBodyToday(String name, String amount) {
    return '$name спишет $amount сегодня.';
  }

  @override
  String notificationBodyUpcoming(String name, String amount, String date) {
    return '$name спишет $amount $date.';
  }

  @override
  String get notificationChannelName => 'Напоминания о платежах';

  @override
  String get notificationChannelDescription =>
      'Напоминания перед продлением подписки';
}
