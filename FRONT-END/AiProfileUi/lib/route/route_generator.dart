import 'package:flutter/material.dart';

import '../screen/auth/login.dart';
import '../screen/auth/recover_password.dart';
import '../screen/auth/register.dart';
import '../screen/auth/verification_code.dart';
import '../screen/chat/chat_ai.dart';
import '../screen/chat/chat_history.dart';
import '../screen/home/home.dart';
import '../screen/home/transaction.dart';
import '../screen/profile/user_details.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.recoverPassword:
        return MaterialPageRoute(builder: (_) => const RecoverPasswordScreen());
      case AppRoutes.verificationCode:
        return MaterialPageRoute(builder: (_) => const VerificationCodeScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.chat:
        return MaterialPageRoute(builder: (_) => const ChatAiScreen());
      case AppRoutes.chatHistory:
        return MaterialPageRoute(builder: (_) => const ChatHistoryScreen());
      case AppRoutes.transactions:
        return MaterialPageRoute(builder: (_) => const TransactionScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
