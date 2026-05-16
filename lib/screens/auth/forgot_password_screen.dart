import 'package:flutter/material.dart';

import 'package:shree/screens/auth/auth_shared.dart';
import 'package:shree/services/auth_service.dart';

import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.isAdmin = false});

  final bool isAdmin;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await AuthService.sendPasswordResetEmail(_emailController.text);
      if (!mounted) return;

      setState(() => _emailSent = true);
      showAuthSnackBar(
        context,
        'Password reset email sent. Please check your inbox.',
      );
    } on AuthFailure catch (error) {
      if (!mounted) return;
      showAuthSnackBar(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      showAuthSnackBar(
        context,
        'We could not send the reset email right now. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen(isAdmin: widget.isAdmin)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenScaffold(
      title: widget.isAdmin ? 'Reset Admin Access' : 'Forgot Password',
      subtitle: widget.isAdmin
          ? 'Enter your registered admin email and we will send a secure reset link.'
          : 'Enter your registered email and we will send a secure reset link to get you back in.',
      icon: widget.isAdmin
          ? Icons.admin_panel_settings_outlined
          : Icons.lock_reset_rounded,
      showAccentDot: false,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FBFF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE1E8F2)),
              ),
              child: Text(
                widget.isAdmin
                    ? 'Use the same admin email you sign in with. The reset link will be sent only to that inbox.'
                    : 'Use the same email address linked to your Shree Perfume account. The reset link will arrive in your inbox.',
                style: const TextStyle(
                  fontSize: 13,
                  color: authMutedColor,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 22),
            AuthFieldTitle(widget.isAdmin ? 'Admin Email' : 'Email Address'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: AuthValidators.validateEmail,
              onFieldSubmitted: (_) => _sendResetLink(),
              decoration: authFieldDecoration(
                hintText: widget.isAdmin
                    ? 'admin@shree.com'
                    : 'name@example.com',
                icon: Icons.mail_outline_rounded,
              ),
            ),
            if (_emailSent) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFFFF8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBCEBD3)),
                ),
                child: Text(
                  'Reset link sent to ${_emailController.text.trim()}. Check your inbox and spam folder if needed.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF317252),
                    height: 1.45,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            AuthPrimaryButton(
              label: widget.isAdmin
                  ? 'Send Admin Reset Link'
                  : 'Send Reset Link',
              isLoading: _isLoading,
              onPressed: _sendResetLink,
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
                        ? 'Remember your admin password?'
                        : 'Remember your password?',
                    style: const TextStyle(color: authMutedColor, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: _goToLogin,
                    child: const Text(
                      'Sign In',
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
                      builder: (_) =>
                          ForgotPasswordScreen(isAdmin: !widget.isAdmin),
                    ),
                  );
                },
                child: Text(
                  widget.isAdmin
                      ? 'Back to customer recovery'
                      : 'Admin password help',
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
