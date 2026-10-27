import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/platform/session_store_memory.dart';
import 'package:yaadi/features/demo/domain/demo_household.dart';
import 'package:yaadi/features/settings/data/settings_repository.dart';
import 'package:yaadi/features/settings/domain/app_settings.dart';
import 'package:yaadi/vault/vault_database.dart';

void runSettingsContract(Future<SettingsRepository> Function() create) {
  late SettingsRepository repository;
  setUp(() async => repository = await create());

  test('starts empty', () async {
    expect(await repository.readAll(), isEmpty);
  });

  test('writes, overwrites and removes', () async {
    await repository.write(SettingKeys.language, 'ur');
    await repository.write(SettingKeys.largeText, 'true');
    await repository.write(SettingKeys.language, 'en');
    expect(await repository.readAll(), {
      'language': 'en',
      'large_text': 'true',
    });

    await repository.write(SettingKeys.language, null);
    expect(await repository.readAll(), {'large_text': 'true'});
  });
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('vault settings', () {
    runSettingsContract(() async {
      final db = VaultDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      return DriftSettingsRepository(db);
    });
  });

  group('memory settings', () {
    runSettingsContract(() async => MemorySettingsRepository());
  });

  group('session settings', () {
    runSettingsContract(
      () async => sessionSettingsRepository(MemorySessionStore()),
    );

    test('survive a reload of the tab', () async {
      final store = MemorySessionStore();
      await sessionSettingsRepository(store).write(SettingKeys.theme, 'dark');
      expect(await sessionSettingsRepository(store).readAll(), {
        'theme': 'dark',
      });
    });

    test('start empty from damaged data', () async {
      final store = MemorySessionStore()..write(sessionSettingsKey, '{oops');
      expect(await sessionSettingsRepository(store).readAll(), isEmpty);
    });
  });

  group('AppSettings', () {
    test('defaults follow the phone and use PKR', () {
      const settings = AppSettings();
      expect(settings.language, isNull);
      expect(settings.theme, ThemePreference.system);
      expect(settings.largeText, isFalse);
      expect(settings.defaultCurrency, 'PKR');
      expect(AppSettings.fromEntries(const {}), settings);
    });

    test('reads stored values', () {
      final settings = AppSettings.fromEntries(const {
        'language': 'ur',
        'theme': 'dark',
        'large_text': 'true',
        'default_currency': 'GBP',
      });
      expect(
        settings,
        const AppSettings(
          language: AppLanguage.ur,
          theme: ThemePreference.dark,
          largeText: true,
          defaultCurrency: 'GBP',
        ),
      );
    });

    test('falls back to defaults for values it does not know', () {
      final settings = AppSettings.fromEntries(const {
        'language': 'pa',
        'theme': 'sepia',
        'large_text': 'yes',
        'default_currency': 'rupees',
      });
      expect(settings, const AppSettings());
    });

    test('a demo household brings its own currency', () {
      final khan = AppSettings.fromEntries(const {'demo_household': 'khan'});
      expect(khan.demoHousehold, DemoHousehold.khan);
      expect(khan.householdCurrency, 'PKR');

      final taylor = khan.copyWith(demoHousehold: DemoHousehold.taylor);
      expect(taylor.householdCurrency, 'GBP');
      expect(taylor.copyWith(demoHousehold: null).householdCurrency, 'PKR');
      expect(
        AppSettings.fromEntries(const {'demo_household': 'smith'}),
        const AppSettings(),
      );
    });

    test('copyWith can return to following the phone', () {
      const urdu = AppSettings(language: AppLanguage.ur, largeText: true);
      expect(urdu.copyWith(language: null).language, isNull);
      expect(
        urdu.copyWith(theme: ThemePreference.light).language,
        AppLanguage.ur,
      );
      expect(urdu.copyWith(largeText: false).largeText, isFalse);
    });
  });
}
