import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get_x_todo/db/db_helper.dart';
import 'package:get_x_todo/services/theme_services.dart';
import 'package:get_x_todo/ui/theme.dart';

import 'ui/pages/home_page.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // NotifyHelper().initializeNotification();
  await DBHelper.initDb();
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeServices().theme,
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      // NotificationScreen(payload: 'Titel|Descraption|Date|dddd'),
    );
  }
}
