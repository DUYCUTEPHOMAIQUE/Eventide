# Enva - Event Card Creator

Flutter app để tạo và quản lý event cards với Supabase backend.

## Tính năng đã implement

### 🔐 Authentication & User Management
- **SharedPreferences Integration**: Tự động lưu thông tin đăng nhập vào SharedPreferences khi user đăng nhập thành công qua AuthWrapper
- **User Avatar Display**: Hiển thị avatar người dùng ở góc phải phía trên HomeScreen, lấy từ `userMetadata.image_url` của Supabase currentUser
- **Profile Screen**: Trang profile hiển thị thông tin user từ SharedPreferences và Supabase userMetadata

### 🏠 HomeScreen Features
- **Avatar Navigation**: Ấn vào avatar ở góc phải để chuyển sang ProfileScreen  
- **Add Card Button**: Nút "+" để tạo card mới
- **Auto User Info Save**: Tự động lưu thông tin đăng nhập khi authenticate thành công

### 👤 ProfileScreen Features
- **User Information Display**: Hiển thị full name, email, user ID, created date từ SharedPreferences
- **Avatar Display**: Hiển thị user avatar từ userMetadata hoặc default icon
- **Sign Out**: Tính năng đăng xuất với confirmation dialog
- **Edit Profile**: Placeholder cho tính năng chỉnh sửa profile

### 🎴 Card Creation (MVVM Pattern)
- **Simple MVVM Architecture**: 
  - Service Layer: `CardService` - CRUD operations với Supabase
  - ViewModel Layer: `CardCreationViewModel` - State management với ChangeNotifier
  - View Layer: `CardCreationScreen` - Stateless UI components
- **Form Fields**: Background image URL, title, description, image URL, location
- **Real-time Validation**: Form validation và error handling
- **Loading States**: Loading overlay khi đang tạo card

## Cấu trúc dự án

```
lib/
├── services/
│   ├── auth_service.dart          # Authentication & SharedPreferences
│   └── card_service.dart          # Card CRUD operations
├── viewmodels/
│   └── card_creation_viewmodel.dart # Card creation state management
├── screens/
│   ├── home/
│   │   └── home_screen.dart       # Trang chính với avatar navigation
│   ├── profile/
│   │   └── profile_screen.dart    # Trang profile người dùng
│   ├── card/
│   │   └── card_creation_screen.dart # Tạo card mới
│   └── authwrap/
│       └── auth_wrapper.dart      # Authentication wrapper
└── widgets/
    └── custom_text_field.dart     # Reusable text field component
```

## Luồng hoạt động

1. **Authentication Flow**:
   - User đăng nhập qua DashboardScreen
   - AuthWrapper detect authentication state
   - Tự động lưu user info vào SharedPreferences
   - Navigate to HomeScreen

2. **Home to Profile Flow**:
   - HomeScreen load user avatar từ Supabase userMetadata
   - User tap vào avatar ở góc phải
   - Navigate to ProfileScreen
   - ProfileScreen hiển thị info từ SharedPreferences

3. **Card Creation Flow**:
   - User tap nút "+" trên HomeScreen
   - Navigate to CardCreationScreen
   - MVVM pattern handle form validation và submission
   - Success -> return to HomeScreen với notification

## Dependencies

```yaml
dependencies:
  shared_preferences: ^2.1.1  # Lưu trữ user info local
  provider: ^6.0.5           # State management cho MVVM
  supabase_flutter: ^1.10.9  # Backend authentication & database
```

## Database Schema

User information được lưu trong:
- **Supabase Auth**: userMetadata chứa `image_url`, `full_name`
- **SharedPreferences**: Cache user info locally cho performance

Cards được lưu trong Supabase `cards` table với RLS policies.

## Các tính năng chính đã implement

✅ SharedPreferences integration cho user info  
✅ User avatar display ở HomeScreen  
✅ Profile navigation từ avatar  
✅ ProfileScreen với user information  
✅ Simple MVVM pattern cho card creation  
✅ Authentication state management với AuthWrapper  
✅ Clean architecture separation (Service-ViewModel-View)

## Next Steps

- [ ] Edit profile functionality
- [ ] Image upload cho user avatar
- [ ] Display created cards list ở HomeScreen
- [ ] Card detail view và editing
- [ ] Search và filter cards

## 🚀 Tính năng chính

### 1. **Xác thực người dùng (Authentication)**
- **Đăng nhập bằng Email & Password**: Xác thực truyền thống với email và mật khẩu
- **Đăng nhập bằng Google**: Tích hợp Google Sign-In để đăng nhập nhanh chóng
- **Quản lý phiên làm việc**: Sử dụng Supabase để quản lý phiên đăng nhập an toàn
- **Lưu trữ thông tin bảo mật**: Sử dụng Flutter Secure Storage để bảo vệ token và thông tin nhạy cảm

### 2. **Tạo thiệp mời sự kiện (Card Creation)**
- **Giao diện tạo thiệp trực quan**: Interface hiện đại với preview mode
- **Tùy chỉnh hình nền**: Chọn và thay đổi hình nền cho thiệp mời từ thư viện ảnh
- **Nhập thông tin sự kiện**: 
  - Tiêu đề sự kiện
  - Ngày và giờ tổ chức
  - Địa điểm
  - Mô tả chi tiết
- **Thêm ảnh kỷ niệm**: Upload nhiều ảnh để tạo bộ sưu tập memories
- **Chế độ xem trước**: Preview thiệp mời trước khi hoàn thành

### 3. **Quản lý thiệp mời**
- **Danh sách thiệp mời**: Hiển thị tất cả thiệp mời theo dạng swipeable cards
- **Phân loại sự kiện**: 
  - Upcoming events (Sự kiện sắp tới)
  - Past events (Sự kiện đã qua)
  - Saved events (Sự kiện đã lưu)
- **Card swiper interface**: Giao diện vuốt cards mượt mà và hiện đại

### 4. **Hệ thống lời mời (Invitation System)**
- **Gửi lời mời**: Chia sẻ thiệp mời đến người dùng khác
- **Quản lý trạng thái lời mời**: 
  - Pending (Đang chờ)
  - Accepted (Đã chấp nhận)
  - Expired (Đã hết hạn)
- **Lưu trữ local**: Sử dụng Hive database để lưu trữ offline

### 5. **Đa ngôn ngữ (Internationalization)**
- **Hỗ trợ 2 ngôn ngữ**:
  - Tiếng Anh (English)
  - Tiếng Việt (Vietnamese)
- **Chuyển đổi ngôn ngữ động**: Toggle language button với lưu trữ preference
- **Localization files**: ARB files cho quản lý văn bản đa ngôn ngữ

### 6. **Quản lý giao diện (Theme Management)**
- **Dark/Light Mode**: Hỗ trợ chế độ sáng và tối
- **System theme**: Tự động theo theme hệ thống
- **Lưu trữ preference**: Ghi nhớ lựa chọn theme của người dùng

## 🏗️ Kiến trúc ứng dụng

### **Clean Architecture với BLoC Pattern**

Ứng dụng được xây dựng theo kiến trúc Clean Architecture với các lớp rõ ràng:

```
lib/
├── blocs/              # Business Logic Components
│   ├── auth/          # Authentication logic
│   ├── card/          # Card creation logic
│   ├── home/          # Home screen logic
│   ├── theme/         # Theme management
│   └── locale/        # Localization management
├── models/            # Data models
├── repositories/      # Data access layer
├── services/          # External services
├── screens/           # UI screens
├── utils/             # Utilities and helpers
└── l10n/             # Localization files
```

### **State Management: BLoC/Cubit**
- **AuthBloc**: Quản lý trạng thái xác thực
- **CardCreationBloc**: Xử lý logic tạo thiệp mời
- **ThemeCubit**: Quản lý theme
- **LocaleCubit**: Quản lý ngôn ngữ
- **HomeBloc**: Xử lý logic màn hình chính

## 🛠️ Công nghệ sử dụng

### **Frontend Framework**
- **Flutter 3.5.2+**: Framework UI đa nền tảng
- **Dart**: Ngôn ngữ lập trình chính

### **State Management**
- **flutter_bloc 9.0.0**: BLoC pattern implementation
- **bloc 9.0.0**: Core BLoC library
- **equatable 2.0.7**: Object comparison utilities

### **Backend & Authentication**
- **Supabase Flutter 2.8.3**: Backend-as-a-Service
- **Firebase Core 3.11.0**: Firebase integration
- **Google Sign-In 6.2.2**: Google authentication
- **Facebook Auth 7.1.1**: Facebook authentication

### **Local Storage**
- **Hive 2.2.3 & Hive Flutter 1.1.0**: NoSQL local database
- **Flutter Secure Storage 9.2.4**: Secure local storage
- **Shared Preferences 2.1.1**: Simple key-value storage

### **UI/UX**
- **Google Fonts 4.0.4**: Typography
- **Card Swiper 3.0.1**: Swipeable card interface
- **Cached Network Image 3.4.1**: Image loading và caching
- **Rive 0.13.20**: Advanced animations

### **Utilities**
- **Image Picker 1.0.4**: Image selection từ gallery/camera
- **Share Plus 10.1.4**: Sharing functionality
- **Flutter Toast 8.2.11**: Toast notifications
- **Flutter Dotenv 5.2.1**: Environment variables

## 📱 Cấu trúc màn hình

### **1. Authentication Flow**
- **DashboardScreen**: Màn hình welcome với options đăng nhập
- **LoginScreen**: Form đăng nhập email/password
- **SignupScreen**: Form đăng ký tài khoản mới
- **AuthWrapper**: Wrapper để điều hướng authentication

### **2. Main App Flow**
- **HomeScreen**: Màn hình chính với card swiper
- **CardCreationScreen**: Màn hình tạo thiệp mời
- **CardPreviewScreen**: Xem trước thiệp mời
- **ProfileScreen**: Thông tin và cài đặt người dùng

### **3. Shared Components**
- **InviteCard**: Component hiển thị thiệp mời
- **UserAvatar**: Component avatar người dùng
- **ThemeToggleButton**: Nút chuyển đổi theme
- **LanguageToggleButton**: Nút chuyển đổi ngôn ngữ

## 🗄️ Mô hình dữ liệu

### **CardModel**
```dart
class CardModel {
  final String id;
  final String title;           // Tên sự kiện
  final String description;     // Mô tả
  final String imageUserUrl;    // Avatar người tạo
  final String ownerId;         // ID người sở hữu
  final String backgroundImageUrl; // Hình nền
  final String location;        // Địa điểm
  final String created_at;      // Thời gian tạo
}
```

### **InviteModel**
```dart
class InviteModel {
  final String id;
  final String cardId;          // ID thiệp mời
  final String senderId;        // ID người gửi
  final String receiverId;      // ID người nhận
  final String status;          // Trạng thái: pending/accepted/expired
  final String sent_at;         // Thời gian gửi
  final String expired_at;      // Thời gian hết hạn
  final String accepted_at;     // Thời gian chấp nhận
}
```

### **UserModel**
```dart
class User {
  final String id;
  final String name;            // Tên người dùng
  final String email;           // Email
  final String avatarUrl;       // URL avatar
}
```

## 🚦 Luồng hoạt động

### **1. Authentication Flow**
1. User mở app → `AuthWrapper` kiểm tra session
2. Nếu chưa đăng nhập → `DashboardScreen`
3. User chọn đăng nhập → Modal bottom sheet với options
4. Đăng nhập thành công → Navigate to `HomeScreen`

### **2. Card Creation Flow**
1. User nhấn "+" button → `CardCreationScreen`
2. Chọn background image từ gallery
3. Nhập thông tin sự kiện (title, date, location, description)
4. Thêm memory images (optional)
5. Preview card → `CardPreviewScreen`
6. Submit để lưu card

### **3. Home Flow**
1. Load danh sách cards từ local storage (Hive)
2. Hiển thị cards trong swiper interface
3. User có thể swipe để xem cards khác nhau
4. Filter theo category (upcoming/past/saved)

## 🔧 Cài đặt và chạy ứng dụng

### **Prerequisites**
- Flutter SDK 3.5.2+
- Dart SDK
- Android Studio / VS Code
- Supabase account
- Firebase project

### **Installation Steps**

1. **Clone repository**
```bash
git clone [repository-url]
cd enva
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Setup environment variables**
Tạo file `.env` trong root directory:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GOOGLE_CLIENT_ID=your_google_client_id
```

4. **Configure Firebase**
- Add `google-services.json` cho Android
- Add `GoogleService-Info.plist` cho iOS

5. **Generate code**
```bash
flutter packages pub run build_runner build
```

6. **Run app**
```bash
flutter run
```

## 🧪 Testing

### **Unit Tests**
```bash
flutter test
```

### **Integration Tests**
```bash
flutter drive --target=test_driver/app.dart
```

## 📦 Build & Deployment

### **Android APK**
```bash
flutter build apk --release
```

### **iOS**
```bash
flutter build ios --release
```

### **Web**
```bash
flutter build web
```

## 🔐 Bảo mật

- **Secure Storage**: Sử dụng Flutter Secure Storage cho tokens
- **Environment Variables**: Sensitive data trong .env files
- **Supabase RLS**: Row Level Security policies
- **Token Management**: Automatic token refresh

## 🎨 Design System

### **Colors**
- Primary: Black/White theme
- Background: Dynamic based on theme
- Accent: White with opacity overlays

### **Typography**
- Primary Font: Aldrich (custom font)
- Secondary: Google Fonts (Poppins)

### **UI Components**
- Glassmorphism effects với BackdropFilter
- Animated buttons với ScaleTransition
- Modal bottom sheets cho interactions
- Card-based layouts

## 🔄 State Management Flow

```
Event → BLoC → State → UI Update
  ↑                      ↓
Repository ← Service ← Action
```

**Example: Authentication Flow**
```
EmailSignInRequested → AuthBloc → AuthLoading → UI shows loading
                          ↓
                   SupabaseServices.signInWithEmail
                          ↓
                   AuthSuccess/AuthError → UI update
```

## 📱 Platform Support

- ✅ **Android**: Full support
- ✅ **iOS**: Full support  
- ✅ **Web**: Basic support
- ⚠️ **Desktop**: Limited testing

## 🐛 Known Issues & Limitations

1. **Offline functionality**: Limited offline support for card creation
2. **Image compression**: Large images might impact performance
3. **Real-time sync**: Cards don't sync in real-time between devices
4. **Push notifications**: Not implemented yet

## 🔮 Future Enhancements

1. **Real-time collaboration**: Multiple users editing same card
2. **Push notifications**: Invite notifications
3. **Advanced templates**: Pre-designed card templates
4. **Social features**: Like, comment, share cards
5. **Analytics**: Event attendance tracking
6. **Payment integration**: Premium features
7. **Calendar integration**: Sync with device calendar

## 👥 Đóng góp

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 📞 Liên hệ

- **Author**: [Your Name]
- **Email**: [your.email@example.com]
- **Project Link**: [https://github.com/username/enva](https://github.com/username/enva)

## 🙏 Acknowledgments

- Flutter team cho framework tuyệt vời
- Supabase cho backend services
- Community packages và contributors
- Design inspiration từ modern invitation apps

---

**Enva** - *Making beautiful event invitations simple and accessible for everyone* 🎉
