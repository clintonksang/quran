import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_translate/google_translate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_app/config/export_configs.dart';
import 'package:quran_app/models/export_models.dart';
import 'package:quran_app/repositories/export_repo.dart';
import 'package:quran_app/services/localstoragerepo.dart';
import 'package:quran_app/services/notification_service.dart';
import 'blocs/export_blocs.dart';
import 'utils/export_utils.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  {}
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  GoogleTranslate.initialize(
    apiKey: "AIzaSyDPtlYw6lq2ygIQU4VgJOx2Jxm3GwVVVmM",
    targetLanguage: "en",
  );
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);
  Hive.registerAdapter(AyatAdapter());
  var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en_US', supportedLocales: ['en_US', 'ms', 'es', 'ar']);

  await initializeDateFormatting('id_ID').then((value) => runApp(LocalizedApp(
        delegate,
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            var localizationDelegate = LocalizedApp.of(context).delegate;

            return MultiBlocProvider(
                providers: [
                  BlocProvider(
                      create: (context) => BookmarksBloc(
                          localStorageRepository: LocalStorageRepository())
                        ..add(StartBookmarks())),
                  BlocProvider(create: (context) => TextSizeAlquranBloc()),
                  BlocProvider(
                      create: (context) => AdzanTimeBloc(
                          adzanConfig: AdzanConfig(),
                          notificationService: NotificationService(),
                          quranSurah: QuranSurah())
                        ..add(const InitAdzanTime())),
                  BlocProvider(create: (context) => NotificationChangerBloc()),
                ],
                child: MaterialApp(
                  localizationsDelegates: [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    localizationDelegate
                  ],
                  supportedLocales: localizationDelegate.supportedLocales,
                  locale: localizationDelegate.currentLocale,
                  debugShowCheckedModeBanner: false,
                  theme: ThemeUtils.lightTheme,
                  onGenerateRoute: AppNavigationConfig.onGenerateRoute,
                  initialRoute: '/',
                ));
          },
        ),
      )));
}
