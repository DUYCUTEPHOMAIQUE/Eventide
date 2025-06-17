# Signup Flow Fix - Giải quyết vấn đề flow đăng ký

## Vấn đề đã được giải quyết

### 1. **Flow đăng ký không cần nhập tên ở form đầu**
- ✅ Đã loại bỏ trường tên khỏi form đăng ký email
- ✅ Tên sẽ được nhập ở màn hình "Hoàn tất hồ sơ" sau khi verify OTP
- ✅ Flow: Email + Password → OTP Verification → Complete Profile → Home

### 2. **Chức năng resend OTP sau 60s**
- ✅ Đã thêm countdown timer 60 giây
- ✅ Hiển thị thời gian còn lại: "Gửi lại mã sau 60s"
- ✅ Sau 60s, nút "Gửi lại mã" sẽ được kích hoạt
- ✅ Khi resend thành công, countdown sẽ reset về 60s

### 3. **Xử lý lỗi navigation khi back từ màn hình OTP**
- ✅ Thêm `WillPopScope` để chặn back gesture
- ✅ Hiển thị dialog xác nhận khi user muốn quay lại
- ✅ Cả nút back và "Quay lại đăng ký" đều có dialog xác nhận
- ✅ Ngăn chặn việc user vô tình hủy quá trình đăng ký
- ✅ **FIXED: Lỗi đen màn hình khi back từ OTP screen**
  - Reset BLoC state về initial trước khi navigate
  - Sử dụng `Navigator.pushAndRemoveUntil` thay vì `Navigator.pop`
  - Thêm `Future.delayed` để đảm bảo BLoC xử lý xong trước khi navigate
  - Kiểm tra `mounted` trước khi navigate

### 4. **Cải thiện Auth Wrapper**
- ✅ Kiểm tra `emailConfirmedAt` để xác định user đã verify chưa
- ✅ Nếu chưa verify → quay về màn hình đăng nhập
- ✅ Nếu đã verify nhưng chưa complete profile → màn hình complete profile
- ✅ Nếu đã verify và complete profile → màn hình home

### 5. **Sử dụng BLoC pattern**
- ✅ Chuyển từ gọi service trực tiếp sang sử dụng BLoC
- ✅ Thêm state `AuthOTPVerified` để xử lý OTP verification thành công
- ✅ Xử lý states một cách nhất quán trong toàn bộ flow

### 6. **Cải thiện Validation và Error Handling**
- ✅ **Loại bỏ trường tên khỏi form đăng ký**
- ✅ **Validation mật khẩu mạnh**: Ít nhất 6 ký tự, bao gồm chữ hoa, chữ thường và số
- ✅ **Kiểm tra email tồn tại**: Trước khi đăng nhập và đăng ký
- ✅ **Thông báo lỗi thân thiện**: Chuyển đổi lỗi kỹ thuật thành thông báo dễ hiểu
- ✅ **Validation real-time**: Kiểm tra format email và mật khẩu trước khi submit
- ✅ **Thông báo lỗi rõ ràng và cụ thể**: Với ví dụ và hướng dẫn cách sửa

## Cấu trúc flow mới

```
MinimalistDashboardScreen (Đăng nhập/Đăng ký)
    ↓ (Chọn đăng ký)
EmailSignupScreen (Email + Password)
    ↓ (Đăng ký thành công)
OTPVerificationScreen (Nhập mã 6 chữ số)
    ↓ (Verify thành công)
CompleteProfileScreen (Tên + Avatar)
    ↓ (Hoàn tất)
EnhancedMinimalistHomeScreen (Màn hình chính)
```

## Các file đã được sửa

### 1. **lib/screens/auth/otp_verification_screen.dart**
- Thêm countdown timer cho resend OTP
- Thêm `WillPopScope` và dialog xác nhận
- Sử dụng BLoC thay vì gọi service trực tiếp
- Cải thiện UX với loading states
- **FIXED: Lỗi đen màn hình khi back**
  - Reset BLoC state trước khi navigate
  - Sử dụng `Navigator.pushAndRemoveUntil`
  - Thêm delay để đảm bảo BLoC xử lý xong

### 2. **lib/screens/authwrap/auth_wrapper.dart**
- Kiểm tra `emailConfirmedAt` để xác định trạng thái user
- Xử lý flow navigation dựa trên trạng thái verify và profile

### 3. **lib/blocs/auth/auth_bloc.dart**
- Thêm logic xử lý OTP verification
- Emit state `AuthOTPVerified` khi verify thành công
- **NEW: Cải thiện error handling**
  - Thêm method `_getFriendlyErrorMessage()` để chuyển đổi lỗi kỹ thuật
  - Thêm method `_isStrongPassword()` để validate mật khẩu mạnh
  - Kiểm tra email tồn tại trước khi đăng nhập/đăng ký

### 4. **lib/blocs/auth/auth_state.dart**
- Thêm state `AuthOTPVerified`

### 5. **lib/screens/auth/minimalist_dashboard_screen.dart**
- Xử lý state `AuthOTPVerified`
- Chuyển sang màn hình complete profile khi OTP verified
- **NEW: Cải thiện validation và UI**
  - Loại bỏ trường tên khỏi form đăng ký
  - Thêm validation email và mật khẩu real-time
  - Thêm method `_showFriendlyErrorMessage()` để hiển thị lỗi thân thiện
  - Thêm method `_getFriendlyErrorMessage()` để chuyển đổi lỗi kỹ thuật

### 6. **lib/screens/auth/email_signup_screen.dart**
- Sử dụng BLoC thay vì gọi service trực tiếp
- Xử lý states một cách nhất quán

### 7. **lib/services/supabase_services.dart**
- **NEW: Thêm method `checkEmailExists()`**
  - Kiểm tra email đã tồn tại trong database chưa
  - Sử dụng để validate trước khi đăng ký/đăng nhập

## Tính năng mới

### 1. **Resend OTP với countdown**
```dart
// Countdown timer 60 giây
Timer.periodic(const Duration(seconds: 1), (timer) {
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
```

### 2. **Dialog xác nhận khi back**
```dart
WillPopScope(
  onWillPop: () async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn quay lại? Quá trình đăng ký sẽ bị hủy.'),
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
    return shouldPop ?? false;
  },
  child: // ... rest of the widget
)
```

### 3. **Auth Wrapper logic**
```dart
if (session.user.emailConfirmedAt != null) {
  // User đã verify email, kiểm tra profile
  final authService = AuthService();
  if (authService.isProfileComplete()) {
    return const EnhancedMinimalistHomeScreen();
  } else {
    return const CompleteProfileScreen();
  }
} else {
  // User chưa verify email, quay về màn hình đăng nhập
  return const MinimalistDashboardScreen();
}
```

### 4. **FIXED: Navigation an toàn khi back từ OTP**
```dart
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
```

### 5. **NEW: Validation mật khẩu mạnh**
```dart
bool _isStrongPassword(String password) {
  if (password.length < 6) return false;
  
  // Kiểm tra có ít nhất 1 chữ hoa, 1 chữ thường và 1 số
  bool hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
  bool hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
  bool hasDigit = RegExp(r'\d').hasMatch(password);
  
  return hasUpperCase && hasLowerCase && hasDigit;
}
```

### 6. **NEW: Kiểm tra email tồn tại**
```dart
static Future<bool> checkEmailExists(String email) async {
  try {
    print('Checking if email exists: $email');
    
    // Kiểm tra trong bảng profiles
    final response = await client
        .from('profiles')
        .select('email')
        .eq('email', email)
        .limit(1);
    
    print('Email check response: $response');
    
    // Nếu có kết quả trả về, email đã tồn tại
    final exists = response.isNotEmpty;
    print('Email exists: $exists');
    
    return exists;
  } catch (e) {
    print('Error checking email existence: $e');
    // Nếu có lỗi, giả sử email không tồn tại để tránh chặn user
    return false;
  }
}
```

### 7. **NEW: Thông báo lỗi thân thiện**
```dart
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
    return 'Mật khẩu không hợp lệ. Vui lòng kiểm tra lại';
  }
  
  // Lỗi email
  if (lowerError.contains('email')) {
    if (lowerError.contains('invalid') || lowerError.contains('không hợp lệ')) {
      return 'Email không hợp lệ. Vui lòng nhập đúng định dạng email. Ví dụ: example@gmail.com';
    }
    if (lowerError.contains('not found') || lowerError.contains('không tìm thấy')) {
      return 'Email chưa được đăng ký. Vui lòng kiểm tra lại hoặc chuyển sang đăng ký tài khoản mới';
    }
    if (lowerError.contains('already exists') || lowerError.contains('đã tồn tại')) {
      return 'Email đã được đăng ký. Vui lòng đăng nhập hoặc sử dụng email khác';
    }
    if (lowerError.contains('not confirmed') || lowerError.contains('chưa xác thực')) {
      return 'Email chưa được xác thực. Vui lòng kiểm tra email và nhấp vào link xác thực';
    }
    return 'Lỗi email. Vui lòng kiểm tra lại định dạng email';
  }
  
  // Lỗi mạng
  if (lowerError.contains('network') || lowerError.contains('connection') || lowerError.contains('timeout')) {
    return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet và thử lại';
  }
  
  // Lỗi server
  if (lowerError.contains('server') || lowerError.contains('500') || lowerError.contains('503')) {
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
```

## Ví dụ thông báo lỗi cụ thể:

### Lỗi mật khẩu:
- ❌ **Cũ**: "Mật khẩu quá yếu"
- ✅ **Mới**: "Mật khẩu yêu cầu: ít nhất 6 ký tự, bao gồm 1 chữ hoa, 1 chữ thường và 1 số. Ví dụ: Password123"

### Lỗi email:
- ❌ **Cũ**: "Email không hợp lệ"
- ✅ **Mới**: "Email không hợp lệ. Vui lòng nhập đúng định dạng email. Ví dụ: example@gmail.com"

### Lỗi email tồn tại:
- ❌ **Cũ**: "Email đã tồn tại"
- ✅ **Mới**: "Email đã được đăng ký. Vui lòng đăng nhập hoặc sử dụng email khác"

### Lỗi OTP:
- ❌ **Cũ**: "OTP verification failed"
- ✅ **Mới**: "Mã OTP không đúng hoặc đã hết hạn. Vui lòng kiểm tra lại mã 6 chữ số hoặc nhấn 'Gửi lại mã'"

## Lưu ý quan trọng

1. **User chưa verify email**: Nếu user refresh app hoặc mở lại app mà chưa verify email, sẽ được chuyển về màn hình đăng nhập
2. **User đã verify nhưng chưa complete profile**: Sẽ được chuyển đến màn hình complete profile
3. **User đã verify và complete profile**: Sẽ được chuyển đến màn hình home
4. **Back navigation**: Tất cả các màn hình trong flow đăng ký đều có dialog xác nhận khi user muốn quay lại
5. **FIXED: Lỗi đen màn hình**: Đã được sửa bằng cách reset BLoC state và sử dụng navigation an toàn
6. **NEW: Validation mạnh**: Mật khẩu phải có ít nhất 6 ký tự, bao gồm chữ hoa, chữ thường và số
7. **NEW: Kiểm tra email**: Trước khi đăng nhập/đăng ký sẽ kiểm tra email đã tồn tại chưa
8. **NEW: Thông báo lỗi thân thiện**: Tất cả lỗi kỹ thuật sẽ được chuyển đổi thành thông báo dễ hiểu

## Testing

Để test flow mới:

1. **Test đăng ký bình thường**: Email + Password → OTP → Complete Profile → Home
2. **Test resend OTP**: Đợi 60s hoặc ấn nút resend
3. **Test back navigation**: Thử ấn back ở mỗi màn hình (đã fix lỗi đen màn hình)
4. **Test refresh app**: Refresh app ở các giai đoạn khác nhau của flow
5. **Test error handling**: Thử nhập sai OTP, sai email format, etc.
6. **Test back từ OTP screen**: Đảm bảo không bị lỗi đen màn hình
7. **NEW: Test validation mật khẩu**: Thử nhập mật khẩu yếu (không có chữ hoa, chữ thường, số)
8. **NEW: Test kiểm tra email**: Thử đăng ký email đã tồn tại, đăng nhập email chưa đăng ký
9. **NEW: Test thông báo lỗi**: Kiểm tra các thông báo lỗi có thân thiện và dễ hiểu không

## Bug Fixes

### Lỗi đen màn hình khi back từ OTP screen
**Nguyên nhân**: 
- BLoC state không được reset khi back
- Navigation stack bị lỗi khi sử dụng `Navigator.pop()`

**Giải pháp**:
1. Reset BLoC state về initial trước khi navigate
2. Sử dụng `Navigator.pushAndRemoveUntil` thay vì `Navigator.pop()`
3. Thêm delay để đảm bảo BLoC xử lý xong
4. Kiểm tra `mounted` trước khi navigate

**Code fix**:
```dart
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
```

### Cải thiện Validation và Error Handling
**Nguyên nhân**: 
- Form đăng ký có trường tên không cần thiết
- Validation mật khẩu yếu
- Thông báo lỗi kỹ thuật khó hiểu
- Không kiểm tra email tồn tại

**Giải pháp**:
1. Loại bỏ trường tên khỏi form đăng ký
2. Thêm validation mật khẩu mạnh (chữ hoa, chữ thường, số)
3. Thêm method chuyển đổi lỗi kỹ thuật thành thông báo thân thiện
4. Thêm kiểm tra email tồn tại trước khi đăng nhập/đăng ký

**Code fix**:
```dart
// Validation mật khẩu mạnh
bool _isStrongPassword(String password) {
  if (password.length < 6) return false;
  
  bool hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
  bool hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
  bool hasDigit = RegExp(r'\d').hasMatch(password);
  
  return hasUpperCase && hasLowerCase && hasDigit;
}

// Kiểm tra email tồn tại
final emailExists = await SupabaseServices.checkEmailExists(event.email);
if (emailExists) {
  emit(const AuthError('Email đã được đăng ký. Vui lòng đăng nhập hoặc sử dụng email khác'));
  return;
}
``` 