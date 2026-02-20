import 'package:flutter/material.dart';
import 'package:dax/features/auth/providers/auth_provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _controller = AuthProvider();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _codeSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendCode([String? _]) async {
    if (_controller.isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    await _controller.sendOTP(_emailController.text);

    if (!mounted) {
      return;
    }

    if (_controller.errorMessage == null && _codeSent == false) {
      setState(() {
        _codeSent = true;
      });
    }
  }

  Future<void> _verifyCode([String? _]) async {
    if (_controller.isLoading) {
      return;
    }

    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter the code')));
      return;
    }

    final success = await _controller.verifyOTP(
      _emailController.text,
      _otpController.text,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage ?? 'Invalid code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 400,
              child: Form(
                key: _formKey,
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    return Column(
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
                            child: _controller.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Send Code'),
                          ),
                          if (_controller.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                _controller.errorMessage!,
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
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _verifyCode,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _controller.isLoading
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
                                  _controller.clearError();
                                },
                                child: const Text('Change Email'),
                              ),
                              TextButton(
                                onPressed: _sendCode,
                                child: const Text('Resend Code'),
                              ),
                            ],
                          ),
                          if (_controller.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                _controller.errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}