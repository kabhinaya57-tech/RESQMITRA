import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/app_config.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignIn = true;
  bool busy = false;
  bool showPassword = false;
  bool acceptedTerms = false;
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  @override
  void dispose() {
    name.dispose(); email.dispose(); phone.dispose();
    password.dispose(); confirmPassword.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!AppConfig.firebaseReady) {
      _message('Authentication is not connected. Configure Firebase first; no login was attempted.');
      return;
    }
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      _message('Enter your email and password.');
      return;
    }
    if (!isSignIn) {
      if (name.text.trim().isEmpty || phone.text.trim().isEmpty) {
        _message('Enter your name and phone number.');
        return;
      }
      if (password.text != confirmPassword.text) {
        _message('Passwords do not match.');
        return;
      }
      if (password.text.length < 8) {
        _message('Use a password with at least 8 characters.');
        return;
      }
      if (!acceptedTerms) {
        _message('Please accept the Terms and Privacy Policy.');
        return;
      }
    }

    setState(() => busy = true);
    try {
      if (isSignIn) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text.trim(), password: password.text,
        );
      } else {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text.trim(), password: password.text,
        );
        await credential.user?.updateDisplayName(name.text.trim());
        await credential.user?.sendEmailVerification();
      }
      if (!mounted) return;
      if (!isSignIn && FirebaseAuth.instance.currentUser != null) {
        _message('Account created. Check your email to verify your address.');
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      _message(e.message ?? 'Authentication failed.');
    } catch (e) {
      _message('Could not complete authentication: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F6FF), Colors.white],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/images/resq_mitra_logo.jpeg', height: 170, fit: BoxFit.contain),
                    const SizedBox(height: 8),
                    const Center(child: Text.rich(TextSpan(children: [
                      TextSpan(text: 'ResQ', style: TextStyle(color: Color(0xFFFF7900))),
                      TextSpan(text: 'Mitra', style: TextStyle(color: Color(0xFF078B43))),
                    ]), style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800))),
                    const Center(child: Text('BE FIRST TO RESPOND',
                      style: TextStyle(color: Color(0xFF102A56), letterSpacing: 1.8, fontWeight: FontWeight.w700))),
                    const SizedBox(height: 28),
                    Text(isSignIn ? 'Welcome to ResQMitra' : 'Create your account',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF102A56))),
                    const SizedBox(height: 18),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Sign In')),
                        ButtonSegment(value: false, label: Text('Create Account')),
                      ],
                      selected: {isSignIn},
                      onSelectionChanged: (s) => setState(() => isSignIn = s.first),
                    ),
                    const SizedBox(height: 18),
                    if (!isSignIn) ...[
                      TextField(controller: name, decoration: const InputDecoration(labelText: 'Full Name')),
                      const SizedBox(height: 12),
                      TextField(controller: phone, keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone Number')),
                      const SizedBox(height: 12),
                    ],
                    TextField(controller: email, keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email Address')),
                    const SizedBox(height: 12),
                    TextField(controller: password, obscureText: !showPassword,
                      decoration: InputDecoration(labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => showPassword = !showPassword),
                          icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                        )),
                    ),
                    if (!isSignIn) ...[
                      const SizedBox(height: 12),
                      TextField(controller: confirmPassword, obscureText: !showPassword,
                        decoration: const InputDecoration(labelText: 'Confirm Password')),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: acceptedTerms,
                        onChanged: (v) => setState(() => acceptedTerms = v ?? false),
                        title: const Text('I agree to the Terms and Privacy Policy'),
                      ),
                    ],
                    if (isSignIn)
                      Align(alignment: Alignment.centerRight, child: TextButton(
                        onPressed: () async {
                          if (!AppConfig.firebaseReady) {
                            _message('Password recovery is not connected. Configure Firebase first.');
                            return;
                          }
                          if (email.text.trim().isEmpty) {
                            _message('Enter your registered email address first.');
                            return;
                          }
                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
                            _message('If the account exists, a password reset email has been sent.');
                          } on FirebaseAuthException catch (e) { _message(e.message ?? 'Reset failed.'); }
                        },
                        child: const Text('Forgot Password?'),
                      )),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: busy ? null : submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF168DDB),
                      ),
                      child: busy
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(isSignIn ? 'Login' : 'Create Account'),
                    ),
                    const SizedBox(height: 16),
                    if (!AppConfig.firebaseReady)
                      const Text('Setup required: Firebase is not configured. Authentication and SOS submission are disabled.',
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontSize: 12)),
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
