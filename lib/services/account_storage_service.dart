import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AccountProfileDraft {
  const AccountProfileDraft({
    this.phone = '',
    this.city = '',
    this.address = '',
  });

  final String phone;
  final String city;
  final String address;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'phone': phone, 'city': city, 'address': address};
  }

  factory AccountProfileDraft.fromJson(Map<String, dynamic> json) {
    return AccountProfileDraft(
      phone: json['phone'] as String? ?? '',
      city: json['city'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }
}

class SavedPaymentCard {
  const SavedPaymentCard({
    this.cardHolder = '',
    this.lastFourDigits = '',
    this.expiry = '',
  });

  final String cardHolder;
  final String lastFourDigits;
  final String expiry;

  bool get hasSavedCard => lastFourDigits.isNotEmpty;

  String get maskedNumber =>
      hasSavedCard ? '**** **** **** $lastFourDigits' : '';

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'cardHolder': cardHolder,
      'lastFourDigits': lastFourDigits,
      'expiry': expiry,
    };
  }

  factory SavedPaymentCard.fromJson(Map<String, dynamic> json) {
    return SavedPaymentCard(
      cardHolder: json['cardHolder'] as String? ?? '',
      lastFourDigits: json['lastFourDigits'] as String? ?? '',
      expiry: json['expiry'] as String? ?? '',
    );
  }
}

class AccountPreferencesData {
  const AccountPreferencesData({
    this.language = 'English',
    this.currency = 'USD',
    this.orderAlerts = true,
    this.promotionalAlerts = true,
    this.wishlistAlerts = true,
  });

  final String language;
  final String currency;
  final bool orderAlerts;
  final bool promotionalAlerts;
  final bool wishlistAlerts;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'language': language,
      'currency': currency,
      'orderAlerts': orderAlerts,
      'promotionalAlerts': promotionalAlerts,
      'wishlistAlerts': wishlistAlerts,
    };
  }

  factory AccountPreferencesData.fromJson(Map<String, dynamic> json) {
    return AccountPreferencesData(
      language: json['language'] as String? ?? 'English',
      currency: json['currency'] as String? ?? 'USD',
      orderAlerts: json['orderAlerts'] as bool? ?? true,
      promotionalAlerts: json['promotionalAlerts'] as bool? ?? true,
      wishlistAlerts: json['wishlistAlerts'] as bool? ?? true,
    );
  }
}

class AccountStorageService {
  AccountStorageService._();

  static const String _profileDraftKey = 'account.profileDraft';
  static const String _paymentCardKey = 'account.paymentCard';
  static const String _preferencesKey = 'account.preferences';

  static Future<AccountProfileDraft> loadProfileDraft() async {
    final prefs = await SharedPreferences.getInstance();
    return _readJson(prefs, _profileDraftKey, AccountProfileDraft.fromJson) ??
        const AccountProfileDraft();
  }

  static Future<void> saveProfileDraft(AccountProfileDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileDraftKey, jsonEncode(draft.toJson()));
  }

  static Future<SavedPaymentCard> loadPaymentCard() async {
    final prefs = await SharedPreferences.getInstance();
    return _readJson(prefs, _paymentCardKey, SavedPaymentCard.fromJson) ??
        const SavedPaymentCard();
  }

  static Future<void> savePaymentCard(SavedPaymentCard card) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paymentCardKey, jsonEncode(card.toJson()));
  }

  static Future<void> clearPaymentCard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_paymentCardKey);
  }

  static Future<AccountPreferencesData> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return _readJson(prefs, _preferencesKey, AccountPreferencesData.fromJson) ??
        const AccountPreferencesData();
  }

  static Future<void> savePreferences(AccountPreferencesData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferencesKey, jsonEncode(data.toJson()));
  }

  static T? _readJson<T>(
    SharedPreferences prefs,
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final rawValue = prefs.getString(key);
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is Map) {
        return fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}
