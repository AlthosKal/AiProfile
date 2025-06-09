import 'package:ai_profile_ui/route/app_routes.dart';
import 'package:ai_profile_ui/route/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      onGenerateRoute: RouteGenerator.generateRoute,
      //Manejo de errores global
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
