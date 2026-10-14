import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.88, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    Timer(const Duration(milliseconds: 2300), () {
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: LinearGradient(
        colors: [Color(0xFFE8F6FF), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: SafeArea(child: FadeTransition(
        opacity: _fade,
        child: Center(child: SingleChildScrollView(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ScaleTransition(scale: _scale, child: Image.asset('assets/images/resq_mitra_logo.jpeg', width: 270, height: 270, fit: BoxFit.contain)),
          const SizedBox(height: 16),
          const Text('Emergency Assistance\\n& Responder System', textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF102A56), fontSize: 21, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          const Text('BE FIRST TO RESPOND', style: TextStyle(color: Color(0xFF168DDB), fontWeight: FontWeight.w800, letterSpacing: 2)),
          const SizedBox(height: 28),
          const SizedBox(width: 150, child: LinearProgressIndicator(
            minHeight: 5, borderRadius: BorderRadius.all(Radius.circular(8)),
            backgroundColor: Color(0xFFD4ECFA), color: Color(0xFF168DDB))),
        ]))),
      )),
    ),
  );
}
