import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shree/models/user_model.dart';
import 'package:shree/screens/auth/auth_shared.dart';
import 'package:shree/services/account_storage_service.dart';
import 'package:shree/services/auth_service.dart';

const Color _green = Color(0xFF1FD58B);
const Color _dark = Color(0xFF1D2740);
const Color _muted = Color(0xFF8B9AB0);

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key, required this.user});

  final AppUser? user;

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user?.name ?? '';
    _emailController.text = widget.user?.email ?? '';
    _loadDraft();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final draft = await AccountStorageService.loadProfileDraft();
    if (!mounted) return;

    _phoneController.text = draft.phone;
    _cityController.text = draft.city;
    _addressController.text = draft.address;
    setState(() => _isLoading = false);
  }

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your name';
    if (text.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    if (digits.length < 10) return 'Phone number must be at least 10 digits';
    return null;
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      await AccountStorageService.saveProfileDraft(
        AccountProfileDraft(
          phone: _phoneController.text.trim(),
          city: _cityController.text.trim(),
          address: _addressController.text.trim(),
        ),
      );
      if (widget.user != null) {
        await AuthService.updateProfileName(_nameController.text.trim());
      }
      if (!mounted) return;
      showAuthSnackBar(context, 'Profile details saved');
      Navigator.pop(context, true);
    } on AuthFailure catch (error) {
      if (!mounted) return;
      showAuthSnackBar(context, error.message, isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Shree Perfume'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _HeaderCard(),
          const SizedBox(height: 18),
          _InfoCard(user: user),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration,
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AuthFieldTitle('Full Name'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: authFieldDecoration(
                            hintText: 'Enter your name',
                            icon: Icons.person_outline_rounded,
                          ),
                          validator: _validateName,
                        ),
                        const SizedBox(height: 16),
                        const AuthFieldTitle('Email Address'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          readOnly: true,
                          decoration: authFieldDecoration(
                            hintText: 'Email address',
                            icon: Icons.mail_outline_rounded,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const AuthFieldTitle('Phone Number'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9+\-\s]'),
                            ),
                          ],
                          decoration: authFieldDecoration(
                            hintText: 'Enter your phone number',
                            icon: Icons.phone_outlined,
                          ),
                          validator: _validatePhone,
                        ),
                        const SizedBox(height: 16),
                        const AuthFieldTitle('City'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cityController,
                          textCapitalization: TextCapitalization.words,
                          decoration: authFieldDecoration(
                            hintText: 'Enter your city',
                            icon: Icons.location_city_outlined,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const AuthFieldTitle('Shipping Address'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressController,
                          minLines: 3,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: authFieldDecoration(
                            hintText: 'Street, area, landmark',
                            icon: Icons.home_outlined,
                          ),
                        ),
                        const SizedBox(height: 22),
                        AuthPrimaryButton(
                          label: 'Save Profile',
                          isLoading: _isSaving,
                          onPressed: _save,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFF4FFF9), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFE3F6EC)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEFFFF8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person_outline_rounded, color: _green),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Info',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Manage your profile details',
                  style: TextStyle(fontSize: 14, color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _InfoBlock(
                  label: 'Role',
                  value: (user?.role ?? 'Customer').toUpperCase(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoBlock(
                  label: 'Member Since',
                  value: user?.memberSinceLabel ?? 'Now',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 18, color: _muted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  user?.email ?? 'Sign in to sync your profile',
                  style: const TextStyle(fontSize: 14, color: _muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7EDF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
        ],
      ),
    );
  }
}

final BoxDecoration _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: const Color(0xFFEDF2F8)),
  boxShadow: const [
    BoxShadow(color: Color(0x080B1B34), blurRadius: 18, offset: Offset(0, 8)),
  ],
);
