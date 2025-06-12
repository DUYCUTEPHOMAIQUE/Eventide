# Hệ thống Tự động Tạo Profile

## Tổng quan

Hệ thống này tự động tạo và cập nhật profile cho user trong bảng `profiles` khi họ đăng ký hoặc đăng nhập bằng email hoặc Google.

## Các thành phần chính

### 1. ProfileService (`lib/services/profile_service.dart`)
- **Chức năng**: Xử lý tạo, cập nhật và quản lý profile trong database
- **Các method chính**:
  - `createOrUpdateProfile(User user)`: Tạo hoặc cập nhật profile từ user data
  - `_extractDisplayName(User user)`: Trích xuất tên hiển thị từ user metadata
  - `_extractAvatarUrl(User user)`: Trích xuất URL avatar từ user metadata
  - `getCurrentUserProfile()`: Lấy profile của user hiện tại
  - `updateProfile()`: Cập nhật profile thủ công

### 2. AuthListenerService (`lib/services/auth_listener_service.dart`)
- **Chức năng**: Lắng nghe thay đổi auth state và tự động tạo profile
- **Các event được xử lý**:
  - `AuthChangeEvent.signedIn`: User đăng nhập
  - `AuthChangeEvent.userUpdated`: User được cập nhật
  - `AuthChangeEvent.tokenRefreshed`: Token được refresh
  - `AuthChangeEvent.signedOut`: User đăng xuất

### 3. SupabaseServices (`lib/services/supabase_services.dart`)
- **Chức năng**: Tích hợp ProfileService vào các method authentication
- **Các method được cập nhật**:
  - `signInWithGoogle()`: Tự động tạo profile sau khi đăng nhập Google
  - `signInWithEmailAndPassword()`: Tự động tạo profile sau khi đăng nhập email
  - `signUpWithEmail()`: Tự động tạo profile sau khi đăng ký email
  - `verifyOTP()`: Tự động tạo profile sau khi xác thực OTP

### 4. AuthBloc (`lib/blocs/auth/auth_bloc.dart`)
- **Chức năng**: Quản lý state authentication với debug logs chi tiết
- **Các event mới**:
  - `VerifyOTPRequested`: Xác thực OTP
  - `ResendOTPRequested`: Gửi lại OTP

## Cách hoạt động

### 1. Đăng ký bằng Email
```
User đăng ký → Supabase tạo user → ProfileService tạo profile → Lưu vào bảng profiles
```

### 2. Đăng nhập bằng Google
```
User đăng nhập Google → Supabase xác thực → ProfileService tạo/cập nhật profile → Lưu vào bảng profiles
```

### 3. Đăng nhập bằng Email
```
User đăng nhập email → Supabase xác thực → ProfileService tạo/cập nhật profile → Lưu vào bảng profiles
```

## Debug Logs

Hệ thống có debug logs chi tiết để theo dõi quá trình:

### ProfileService Logs
```
Creating/updating profile for user: [user_id]
User email: [email]
User metadata: [metadata]
Extracted display name: [display_name]
Extracted avatar URL: [avatar_url]
Profile creation response: [response]
Profile created successfully: [user_info]
```

### AuthListenerService Logs
```
Auth state change detected
Event: [event_type]
User: [email]
Session: [session_status]
Handling user sign in for: [email]
Profile already exists for signed in user: [user_info]
```

### SupabaseServices Logs
```
Starting Google Sign-In process
GoogleSignIn initialized
Google user sign-in result: [email]
Google access token obtained: [status]
Supabase Google sign-in successful
Creating/updating profile for Google user
Profile created/updated successfully for Google user: [user_info]
```

### AuthBloc Logs
```
AuthBloc: Starting Google sign-in
AuthBloc: Google sign-in successful for user [user_id]
```

## Cấu trúc Database

### Bảng `profiles`
```sql
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT NOT NULL,
    display_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Triggers
```sql
-- Trigger để tự động cập nhật updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

## Sử dụng

### 1. Khởi tạo hệ thống
```dart
// Trong main.dart
AuthListenerService.initialize();
```

### 2. Lấy profile hiện tại
```dart
final profile = await AuthListenerService.getCurrentUserProfile();
```

### 3. Cập nhật profile
```dart
final updatedProfile = await AuthListenerService.updateCurrentUserProfile(
  displayName: 'New Name',
  avatarUrl: 'https://example.com/avatar.jpg',
);
```

### 4. Đảm bảo profile tồn tại
```dart
await AuthListenerService.ensureCurrentUserProfile();
```

## Lưu ý quan trọng

1. **Database Setup**: Phải chạy SQL script để tạo bảng `profiles` và triggers trước khi sử dụng
2. **Permissions**: Đảm bảo RLS policies cho phép user đọc/ghi profile của chính họ
3. **Error Handling**: Tất cả các operation đều có try-catch và debug logs
4. **Metadata Extraction**: Hệ thống tự động trích xuất thông tin từ user metadata của Supabase

## Troubleshooting

### Profile không được tạo
1. Kiểm tra debug logs để xem lỗi
2. Đảm bảo bảng `profiles` đã được tạo
3. Kiểm tra RLS policies
4. Kiểm tra user có quyền ghi vào bảng

### Metadata không được trích xuất
1. Kiểm tra user metadata trong Supabase dashboard
2. Kiểm tra các key được sử dụng trong `_extractDisplayName()` và `_extractAvatarUrl()`
3. Thêm debug logs để xem metadata structure 