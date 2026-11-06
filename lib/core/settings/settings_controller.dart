import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/strings.dart';
import '../theme/app_palette.dart';

final prefsProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

class SettingsState {
  final String themeId;
  final String lang;
  const SettingsState({required this.themeId, required this.lang});

  AppPalette get palette => AppPalette.byId(themeId);

  SettingsState copyWith({String? themeId, String? lang}) =>
      SettingsState(themeId: themeId ?? this.themeId, lang: lang ?? this.lang);
}

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final prefs = ref.read(prefsProvider);
    return SettingsState(
      themeId: prefs.getString('theme') ?? AppPalette.midnight.id,
      lang: prefs.getString('lang') ?? 'en',
    );
  }

  Future<void> setTheme(String id) async {
    state = state.copyWith(themeId: id);
    await ref.read(prefsProvider).setString('theme', id);
  }

  Future<void> setLang(String lang) async {
    state = state.copyWith(lang: lang);
    await ref.read(prefsProvider).setString('lang', lang);
  }
}

final settingsProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

final stringsProvider =
    Provider<S>((ref) => S(ref.watch(settingsProvider).lang));
