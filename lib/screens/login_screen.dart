import 'package:app_garb/widgets/custom_textField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_elevatedbutton.dart';

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
  bool _emailNotVerified = false; // Flag para saber si el email no ha sido verificado

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } else {
      // Verificación de si el correo está verificado
      User? user = FirebaseAuth.instance.currentUser; // Aquí usamos FirebaseAuth
      if (user != null && !user.emailVerified) {
        // Si el correo no está verificado, mostramos el botón de reenviar
        setState(() {
          _emailNotVerified = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, verifica tu correo antes de continuar.')));
      } else {
        // Navegar al home
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Bienvenido!')));
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser; // Aquí usamos FirebaseAuth
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Se ha reenviado el correo de verificación.')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
                
                // Botón invisible para reenviar el correo de verificación
                Visibility(
                  visible: _emailNotVerified,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _sendVerificationEmail,
                        child: const Text('Reenviar correo de verificación'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Color de fondo del botón
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}