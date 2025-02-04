import 'dart:io';
import 'package:app_reserva/routes/cadastrar.dart';
import 'package:app_reserva/routes/login.dart';
import 'package:app_reserva/routes/property_list_page.dart';
import 'package:app_reserva/routes/welcome.dart';
import 'package:app_reserva/theme/appTheme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

Future main() async {
  if (kIsWeb) {
    // Use web implementation on the web.
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    // Use ffi on Linux and Windows.
    if (Platform.isLinux || Platform.isWindows) {
      databaseFactory = databaseFactoryFfi;
      sqfliteFfiInit();
    }
  }
  runApp(MaterialApp(
    title: 'TRIV Reservas',
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: ThemeMode.system,
    initialRoute: '/welcome',
    routes: {
      '/welcome': (context) => const WelcomeScreen(),
      '/login': (context) => const Login(),
      '/cadastrar': (context) => const Cadastro(),
      '/busca': (context) => const PropertyListPage(),
    },
  ));
}
