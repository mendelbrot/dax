import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dax/providers/auth_provider.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _codeSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendCode([String? _]) async {
    final authState = ref.read(authProvider);
    if (authState.isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authProvider.notifier).sendOTP(_emailController.text);

    if (!mounted) {
      return;
    }

    final newAuthState = ref.read(authProvider);
    if (newAuthState.errorMessage == null && _codeSent == false) {
      setState(() {
        _codeSent = true;
      });
    }
  }

  Future<void> _verifyCode([String? _]) async {
    final authState = ref.read(authProvider);
    if (authState.isLoading) {
      return;
    }

    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter the code')));
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyOTP(
      _emailController.text,
      _otpController.text,
    );

    if (!success && mounted) {
      // Need to read the latest error message
      final errorState = ref.read(authProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorState.errorMessage ?? 'Invalid code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 400,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_codeSent) ...[
                      Text(
                        'Sign In',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.send,
                        onFieldSubmitted: _sendCode,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _sendCode,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Send Code'),
                      ),
                      if (authState.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            authState.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ] else ...[
                      Text(
                        'Enter Code',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'We sent a 6-digit code to\n${_emailController.text}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: _verifyCode,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, letterSpacing: 8),
                        decoration: const InputDecoration(
                          labelText: 'Code',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _verifyCode,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Verify Code'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _codeSent = false;
                                _otpController.clear();
                              });
                              ref.read(authProvider.notifier).clearError();
                            },
                            child: const Text('Change Email'),
                          ),
                          TextButton(
                            onPressed: _sendCode,
                            child: const Text('Resend Code'),
                          ),
                        ],
                      ),
                      if (authState.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            authState.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}