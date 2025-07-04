import 'package:ai_profile_ui/screen/auth/validate_verification_code.dart';
import 'package:ai_profile_ui/screen/chat/chat_ai_analysis_screen.dart';
import 'package:ai_profile_ui/screen/chat/chat_history_screen.dart';
import 'package:flutter/material.dart';

import '../controller/home_controller.dart';
import '../screen/auth/change_password.dart';
import '../screen/auth/login.dart';
import '../screen/auth/register.dart';
import '../screen/auth/send_verification_code.dart';
import '../screen/home/home.dart';
import '../screen/logic/create_transaction_screen.dart';
import '../screen/logic/edit_transaction_screen.dart';
import '../screen/logic/transaction.dart';
import '../screen/logic/transaction_excel_screen.dart';
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
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder:
              (_) => RecoverPasswordScreen(
                email: args['email']!,
                code: args['code']!,
              ),
        );
      case AppRoutes.sendVerificationCode:
        return MaterialPageRoute(
          builder: (_) => const VerificationCodeScreen(),
        );
      case AppRoutes.validateVerificationCode:
        final email = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ValidateCodeScreen(email: email),
        );
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.chat:
        return MaterialPageRoute(builder: (_) => const ChatAiAnalysisScreen());
      case AppRoutes.transactions:
        return MaterialPageRoute(builder: (_) => const TransactionScreen());
      case AppRoutes.createTransaction:
        return MaterialPageRoute(
          builder: (_) => const CreateTransactionScreen(),
        );
      case AppRoutes.transactionExcel:
        return MaterialPageRoute(
          builder: (_) => const TransactionExcelScreen(),
        );
      case AppRoutes.editTransaction:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => EditTransactionScreen(
                id: args['id'],
                original: args['original'],
              ),
        );

      case AppRoutes.profile:
        final controller = settings.arguments as HomeController;
        return MaterialPageRoute(
          builder: (_) => UserDetails(controller: controller),
        );

      case AppRoutes.chatHistory:
        final conversationId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ChatHistoryScreen(conversationId: conversationId),
        );

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('Ruta no encontrada: ${settings.name}'),
                ),
              ),
        );
    }
  }
}
