import 'package:flutter/material.dart';

import 'package:shree/models/user_model.dart';
import 'package:shree/screens/account/orders_screen.dart';
import 'package:shree/screens/account/payment_methods_screen.dart';
import 'package:shree/screens/account/personal_info_screen.dart';
import 'package:shree/screens/account/preferences_screen.dart';
import 'package:shree/screens/auth/login_screen.dart';
import 'package:shree/screens/widgets/wishlist_action_button.dart';
import 'package:shree/screens/wishlist/wishlist_screen.dart';
import 'package:shree/services/auth_service.dart';

const Color _green = Color(0xFF1FD58B);
const Color _dark = Color(0xFF1D2740);
const Color _muted = Color(0xFF8B9AB0);

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late Future<AppUser?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  void _refreshProfile() {
    _profileFuture = AuthService.currentUserProfile();
  }

  Future<void> _openScreen(BuildContext context, Widget screen) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );

    if (result == true && mounted) {
      setState(_refreshProfile);
    }
  }

  Future<void> _handleSignOut() async {
    await AuthService.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleSignOut();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'Shree Perfume',
              style: TextStyle(
                color: _dark,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              WishlistActionButton(
                onTap: () => _openScreen(context, const WishlistScreen()),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              children: [
                _AccountHeader(user: user),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Account Menu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _dark,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _MenuTile(
                  icon: Icons.inventory_2_outlined,
                  title: 'My Orders',
                  subtitle: 'Track, return, or buy again',
                  onTap: () => _openScreen(context, const OrdersScreen()),
                ),
                const SizedBox(height: 14),
                _MenuTile(
                  icon: Icons.favorite_border_rounded,
                  title: 'Wishlist',
                  subtitle: 'Items you saved for later',
                  onTap: () => _openScreen(context, const WishlistScreen()),
                ),
                const SizedBox(height: 14),
                _MenuTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Info',
                  subtitle: 'Manage your profile details',
                  onTap: () =>
                      _openScreen(context, PersonalInfoScreen(user: user)),
                ),
                const SizedBox(height: 14),
                _MenuTile(
                  icon: Icons.credit_card_outlined,
                  title: 'Payment Methods',
                  subtitle: 'Saved cards and wallet',
                  onTap: () =>
                      _openScreen(context, const PaymentMethodsScreen()),
                ),
                const SizedBox(height: 14),
                _MenuTile(
                  icon: Icons.tune_rounded,
                  title: 'Preferences',
                  subtitle: 'Language, currency, alerts',
                  onTap: () => _openScreen(context, const PreferencesScreen()),
                ),
                const SizedBox(height: 40),
                InkWell(
                  onTap: _confirmLogout,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.red),
                        SizedBox(width: 10),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.name.isNotEmpty == true
        ? user!.name
        : 'Shree Customer';
    final displayEmail = user?.email.isNotEmpty == true
        ? user!.email
        : 'Sign in to manage your fragrance profile';
    final displayRole = (user?.role ?? 'Customer').toUpperCase();
    final displayMemberSince = user?.memberSinceLabel ?? 'Now';

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBFEFD8), width: 4),
                color: const Color(0xFFFFF1DD),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 62,
                color: Color(0xFFC38C5E),
              ),
            ),
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _dark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          displayEmail,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: _muted),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEAFBF5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                displayRole,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _green,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Since $displayMemberSince',
              style: const TextStyle(fontSize: 14, color: _muted),
            ),
          ],
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEDF2F8)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x080B1B34),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFFFF8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _green),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
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
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFA0AEC0)),
            ],
          ),
        ),
      ),
    );
  }
}
