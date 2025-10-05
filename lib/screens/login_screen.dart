import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login() async {
    final payload = {
      "email": emailController.text,
      "password": passwordController.text,
    };

    try {
      final response = await authService.login(payload);
      final token = response['data']['token'];

      //Guardar token

      await SessionService.setToken(token);
      
      // Guardar token o lo que devuelva tu backend
      //print(response); // solo para debug

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión exitoso')),
        );
        Navigator.pushReplacementNamed(context, '/cita/list');
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Ingresar')),
          ],
        ),
      ),
    );
  }
}
