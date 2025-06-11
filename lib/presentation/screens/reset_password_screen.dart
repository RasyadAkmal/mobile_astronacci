// lib/presentation/screens/reset_password_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_astronacci/api/api_service.dart';
import 'package:dio/dio.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String token;
  const ResetPasswordScreen({super.key, required this.email, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _tokenController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tokenController.text = widget.token;
  }

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      await _apiService.resetPassword(
        email: widget.email,
        token: _tokenController.text,
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmationController.text,
      );
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully! Please login.')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.response?.data['message'] ?? 'An error occurred.')),
        );
      }
    } finally {
       if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tokenController,
                decoration: const InputDecoration(
                  labelText: 'Paste Token Here',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Token is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                    labelText: 'New Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (val) => val!.length < 8 ? 'Min 8 characters' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordConfirmationController,
                decoration: const InputDecoration(
                    labelText: 'Confirm New Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (val) => val! != _passwordController.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: _resetPassword,
                    child: const Text('RESET PASSWORD'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}