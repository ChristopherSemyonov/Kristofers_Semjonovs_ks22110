import 'package:flutter/material.dart';

import '../services/password_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();

  bool codeSent = false;
  bool isSendingCode = false;
  bool isResettingPassword = false;

  Future<void> _sendCode() async {
    setState(() {
      isSendingCode = true;
    });

    try {
      await PasswordService.requestForgotPassword(
        email: emailController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        codeSent = true;
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset code sent to your email.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSendingCode = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    setState(() {
      isResettingPassword = true;
    });

    try {
      await PasswordService.confirmForgotPassword(
        email: emailController.text.trim(),
        code: codeController.text.trim(),
        newPassword: passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successfully.')),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isResettingPassword = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        title: const Text(
          'Forgot password',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFFF7FAF8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset your password',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter your email, request a verification code, then create a new password.',
              style: TextStyle(fontSize: 16, color: Color(0xFF5C4037)),
            ),
            const SizedBox(height: 28),

            TextField(
              controller: emailController,
              enabled: !codeSent,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: isSendingCode || codeSent ? null : _sendCode,
                child: Text(
                  isSendingCode ? 'Sending...' : 'Send reset code',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: codeController,
              enabled: codeSent,
              decoration: InputDecoration(
                labelText: 'Verification code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: passwordController,
              enabled: codeSent,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isResettingPassword || !codeSent
                    ? null
                    : _resetPassword,
                child: Text(
                  isResettingPassword ? 'Saving...' : 'Reset password',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
