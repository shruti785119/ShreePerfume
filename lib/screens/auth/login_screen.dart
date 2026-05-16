import 'package:flutter/material.dart';
import 'package:shree/core/session_manager.dart';
import 'package:shree/screens/auth/auth_shared.dart';
import 'package:shree/screens/navigation/main_navigation.dart';
import 'package:shree/screens/admin/admin_home.dart';
import 'package:shree/services/auth_service.dart';

import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.isAdmin = false});

  final bool isAdmin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  SessionRole get _targetRole {
    return widget.isAdmin ? SessionRole.admin : SessionRole.user;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

Future<void> _login() async {
  final isValid = _formKey.currentState?.validate() ?? false;
  if (!isValid) return;

  FocusScope.of(context).unfocus();
  setState(() => _isLoading = true);

  try {
    await AuthService.login(
      email: _emailController.text,
      password: _passwordController.text,
      expectedRole: _targetRole,
    );

    ///   SAVE SESSION
    await SessionManager.saveLogin(_targetRole);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            widget.isAdmin ? const AdminHome() : const MainNavigation(),
      ),
      (route) => false,
    );

  } on AuthFailure catch (error) {
    if (!mounted) return;
    showAuthSnackBar(context, error.message, isError: true);
  } catch (_) {
    if (!mounted) return;
    showAuthSnackBar(
      context,
      'Something went wrong while signing in. Please try again.',
      isError: true,
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return AuthScreenScaffold(
      title: widget.isAdmin ? 'Admin Login' : 'Welcome Back',
      subtitle: widget.isAdmin
          ? 'Sign in with your Firebase admin account to manage the store.'
          : 'Sign in with your Firebase customer account to continue shopping.',
      icon: widget.isAdmin
          ? Icons.security_rounded
          : Icons.person_outline_rounded,
      showAccentDot: false,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthFieldTitle(widget.isAdmin ? 'Admin Email' : 'Email Address'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.validateEmail,
              decoration: authFieldDecoration(
                hintText: widget.isAdmin
                    ? 'admin@shree.com'
                    : 'name@example.com',
                icon: Icons.mail_outline_rounded,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: AuthFieldTitle('Password')),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ForgotPasswordScreen(isAdmin: widget.isAdmin),
                            ),
                          );
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: authPrimaryGreen,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    widget.isAdmin ? 'Reset Access?' : 'Forgot Password?',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              validator: AuthValidators.validatePassword,
              onFieldSubmitted: (_) => _login(),
              decoration: authFieldDecoration(
                hintText: 'Enter your password',
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: authMutedColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.isAdmin
                  ? 'Admin accounts can only sign in from the admin portal.'
                  : 'Customer accounts can only sign in from the customer portal.',
              style: const TextStyle(
                fontSize: 13,
                color: authMutedColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            AuthPrimaryButton(
              label: widget.isAdmin ? 'Admin Sign In' : 'Sign In',
              isLoading: _isLoading,
              onPressed: _login,
            ),
            const SizedBox(height: 40),
            Container(height: 1, color: const Color(0xFFEAF0F6)),
            const SizedBox(height: 24),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  Text(
                    widget.isAdmin
                        ? 'Need an admin account?'
                        : 'New to Shree Perfume?',
                    style: const TextStyle(color: authMutedColor, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RegisterScreen(isAdmin: widget.isAdmin),
                        ),
                      );
                    },
                    child: const Text(
                      'Create account',
                      style: TextStyle(
                        color: authPrimaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(isAdmin: !widget.isAdmin),
                    ),
                  );
                },
                child: Text(
                  widget.isAdmin ? 'Back to customer login' : 'Admin sign in',
                  style: const TextStyle(
                    color: authPrimaryGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
