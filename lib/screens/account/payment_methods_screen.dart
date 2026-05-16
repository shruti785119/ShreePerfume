import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shree/screens/auth/auth_shared.dart';
import 'package:shree/services/account_storage_service.dart';

const Color _green = Color(0xFF1FD58B);
const Color _dark = Color(0xFF1D2740);
const Color _muted = Color(0xFF8B9AB0);

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();

  SavedPaymentCard _savedCard = const SavedPaymentCard();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  Future<void> _loadCard() async {
    final savedCard = await AccountStorageService.loadPaymentCard();
    if (!mounted) return;

    _savedCard = savedCard;
    _cardHolderController.text = savedCard.cardHolder;
    _expiryController.text = savedCard.expiry;
    setState(() => _isLoading = false);
  }

  String? _validateCardHolder(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'Please enter the card holder name';
    }
    return null;
  }

  String? _validateCardNumber(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 16) return 'Card number must be 16 digits';
    return null;
  }

  String? _validateExpiry(String? value) {
    final expiry = value?.trim() ?? '';
    if (!RegExp(r'^(0[1-9]|1[0-2])/\d{2}$').hasMatch(expiry)) {
      return 'Use MM/YY format';
    }
    return null;
  }

  Future<void> _saveCard() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final digits = _cardNumberController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final savedCard = SavedPaymentCard(
      cardHolder: _cardHolderController.text.trim(),
      lastFourDigits: digits.substring(digits.length - 4),
      expiry: _expiryController.text.trim(),
    );
    await AccountStorageService.savePaymentCard(savedCard);

    if (!mounted) return;

    setState(() {
      _savedCard = savedCard;
      _cardNumberController.clear();
      _isSaving = false;
    });
    showAuthSnackBar(context, 'Payment method saved');
  }

  Future<void> _removeCard() async {
    await AccountStorageService.clearPaymentCard();
    if (!mounted) return;

    setState(() {
      _savedCard = const SavedPaymentCard();
      _cardHolderController.clear();
      _cardNumberController.clear();
      _expiryController.clear();
    });
    showAuthSnackBar(context, 'Saved card removed');
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
          if (_savedCard.hasSavedCard) ...[
            _SavedCardPanel(card: _savedCard, onRemove: _removeCard),
            const SizedBox(height: 16),
          ] else
            const _EmptyCardPanel(),
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
                        const AuthFieldTitle('Card Holder'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cardHolderController,
                          textCapitalization: TextCapitalization.words,
                          decoration: authFieldDecoration(
                            hintText: 'Name on card',
                            icon: Icons.badge_outlined,
                          ),
                          validator: _validateCardHolder,
                        ),
                        const SizedBox(height: 16),
                        const AuthFieldTitle('Card Number'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cardNumberController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                          ],
                          decoration: authFieldDecoration(
                            hintText: '16 digit card number',
                            icon: Icons.credit_card_rounded,
                          ),
                          validator: _validateCardNumber,
                        ),
                        const SizedBox(height: 16),
                        const AuthFieldTitle('Expiry'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _expiryController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9/]'),
                            ),
                            LengthLimitingTextInputFormatter(5),
                          ],
                          decoration: authFieldDecoration(
                            hintText: 'MM/YY',
                            icon: Icons.event_outlined,
                          ),
                          validator: _validateExpiry,
                        ),
                        const SizedBox(height: 22),
                        AuthPrimaryButton(
                          label: 'Save Card',
                          isLoading: _isSaving,
                          onPressed: _saveCard,
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
            child: const Icon(Icons.credit_card_outlined, color: _green),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Methods',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Saved cards and wallet',
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

class _SavedCardPanel extends StatelessWidget {
  const _SavedCardPanel({required this.card, required this.onRemove});

  final SavedPaymentCard card;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF12233E), Color(0xFF233B63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Saved Card',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onRemove,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Remove'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            card.maskedNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            card.cardHolder,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            'Expiry ${card.expiry}',
            style: const TextStyle(color: Color(0xFFAFBED6), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _EmptyCardPanel extends StatelessWidget {
  const _EmptyCardPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration,
      child: const Column(
        children: [
          Icon(Icons.credit_card_off_outlined, size: 36, color: _muted),
          SizedBox(height: 12),
          Text(
            'No saved card yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add a card below to make checkout faster next time. Only masked card details are stored on this device.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _muted, height: 1.5),
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
