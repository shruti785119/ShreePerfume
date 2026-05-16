// screens/cart/checkout_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shree/core/app_state.dart';
import 'package:shree/screens/auth/auth_shared.dart';
import 'package:shree/screens/widgets/brand_background.dart';
import 'package:shree/theme/app_theme.dart';

enum _PaymentMethod { card, cashOnDelivery }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _noteController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  _PaymentMethod _paymentMethod = _PaymentMethod.card;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _noteController.dispose();
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String label) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter $label';
    return null;
  }

  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 'Please enter your phone number';
    if (digits.length < 10) return 'Phone number must be at least 10 digits';
    return null;
  }

  String? _validatePostalCode(String? value) {
    final postalCode = value?.trim() ?? '';
    if (postalCode.isEmpty) return 'Please enter your postal code';
    if (!RegExp(r'^[A-Za-z0-9 -]{4,10}$').hasMatch(postalCode)) {
      return 'Please enter a valid postal code';
    }
    return null;
  }

  String? _validateCardNumber(String? value) {
    if (_paymentMethod != _PaymentMethod.card) return null;
    final digits = (value ?? '').replaceAll(' ', '');
    if (digits.isEmpty) return 'Please enter your card number';
    if (!RegExp(r'^\d{16}$').hasMatch(digits)) {
      return 'Card number must be 16 digits';
    }
    return null;
  }

  String? _validateExpiry(String? value) {
    if (_paymentMethod != _PaymentMethod.card) return null;
    final expiry = value?.trim() ?? '';
    if (expiry.isEmpty) return 'Please enter expiry date';
    if (!RegExp(r'^(0[1-9]|1[0-2])/\d{2}$').hasMatch(expiry)) {
      return 'Use MM/YY format';
    }
    return null;
  }

  String? _validateCvv(String? value) {
    if (_paymentMethod != _PaymentMethod.card) return null;
    final cvv = value?.trim() ?? '';
    if (cvv.isEmpty) return 'Please enter CVV';
    if (!RegExp(r'^\d{3,4}$').hasMatch(cvv)) {
      return 'CVV must be 3 or 4 digits';
    }
    return null;
  }

  Future<void> _placeOrder() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    final digits = _cardNumberController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final paymentLabel = _paymentMethod == _PaymentMethod.card
        ? 'Card ending ${digits.substring(digits.length - 4)}'
        : 'Cash on delivery';

    final currentUser = FirebaseAuth.instance.currentUser;
    final customerEmail = currentUser?.email?.trim().toLowerCase() ??
        _emailController.text.trim().toLowerCase();

    AppState.instance.placeOrder(
      customerName: _fullNameController.text.trim(),
      shippingAddress: _addressController.text.trim(),
      city: _cityController.text.trim(),
      paymentLabel: paymentLabel,
      customerId: currentUser?.uid,
      customerEmail: customerEmail,
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final entries = appState.cartEntries;
        final subtotal = appState.subtotal;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text('Shree Perfume'),
          ),
          body: BrandBackground(
            child: SafeArea(
              top: false,
              child: entries.isEmpty
                  ? const _EmptyCheckout()
                  : Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: AppTheme.heroGradient,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'SECURE CHECKOUT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Complete Your Order',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${appState.cartItemCount} items ready to ship. Review your details and place the order with confidence.',
                                    style: const TextStyle(
                                      color: Color(0xFFD5DCE8),
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      _HeroPill(
                                        icon: Icons.shopping_bag_outlined,
                                        label:
                                            '${appState.cartItemCount} items',
                                      ),
                                      const SizedBox(width: 10),
                                      _HeroPill(
                                        icon: Icons.verified_user_outlined,
                                        label:
                                            '\$${subtotal.toStringAsFixed(2)} total',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            _SectionCard(
                              title: 'Contact Details',
                              subtitle:
                                  'Order updates and delivery support will be sent here.',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AuthFieldTitle('Full Name'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _fullNameController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: authFieldDecoration(
                                      hintText: 'Enter your full name',
                                      icon: Icons.person_outline_rounded,
                                    ),
                                    validator: AuthValidators.validateName,
                                  ),
                                  const SizedBox(height: 16),
                                  const AuthFieldTitle('Email Address'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: authFieldDecoration(
                                      hintText: 'Enter your email address',
                                      icon: Icons.mail_outline_rounded,
                                    ),
                                    validator: AuthValidators.validateEmail,
                                  ),
                                  const SizedBox(height: 16),
                                  const AuthFieldTitle('Phone Number'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9+ -]'),
                                      ),
                                      LengthLimitingTextInputFormatter(17),
                                    ],
                                    decoration: authFieldDecoration(
                                      hintText: 'Enter your phone number',
                                      icon: Icons.phone_outlined,
                                    ),
                                    validator: _validatePhone,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: 'Delivery Address',
                              subtitle:
                                  'A complete address helps us avoid delivery delays.',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AuthFieldTitle('Street Address'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _addressController,
                                    maxLines: 2,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: authFieldDecoration(
                                      hintText: 'House number, street, area',
                                      icon: Icons.location_on_outlined,
                                    ),
                                    validator: (value) => _validateRequired(
                                      value,
                                      'your address',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const AuthFieldTitle('City'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _cityController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: authFieldDecoration(
                                      hintText: 'Enter your city',
                                      icon: Icons.location_city_outlined,
                                    ),
                                    validator: (value) =>
                                        _validateRequired(value, 'your city'),
                                  ),
                                  const SizedBox(height: 16),
                                  const AuthFieldTitle('State'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _stateController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: authFieldDecoration(
                                      hintText: 'Enter your state',
                                      icon: Icons.map_outlined,
                                    ),
                                    validator: (value) =>
                                        _validateRequired(value, 'your state'),
                                  ),
                                  const SizedBox(height: 16),
                                  const AuthFieldTitle('Postal Code'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _postalCodeController,
                                    decoration: authFieldDecoration(
                                      hintText: 'Enter your postal code',
                                      icon: Icons.markunread_mailbox_outlined,
                                    ),
                                    validator: _validatePostalCode,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: 'Payment Method',
                              subtitle:
                                  'Choose your preferred option. Card details are validated before order placement.',
                              child: Column(
                                children: [
                                  _PaymentChoice(
                                    title: 'Credit or Debit Card',
                                    subtitle:
                                        'Fastest checkout with secure card payment.',
                                    icon: Icons.credit_card_rounded,
                                    selected:
                                        _paymentMethod == _PaymentMethod.card,
                                    onTap: () => setState(
                                      () =>
                                          _paymentMethod = _PaymentMethod.card,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _PaymentChoice(
                                    title: 'Cash on Delivery',
                                    subtitle:
                                        'Pay once the order reaches your doorstep.',
                                    icon: Icons.payments_outlined,
                                    selected:
                                        _paymentMethod ==
                                        _PaymentMethod.cashOnDelivery,
                                    onTap: () => setState(
                                      () => _paymentMethod =
                                          _PaymentMethod.cashOnDelivery,
                                    ),
                                  ),
                                  if (_paymentMethod ==
                                      _PaymentMethod.card) ...[
                                    const SizedBox(height: 18),
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: AuthFieldTitle('Card Holder Name'),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _cardHolderController,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      decoration: authFieldDecoration(
                                        hintText: 'Name on the card',
                                        icon: Icons.badge_outlined,
                                      ),
                                      validator: (value) => _validateRequired(
                                        value,
                                        'the card holder name',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: AuthFieldTitle('Card Number'),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _cardNumberController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9 ]'),
                                        ),
                                        LengthLimitingTextInputFormatter(19),
                                      ],
                                      decoration: authFieldDecoration(
                                        hintText: '1234 5678 9012 3456',
                                        icon: Icons.credit_card_outlined,
                                      ),
                                      validator: _validateCardNumber,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const AuthFieldTitle('Expiry'),
                                              const SizedBox(height: 8),
                                              TextFormField(
                                                controller: _expiryController,
                                                keyboardType:
                                                    TextInputType.datetime,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(
                                                    RegExp(r'[0-9/]'),
                                                  ),
                                                  LengthLimitingTextInputFormatter(
                                                    5,
                                                  ),
                                                ],
                                                decoration: authFieldDecoration(
                                                  hintText: 'MM/YY',
                                                  icon: Icons
                                                      .calendar_today_outlined,
                                                ),
                                                validator: _validateExpiry,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const AuthFieldTitle('CVV'),
                                              const SizedBox(height: 8),
                                              TextFormField(
                                                controller: _cvvController,
                                                keyboardType:
                                                    TextInputType.number,
                                                obscureText: true,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                    4,
                                                  ),
                                                ],
                                                decoration: authFieldDecoration(
                                                  hintText: '123',
                                                  icon: Icons.lock_outline,
                                                ),
                                                validator: _validateCvv,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: 'Special Instructions',
                              subtitle:
                                  'Optional notes for packaging, gifting, or delivery timing.',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AuthFieldTitle('Order Note'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _noteController,
                                    maxLines: 3,
                                    decoration: authFieldDecoration(
                                      hintText:
                                          'Add any extra delivery or gifting note',
                                      icon: Icons.edit_note_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4FFF8),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFDDF5E7),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Order Summary',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${appState.cartItemCount} items ready for dispatch',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: AppTheme.mutedTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  for (final entry in entries) ...[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          child: SizedBox(
                                            width: 64,
                                            height: 64,
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                entry.product.image.isNotEmpty
                                                    ? Image.asset(
                                                        entry.product.image,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return const ColoredBox(
                                                            color: Color(0xFFF4F7FB),
                                                          );
                                                        },
                                                      )
                                                    : const ColoredBox(
                                                        color: Color(0xFFF4F7FB),
                                                      ),
                                                ColoredBox(
                                                  color: entry.product.overlay,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.product.title,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.textColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${entry.product.category} - Qty ${entry.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  color:
                                                      AppTheme.mutedTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '₹${entry.totalPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                  const Divider(
                                    height: 24,
                                    color: Color(0xFFDCEEE3),
                                  ),
                                  _SummaryLine(
                                    label: 'Subtotal',
                                    value: '₹${subtotal.toStringAsFixed(2)}',
                                  ),
                                  const SizedBox(height: 10),
                                  const _SummaryLine(
                                    label: 'Shipping',
                                    value: 'Free',
                                  ),
                                  const SizedBox(height: 10),
                                  const _SummaryLine(
                                    label: 'Taxes',
                                    value: 'Calculated at delivery',
                                  ),
                                  const SizedBox(height: 18),
                                  const Divider(
                                    height: 24,
                                    color: Color(0xFFDCEEE3),
                                  ),
                                  _SummaryLine(
                                    label: 'Amount Payable',
                                    value: '₹${subtotal.toStringAsFixed(2)}',
                                    emphasized: true,
                                  ),
                                  const SizedBox(height: 18),
                                  AuthPrimaryButton(
                                    label: 'Place Order',
                                    isLoading: _isSubmitting,
                                    onPressed: _placeOrder,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120B1B34),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.mutedTextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _PaymentChoice extends StatelessWidget {
  const _PaymentChoice({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFFFF8) : const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.primaryColor : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: selected
                    ? AppTheme.primaryColor
                    : AppTheme.mutedTextColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.mutedTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppTheme.primaryColor : AppTheme.mutedTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: emphasized ? 15 : 14,
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
            color: AppTheme.mutedTextColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasized ? 16 : 14.5,
            fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }
}

class _EmptyCheckout extends StatelessWidget {
  const _EmptyCheckout();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFFFF8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppTheme.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add a few perfumes to your cart before starting checkout.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.mutedTextColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Return to Cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
