import 'package:flutter/material.dart';

import 'package:shree/screens/auth/auth_shared.dart';
import 'package:shree/services/account_storage_service.dart';

const Color _green = Color(0xFF1FD58B);
const Color _dark = Color(0xFF1D2740);
const Color _muted = Color(0xFF8B9AB0);

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  static const List<String> _languages = <String>[
    'English',
    'Hindi',
    'Bengali',
  ];
  static const List<String> _currencies = <String>['USD', 'INR', 'EUR'];

  String _language = _languages.first;
  String _currency = _currencies.first;
  bool _orderAlerts = true;
  bool _promotionalAlerts = true;
  bool _wishlistAlerts = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final data = await AccountStorageService.loadPreferences();
    if (!mounted) return;

    setState(() {
      _language = _languages.contains(data.language)
          ? data.language
          : _languages.first;
      _currency = _currencies.contains(data.currency)
          ? data.currency
          : _currencies.first;
      _orderAlerts = data.orderAlerts;
      _promotionalAlerts = data.promotionalAlerts;
      _wishlistAlerts = data.wishlistAlerts;
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await AccountStorageService.savePreferences(
      AccountPreferencesData(
        language: _language,
        currency: _currency,
        orderAlerts: _orderAlerts,
        promotionalAlerts: _promotionalAlerts,
        wishlistAlerts: _wishlistAlerts,
      ),
    );

    if (!mounted) return;

    setState(() => _isSaving = false);
    showAuthSnackBar(context, 'Preferences updated');
  }

  @override
  Widget build(BuildContext context) {
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
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration,
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuthFieldTitle('Language'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _language,
                        decoration: authFieldDecoration(
                          hintText: 'Select language',
                          icon: Icons.language_rounded,
                        ),
                        items: _languages
                            .map(
                              (language) => DropdownMenuItem<String>(
                                value: language,
                                child: Text(language),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _language = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      const AuthFieldTitle('Currency'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _currency,
                        decoration: authFieldDecoration(
                          hintText: 'Select currency',
                          icon: Icons.payments_outlined,
                        ),
                        items: _currencies
                            .map(
                              (currency) => DropdownMenuItem<String>(
                                value: currency,
                                child: Text(currency),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _currency = value);
                        },
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration,
            child: Column(
              children: [
                _ToggleTile(
                  icon: Icons.local_shipping_outlined,
                  title: 'Order updates',
                  subtitle: 'Get shipping and delivery notifications.',
                  value: _orderAlerts,
                  onChanged: (value) => setState(() => _orderAlerts = value),
                ),
                const Divider(height: 28, color: Color(0xFFE8EEF6)),
                _ToggleTile(
                  icon: Icons.sell_outlined,
                  title: 'Promotional alerts',
                  subtitle: 'Be first to know about offers and launches.',
                  value: _promotionalAlerts,
                  onChanged: (value) =>
                      setState(() => _promotionalAlerts = value),
                ),
                const Divider(height: 28, color: Color(0xFFE8EEF6)),
                _ToggleTile(
                  icon: Icons.favorite_border_rounded,
                  title: 'Wishlist price drops',
                  subtitle: 'Get notified when saved items change price.',
                  value: _wishlistAlerts,
                  onChanged: (value) => setState(() => _wishlistAlerts = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          AuthPrimaryButton(
            label: 'Save Preferences',
            isLoading: _isSaving,
            onPressed: _save,
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
            child: const Icon(Icons.tune_rounded, color: _green),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preferences',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Language, currency, alerts',
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

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEFFFF8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: _muted),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeThumbColor: _green,
          activeTrackColor: _green.withValues(alpha: 0.35),
          onChanged: onChanged,
        ),
      ],
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
