import 'package:ai_profile_ui/core/config/is_authenticated.dart';
import 'package:ai_profile_ui/route/app_routes.dart';
import 'package:ai_profile_ui/route/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final authenticated = await isAuthenticated();
  runApp(MyApp(initialRoute: authenticated ? AppRoutes.home : AppRoutes.login));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      onGenerateRoute: RouteGenerator.generateRoute,
      //Manejo de errores global
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
