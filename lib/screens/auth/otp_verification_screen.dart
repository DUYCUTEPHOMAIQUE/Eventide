import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enva/blocs/auth/auth_bloc.dart';
import 'package:enva/blocs/auth/auth_event.dart';
import 'package:enva/blocs/auth/auth_state.dart';
import 'package:enva/screens/auth/complete_profile_screen.dart';
import 'package:enva/screens/auth/minimalist_dashboard_screen.dart';
import 'dart:async';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  bool _canResend = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });
        if (_resendCountdown <= 0) {
          setState(() {
            _canResend = true;
          });
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOTPVerified) {
          // OTP verification thành công, chuyển sang màn hình complete profile
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const CompleteProfileScreen(),
            ),
            (route) => false, // Xóa tất cả route cũ
          );
        } else if (state is AuthOTPResent) {
          // OTP đã được gửi lại thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Mã OTP mới đã được gửi đến email của bạn'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );

          // Clear OTP fields
          for (var controller in _otpControllers) {
            controller.clear();
          }

          // Focus on first field
          _focusNodes[0].requestFocus();

          // Start countdown again
          _startResendCountdown();

          setState(() {
            _isResending = false;
          });
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          setState(() {
            _isLoading = false;
            _isResending = false;
          });
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          // Hiển thị dialog xác nhận khi user muốn quay lại
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Xác nhận'),
              content: const Text(
                  'Bạn có chắc muốn quay lại? Quá trình đăng ký sẽ bị hủy.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Đồng ý'),
                ),
              ],
            ),
          );

          if (shouldPop == true) {
            // Reset BLoC state về initial
            context.read<AuthBloc>().add(SignOutRequested());

            // Đợi một chút để BLoC xử lý xong
            await Future.delayed(const Duration(milliseconds: 100));

            // Xóa tất cả route và quay về màn hình đăng nhập
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MinimalistDashboardScreen(),
                ),
                (route) => false,
              );
            }
          }

          return false; // Không cho phép back tự nhiên
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Header
                  _buildHeader(),

                  const SizedBox(height: 48),

                  // Email display
                  _buildEmailDisplay(),

                  const SizedBox(height: 32),

                  // OTP Input
                  _buildOTPInput(),

                  const SizedBox(height: 32),

                  // Verify Button
                  _buildVerifyButton(),

                  const SizedBox(height: 24),

                  // Resend OTP
                  _buildResendOTP(),

                  const SizedBox(height: 24),

                  // Back to signup
                  _buildBackToSignup(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () async {
            // Hiển thị dialog xác nhận khi user muốn quay lại
            final shouldPop = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Xác nhận'),
                content: const Text(
                    'Bạn có chắc muốn quay lại? Quá trình đăng ký sẽ bị hủy.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Hủy'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Đồng ý'),
                  ),
                ],
              ),
            );
            if (shouldPop == true && mounted) {
              // Reset BLoC state về initial
              context.read<AuthBloc>().add(SignOutRequested());

              // Đợi một chút để BLoC xử lý xong
              await Future.delayed(const Duration(milliseconds: 100));

              // Xóa tất cả route và quay về màn hình đăng nhập
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MinimalistDashboardScreen(),
                  ),
                  (route) => false,
                );
              }
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Theme.of(context).colorScheme.onBackground,
            size: 24,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Xác thực email',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onBackground,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Nhập mã 6 chữ số đã được gửi đến email của bạn',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildEmailDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.email_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mã xác thực',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onBackground,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              6,
              (index) => _buildOTPField(index),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Nhập mã 6 chữ số đã được gửi đến email của bạn',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOTPField(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = (screenWidth - 48 - 60) / 6; // 48 padding, 60 spacing

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: fieldWidth.clamp(40.0, 50.0), // Min 40, max 50
      height: 56,
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onBackground,
              letterSpacing: 2,
            ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          counterText: '', // Ẩn character counter
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleVerifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                'Xác thực',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
      ),
    );
  }

  Widget _buildResendOTP() {
    return Center(
      child: Column(
        children: [
          if (!_canResend) ...[
            Text(
              'Gửi lại mã sau ${_resendCountdown}s',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ] else ...[
            TextButton(
              onPressed: _isResending ? null : _handleResendOTP,
              child: _isResending
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : Text(
                      'Gửi lại mã',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackToSignup() {
    return Center(
      child: TextButton(
        onPressed: () async {
          // Hiển thị dialog xác nhận khi user muốn quay lại
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Xác nhận'),
              content: const Text(
                  'Bạn có chắc muốn quay lại? Quá trình đăng ký sẽ bị hủy.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Đồng ý'),
                ),
              ],
            ),
          );
          if (shouldPop == true && mounted) {
            // Reset BLoC state về initial
            context.read<AuthBloc>().add(SignOutRequested());

            // Đợi một chút để BLoC xử lý xong
            await Future.delayed(const Duration(milliseconds: 100));

            // Xóa tất cả route và quay về màn hình đăng nhập
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MinimalistDashboardScreen(),
                ),
                (route) => false,
              );
            }
          }
        },
        child: Text(
          'Quay lại đăng ký',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }

  String _getOTPCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _handleVerifyOTP() async {
    final otpCode = _getOTPCode();

    if (otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập đầy đủ 6 chữ số'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Sử dụng BLoC để verify OTP
    context.read<AuthBloc>().add(VerifyOTPRequested(widget.email, otpCode));
  }

  Future<void> _handleResendOTP() async {
    setState(() {
      _isResending = true;
    });

    // Sử dụng BLoC để resend OTP
    context.read<AuthBloc>().add(ResendOTPRequested(widget.email));
  }
}
