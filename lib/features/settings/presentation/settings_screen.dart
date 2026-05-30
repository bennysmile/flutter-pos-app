import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/app_user.dart';
import '../../../shared/models/store_settings.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/store_settings_providers.dart';
import '../data/store_settings_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storeSettingsProvider);
    final user = ref.watch(authControllerProvider).currentUser;
    final canEdit =
        user?.role == UserRole.owner ||
        user?.role == UserRole.admin ||
        user?.role == UserRole.manager;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: settings.when(
          data: (data) =>
              _SettingsContent(settings: data, user: user, canEdit: canEdit),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _SettingsError(message: error.toString()),
        ),
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.settings,
    required this.user,
    required this.canEdit,
  });

  final StoreSettings settings;
  final AppUser? user;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 24,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              children: [
                _AccountInfo(
                  label: 'Shop',
                  value: settings.storeName,
                  icon: Icons.storefront_outlined,
                ),
                _AccountInfo(
                  label: 'User',
                  value: user?.name ?? 'Signed in user',
                  icon: Icons.person_outline,
                ),
                _AccountInfo(
                  label: 'Role',
                  value: user?.role.label ?? 'Unknown',
                  icon: Icons.admin_panel_settings_outlined,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        StoreSettingsForm(settings: settings, canEdit: canEdit),
      ],
    );
  }
}

class _AccountInfo extends StatelessWidget {
  const _AccountInfo({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ],
    );
  }
}

class StoreSettingsForm extends ConsumerStatefulWidget {
  const StoreSettingsForm({
    super.key,
    required this.settings,
    required this.canEdit,
  });

  final StoreSettings settings;
  final bool canEdit;

  @override
  ConsumerState<StoreSettingsForm> createState() => _StoreSettingsFormState();
}

class _StoreSettingsFormState extends ConsumerState<StoreSettingsForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _storeNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _taxIdController;
  late final TextEditingController _receiptFooterController;
  late final TextEditingController _branchNameController;
  late final TextEditingController _lowStockThresholdController;
  late final TextEditingController _taxRateController;
  var _taxEnabled = false;
  var _cashEnabled = true;
  var _mobileMoneyEnabled = true;
  var _bankTransferEnabled = true;
  var _cardEnabled = true;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    final settings = widget.settings;
    _storeNameController = TextEditingController(text: settings.storeName);
    _addressController = TextEditingController(text: settings.address);
    _phoneController = TextEditingController(text: settings.phone);
    _emailController = TextEditingController(text: settings.email);
    _taxIdController = TextEditingController(text: settings.taxId);
    _receiptFooterController = TextEditingController(
      text: settings.receiptFooter,
    );
    _branchNameController = TextEditingController(text: settings.branchName);
    _lowStockThresholdController = TextEditingController(
      text: settings.lowStockThreshold.toString(),
    );
    _taxRateController = TextEditingController(
      text: settings.taxRate.toStringAsFixed(2),
    );
    _taxEnabled = settings.taxEnabled;
    _cashEnabled = settings.cashEnabled;
    _mobileMoneyEnabled = settings.mobileMoneyEnabled;
    _bankTransferEnabled = settings.bankTransferEnabled;
    _cardEnabled = settings.cardEnabled;
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _taxIdController.dispose();
    _receiptFooterController.dispose();
    _branchNameController.dispose();
    _lowStockThresholdController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: AbsorbPointer(
            absorbing: !widget.canEdit || _isSaving,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Store Settings',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),
                _TextInput(
                  controller: _storeNameController,
                  label: 'Store Name',
                  validator: _required,
                ),
                _TextInput(controller: _addressController, label: 'Address'),
                _TextInput(
                  controller: _phoneController,
                  label: 'Phone Number',
                  validator: _required,
                ),
                _TextInput(
                  controller: _emailController,
                  label: 'Email Address',
                  validator: _optionalEmail,
                ),
                _TextInput(
                  controller: _taxIdController,
                  label: 'Tax ID / Registration Number',
                ),
                _TextInput(
                  controller: _branchNameController,
                  label: 'Branch Name',
                ),
                _TextInput(
                  controller: _receiptFooterController,
                  label: 'Receipt Footer Message',
                  maxLines: 2,
                ),
                const _ReadOnlyCurrencyField(),
                _TextInput(
                  controller: _lowStockThresholdController,
                  label: 'Low Stock Alert Threshold',
                  keyboardType: TextInputType.number,
                  validator: _nonNegativeInteger,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Tax/VAT'),
                  value: _taxEnabled,
                  onChanged: (value) => setState(() => _taxEnabled = value),
                ),
                _TextInput(
                  controller: _taxRateController,
                  label: 'Tax Rate',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _nonNegativeDecimal,
                ),
                const SizedBox(height: 12),
                Text(
                  'Payment Methods',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Cash'),
                  value: _cashEnabled,
                  onChanged: (value) => setState(() => _cashEnabled = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mobile Money'),
                  value: _mobileMoneyEnabled,
                  onChanged: (value) =>
                      setState(() => _mobileMoneyEnabled = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Bank Transfer'),
                  value: _bankTransferEnabled,
                  onChanged: (value) =>
                      setState(() => _bankTransferEnabled = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Card'),
                  value: _cardEnabled,
                  onChanged: (value) => setState(() => _cardEnabled = value),
                ),
                const SizedBox(height: 20),
                if (widget.canEdit)
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveSettings,
                    child: Text(_isSaving ? 'Saving...' : 'Save Settings'),
                  )
                else
                  const Text(
                    'Only Owner, Admin, or Manager users can edit settings.',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    final settings = widget.settings.copyWith(
      storeName: _storeNameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      taxId: _taxIdController.text.trim(),
      receiptFooter: _receiptFooterController.text.trim().isEmpty
          ? 'Thank you for shopping with us.'
          : _receiptFooterController.text.trim(),
      currencyCode: 'GHS',
      currencySymbol: 'GHS',
      taxEnabled: _taxEnabled,
      taxRate: double.parse(_taxRateController.text.trim()),
      lowStockThreshold: int.parse(_lowStockThresholdController.text.trim()),
      branchName: _branchNameController.text.trim(),
      cashEnabled: _cashEnabled,
      mobileMoneyEnabled: _mobileMoneyEnabled,
      bankTransferEnabled: _bankTransferEnabled,
      cardEnabled: _cardEnabled,
    );

    try {
      await ref.read(storeSettingsRepositoryProvider).saveSettings(settings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Store settings saved successfully.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _optionalEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
    return isValid ? null : 'Enter a valid email';
  }

  String? _nonNegativeInteger(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null) {
      return 'Enter a whole number';
    }
    return parsed < 0 ? 'Cannot be negative' : null;
  }

  String? _nonNegativeDecimal(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null) {
      return 'Enter a valid number';
    }
    return parsed < 0 ? 'Cannot be negative' : null;
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }
}

class _ReadOnlyCurrencyField extends StatelessWidget {
  const _ReadOnlyCurrencyField();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Currency',
          hintText: 'GHS - Ghana Cedis',
        ),
      ),
    );
  }
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
