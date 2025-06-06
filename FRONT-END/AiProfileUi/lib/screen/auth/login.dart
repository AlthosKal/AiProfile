import 'package:ai_profile_ui/controller/login_controller.dart';
import 'package:ai_profile_ui/widget/particle_animation_widget.dart';
import 'package:flutter/material.dart';

import '../../route/app_routes.dart';
import '../../widget/common/blurred_card.dart';
import '../../widget/common/primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: ParticleAnimation()),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const LoginForm(),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = LoginController();
  final _nameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameOrEmailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _nameOrEmailController.dispose();
    _passwordController.dispose();
    _nameOrEmailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _loginController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (!_formKey.currentState!.validate()) return;

    _loginController.login(
      context: context,
      nameOrEmail: _nameOrEmailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return BlurredCard(
      width: isSmallScreen ? 360.0 : 400.0,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Inicio de Sesión',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameOrEmailController,
              focusNode: _nameOrEmailFocusNode,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nombre o correo',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo requerido';
                }
                if (!value.contains('@') && value.trim().length < 3) {
                  return 'Ingrese un nombre válido o un correo electrónico';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<bool>(
              valueListenable: _loginController.obscurePassword,
              builder: (context, obscure, _) {
                return TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: obscure,
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: const TextStyle(color: Colors.white),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: _loginController.togglePasswordVisibility,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Campo requerido';
                    if (value.length < 6)
                      return 'Debe tener al menos 6 caracteres';
                    return null;
                  },
                  onFieldSubmitted: (_) => _submitLogin(),
                );
              },
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<bool>(
              valueListenable: _loginController.rememberPassword,
              builder: (context, remember, _) {
                return Row(
                  children: [
                    Checkbox(
                      value: remember,
                      onChanged: _loginController.toggleRememberPassword,
                      checkColor: Colors.black,
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                        (states) =>
                            states.contains(MaterialState.selected)
                                ? Colors.white
                                : Colors.transparent,
                      ),
                    ),
                    const Text(
                      'Recordar contraseña',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: _loginController.isLoading,
              builder: (context, isLoading, _) {
                return isLoading
                    ? const CircularProgressIndicator()
                    : PrimaryButton(label: 'Ingresar', onPressed: _submitLogin);
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
              child: const Text.rich(
                TextSpan(
                  text: '¿No tienes una cuenta? ',
                  style: TextStyle(color: Colors.white),
                  children: [
                    TextSpan(
                      text: 'Regístrate',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed:
                  () => Navigator.pushNamed(context, AppRoutes.recoverPassword),
              child: const Text.rich(
                TextSpan(
                  text: '¿Olvidaste tu contraseña? ',
                  style: TextStyle(color: Colors.white),
                  children: [
                    TextSpan(
                      text: 'Recupérala',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}