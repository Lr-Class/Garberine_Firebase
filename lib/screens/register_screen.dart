import 'package:app_garb/widgets/custom_textField.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_elevatedbutton.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  bool _loading = false;

  // Método de registro
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    String? errorMessage = await AuthService().register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      username: _usernameController.text.trim(),
      fullName: _fullNameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
    );

    setState(() {
      _loading = false;
    });

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso. Verifica tu correo electrónico.')),
      );
      Navigator.pop(context); // Volver al login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Campo de nombre de usuario
              CustomTextField(
                controller: _usernameController,
                labelText: 'Nombre de usuario (Juego)',
                icon: Icons.person,
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              
              // Campo de nombre real
              CustomTextField(
                controller: _fullNameController,
                labelText: 'Nombre real',
                icon: Icons.abc,
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              
              // Campo de edad
              CustomTextField(
                controller: _ageController,
                labelText: 'Edad',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obligatorio';
                  if (int.tryParse(value) == null) return 'Debe ser un número';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Campo de correo electrónico
              CustomTextField(
                controller: _emailController,
                labelText: 'Correo electrónico',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              
              // Campo de contraseña
              CustomTextField(
                controller: _passwordController,
                labelText: 'Contraseña',
                obscureText: true,
                icon: Icons.lock,
                validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 20),
              
              // Botón de registro
              CustomElevatedButton(
                text: 'Registrarse',
                onPressed: _register,
                isLoading: _loading,
                backgroundColor: Colors.blueAccent, // Puedes cambiar el color
                icon: Icons.person_add, // Icono opcional
              ),
            ],
          ),
        ),
      ),
    );
  }
}
