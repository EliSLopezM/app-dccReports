import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../register/register_screen.dart';
import '../report/public_report_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthRepository>().login(
            identifier: _identifierController.text.trim(),
            password: _passwordController.text,
          );
    } on InvalidCredentialsException {
      // RF-10: mensaje genérico, sin indicar si el correo/teléfono existe.
      setState(() => _errorMessage = 'Correo/teléfono o contraseña incorrectos.');
    } on AuthUnexpectedException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('identifier-field'),
              controller: _identifierController,
              decoration: const InputDecoration(labelText: 'Correo o teléfono'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Ingresa tu correo o teléfono' : null,
            ),
            TextFormField(
              key: const Key('password-field'),
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Ingresa tu contraseña' : null,
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                key: const Key('login-error'),
                style: const TextStyle(color: Colors.red),
              ),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? 'Entrando...' : 'Entrar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
            const Divider(height: 32),
            // RF-1: alcanzable sin sesión, para cualquier persona.
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PublicReportScreen()),
              ),
              icon: const Icon(Icons.report),
              label: const Text('Reportar una emergencia'),
            ),
          ],
        ),
      ),
    );
  }
}
