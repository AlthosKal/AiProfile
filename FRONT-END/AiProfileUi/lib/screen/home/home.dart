import 'dart:io';

import 'package:ai_profile_ui/screen/home/android/android_home.dart';
import 'package:ai_profile_ui/screen/home/web/web_home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebHomeScreen();
    } else if (Platform.isAndroid) {
      return const AndroidHomeScreen();
    } else {
      return const Center(child: Text('Plataforma no soportada'));
    }
  }
}
