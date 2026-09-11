import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/account_role.dart';
import '../../domain/entities/course_catalog.dart';
import '../../domain/entities/organization_info.dart';
import '../../domain/exceptions.dart';
import '../../domain/repositories/auth_repository.dart';

const _registrableRoles = [
  AccountRole.voluntario,
  AccountRole.funcionario,
  AccountRole.lider,
  AccountRole.liderFuncionario,
];

const _roleLabels = {
  AccountRole.voluntario: 'Voluntario',
  AccountRole.funcionario: 'Funcionario',
  AccountRole.lider: 'Líder',
  AccountRole.liderFuncionario: 'Líder funcionario',
};

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _organizationNameController = TextEditingController();
  final _organizationAddressController = TextEditingController();

  AccountRole _role = AccountRole.voluntario;
  final Set<String> _selectedCourseIds = {};
  bool _submitting = false;
  String? _errorMessage;

  bool get _requiresOrganization => _role.requiresOrganization;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _organizationNameController.dispose();
    _organizationAddressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    if (_emailController.text.trim().isEmpty && _phoneController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Ingresa un correo o un teléfono.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthRepository>().register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            password: _passwordController.text,
            role: _role,
            activeCourseIds: _selectedCourseIds.toList(),
            organization: _requiresOrganization
                ? OrganizationInfo(
                    name: _organizationNameController.text.trim(),
                    address: _organizationAddressController.text.trim(),
                  )
                : null,
          );
    } on DuplicateAccountException {
      setState(() => _errorMessage = 'Ese correo o teléfono ya tiene una cuenta.');
    } on AuthUnexpectedException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro DCC-BOGOTA')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Ingresa tu nombre' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo (opcional si das teléfono)'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono (opcional si das correo)'),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
              validator: (value) =>
                  (value == null || value.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AccountRole>(
              key: const Key('role-dropdown'),
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Rango solicitado'),
              items: [
                for (final role in _registrableRoles)
                  DropdownMenuItem(value: role, child: Text(_roleLabels[role]!)),
              ],
              onChanged: (role) => setState(() => _role = role ?? _role),
            ),
            const SizedBox(height: 16),
            const Text('Cursos activos', style: TextStyle(fontWeight: FontWeight.bold)),
            for (final course in kCourseCatalog)
              CheckboxListTile(
                title: Text(course.label),
                value: _selectedCourseIds.contains(course.id),
                onChanged: (checked) => setState(() {
                  if (checked ?? false) {
                    _selectedCourseIds.add(course.id);
                  } else {
                    _selectedCourseIds.remove(course.id);
                  }
                }),
              ),
            if (_requiresOrganization) ...[
              const SizedBox(height: 16),
              Text(
                'Organización (grupo o comité)',
                key: const Key('organization-section'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _organizationNameController,
                decoration: const InputDecoration(labelText: 'Nombre del grupo/comité'),
                validator: (value) => _requiresOrganization && (value == null || value.trim().isEmpty)
                    ? 'Ingresa el nombre de tu grupo/comité'
                    : null,
              ),
              TextFormField(
                controller: _organizationAddressController,
                decoration: const InputDecoration(labelText: 'Dirección de la sede principal'),
                validator: (value) => _requiresOrganization && (value == null || value.trim().isEmpty)
                    ? 'Ingresa la dirección de la sede'
                    : null,
              ),
            ],
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? 'Enviando...' : 'Registrarme'),
            ),
          ],
        ),
      ),
    );
  }
}
