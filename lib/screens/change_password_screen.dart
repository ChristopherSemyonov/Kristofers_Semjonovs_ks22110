import 'package:flutter/material.dart';

import '../services/password_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final codeController = TextEditingController();
  final passwordController = TextEditingController();

  bool isSendingCode = false;
  bool isChangingPassword = false;
  bool codeSent = false;

  Future<void> _sendCode() async {
    setState(() {
      isSendingCode = true;
    });

    try {
      await PasswordService.requestPasswordChange();

      if (!mounted) return;

      setState(() {
        codeSent = true;
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verifikācijas kods nosūtīts uz e-pastu.'),
        ),
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

  Future<void> _changePassword() async {
    try {
      setState(() {
        isChangingPassword = true;
      });

      await PasswordService.confirmPasswordChange(
        code: codeController.text.trim(),
        newPassword: passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parole veiksmīgi nomainīta.')),
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
          isChangingPassword = false;
        });
      }
    }
  }

  @override
  void dispose() {
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
          'Change password',
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
              'Password security',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            const Text(
              'Request a verification code, then enter the code and your new password.',
              style: TextStyle(fontSize: 16, color: Color(0xFF5C4037)),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: isSendingCode ? null : _sendCode,
                child: Text(
                  isSendingCode ? 'Sending...' : 'Send verification code',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: codeController,
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
                onPressed: isChangingPassword || !codeSent
                    ? null
                    : _changePassword,
                child: Text(
                  isChangingPassword ? 'Saving...' : 'Save new password',
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
