import 'package:flutter/material.dart';
import 'package:shree/core/session_manager.dart';
import 'package:shree/screens/auth/auth_shared.dart';
// import 'package:shree/screens/home/home_screen.dart';
// import 'package:shree/screens/admin/admin_dashboard.dart';
// import 'package:shree/screens/navigation/main_navigation.dart';
import 'package:shree/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.isAdmin = false});

  final bool isAdmin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  SessionRole get _targetRole {
    return widget.isAdmin ? SessionRole.admin : SessionRole.user;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

Future<void> _register() async {
  final isValid = _formKey.currentState?.validate() ?? false;
  if (!isValid) return;

  FocusScope.of(context).unfocus();
  setState(() => _isLoading = true);

  try {
    await AuthService.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: _targetRole,
    );

    /// 🔥 VERY IMPORTANT (Firebase auto login fix)
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    /// ✅ GO TO LOGIN SCREEN (NOT HOME)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(isAdmin: widget.isAdmin),
      ),
    );

  } on AuthFailure catch (error) {
    if (!mounted) return;
    showAuthSnackBar(context, error.message, isError: true);
  } catch (_) {
    if (!mounted) return;
    showAuthSnackBar(
      context,
      'Something went wrong while creating your account.',
      isError: true,
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}


//   Future<void> _register() async {
//     final isValid = _formKey.currentState?.validate() ?? false;
//     if (!isValid) return;

//     FocusScope.of(context).unfocus();
//     setState(() => _isLoading = true);

//     try {
//       await AuthService.register(
//         name: _nameController.text,
//         email: _emailController.text,
//         password: _passwordController.text,
//         role: _targetRole,
//       );

//       if (!mounted) return;
//     Navigator.pushAndRemoveUntil(
//   context,
//   MaterialPageRoute(
//     builder: (_) =>
//         widget.isAdmin
//             ? AdminDashboard(
//                 onNavigate: (index) {},
//                 onOpenProductTab: (index) {},
//               )
//             : const MainNavigation(),
//   ),
//   (route) => false,
// );
//     } on AuthFailure catch (error) {
//       if (!mounted) return;
//       showAuthSnackBar(context, error.message, isError: true);
//     } catch (_) {
//       if (!mounted) return;
//       showAuthSnackBar(
//         context,
//         'Something went wrong while creating your account. Please try again.',
//         isError: true,
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

  @override
  Widget build(BuildContext context) {
    return AuthScreenScaffold(
      title: widget.isAdmin ? 'Create Admin Account' : 'Create Account',
      subtitle: widget.isAdmin
          ? 'Create a secure Firebase-backed admin profile for your management team.'
          : 'Register a new Firebase-backed customer account with the same premium experience.',
      icon: widget.isAdmin ? Icons.admin_panel_settings_outlined : Icons.person_add_alt_1_rounded,
      showAccentDot: true,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthFieldTitle('Full Name'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              validator: AuthValidators.validateName,
              decoration: authFieldDecoration(
                hintText: 'Enter your full name',
                icon: Icons.person_outline_rounded,
              ),
            ),
            const SizedBox(height: 20),
            AuthFieldTitle(widget.isAdmin ? 'Admin Email' : 'Email Address'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.validateEmail,
              decoration: authFieldDecoration(
                hintText: widget.isAdmin ? 'admin@shree.com' : 'name@example.com',
                icon: Icons.mail_outline_rounded,
              ),
            ),
            const SizedBox(height: 20),
            const AuthFieldTitle('Password'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.validatePassword,
              decoration: authFieldDecoration(
                hintText: 'Minimum 8 characters',
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
            const SizedBox(height: 12),
            const Text(
              'Use at least 8 characters with uppercase, lowercase, and a number.',
              style: TextStyle(
                fontSize: 13,
                color: authMutedColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            const AuthFieldTitle('Confirm Password'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              validator: (value) {
                return AuthValidators.validateConfirmPassword(
                  value,
                  _passwordController.text,
                );
              },
              onFieldSubmitted: (_) => _register(),
              decoration: authFieldDecoration(
                hintText: 'Repeat your password',
                icon: Icons.verified_user_outlined,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: authMutedColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            AuthPrimaryButton(
              label: widget.isAdmin ? 'Create Admin' : 'Create Account',
              isLoading: _isLoading,
              onPressed: _register,
            ),
            const SizedBox(height: 40),
            Container(height: 1, color: const Color(0xFFEAF0F6)),
            const SizedBox(height: 24),
            Center(
              child: Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    widget.isAdmin
                        ? 'Already registered as admin?'
                        : 'Already have an account?',
                    style: const TextStyle(fontSize: 14, color: authMutedColor),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: authPrimaryGreen,
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
                      builder: (_) => RegisterScreen(isAdmin: !widget.isAdmin),
                    ),
                  );
                },
                child: Text(
                  widget.isAdmin
                      ? 'Back to customer registration'
                      : 'Create admin account',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: authPrimaryGreen,
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
