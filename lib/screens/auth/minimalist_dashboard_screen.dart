import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enva/blocs/auth/auth_bloc.dart';
import 'package:enva/blocs/auth/auth_event.dart';
import 'package:enva/blocs/auth/auth_state.dart';
import 'package:enva/widgets/theme_toggle_widget.dart';
import 'package:enva/screens/auth/widgets/widgets.dart';
import 'package:enva/screens/auth/otp_verification_screen.dart';
import 'package:enva/screens/auth/complete_profile_screen.dart';

class MinimalistDashboardScreen extends StatefulWidget {
  const MinimalistDashboardScreen({Key? key}) : super(key: key);

  @override
  State<MinimalistDashboardScreen> createState() =>
      _MinimalistDashboardScreenState();
}

class _MinimalistDashboardScreenState extends State<MinimalistDashboardScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navigation will be handled by AuthWrapper
          } else if (state is AuthSignUpSuccess) {
            // Chuyển sang màn hình OTP verification
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OTPVerificationScreen(
                  email: _emailController.text.trim(),
                ),
              ),
            );
          } else if (state is AuthOTPVerified) {
            // OTP verification thành công, chuyển sang màn hình complete profile
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CompleteProfileScreen(),
              ),
            );
          } else if (state is AuthError) {
            // Hiển thị thông báo lỗi thân thiện
            _showFriendlyErrorMessage(state.message);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Stack(
              children: [
                // Main Content
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Theme toggle (top right)
                        Align(
                          alignment: Alignment.centerRight,
                          child: const ThemeToggleWidget(isCompact: true),
                        ),

                        const SizedBox(height: 20),

                        // Header Section
                        _buildHeader(),

                        const SizedBox(height: 60),

                        // Auth Form
                        _buildAuthForm(state),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Loading Overlay
                if (state is AuthLoading) _buildLoadingOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App Logo/Title
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.card_giftcard,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Eventide',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Welcome Message
        Text(
          'Chào mừng bạn',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onBackground,
                height: 1.2,
              ),
        ),

        const SizedBox(height: 12),

        Text(
          'Tạo và chia sẻ những thiệp mời đẹp mắt cho các sự kiện đặc biệt của bạn',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
        ),
      ],
    );
  }

  Widget _buildAuthForm(AuthState state) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Theme.of(context).colorScheme.outline, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Toggle
          _buildFormToggle(),

          const SizedBox(height: 32),

          // Form Fields
          _buildFormFields(),

          const SizedBox(height: 32),

          // Action Buttons
          _buildActionButtons(state),

          const SizedBox(height: 24),

          // Divider
          _buildDivider(),

          const SizedBox(height: 24),

          // Google Sign In
          _buildGoogleSignIn(state),
        ],
      ),
    );
  }

  Widget _buildFormToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isSignUp = false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !_isSignUp ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: _isSignUp
                    ? Border.all(color: Colors.grey[300]!, width: 1.5)
                    : null,
              ),
              child: Text(
                'Đăng nhập',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: !_isSignUp ? Colors.white : Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isSignUp = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _isSignUp ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: !_isSignUp
                    ? Border.all(color: Colors.grey[300]!, width: 1.5)
                    : null,
              ),
              child: Text(
                'Đăng ký',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isSignUp ? Colors.white : Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Email field
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'example@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 16),

        // Password field
        _buildTextField(
          controller: _passwordController,
          label: 'Mật khẩu',
          hint: 'Nhập mật khẩu',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey[500],
                      size: 20,
                    ),
                    onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[300]!, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AuthState state) {
    return Column(
      children: [
        // Primary action button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state is AuthLoading ? null : _handlePrimaryAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 56),
            ),
            child: Text(
              _isSignUp ? 'Tạo tài khoản' : 'Đăng nhập',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Forgot password (only for sign in)
        if (!_isSignUp) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // TODO: Handle forgot password
            },
            child: Text(
              'Quên mật khẩu?',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'hoặc',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleSignIn(AuthState state) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: state is AuthLoading ? null : _handleGoogleSignIn,
        icon: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Image.network(
            'https://developers.google.com/identity/images/g-logo.png',
            width: 20,
            height: 20,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.g_mobiledata,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
        label: Text(
          'Tiếp tục với Google',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1.5,
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
            SizedBox(height: 16),
            Text(
              'Đang xử lý...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Validation functions
  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Vui lòng nhập email';
    }

    return null; // Hợp lệ
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    if (_isSignUp) {
      // Kiểm tra mật khẩu mạnh cho đăng ký
      if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
        return 'Mật khẩu yêu cầu: ít nhất 1 chữ hoa, 1 chữ thường và 1 số. Ví dụ: Password123';
      }
    }
    return null;
  }

  // Hiển thị thông báo lỗi thân thiện
  void _showFriendlyErrorMessage(String errorMessage) {
    String friendlyMessage = _getFriendlyErrorMessage(errorMessage);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(friendlyMessage),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Chuyển đổi lỗi kỹ thuật thành thông báo thân thiện
  String _getFriendlyErrorMessage(String errorMessage) {
    final lowerError = errorMessage.toLowerCase();

    // Lỗi mật khẩu
    if (lowerError.contains('password') || lowerError.contains('mật khẩu')) {
      if (lowerError.contains('weak') || lowerError.contains('yếu')) {
        return 'Mật khẩu yêu cầu: ít nhất 6 ký tự, bao gồm 1 chữ hoa, 1 chữ thường và 1 số. Ví dụ: Password123';
      }
      if (lowerError.contains('incorrect') || lowerError.contains('sai')) {
        return 'Mật khẩu không đúng. Vui lòng kiểm tra lại hoặc sử dụng "Quên mật khẩu"';
      }
      if (lowerError.contains('too short') || lowerError.contains('ngắn')) {
        return 'Mật khẩu quá ngắn. Yêu cầu ít nhất 6 ký tự';
      }
      return 'Mật khẩu yêu cầu: ít nhất 6 ký tự, bao gồm 1 chữ hoa, 1 chữ thường và 1 số. Ví dụ: Password123';
    }

    // Lỗi email đã tồn tại (từ AuthBloc)
    if (lowerError.contains('đã được đăng ký')) {
      return 'Email đã được đăng ký. Vui lòng đăng nhập hoặc sử dụng email khác';
    }

    // Lỗi email chưa đăng ký (từ AuthBloc)
    if (lowerError.contains('chưa được đăng ký')) {
      return 'Email chưa được đăng ký. Vui lòng kiểm tra lại hoặc chuyển sang đăng ký tài khoản mới';
    }

    // Lỗi email
    if (lowerError.contains('email')) {
      if (lowerError.contains('not found') ||
          lowerError.contains('không tìm thấy')) {
        return 'Email chưa được đăng ký. Vui lòng kiểm tra lại hoặc chuyển sang đăng ký tài khoản mới';
      }
      if (lowerError.contains('already exists') ||
          lowerError.contains('đã tồn tại')) {
        return 'Email đã được đăng ký. Vui lòng đăng nhập hoặc sử dụng email khác';
      }
      if (lowerError.contains('not confirmed') ||
          lowerError.contains('chưa xác thực')) {
        return 'Email chưa được xác thực. Vui lòng kiểm tra email và nhấp vào link xác thực';
      }
      return 'Lỗi email. Vui lòng kiểm tra lại';
    }

    // Lỗi mạng
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout')) {
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet và thử lại';
    }

    // Lỗi server
    if (lowerError.contains('server') ||
        lowerError.contains('500') ||
        lowerError.contains('503')) {
      return 'Lỗi hệ thống. Vui lòng thử lại sau vài phút';
    }

    // Lỗi xác thực
    if (lowerError.contains('auth') || lowerError.contains('authentication')) {
      return 'Lỗi xác thực. Vui lòng đăng nhập lại';
    }

    // Lỗi OTP
    if (lowerError.contains('otp') || lowerError.contains('token')) {
      if (lowerError.contains('invalid') || lowerError.contains('không đúng')) {
        return 'Mã OTP không đúng. Vui lòng kiểm tra lại mã 6 chữ số';
      }
      if (lowerError.contains('expired') || lowerError.contains('hết hạn')) {
        return 'Mã OTP đã hết hạn. Vui lòng nhấn "Gửi lại mã" để nhận mã mới';
      }
      return 'Lỗi xác thực OTP. Vui lòng thử lại';
    }

    // Lỗi Google Sign In
    if (lowerError.contains('google')) {
      if (lowerError.contains('cancelled')) {
        return 'Đăng nhập Google bị hủy. Vui lòng thử lại';
      }
      return 'Lỗi đăng nhập Google. Vui lòng thử lại hoặc sử dụng đăng nhập email';
    }

    // Lỗi mặc định - hiển thị lỗi gốc nếu không nhận diện được
    return 'Lỗi: $errorMessage. Vui lòng thử lại';
  }

  void _handlePrimaryAction() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validate email
    final emailError = _validateEmail(email);
    if (emailError != null) {
      _showFriendlyErrorMessage(emailError);
      return;
    }

    // Validate password
    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      _showFriendlyErrorMessage(passwordError);
      return;
    }

    // Kiểm tra xem là đăng ký hay đăng nhập
    if (_isSignUp) {
      context.read<AuthBloc>().add(EmailSignUpRequested(email, password));
    } else {
      context.read<AuthBloc>().add(EmailSignInRequested(email, password));
    }
  }

  void _handleGoogleSignIn() {
    context.read<AuthBloc>().add(GoogleSignInRequested());
  }
}
