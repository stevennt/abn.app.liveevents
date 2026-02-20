import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/vision_os_colors.dart';
import '../../../core/themes/vision_os_typography.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../state/auth_state.dart';

class OneIdLoginSheet extends StatefulWidget {
  const OneIdLoginSheet({super.key, this.onLoggedIn});

  final VoidCallback? onLoggedIn;

  static Future<bool?> show(BuildContext context, {VoidCallback? onLoggedIn}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OneIdLoginSheet(onLoggedIn: onLoggedIn),
    );
  }

  @override
  State<OneIdLoginSheet> createState() => _OneIdLoginSheetState();
}

class _OneIdLoginSheetState extends State<OneIdLoginSheet> {
  final _identifierController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSignupMode = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final authState = context.read<AuthState>();

    final success = _isSignupMode
        ? await authState.register(
            email: _emailController.text.trim(),
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
          )
        : await authState.login(
            identifier: _identifierController.text.trim(),
            password: _passwordController.text,
          );

    if (!mounted) {
      return;
    }

    if (success) {
      widget.onLoggedIn?.call();
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSignupMode
                ? 'OneID account created and signed in.'
                : 'Logged in with OneID.',
          ),
        ),
      );
      return;
    }

    final message = authState.errorMessage ?? 'Unable to continue.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _toggleMode() {
    setState(() {
      _isSignupMode = !_isSignupMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, bottomInset + 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isSignupMode ? 'OneID Signup' : 'OneID Login',
                style: VisionOSTypography.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                _isSignupMode
                    ? 'Create an account and link your submitted events.'
                    : 'Use your OneID account to manage submitted events.',
                style: VisionOSTypography.bodySmall,
              ),
              const SizedBox(height: 16),
              if (_isSignupMode) ...[
                GlassTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  controller: _usernameController,
                  labelText: 'Username',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  controller: _fullNameController,
                  labelText: 'Full name (optional)',
                ),
                const SizedBox(height: 12),
              ] else ...[
                GlassTextField(
                  controller: _identifierController,
                  labelText: 'Email or username',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Identifier is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],
              GlassTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (_isSignupMode && value.length < 6) {
                    return 'Use at least 6 characters';
                  }
                  return null;
                },
                suffix: const Icon(Icons.lock_outline, size: 18),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: VisionOSColors.accentBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _isSignupMode
                      ? 'Signup uses OneID registration and then logs you in automatically.'
                      : 'No account yet? Switch to signup below.',
                  style: VisionOSTypography.captionStrong,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: authState.isLoading
                          ? (_isSignupMode ? 'Creating...' : 'Signing in...')
                          : (_isSignupMode ? 'Create Account' : 'Sign In'),
                      icon: _isSignupMode
                          ? Icons.person_add_alt_1
                          : Icons.login,
                      onPressed: authState.isLoading ? null : _submit,
                      expand: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassButton(
                      label: 'Continue Guest',
                      isPrimary: false,
                      icon: Icons.person_outline,
                      onPressed: () => Navigator.of(context).pop(false),
                      expand: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isSignupMode
                        ? 'Already have OneID? Sign in'
                        : 'Need OneID? Create account',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
