import 'package:app_garb/widgets/custom_textField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_elevatedbutton.dart';
import '../widgets/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    String? errorMessage = await AuthService().login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() {
      _loading = false;
    });

    if (errorMessage != null) {
      CustomSnackbar.show(
        context: context,
        title: 'Error',
        message: errorMessage,
        backgroundColor: Colors.red, // Color de fondo para error
        textColor: Colors.white, // Color del texto
      );
    } else {
      // Verificación de si el correo está verificado
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        CustomSnackbar.show(
          context: context,
          title: 'Verificación pendiente',
          message: 'Por favor, verifica tu correo.',
          backgroundColor: Colors.orange, // Color para advertencia
          textColor: Colors.white, // Texto en blanco
        );
      } else {
        CustomSnackbar.show(
          context: context,
          title: '¡Bienvenido!',
          message: 'Iniciaste sesión correctamente.',
          backgroundColor: Colors.green, // Color para éxito
          textColor: Colors.white, // Texto en blanco
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título: Iniciar Sesión
                Text(
                  'Iniciar Sesión',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Email
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Correo electrónico',
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.email,
                  validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 16),
                
                // Contraseña
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Contraseña',
                  obscureText: true,
                  icon: Icons.lock,
                  validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 24),
                
                // Botón Entrar
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    text: 'Entrar',
                    onPressed: _login,
                    isLoading: _loading,
                    backgroundColor: Colors.blueAccent,
                    icon: Icons.login,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Botón de Registro
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('¿No tienes cuenta? Regístrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
