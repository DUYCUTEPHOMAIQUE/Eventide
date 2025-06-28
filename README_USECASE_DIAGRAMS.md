# ENVA - Use Case Diagrams Documentation

## Tổng quan

Đây là bộ tài liệu use case diagram chi tiết cho ứng dụng **Enva** - một ứng dụng quản lý sự kiện và mời khách được phát triển bằng Flutter.

## Các file Use Case Diagram

### 1. `ENVA_USECASE_DIAGRAM.md` - Chi tiết nhất
- **Mô tả**: Use case diagram đầy đủ với 56 use cases
- **Đặc điểm**: 
  - Phân chia theo 9 nhóm chức năng chính
  - Bao gồm tất cả relationships (include, extend)
  - Mô tả chi tiết từng use case
  - Thông tin về công nghệ và database schema

### 2. `ENVA_SIMPLE_USECASE.md` - Đơn giản và dễ đọc
- **Mô tả**: Use case diagram đơn giản với emoji và nhóm chức năng
- **Đặc điểm**:
  - Sử dụng emoji để dễ nhận biết
  - Tập trung vào 7 nhóm chức năng chính
  - Mô tả ngắn gọn và dễ hiểu
  - Workflow chính của ứng dụng

### 3. `ENVA_UML_USECASE.md` - Chuẩn UML
- **Mô tả**: Use case diagram theo chuẩn UML truyền thống
- **Đặc điểm**:
  - Tuân thủ chuẩn UML notation
  - Bảng mô tả chi tiết từng use case
  - Preconditions và Postconditions
  - System architecture overview

## Cách sử dụng

### Xem Use Case Diagram
1. Mở file `.md` trong editor hỗ trợ Mermaid
2. Hoặc copy code Mermaid vào [Mermaid Live Editor](https://mermaid.live/)
3. Hoặc sử dụng GitHub/GitLab để render diagram

### Công cụ hỗ trợ Mermaid
- **VS Code**: Extension "Mermaid Preview"
- **GitHub**: Tự động render trong markdown
- **GitLab**: Tự động render trong markdown
- **Online**: [Mermaid Live Editor](https://mermaid.live/)

## Cấu trúc ứng dụng Enva

### 🎯 Mục đích chính
Enva là ứng dụng giúp người dùng:
- Tạo và quản lý sự kiện
- Mời khách tham gia
- Theo dõi RSVP
- Nhận thông báo
- Quản lý hồ sơ cá nhân

### 🏗️ Kiến trúc hệ thống
```
Frontend (Flutter)
├── UI Layer (Screens, Widgets)
├── Business Logic (BLoC, Services)
└── Data Layer (Repositories, Local Storage)

Backend (Supabase)
├── Database (PostgreSQL)
├── Authentication
├── Real-time Subscriptions
└── Storage (Cloudinary)

External Services
├── Firebase FCM (Notifications)
├── Google Gemini AI (Content Generation)
├── Maps API (Location Services)
└── Payment Gateway (Stripe)
```

### 📱 Các màn hình chính
1. **Authentication Screens**
   - Đăng ký/Đăng nhập
   - Xác thực OTP
   - Hoàn tất hồ sơ

2. **Home Screen**
   - Danh sách sự kiện
   - Tạo sự kiện mới
   - Lọc theo danh mục

3. **Event Creation Screen**
   - Form tạo sự kiện
   - Upload ảnh
   - Chọn vị trí
   - Mời người tham gia

4. **Event Detail Screen**
   - Chi tiết sự kiện
   - Danh sách người mời
   - RSVP management
   - Chia sẻ sự kiện

5. **Profile Screen**
   - Thông tin cá nhân
   - Cài đặt ứng dụng
   - Quản lý đăng ký

6. **Notifications Screen**
   - Danh sách thông báo
   - Đánh dấu đã đọc

## Công nghệ sử dụng

### Frontend
- **Flutter** - Cross-platform framework
- **BLoC Pattern** - State management
- **Provider** - Dependency injection
- **Material Design** - UI framework

### Backend & Services
- **Supabase** - Backend as a Service
- **Cloudinary** - Image storage & processing
- **Firebase FCM** - Push notifications
- **Google Gemini AI** - AI content generation

### Local Storage
- **Hive** - NoSQL database
- **SharedPreferences** - Key-value storage
- **SQLite** - Local database

### External APIs
- **Maps API** - Location services
- **Geocoding API** - Address conversion
- **Payment API** - Subscription management

## Database Schema

### Core Tables
```sql
-- Users table
users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP
);

-- Events/Cards table
cards (
  id UUID PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  owner_id UUID REFERENCES users(id),
  image_url TEXT,
  background_image_url TEXT,
  location TEXT,
  latitude DECIMAL,
  longitude DECIMAL,
  event_date_time TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Invitations table
invites (
  id UUID PRIMARY KEY,
  card_id UUID REFERENCES cards(id),
  sender_id UUID REFERENCES users(id),
  receiver_id UUID REFERENCES users(id),
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Notifications table
notifications (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT,
  event_id UUID REFERENCES cards(id),
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Subscriptions table
subscriptions (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  plan_type TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);
```

## Workflow chính

### 1. Quy trình tạo sự kiện
```
Đăng nhập → Tạo sự kiện → Upload ảnh → Chọn vị trí → 
Đặt thời gian → Mời người tham gia → Gửi thông báo
```

### 2. Quy trình mời khách
```
Nhận lời mời → Xem chi tiết → RSVP (Chấp nhận/Từ chối) → 
Nhận nhắc nhở → Tham gia sự kiện
```

### 3. Quy trình quản lý hồ sơ
```
Xem hồ sơ → Cập nhật thông tin → Thay đổi cài đặt → 
Nâng cấp tài khoản (nếu cần)
```

## Tính năng nổi bật

### ✅ Đã triển khai
- **Real-time synchronization** với Supabase
- **Offline support** với local storage
- **Multi-language support** (English/Vietnamese)
- **Dark/Light theme** toggle
- **Location-based features** với GPS
- **AI-powered content generation**
- **Push notifications** system
- **Subscription management**
- **Image upload & processing**
- **Map integration**

### 🔄 Đang phát triển
- **Advanced analytics**
- **Social features**
- **Calendar integration**
- **Advanced AI features**

## Hướng dẫn đóng góp

### Cách thêm Use Case mới
1. Xác định Actor và Use Case
2. Thêm vào diagram Mermaid
3. Cập nhật mô tả trong bảng
4. Cập nhật workflow nếu cần

### Cách cập nhật diagram
1. Chỉnh sửa code Mermaid
2. Test render trên Mermaid Live Editor
3. Commit changes với message rõ ràng
4. Update documentation nếu cần

## Liên hệ và hỗ trợ

Nếu có câu hỏi về use case diagrams hoặc ứng dụng Enva, vui lòng:
- Tạo issue trên repository
- Liên hệ team phát triển
- Tham khảo documentation chi tiết

---

**Lưu ý**: Các use case diagram này được tạo dựa trên phân tích codebase thực tế của ứng dụng Enva và có thể được cập nhật khi có thay đổi trong hệ thống. 