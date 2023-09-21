import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger_type_app/src/config/app_controller.dart';
import 'package:messenger_type_app/src/data/app_dao.dart';
import 'package:messenger_type_app/src/data/app_database.dart';
import 'package:messenger_type_app/src/presentation/login.dart';
import 'package:messenger_type_app/src/presentation/speech_recognizer.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorAppDatabase.databaseBuilder('messenger_app.db').build();
  AppDao appDao = database.appDao;
  Get.put(AppController(appDao: appDao));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const Login()
    );
  }
}