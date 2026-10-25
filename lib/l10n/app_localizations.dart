import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('en', 'English', 'English', 'Estedad'),
  russian('ru', 'Russian', 'Русский', 'Roboto');

  const AppLanguage(
    this.code,
    this.englishName,
    this.nativeName,
    this.fontFamily,
  );

  final String code;
  final String englishName;
  final String nativeName;

  /// Estedad has no Cyrillic glyphs, so Russian uses the Android system font.
  final String fontFamily;

  Locale get locale => Locale(code);

  /// Both supported languages are written left to right.
  TextDirection get textDirection => TextDirection.ltr;

  static AppLanguage fromCode(String? code) {
    return switch (code) {
      'ru' => AppLanguage.russian,
      _ => AppLanguage.english,
    };
  }
}

class AppLanguageController extends ChangeNotifier {
  AppLanguageController() {
    _load();
  }

  static const String _prefsKey = 'app_language_v1';

  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final next = AppLanguage.fromCode(prefs.getString(_prefsKey));
    if (next == _language) return;
    _language = next;
    AppText.setLanguage(next);
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (language == _language) return;
    _language = language;
    AppText.setLanguage(language);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.code);
  }

  static AppLanguageController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppLanguageScope>();
    assert(scope != null, 'No AppLanguageScope found in context.');
    return scope!.controller;
  }
}

class AppLanguageScope extends InheritedNotifier<AppLanguageController> {
  const AppLanguageScope({
    super.key,
    required AppLanguageController controller,
    required super.child,
  }) : super(notifier: controller);

  AppLanguageController get controller => notifier!;
}

class AppLocalizations {
  const AppLocalizations(this.language);

  final AppLanguage language;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ru')];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppText.current;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    final language = AppLanguage.fromCode(locale.languageCode);
    AppText.setLanguage(language);
    return SynchronousFuture<AppLocalizations>(AppText.current);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class AppText {
  AppText._();

  static AppLocalizations current = const AppLocalizations(AppLanguage.english);

  static void setLanguage(AppLanguage language) {
    current = AppLocalizations(language);
  }

  static bool get isRu => current.language == AppLanguage.russian;
  static String pick(String en, String ru) => isRu ? ru : en;
}

extension AppStrings on AppLocalizations {
  String get appTitle => 'TunnelForge';
  String get vpn => AppText.pick('VPN', 'VPN');
  String get logs => AppText.pick('Logs', 'Журнал');
  String get settings => AppText.pick('Settings', 'Настройки');
  String get cancel => AppText.pick('Cancel', 'Отмена');
  String get delete => AppText.pick('Delete', 'Удалить');
  String get close => AppText.pick('Close', 'Закрыть');
  String get save => AppText.pick('Save', 'Сохранить');
  String get done => AppText.pick('Done', 'Готово');
  String get continueLabel => AppText.pick('Continue', 'Продолжить');
  String get confirm => AppText.pick('Confirm', 'Подтвердить');
  String confirmInSeconds(int seconds) => AppText.pick(
    'Confirm in ${seconds}s',
    'Подтвердить через $seconds с',
  );
  String get dismiss => AppText.pick('Dismiss', 'Закрыть');
  String get languageLabel => AppText.pick('Language', 'Язык');
  String get chooseLanguage =>
      AppText.pick('Choose your language', 'Выберите язык');
  String get languageSubtitle => AppText.pick(
    'Set the language for every screen before you continue.',
    'Выберите язык интерфейса. Он будет использоваться на всех экранах.',
  );
  String get languageBody => AppText.pick(
    'This choice updates the app immediately. You can change it later from Settings.',
    'Язык меняется сразу. Позже его можно изменить в настройках.',
  );
  String get english => 'English';
  String get russian => 'Русский';
  String get notice => AppText.pick('Notice', 'Уведомление');
  String get onboardingIntroSubtitle => AppText.pick(
    'Legacy L2TP support for modern Android, with setup and connection management in one place.',
    'Поддержка L2TP на современных Android: настройка и управление подключениями в одном месте.',
  );
  String get onboardingIntroP1 => AppText.pick(
    'Create and organize profiles, switch between connections, and keep the essentials close at hand.',
    'Создавайте и упорядочивайте профили, переключайтесь между подключениями и держите всё нужное под рукой.',
  );
  String get onboardingIntroP2 => AppText.pick(
    'Designed for environments that still depend on L2TP, without forcing an outdated setup experience.',
    'Для сетей, которые всё ещё работают через L2TP, без устаревших и запутанных настроек.',
  );
  String get onboardingIntroP3 => AppText.pick(
    'A focused way to manage legacy VPN access on current Android devices.',
    'Удобный способ подключаться к старым VPN на современных устройствах Android.',
  );
  String get securityNoticeTitle => AppText.pick(
    'Review security notice',
    'Предупреждение о безопасности',
  );
  String get securityNoticeSubtitle => AppText.pick(
    'L2TP/IPsec is provided for legacy compatibility, is not considered secure by modern standards, and should only be used when stronger protocols are not available.',
    'L2TP/IPsec поддерживается для совместимости со старыми системами. По современным меркам он не считается надёжным: используйте его, только если более защищённые протоколы недоступны.',
  );
  String get securityReadOnlySubtitle => AppText.pick(
    'L2TP should only be used when no stronger option is available.',
    'Используйте L2TP, только если нет более надёжного варианта.',
  );
  String get securityP1 => AppText.pick(
    'This protocol remains available to support older infrastructure, not as a recommended default for new deployments.',
    'Протокол оставлен для поддержки существующей инфраструктуры, а не как рекомендуемый вариант для новых сетей.',
  );
  String get securityP2 => AppText.pick(
    'It should be treated as easier to decrypt than modern VPN protocols. If your network supports WireGuard, OpenVPN, or another modern alternative, that should be the preferred choice.',
    'Его проще расшифровать, чем современные VPN-протоколы. Если ваша сеть поддерживает WireGuard, OpenVPN или другую современную альтернативу, лучше выбрать её.',
  );
  String get securityReadOnlyP1 => AppText.pick(
    'L2TP/IPsec no longer meets modern security expectations for sensitive traffic.',
    'L2TP/IPsec больше не отвечает современным требованиям безопасности для конфиденциальных данных.',
  );
  String get securityReadOnlyP2 => AppText.pick(
    'Use this option only when compatibility is required and no stronger protocol is available.',
    'Используйте его, только если это нужно для совместимости и более надёжный протокол недоступен.',
  );
  String get introCheckbox => AppText.pick(
    'Keep VPN profiles organized.',
    'Держать профили VPN в порядке.',
  );
  String get riskCheckbox =>
      AppText.pick('I understand the L2TP risk.', 'Я понимаю риски L2TP.');
  String get compatibilityOnly => AppText.pick(
    'Use only when compatibility requires it',
    'Только когда это нужно для совместимости',
  );
  String get compatibilityBody => AppText.pick(
    'Proceed only if this connection depends on L2TP/IPsec, you understand that it is not a secure modern protocol, and no stronger option is available for the same service.',
    'Продолжайте, только если это подключение работает через L2TP/IPsec, вы понимаете, что это не защищённый современный протокол, и для этого сервиса нет более надёжного варианта.',
  );

  String get appearance => AppText.pick('Appearance', 'Оформление');
  String get system => AppText.pick('System', 'Системное');
  String get light => AppText.pick('Light', 'Светлое');
  String get dark => AppText.pick('Dark', 'Тёмное');
  String get connectionMode =>
      AppText.pick('Connection mode', 'Режим подключения');
  String get localProxy => AppText.pick('Local proxy', 'Локальный прокси');
  String get splitTunneling =>
      AppText.pick('Split tunneling', 'Раздельное туннелирование');
  String get enableSplitTunneling => AppText.pick(
    'Enable split tunneling',
    'Включить раздельное туннелирование',
  );
  String splitTunnelApply(String mode) => AppText.pick(
    'Apply the selected app list using $mode mode.',
    'Выбранный список приложений применяется в режиме «$mode».',
  );
  String get splitTunnelRouteAll => AppText.pick(
    'Route all apps through the VPN and keep both app lists saved for later.',
    'Все приложения идут через VPN, оба списка приложений сохраняются на будущее.',
  );
  String get mode => AppText.pick('Mode', 'Режим');
  String get inclusive => AppText.pick('Inclusive', 'Включение');
  String get exclusive => AppText.pick('Exclusive', 'Исключение');
  String get inclusiveDescription => AppText.pick(
    'Inclusive routes only the apps you choose through the VPN.',
    'В режиме включения через VPN идут только выбранные приложения.',
  );
  String get exclusiveDescription => AppText.pick(
    'Exclusive routes all apps through the VPN except the apps you choose.',
    'В режиме исключения через VPN идут все приложения, кроме выбранных.',
  );
  String get selectAppsUsingVpn =>
      AppText.pick('Select apps using VPN', 'Выбрать приложения для VPN');
  String get selectAppsOutsideVpn =>
      AppText.pick('Select apps outside VPN', 'Выбрать приложения вне VPN');
  String get noAppsUseVpn => AppText.pick(
    'No apps selected. Choose at least one app to use the VPN.',
    'Приложения не выбраны. Выберите хотя бы одно приложение для VPN.',
  );
  String appsWillUseVpn(int count) => AppText.pick(
    '$count app${count == 1 ? '' : 's'} will use the VPN.',
    'Приложений, использующих VPN: $count.',
  );
  String get noAppsBypassVpn => AppText.pick(
    'No apps selected. All apps will continue using the VPN.',
    'Приложения не выбраны. Все приложения продолжат использовать VPN.',
  );
  String appsWillBypassVpn(int count) => AppText.pick(
    '$count app${count == 1 ? '' : 's'} will bypass the VPN.',
    'Приложений в обход VPN: $count.',
  );
  String get httpPort => AppText.pick('HTTP port', 'Порт HTTP');
  String get socksPort => AppText.pick('SOCKS5 port', 'Порт SOCKS5');
  String get allowLan => AppText.pick(
    'Allow connections from LAN',
    'Разрешить подключения из локальной сети',
  );
  String get allowLanOn => AppText.pick(
    'Detect a shareable local IPv4 and expose both listeners to devices on the same Wi-Fi or hotspot when available.',
    'Определяет локальный IPv4-адрес и, когда возможно, открывает оба прокси для устройств в той же сети Wi-Fi или точке доступа.',
  );
  String get allowLanOff => AppText.pick(
    'Keep both listeners on this device only.',
    'Оба прокси доступны только на этом устройстве.',
  );
  String get proxyPortsDifferent => AppText.pick(
    'HTTP and SOCKS5 ports must be different before connecting.',
    'Перед подключением порты HTTP и SOCKS5 должны различаться.',
  );
  String get proxyEndpoints => AppText.pick('Proxy endpoints', 'Адреса прокси');
  String get lanClientsCanUse => AppText.pick(
    'LAN clients on the same Wi-Fi or hotspot can use this address.',
    'Устройства в той же сети Wi-Fi или точке доступа могут использовать этот адрес.',
  );
  String get lanSharingEnabled => AppText.pick(
    'LAN sharing is enabled for this session.',
    'Доступ из локальной сети включён для этого сеанса.',
  );
  String get connectToDetectLan => AppText.pick(
    'Connect to detect the current LAN IP for other devices.',
    'Подключитесь, чтобы определить IP-адрес в локальной сети для других устройств.',
  );
  String get lanDisabled => AppText.pick(
    'LAN access is disabled.',
    'Доступ из локальной сети отключён.',
  );
  String get connectivityCheck =>
      AppText.pick('Connectivity check', 'Проверка связи');
  String get batteryOptimization =>
      AppText.pick('Battery optimization', 'Оптимизация батареи');
  String get batteryOptimizationAllowed => AppText.pick(
    'Allowed for background use.',
    'Работа в фоне разрешена.',
  );
  String get batteryOptimizationRestricted => AppText.pick(
    'Restricted in the background.',
    'Работа в фоне ограничена.',
  );
  String get batteryOptimizationUnsupported => AppText.pick(
    'Not required on this device.',
    'На этом устройстве не требуется.',
  );
  String get batteryOptimizationUnknown =>
      AppText.pick('Status unavailable.', 'Состояние неизвестно.');
  String get allowBackgroundVpn => AppText.pick('Allow', 'Разрешить');
  String get statusCheckUrl =>
      AppText.pick('Status check URL', 'Адрес для проверки связи');
  String get statusCheckHelp => AppText.pick(
    'Used for the status check after you connect. Tap the badge anytime to refresh.',
    'Используется для проверки связи после подключения. Нажмите на значок, чтобы обновить.',
  );
  String get connectivityUrl =>
      AppText.pick('Connectivity URL', 'URL проверки');
  String get connectivityTimeout =>
      AppText.pick('Connectivity timeout (ms)', 'Тайм-аут проверки (мс)');
  String get timeoutHelp => AppText.pick(
    'Maximum time to wait before marking the check unreachable.',
    'Максимальное время ожидания, после которого адрес считается недоступным.',
  );
  String get l2tpSecurityNotice =>
      AppText.pick('L2TP security notice', 'Безопасность L2TP');
  String get reviewL2tpNotice => AppText.pick(
    'Review the L2TP/IPsec compatibility notice.',
    'Посмотреть предупреждение о совместимости L2TP/IPsec.',
  );
  String get updates => AppText.pick('Updates', 'Обновления');
  String get refresh => AppText.pick('Refresh', 'Обновить');
  String get openReleasePage =>
      AppText.pick('Open release page', 'Открыть страницу релиза');
  String get versionUnavailable =>
      AppText.pick('Version unavailable', 'Версия неизвестна');
  String version(String value) =>
      AppText.pick('Version $value', 'Версия $value');
  String get about => AppText.pick('About', 'О приложении');
  String get aboutText => AppText.pick(
    'TunnelForge keeps L2TP/IPsec usable on modern Android, with profile management, local proxy access, per-app routing, and clear connection logs in one place.',
    'TunnelForge позволяет пользоваться L2TP/IPsec на современных Android: управление профилями, локальный прокси, маршрутизация по приложениям и понятный журнал подключения в одном месте.',
  );
  String get telegramTitle => AppText.pick('Telegram', 'Telegram');
  String get githubTitle => AppText.pick('GitHub', 'GitHub');
  String get checkingUpdates =>
      AppText.pick('Checking for updates', 'Проверка обновлений');
  String get updateAvailable =>
      AppText.pick('Update available', 'Доступно обновление');
  String get buildNewer => AppText.pick(
    'Installed build is newer',
    'Установлена более новая сборка',
  );
  String get updateCheckUnavailable => AppText.pick(
    'Update check unavailable',
    'Проверка обновлений недоступна',
  );
  String get appUpToDate =>
      AppText.pick('App is up to date', 'Установлена последняя версия');
  String get checkForUpdates =>
      AppText.pick('Check for updates', 'Проверить обновления');
  String get lookingUpRelease => AppText.pick(
    'Looking up the latest published GitHub release.',
    'Получение последнего релиза с GitHub.',
  );
  String get updateCheckConsentTitle => AppText.pick(
    'Check GitHub releases?',
    'Проверить релизы на GitHub?',
  );
  String get updateCheckConsentMessage => AppText.pick(
    'TunnelForge will contact GitHub Releases to compare your installed version with the latest published build. This is used only when you request an update check.',
    'TunnelForge обратится к GitHub Releases, чтобы сравнить установленную версию с последней опубликованной. Это происходит только по вашему запросу.',
  );
  String get updateCheckConsentAllow =>
      AppText.pick('Check releases', 'Проверить');
  String latestReleaseRunning(String latest, String installed) => AppText.pick(
    'Latest release: $latest. You are running $installed.',
    'Последний релиз: $latest. У вас установлена $installed.',
  );
  String latestPublished(String latest) => AppText.pick(
    'You are running the latest published release: $latest.',
    'Установлен последний опубликованный релиз: $latest.',
  );
  String buildNewerThanLatest(String latest) => AppText.pick(
    'This build is newer than the latest GitHub release ($latest).',
    'Эта сборка новее последнего релиза на GitHub ($latest).',
  );
  String latestCannotCompare(String latest, String reason) => AppText.pick(
    'Latest release: $latest. $reason',
    'Последний релиз: $latest. $reason',
  );
  String get unknownBuild =>
      AppText.pick('an unknown build', 'неизвестная сборка');
  String get couldNotCheckUpdates => AppText.pick(
    'Couldn\'t check for updates right now.',
    'Сейчас не удаётся проверить обновления.',
  );
  String updateCheckError(String message) {
    if (!AppText.isRu) return message;
    if (message.startsWith('GitHub Releases returned HTTP ')) {
      final status = message
          .replaceFirst('GitHub Releases returned HTTP ', '')
          .replaceFirst('.', '');
      return 'Сервер GitHub вернул ошибку ($status).';
    }
    return switch (message) {
      'Network error while contacting GitHub Releases.' =>
        'Не удалось подключиться к GitHub для проверки обновлений.',
      'GitHub Releases request timed out.' =>
        'Проверка обновлений заняла слишком много времени.',
      'Secure connection to GitHub Releases failed.' =>
        'Не удалось установить защищённое соединение с GitHub.',
      'GitHub Releases returned malformed data.' =>
        'Не удалось разобрать ответ GitHub.',
      'GitHub Releases returned no usable releases.' =>
        'На GitHub не найдено подходящих релизов.',
      'Unexpected error while checking GitHub Releases.' =>
        'Непредвиденная ошибка при проверке обновлений.',
      'Installed version unavailable, so this build cannot be compared.' =>
        installedVersionUnavailableCompare,
      _ => message,
    };
  }

  String get checkGithubReleases => AppText.pick(
    'Check GitHub releases to see whether a newer build is available.',
    'Проверьте релизы на GitHub, чтобы узнать, есть ли новая сборка.',
  );
  String get installedVersionUnavailableCompare => AppText.pick(
    'Installed version unavailable, so this build cannot be compared.',
    'Установленная версия неизвестна, поэтому сравнить сборки нельзя.',
  );

  String get activeProfile => AppText.pick('Active profile', 'Активный профиль');
  String get noSavedProfile =>
      AppText.pick('No saved profile', 'Нет сохранённых профилей');
  String get quickConnect =>
      AppText.pick('Quick connect', 'Быстрое подключение');
  String get createFirstProfile =>
      AppText.pick('Create your first profile', 'Создайте первый профиль');
  String get selectSavedProfile =>
      AppText.pick('Select a saved profile', 'Выберите сохранённый профиль');
  String get selectProfile =>
      AppText.pick('Select profile', 'Выберите профиль');
  String get ready => AppText.pick('Ready', 'Готово');
  String get connected => AppText.pick('Connected', 'Подключено');
  String get proxyReady => AppText.pick('Proxy ready', 'Прокси готов');
  String get working => AppText.pick('Working...', 'Выполняется...');
  String get connectingTapCancel => AppText.pick(
    'Connecting... tap to cancel',
    'Подключение... нажмите для отмены',
  );
  String get disconnecting => AppText.pick('Disconnecting...', 'Отключение...');
  String get canceling => AppText.pick('Canceling...', 'Отмена...');
  String get tapToCheck =>
      AppText.pick('Tap to check', 'Нажмите для проверки');
  String get checking => AppText.pick('Checking...', 'Проверка...');
  String get unreachable => AppText.pick('Unreachable', 'Недоступно');
  String get logLevel => AppText.pick('Log level', 'Уровень журнала');
  String get wordWrapOff => AppText.pick(
    'Turn off word wrap (wide lines scroll sideways)',
    'Отключить перенос строк (длинные строки прокручиваются вбок)',
  );
  String get wordWrapOn =>
      AppText.pick('Turn on word wrap', 'Включить перенос строк');
  String get copyVisible =>
      AppText.pick('Copy visible', 'Копировать видимое');
  String get shareDebugLogs =>
      AppText.pick('Share debug logs', 'Отправить отладочный журнал');
  String get clear => AppText.pick('Clear', 'Очистить');
  String get noLogsMatch =>
      AppText.pick('No logs match this level', 'Нет записей этого уровня');
  String get noActivityYet =>
      AppText.pick('No activity yet', 'Пока нет событий');
  String get differentLogLevel => AppText.pick(
    'Try a different log level to see more entries.',
    'Выберите другой уровень журнала, чтобы увидеть больше записей.',
  );
  String get logsWillAppear => AppText.pick(
    'Connection events and diagnostics will appear here.',
    'Здесь появятся события подключения и диагностика.',
  );
  String get latest => AppText.pick('Latest', 'К последним');

  String get profiles => AppText.pick('Profiles', 'Профили');
  String get addProfile => AppText.pick('Add profile', 'Добавить профиль');
  String get createNewProfile =>
      AppText.pick('Create new profile', 'Создать профиль');
  String get importFromFile =>
      AppText.pick('Import from file', 'Импорт из файла');
  String get importFromClipboard =>
      AppText.pick('Import from clipboard', 'Импорт из буфера обмена');
  String get noProfilesYet => AppText.pick(
    'No profiles yet. Tap + to create or import your first profile.',
    'Профилей пока нет. Нажмите +, чтобы создать или импортировать первый профиль.',
  );
  String get profileActions =>
      AppText.pick('Profile actions', 'Действия с профилем');
  String get copyShareLink =>
      AppText.pick('Copy share link', 'Копировать ссылку');
  String get exportTfp => AppText.pick('Export .tfp', 'Экспорт .tfp');
  String get editProfile => AppText.pick('Edit profile', 'Изменить профиль');
  String get deleteProfile => AppText.pick('Delete profile', 'Удалить профиль');
  String get deleteProfileQuestion =>
      AppText.pick('Delete profile?', 'Удалить профиль?');
  String get deleteProfileBody => AppText.pick(
    'This will remove the server and saved credentials from this device.',
    'Сервер и сохранённые учётные данные будут удалены с этого устройства.',
  );
  String get profileSaved => AppText.pick('Profile saved', 'Профиль сохранён');
  String get profileRefreshTimedOut => AppText.pick(
    'Profile list refresh timed out',
    'Истекло время обновления списка профилей',
  );
  String get profileImportTimedOut => AppText.pick(
    'Profile import timed out',
    'Истекло время импорта профиля',
  );
  String get couldNotReadSelectedFile => AppText.pick(
    'Couldn\'t read the selected file',
    'Не удалось прочитать выбранный файл',
  );
  String get couldNotImportTfp => AppText.pick(
    'Couldn\'t import .tfp file',
    'Не удалось импортировать файл .tfp',
  );
  String get clipboardEmpty =>
      AppText.pick('Clipboard is empty', 'Буфер обмена пуст');
  String get clipboardInvalidProfile => AppText.pick(
    'Clipboard does not contain a valid TunnelForge profile',
    'В буфере обмена нет корректного профиля TunnelForge',
  );
  String get couldNotImportClipboard => AppText.pick(
    'Couldn\'t import a profile from the clipboard',
    'Не удалось импортировать профиль из буфера обмена',
  );

  String get profileDetails => AppText.pick('Profile details', 'Профиль');
  String get name => AppText.pick('Name', 'Название');
  String get nameHint =>
      AppText.pick('e.g. Office VPN', 'например, VPN офиса');
  String get server => AppText.pick('Server', 'Сервер');
  String get serverHint =>
      AppText.pick('Hostname or IP address', 'Имя хоста или IP-адрес');
  String get username => AppText.pick('Username', 'Имя пользователя');
  String get password => AppText.pick('Password', 'Пароль');
  String get showPassword => AppText.pick('Show password', 'Показать пароль');
  String get hidePassword => AppText.pick('Hide password', 'Скрыть пароль');
  String get ipsecPsk => AppText.pick('IPsec PSK', 'Общий ключ IPsec (PSK)');
  String get showIpsecPsk => AppText.pick('Show IPsec PSK', 'Показать PSK');
  String get hideIpsecPsk => AppText.pick('Hide IPsec PSK', 'Скрыть PSK');
  String get ipsecPskHint => AppText.pick('Optional', 'Необязательно');
  String get automatic => AppText.pick('Automatic', 'Автоматически');
  String get automaticDnsHelp => AppText.pick(
    'Receive DNS configuration automatically from the VPN server during PPP negotiation.',
    'Получать DNS-серверы от VPN-сервера при согласовании PPP.',
  );
  String get dnsServers => AppText.pick('DNS servers', 'DNS-серверы');
  String get dnsHelp => AppText.pick(
    'DNS 1 is primary. DNS 2 is fallback.',
    'DNS 1 — основной, DNS 2 — резервный.',
  );
  String mtuHelper(int min, int max, int defaultValue) => AppText.pick(
    'Range $min-$max. Use $defaultValue unless you need a smaller MTU.',
    'Диапазон $min–$max. Оставьте $defaultValue, если не нужен меньший MTU.',
  );

  String get selectAll => AppText.pick('Select all', 'Выбрать все');
  String get clearAll => AppText.pick('Clear all', 'Снять все');
  String get searchApps => AppText.pick(
    'Search by name or package',
    'Поиск по названию или пакету',
  );
  String get noLaunchableApps => AppText.pick(
    'No launchable apps found. If this is wrong, check that the app can query other packages on your Android version.',
    'Приложения не найдены. Если это ошибка, проверьте, что приложению разрешено видеть другие пакеты в вашей версии Android.',
  );
  String get noMatches => AppText.pick('No matches.', 'Ничего не найдено.');
  String get appsUsingVpn =>
      AppText.pick('Apps using VPN', 'Приложения через VPN');
  String get appsOutsideVpn =>
      AppText.pick('Apps outside VPN', 'Приложения вне VPN');
  String get onlySelectedAppsVpn => AppText.pick(
    'Only the selected apps will use the VPN.',
    'Только выбранные приложения будут использовать VPN.',
  );
  String get selectedAppsBypass => AppText.pick(
    'Selected apps will bypass the VPN and use the normal network.',
    'Выбранные приложения будут обходить VPN и использовать обычную сеть.',
  );
}
