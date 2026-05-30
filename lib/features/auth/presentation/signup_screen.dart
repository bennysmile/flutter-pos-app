import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import 'auth_controller.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _identifierController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _shopPhoneController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _identifierController.dispose();
    _shopNameController.dispose();
    _shopPhoneController.dispose();
    _shopAddressController.dispose();
    _branchNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.storefront,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Create your POS account',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set up the owner profile and first shop.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _FormSection(
                      title: 'Owner Information',
                      children: [
                        _InputField(
                          controller: _fullNameController,
                          label: 'Full name',
                          icon: Icons.person_outline,
                          validator: _required,
                        ),
                        _InputField(
                          controller: _phoneController,
                          label: 'Phone number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: _required,
                        ),
                        _InputField(
                          controller: _identifierController,
                          label: 'Email address or username',
                          icon: Icons.alternate_email,
                          validator: _required,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FormSection(
                      title: 'Shop Information',
                      children: [
                        _InputField(
                          controller: _shopNameController,
                          label: 'Shop/store name',
                          icon: Icons.store_mall_directory_outlined,
                          validator: _required,
                        ),
                        _InputField(
                          controller: _shopPhoneController,
                          label: 'Shop phone number',
                          icon: Icons.local_phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: _required,
                        ),
                        _InputField(
                          controller: _shopAddressController,
                          label: 'Shop address',
                          icon: Icons.location_on_outlined,
                          validator: _required,
                        ),
                        _InputField(
                          controller: _branchNameController,
                          label: 'Branch name',
                          icon: Icons.account_tree_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FormSection(
                      title: 'Account Security',
                      children: [
                        _InputField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: _required,
                        ),
                        _InputField(
                          controller: _confirmPasswordController,
                          label: 'Confirm password',
                          icon: Icons.lock_reset_outlined,
                          obscureText: true,
                          validator: _confirmPassword,
                        ),
                      ],
                    ),
                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        auth.errorMessage!,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: auth.isLoading ? null : _signup,
                      child: auth.isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create account and shop'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: auth.isLoading
                          ? null
                          : () => context.go(AppRoutes.login),
                      child: const Text('Already have an account? Sign in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .signup(
          SignupInput(
            fullName: _fullNameController.text,
            phone: _phoneController.text,
            identifier: _identifierController.text,
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
            shopName: _shopNameController.text,
            shopPhone: _shopPhoneController.text,
            shopAddress: _shopAddressController.text,
            branchName: _branchNameController.text,
          ),
        );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _confirmPassword(String? value) {
    final requiredMessage = _required(value);
    if (requiredMessage != null) {
      return requiredMessage;
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: validator,
      ),
    );
  }
}
