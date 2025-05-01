import 'package:flutter/material.dart';
import 'package:news_app_test/src/app.dart';
import 'package:news_app_test/src/di.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

//* Those points wasn't mentioned in the task overview:
// 1- Webview
// 2- Themeing (light & dark)
// 3- Animation
// 4- Network connectivity
// 5- Testing