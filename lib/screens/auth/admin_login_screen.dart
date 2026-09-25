import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_dimensions.dart';
import '../../core/constants/admin_strings.dart';
import '../../services/admin_state_service.dart';
import '../main_layout/admin_main_scaffold.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@quickride.com');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300)); // Smooth UX transition

    final success = await AdminStateService().authenticateAdmin(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminMainScaffold()),
      );
    } else {
      final msg = AdminStateService().errorMessage ?? 'Invalid admin credentials. Use demo: admin@quickride.com / admin123';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AdminColors.danger,
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Admin Password'),
        content: const Text(
          'For this demo environment, use default credentials:\n\n'
          'Email: admin@quickride.com\nPassword: admin123',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate canvas
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AdminDimensions.p24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminDimensions.radiusLarge),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AdminDimensions.p32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Brand Header
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AdminColors.primary.withOpacity(0.18),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(
                                'assets/images/quickride_admin_logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AdminDimensions.p16),
                      const Text(
                        AdminStrings.appName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AdminDimensions.p4),
                      const Text(
                        AdminStrings.appSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AdminColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AdminDimensions.p8),
                      // Demo Badge
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AdminColors.primaryLight,
                            borderRadius: BorderRadius.circular(AdminDimensions.radiusFull),
                            border: Border.all(color: AdminColors.primary.withOpacity(0.3)),
                          ),
                          child: const Text(
                            AdminStrings.demoBadge,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AdminColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AdminDimensions.p24),

                      // Email Field
                      const Text(
                        'Admin Email / Username',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                          hintText: 'admin@quickride.com',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter admin email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AdminDimensions.p16),

                      // Password Field
                      const Text(
                        'Password',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AdminDimensions.p8),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AdminDimensions.p20),

                      // Login Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Login to Dashboard'),
                      ),
                      const SizedBox(height: AdminDimensions.p16),

                      // Demo Credentials Helper Note
                      Container(
                        padding: const EdgeInsets.all(AdminDimensions.p12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 18, color: AdminColors.secondary),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Demo credentials: admin@quickride.com / admin123',
                                style: TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
