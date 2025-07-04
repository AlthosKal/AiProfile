// lib/core/constants/app_constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // Radios de borde
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;

  // Espaciados
  static const EdgeInsets paddingTiny = EdgeInsets.all(4.0);
  static const EdgeInsets paddingSmall = EdgeInsets.all(8.0);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16.0);
  static const EdgeInsets paddingLarge = EdgeInsets.all(24.0);
  static const EdgeInsets paddingXLarge = EdgeInsets.all(32.0);

  // Espaciados horizontales
  static const EdgeInsets paddingHorizontalSmall = EdgeInsets.symmetric(
    horizontal: 8.0,
  );
  static const EdgeInsets paddingHorizontalMedium = EdgeInsets.symmetric(
    horizontal: 16.0,
  );
  static const EdgeInsets paddingHorizontalLarge = EdgeInsets.symmetric(
    horizontal: 24.0,
  );

  // Espaciados verticales
  static const EdgeInsets paddingVerticalSmall = EdgeInsets.symmetric(
    vertical: 8.0,
  );
  static const EdgeInsets paddingVerticalMedium = EdgeInsets.symmetric(
    vertical: 16.0,
  );
  static const EdgeInsets paddingVerticalLarge = EdgeInsets.symmetric(
    vertical: 24.0,
  );

  // Alturas de componentes
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 80.0;
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;

  // Elevaciones
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Duraciones de animación
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Tamaños de iconos
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // Tamaños de fuente
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeading = 28.0;

  // Límites
  static const int maxRecentConversations = 5;
  static const int maxTransactionsPerPage = 20;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB

  // Strings comunes
  static const String appName = 'AiProfile';
  static const String appVersion = '1.0.0';

  // Mensajes de error comunes
  static const String errorGeneral = 'Ha ocurrido un error inesperado';
  static const String errorNetwork = 'Error de conexión. Verifica tu internet';
  static const String errorValidation = 'Por favor revisa los datos ingresados';
  static const String errorPermissions = 'No tienes permisos para esta acción';

  // Mensajes de éxito comunes
  static const String successSave = 'Guardado exitosamente';
  static const String successUpdate = 'Actualizado exitosamente';
  static const String successDelete = 'Eliminado exitosamente';

  // Breakpoints para responsive design
  static const double mobileBreakpoint = 480.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;
}

// Extensión para obtener dimensiones responsivas
extension ResponsiveSize on BuildContext {
  bool get isMobile =>
      MediaQuery.of(this).size.width < AppConstants.mobileBreakpoint;

  bool get isTablet =>
      MediaQuery.of(this).size.width >= AppConstants.mobileBreakpoint &&
      MediaQuery.of(this).size.width < AppConstants.desktopBreakpoint;

  bool get isDesktop =>
      MediaQuery.of(this).size.width >= AppConstants.desktopBreakpoint;

  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  // Padding adaptativo según el tamaño de pantalla
  EdgeInsets get adaptivePadding =>
      isMobile ? AppConstants.paddingMedium : AppConstants.paddingLarge;
}

// Utilidades para animaciones
class AppAnimations {
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.bounceOut;
  static const Curve elasticCurve = Curves.elasticOut;

  // Transiciones comunes
  static Widget slideTransition({
    required Animation<double> animation,
    required Widget child,
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: defaultCurve)),
      child: child,
    );
  }

  static Widget fadeTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(opacity: animation, child: child);
  }

  static Widget scaleTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: elasticCurve)),
      child: child,
    );
  }
}
