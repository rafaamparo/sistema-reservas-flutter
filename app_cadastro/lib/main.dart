import 'dart:io';
import 'package:app_cadastro/routes/anuncio/visualizarPropriedades.dart';
import 'package:app_cadastro/routes/login.dart';
import 'package:app_cadastro/routes/cadastrar.dart';
import 'package:sqflite/sqflite.dart';
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
    theme: ThemeData(
      primarySwatch: Colors.purple,
    ),
    initialRoute: '/login',
    routes: {
      '/login': (context) => const Login(),
      '/cadastrar': (context) => const Cadastro(),
      '/verProps': (context) => const VerProps(),
    },
  ));
}
