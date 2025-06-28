# ENVA - Use Case Diagram

## Tổng quan ứng dụng
Enva là một ứng dụng Flutter về quản lý sự kiện và mời khách với các tính năng chính:
- Quản lý sự kiện (Event Management)
- Hệ thống mời khách (Invitation System)
- Xác thực người dùng (Authentication)
- Thông báo (Notifications)
- Hệ thống đăng ký (Subscription System)
- Đa ngôn ngữ (Internationalization)

## Use Case Diagram (Mermaid)

```mermaid
graph TB
    %% Actors
    User((Người dùng))
    Guest((Khách))
    Admin((Admin))
    AI((AI Service))
    Payment((Payment System))
    Notification((Notification System))
    Map((Map Service))
    Cloud((Cloud Storage))
    
    %% Authentication Use Cases
    subgraph "Authentication System"
        UC1[Đăng ký tài khoản]
        UC2[Đăng nhập]
        UC3[Xác thực OTP]
        UC4[Hoàn tất hồ sơ]
        UC5[Đăng xuất]
        UC6[Quên mật khẩu]
        UC7[Đăng nhập bằng Google]
        UC8[Đăng nhập bằng Facebook]
    end
    
    %% Event Management Use Cases
    subgraph "Event Management"
        UC9[Tạo sự kiện mới]
        UC10[Chỉnh sửa sự kiện]
        UC11[Xóa sự kiện]
        UC12[Xem chi tiết sự kiện]
        UC13[Xem danh sách sự kiện]
        UC14[Lọc sự kiện theo danh mục]
        UC15[Tạo sự kiện bằng AI]
        UC16[Preview sự kiện]
        UC17[Upload ảnh sự kiện]
        UC18[Chọn vị trí sự kiện]
        UC19[Đặt thời gian sự kiện]
    end
    
    %% Invitation System Use Cases
    subgraph "Invitation System"
        UC20[Mời người tham gia]
        UC21[Chấp nhận lời mời]
        UC22[Từ chối lời mời]
        UC23[Xem danh sách người mời]
        UC24[Tìm kiếm người dùng]
        UC25[Gửi nhắc nhở]
        UC26[Xem trạng thái lời mời]
        UC27[RSVP cho sự kiện]
    end
    
    %% Profile Management Use Cases
    subgraph "Profile Management"
        UC28[Xem hồ sơ cá nhân]
        UC29[Cập nhật thông tin cá nhân]
        UC30[Thay đổi ảnh đại diện]
        UC31[Xem thống kê sự kiện]
        UC32[Thay đổi ngôn ngữ]
        UC33[Thay đổi theme]
    end
    
    %% Notification System Use Cases
    subgraph "Notification System"
        UC34[Nhận thông báo]
        UC35[Xem danh sách thông báo]
        UC36[Đánh dấu đã đọc]
        UC37[Xóa thông báo]
        UC38[Đánh dấu tất cả đã đọc]
        UC39[Push notification]
        UC40[Local notification]
    end
    
    %% Subscription System Use Cases
    subgraph "Subscription System"
        UC41[Xem gói đăng ký]
        UC42[Nâng cấp tài khoản]
        UC43[Nhập mã premium]
        UC44[Xem giới hạn sử dụng]
        UC45[Quản lý thanh toán]
    end
    
    %% Location Services Use Cases
    subgraph "Location Services"
        UC46[Lấy vị trí hiện tại]
        UC47[Chọn vị trí trên bản đồ]
        UC48[Xem bản đồ sự kiện]
        UC49[Mở ứng dụng bản đồ]
        UC50[Geocoding địa chỉ]
    end
    
    %% AI Integration Use Cases
    subgraph "AI Integration"
        UC51[Tạo sự kiện bằng AI]
        UC52[Gợi ý nội dung]
        UC53[Phân tích sự kiện]
    end
    
    %% Sharing & Social Use Cases
    subgraph "Sharing & Social"
        UC54[Chia sẻ sự kiện]
        UC55[Export sự kiện]
        UC56[In sự kiện]
    end
    
    %% Relationships - Authentication
    User --> UC1
    User --> UC2
    User --> UC3
    User --> UC4
    User --> UC5
    User --> UC6
    User --> UC7
    User --> UC8
    
    %% Relationships - Event Management
    User --> UC9
    User --> UC10
    User --> UC11
    User --> UC12
    User --> UC13
    User --> UC14
    User --> UC15
    User --> UC16
    User --> UC17
    User --> UC18
    User --> UC19
    
    %% Relationships - Invitation System
    User --> UC20
    User --> UC21
    User --> UC22
    User --> UC23
    User --> UC24
    User --> UC25
    User --> UC26
    User --> UC27
    Guest --> UC21
    Guest --> UC22
    Guest --> UC27
    
    %% Relationships - Profile Management
    User --> UC28
    User --> UC29
    User --> UC30
    User --> UC31
    User --> UC32
    User --> UC33
    
    %% Relationships - Notification System
    User --> UC35
    User --> UC36
    User --> UC37
    User --> UC38
    Notification --> UC34
    Notification --> UC39
    Notification --> UC40
    
    %% Relationships - Subscription System
    User --> UC41
    User --> UC42
    User --> UC43
    User --> UC44
    Payment --> UC45
    
    %% Relationships - Location Services
    User --> UC46
    User --> UC47
    User --> UC48
    User --> UC49
    Map --> UC50
    
    %% Relationships - AI Integration
    User --> UC51
    AI --> UC52
    AI --> UC53
    
    %% Relationships - Sharing & Social
    User --> UC54
    User --> UC55
    User --> UC56
    
    %% External System Dependencies
    UC17 --> Cloud
    UC30 --> Cloud
    UC47 --> Map
    UC48 --> Map
    UC49 --> Map
    UC51 --> AI
    UC52 --> AI
    UC53 --> AI
    UC39 --> Notification
    UC40 --> Notification
    UC42 --> Payment
    UC43 --> Payment
    
    %% Include Relationships
    UC9 ..> UC17 : <<include>>
    UC9 ..> UC18 : <<include>>
    UC9 ..> UC19 : <<include>>
    UC10 ..> UC17 : <<include>>
    UC10 ..> UC18 : <<include>>
    UC10 ..> UC19 : <<include>>
    UC20 ..> UC24 : <<include>>
    UC25 ..> UC39 : <<include>>
    UC51 ..> UC52 : <<include>>
    
    %% Extend Relationships
    UC15 ..> UC51 : <<extend>>
    UC34 ..> UC39 : <<extend>>
    UC34 ..> UC40 : <<extend>>
    
    %% Styling
    classDef actor fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef useCase fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef system fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    
    class User,Guest,Admin actor
    class UC1,UC2,UC3,UC4,UC5,UC6,UC7,UC8,UC9,UC10,UC11,UC12,UC13,UC14,UC15,UC16,UC17,UC18,UC19,UC20,UC21,UC22,UC23,UC24,UC25,UC26,UC27,UC28,UC29,UC30,UC31,UC32,UC33,UC34,UC35,UC36,UC37,UC38,UC39,UC40,UC41,UC42,UC43,UC44,UC45,UC46,UC47,UC48,UC49,UC50,UC51,UC52,UC53,UC54,UC55,UC56 useCase
    class AI,Payment,Notification,Map,Cloud system
```

## Chi tiết các Use Case

### 1. Authentication System
- **UC1**: Đăng ký tài khoản - Người dùng tạo tài khoản mới
- **UC2**: Đăng nhập - Xác thực người dùng
- **UC3**: Xác thực OTP - Xác minh email qua mã OTP
- **UC4**: Hoàn tất hồ sơ - Cập nhật thông tin cá nhân
- **UC5**: Đăng xuất - Kết thúc phiên làm việc
- **UC6**: Quên mật khẩu - Khôi phục mật khẩu
- **UC7**: Đăng nhập bằng Google - SSO với Google
- **UC8**: Đăng nhập bằng Facebook - SSO với Facebook

### 2. Event Management
- **UC9**: Tạo sự kiện mới - Tạo event card mới
- **UC10**: Chỉnh sửa sự kiện - Cập nhật thông tin event
- **UC11**: Xóa sự kiện - Xóa event
- **UC12**: Xem chi tiết sự kiện - Hiển thị thông tin đầy đủ
- **UC13**: Xem danh sách sự kiện - Hiển thị tất cả events
- **UC14**: Lọc sự kiện theo danh mục - Phân loại events
- **UC15**: Tạo sự kiện bằng AI - Sử dụng AI để tạo content
- **UC16**: Preview sự kiện - Xem trước event card
- **UC17**: Upload ảnh sự kiện - Tải lên hình ảnh
- **UC18**: Chọn vị trí sự kiện - Đặt địa điểm
- **UC19**: Đặt thời gian sự kiện - Lên lịch event

### 3. Invitation System
- **UC20**: Mời người tham gia - Gửi lời mời
- **UC21**: Chấp nhận lời mời - Xác nhận tham gia
- **UC22**: Từ chối lời mời - Từ chối tham gia
- **UC23**: Xem danh sách người mời - Quản lý participants
- **UC24**: Tìm kiếm người dùng - Tìm kiếm để mời
- **UC25**: Gửi nhắc nhở - Nhắc nhở participants
- **UC26**: Xem trạng thái lời mời - Theo dõi RSVP
- **UC27**: RSVP cho sự kiện - Phản hồi lời mời

### 4. Profile Management
- **UC28**: Xem hồ sơ cá nhân - Hiển thị thông tin user
- **UC29**: Cập nhật thông tin cá nhân - Chỉnh sửa profile
- **UC30**: Thay đổi ảnh đại diện - Upload avatar
- **UC31**: Xem thống kê sự kiện - Hiển thị metrics
- **UC32**: Thay đổi ngôn ngữ - Đa ngôn ngữ (EN/VI)
- **UC33**: Thay đổi theme - Light/Dark mode

### 5. Notification System
- **UC34**: Nhận thông báo - Nhận notifications
- **UC35**: Xem danh sách thông báo - Quản lý notifications
- **UC36**: Đánh dấu đã đọc - Mark as read
- **UC37**: Xóa thông báo - Delete notification
- **UC38**: Đánh dấu tất cả đã đọc - Mark all as read
- **UC39**: Push notification - FCM notifications
- **UC40**: Local notification - Local alerts

### 6. Subscription System
- **UC41**: Xem gói đăng ký - Hiển thị plans
- **UC42**: Nâng cấp tài khoản - Upgrade subscription
- **UC43**: Nhập mã premium - Redeem code
- **UC44**: Xem giới hạn sử dụng - Check limits
- **UC45**: Quản lý thanh toán - Payment management

### 7. Location Services
- **UC46**: Lấy vị trí hiện tại - Get current location
- **UC47**: Chọn vị trí trên bản đồ - Pick location on map
- **UC48**: Xem bản đồ sự kiện - View event map
- **UC49**: Mở ứng dụng bản đồ - Open maps app
- **UC50**: Geocoding địa chỉ - Convert address to coordinates

### 8. AI Integration
- **UC51**: Tạo sự kiện bằng AI - AI-powered event creation
- **UC52**: Gợi ý nội dung - Content suggestions
- **UC53**: Phân tích sự kiện - Event analytics

### 9. Sharing & Social
- **UC54**: Chia sẻ sự kiện - Share event
- **UC55**: Export sự kiện - Export event data
- **UC56**: In sự kiện - Print event

## Công nghệ sử dụng

### Frontend
- **Framework**: Flutter
- **State Management**: BLoC, Provider
- **UI**: Material Design, Custom Minimalist Theme
- **Localization**: Flutter Intl (EN/VI)

### Backend & Services
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth, Google Sign-In, Facebook Auth
- **Storage**: Cloudinary (Images)
- **Notifications**: Firebase Cloud Messaging (FCM)
- **AI**: Google Gemini AI
- **Maps**: Flutter Map, Google Maps API
- **Local Storage**: Hive, SharedPreferences

### External Integrations
- **Payment**: Stripe (planned)
- **Analytics**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics

## Database Schema

### Core Tables
- **users**: Thông tin người dùng
- **cards**: Sự kiện/Event cards
- **invites**: Lời mời tham gia
- **notifications**: Thông báo
- **subscriptions**: Gói đăng ký
- **user_devices**: Thiết bị người dùng

### Features
- **Real-time updates** với Supabase subscriptions
- **Offline support** với local storage
- **Push notifications** cho mobile
- **Multi-language support** (English/Vietnamese)
- **Dark/Light theme** support
- **Location-based features** với GPS
- **AI-powered content generation**
- **Subscription-based premium features** 