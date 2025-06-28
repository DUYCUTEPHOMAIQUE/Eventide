# ENVA - Simple Use Case Diagram

## Tổng quan
Enva là ứng dụng quản lý sự kiện và mời khách với giao diện minimalist, hỗ trợ đa ngôn ngữ và tích hợp AI.

## Use Case Diagram (Simplified)

```mermaid
graph TB
    %% Actors
    User((👤 Người dùng))
    Guest((👥 Khách))
    AI((🤖 AI Service))
    Payment((💳 Payment))
    Notification((🔔 Notification))
    Map((🗺️ Map Service))
    
    %% Main Use Case Groups
    subgraph "🔐 Authentication"
        A1[Đăng ký]
        A2[Đăng nhập]
        A3[Xác thực OTP]
        A4[Hoàn tất hồ sơ]
    end
    
    subgraph "📅 Event Management"
        E1[Tạo sự kiện]
        E2[Chỉnh sửa sự kiện]
        E3[Xem chi tiết]
        E4[Xem danh sách]
        E5[Tạo bằng AI]
        E6[Upload ảnh]
        E7[Chọn vị trí]
    end
    
    subgraph "📧 Invitation System"
        I1[Mời người tham gia]
        I2[Chấp nhận/Từ chối]
        I3[Xem danh sách mời]
        I4[Tìm kiếm người dùng]
        I5[Gửi nhắc nhở]
    end
    
    subgraph "👤 Profile & Settings"
        P1[Xem hồ sơ]
        P2[Cập nhật thông tin]
        P3[Thay đổi ngôn ngữ]
        P4[Thay đổi theme]
    end
    
    subgraph "🔔 Notifications"
        N1[Nhận thông báo]
        N2[Xem danh sách]
        N3[Đánh dấu đã đọc]
    end
    
    subgraph "💎 Subscription"
        S1[Xem gói đăng ký]
        S2[Nâng cấp tài khoản]
        S3[Nhập mã premium]
    end
    
    %% User Relationships
    User --> A1
    User --> A2
    User --> A3
    User --> A4
    
    User --> E1
    User --> E2
    User --> E3
    User --> E4
    User --> E5
    User --> E6
    User --> E7
    
    User --> I1
    User --> I3
    User --> I4
    User --> I5
    
    User --> P1
    User --> P2
    User --> P3
    User --> P4
    
    User --> N2
    User --> N3
    
    User --> S1
    User --> S2
    User --> S3
    
    %% Guest Relationships
    Guest --> I2
    
    %% External System Dependencies
    E5 --> AI
    E6 --> Map
    E7 --> Map
    I5 --> Notification
    N1 --> Notification
    S2 --> Payment
    S3 --> Payment
    
    %% Include Relationships
    E1 ..> E6 : <<include>>
    E1 ..> E7 : <<include>>
    I1 ..> I4 : <<include>>
    
    %% Extend Relationships
    E5 ..> AI : <<extend>>
    
    %% Styling
    classDef actor fill:#e3f2fd,stroke:#1976d2,stroke-width:3px
    classDef useCase fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef system fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    
    class User,Guest actor
    class A1,A2,A3,A4,E1,E2,E3,E4,E5,E6,E7,I1,I2,I3,I4,I5,P1,P2,P3,P4,N1,N2,N3,S1,S2,S3 useCase
    class AI,Payment,Notification,Map system
```

## Chi tiết các chức năng chính

### 🔐 Authentication System
- **Đăng ký**: Tạo tài khoản mới với email
- **Đăng nhập**: Xác thực người dùng (email/password, Google, Facebook)
- **Xác thực OTP**: Xác minh email qua mã OTP
- **Hoàn tất hồ sơ**: Cập nhật thông tin cá nhân sau khi đăng ký

### 📅 Event Management
- **Tạo sự kiện**: Tạo event card mới với thông tin chi tiết
- **Chỉnh sửa sự kiện**: Cập nhật thông tin event đã tạo
- **Xem chi tiết**: Hiển thị thông tin đầy đủ của sự kiện
- **Xem danh sách**: Hiển thị tất cả events với phân loại
- **Tạo bằng AI**: Sử dụng Google Gemini AI để tạo content
- **Upload ảnh**: Tải lên hình ảnh cho sự kiện
- **Chọn vị trí**: Đặt địa điểm sự kiện trên bản đồ

### 📧 Invitation System
- **Mời người tham gia**: Gửi lời mời tham gia sự kiện
- **Chấp nhận/Từ chối**: Phản hồi lời mời (RSVP)
- **Xem danh sách mời**: Quản lý danh sách participants
- **Tìm kiếm người dùng**: Tìm kiếm để mời tham gia
- **Gửi nhắc nhở**: Nhắc nhở participants về sự kiện

### 👤 Profile & Settings
- **Xem hồ sơ**: Hiển thị thông tin cá nhân và thống kê
- **Cập nhật thông tin**: Chỉnh sửa thông tin profile
- **Thay đổi ngôn ngữ**: Chuyển đổi EN/VI
- **Thay đổi theme**: Light/Dark mode

### 🔔 Notifications
- **Nhận thông báo**: Nhận push/local notifications
- **Xem danh sách**: Quản lý tất cả notifications
- **Đánh dấu đã đọc**: Mark notifications as read

### 💎 Subscription System
- **Xem gói đăng ký**: Hiển thị các plan available
- **Nâng cấp tài khoản**: Upgrade lên premium
- **Nhập mã premium**: Redeem premium code

## Công nghệ sử dụng

### Frontend
- **Flutter** - Cross-platform framework
- **BLoC/Provider** - State management
- **Material Design** - UI framework
- **Flutter Intl** - Internationalization

### Backend & Services
- **Supabase** - Database & Authentication
- **Cloudinary** - Image storage
- **Firebase FCM** - Push notifications
- **Google Gemini AI** - AI content generation
- **Flutter Map** - Map integration

### Key Features
- ✅ **Real-time updates** với Supabase
- ✅ **Offline support** với local storage
- ✅ **Multi-language** (English/Vietnamese)
- ✅ **Dark/Light theme**
- ✅ **Location-based features**
- ✅ **AI-powered content**
- ✅ **Subscription system**
- ✅ **Push notifications**

## Database Tables

| Table | Mô tả |
|-------|-------|
| `users` | Thông tin người dùng |
| `cards` | Sự kiện/Event cards |
| `invites` | Lời mời tham gia |
| `notifications` | Thông báo |
| `subscriptions` | Gói đăng ký |
| `user_devices` | Thiết bị người dùng |

## Workflow chính

1. **Đăng ký/Đăng nhập** → Xác thực OTP → Hoàn tất hồ sơ
2. **Tạo sự kiện** → Upload ảnh → Chọn vị trí → Mời người tham gia
3. **Nhận lời mời** → RSVP → Nhận thông báo nhắc nhở
4. **Quản lý hồ sơ** → Thay đổi cài đặt → Nâng cấp tài khoản 