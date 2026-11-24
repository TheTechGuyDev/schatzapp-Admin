import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/breakpoints.dart';
import '../../core/session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ui.dart';

/// Admin sign in: email + password, then a 6-digit authenticator code.
/// UI phase: any details are accepted.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  final _codeFocus = FocusNode();
  bool _step2 = false;
  bool _hide = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _code.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_email.text.contains('@') || _password.text.isEmpty) {
      setState(() => _error = 'Enter your admin email and password.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _busy = false;
      _step2 = true;
    });
    _codeFocus.requestFocus();
  }

  Future<void> _verify() async {
    if (_code.text.length != 6) {
      setState(
        () => _error = 'Enter the 6-digit code from your authenticator app.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    AdminSession.instance.signIn();
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final phone = Breakpoints.of(context) == ScreenSize.phone;
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final form = Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(phone ? 20 : 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!wide) ...[
                const _Brand(dark: false),
                const SizedBox(height: 30),
              ],
              Text(
                _step2 ? 'Two-step verification' : 'Admin sign in',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _step2
                    ? 'Enter the 6-digit code from your authenticator app.'
                    : 'Sign in with your SchatzApp administrator account.',
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 26),
              if (!_step2) ...[
                const _Label('Email address'),
                _Field(
                  controller: _email,
                  hint: 'admin@schatzapp.com',
                  icon: Icons.mail_outline_rounded,
                  onSubmit: _continue,
                ),
                const SizedBox(height: 16),
                const _Label('Password'),
                _Field(
                  controller: _password,
                  hint: 'Your password',
                  icon: Icons.lock_outline_rounded,
                  obscure: _hide,
                  onSubmit: _continue,
                  suffix: IconButton(
                    onPressed: () => setState(() => _hide = !_hide),
                    icon: Icon(
                      _hide
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: LinkText(
                    'Forgot password?',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          'Password resets are handled by a Super Administrator.',
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                _CodeBoxes(
                  controller: _code,
                  focus: _codeFocus,
                  onDone: _verify,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    LinkText('Use a recovery code', onTap: () {}),
                    const Spacer(),
                    LinkText(
                      'Back',
                      onTap: () => setState(() {
                        _step2 = false;
                        _code.clear();
                        _error = null;
                      }),
                    ),
                  ],
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.danger,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                height: 46,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _busy ? null : (_step2 ? _verify : _continue),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _step2 ? 'Verify & Sign In' : 'Continue',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brandSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 17,
                      color: AppColors.brand,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Admin accounts are separate from app accounts. Every sign-in is recorded.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.brandDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Preview: any email, password and 6 digits will sign you in.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: wide
          ? Row(
              children: [
                const Expanded(flex: 5, child: _BrandPanel()),
                Expanded(flex: 6, child: form),
              ],
            )
          : SafeArea(child: form),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.onSubmit,
    this.obscure = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final VoidCallback onSubmit;
  final bool obscure;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onSubmitted: (_) => onSubmit(),
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13.5, color: AppColors.textMuted),
        prefixIcon: Icon(icon, size: 19, color: AppColors.textSecondary),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.4),
        ),
      ),
    );
  }
}

class _CodeBoxes extends StatefulWidget {
  const _CodeBoxes({
    required this.controller,
    required this.focus,
    required this.onDone,
  });
  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onDone;

  @override
  State<_CodeBoxes> createState() => _CodeBoxesState();
}

class _CodeBoxesState extends State<_CodeBoxes> {
  @override
  Widget build(BuildContext context) {
    final code = widget.controller.text;
    return Stack(
      children: [
        Row(
          children: [
            for (var i = 0; i < 6; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.focus.requestFocus(),
                  child: Container(
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: i == code.length && widget.focus.hasFocus
                            ? AppColors.brand
                            : AppColors.border,
                        width: i == code.length ? 1.6 : 1,
                      ),
                    ),
                    child: Text(
                      i < code.length ? code[i] : '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focus,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) {
                setState(() {});
                if (v.length == 6) widget.onDone();
              },
              decoration: const InputDecoration(counterText: ''),
            ),
          ),
        ),
      ],
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            gradient: dark
                ? null
                : const LinearGradient(
                    colors: [Color(0xFF7B4DFF), Color(0xFF5B2BE0)],
                  ),
            color: dark ? Colors.white.withValues(alpha: 0.15) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset('assets/images/logo_white.png'),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SchatzApp',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: dark ? Colors.white : AppColors.text,
              ),
            ),
            Text(
              'Admin Panel',
              style: TextStyle(
                fontSize: 12,
                color: dark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6D3BF0), Color(0xFF4A1FC4), Color(0xFF2E1380)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Brand(dark: true),
          const Spacer(),
          const Text(
            'Manage, monitor and protect SchatzApp.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Users, wallets, gift cards, investigations and compliance in one secure place.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          for (final f in const [
            (
              Icons.admin_panel_settings_outlined,
              'Role-based access for every admin',
            ),
            (
              Icons.verified_user_outlined,
              'Authenticator verification on sign-in',
            ),
            (
              Icons.history_rounded,
              'Every action recorded in a tamper-resistant log',
            ),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(f.$1, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    f.$2,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  ),
                ],
              ),
            ),
          const Spacer(),
          const Text(
            '© 2026 SchatzApp. Authorised personnel only.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
