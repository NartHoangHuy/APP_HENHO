import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import '../config/app_theme.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check terms acceptance
    if (!_acceptTerms) {
      _showErrorDialog(
        'Bạn phải đồng ý với Điều khoản sử dụng và Chính sách bảo mật',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final success = await authService.registerWithConfirm(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _confirmPasswordController.text,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        // Use floating snackbar with flexible content to avoid overflow on small screens
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '✅ Đăng ký thành công! Vui lòng đăng nhập',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );

        // Navigate to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        _showErrorDialog('Đăng ký thất bại. Vui lòng kiểm tra lại thông tin.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Lỗi: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Lỗi'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // allow scaffold to resize when keyboard opens
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
              AppColors.accent,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Tạo tài khoản mới',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildUsernameField(),
                          const SizedBox(height: 16),
                          _buildEmailField(),
                          const SizedBox(height: 16),
                          _buildPasswordField(),
                          const SizedBox(height: 16),
                          _buildConfirmPasswordField(),
                          const SizedBox(height: 20),
                          _buildTermsCheckbox(),
                          const SizedBox(height: 24),
                          _buildRegisterButton(),
                          const SizedBox(height: 16),
                          _buildLoginLink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: 'Tên tài khoản',
        hintText: 'Nhập tên tài khoản',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '❌ Vui lòng nhập tên tài khoản';
        }
        if (value.trim().length < 3) {
          return '❌ Tên tài khoản phải có ít nhất 3 ký tự';
        }
        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
          return '❌ Tên tài khoản chỉ chứa chữ cái, số và dấu gạch dưới';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'example@email.com',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '❌ Vui lòng nhập email';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
          return '❌ Email không hợp lệ';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Mật khẩu',
        hintText: 'Tối thiểu 8 ký tự',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '❌ Vui lòng nhập mật khẩu';
        }
        if (value.length < 8) {
          return '❌ Mật khẩu phải có ít nhất 8 ký tự';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        labelText: 'Xác nhận mật khẩu',
        hintText: 'Nhập lại mật khẩu',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '❌ Vui lòng xác nhận mật khẩu';
        }
        if (value != _passwordController.text) {
          return '❌ Mật khẩu xác nhận không khớp';
        }
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() => _acceptTerms = value ?? false);
            },
            activeColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _acceptTerms = !_acceptTerms);
            },
            child: Text.rich(
              TextSpan(
                text: 'Tôi đồng ý với ',
                style: AppTextStyles.bodyMedium,
                children: [
                  TextSpan(
                    text: 'Điều khoản sử dụng',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' và '),
                  TextSpan(
                    text: 'Chính sách bảo mật',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: _isLoading || !_acceptTerms
            ? null
            : LinearGradient(colors: [AppColors.primary, AppColors.accent]),
        color: _isLoading || !_acceptTerms ? Colors.grey : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isLoading || !_acceptTerms
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        onPressed: _isLoading ? null : _register,
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Đăng ký',
                style: AppTextStyles.h4.copyWith(color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đã có tài khoản? ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: Text(
            'Đăng nhập ngay',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
