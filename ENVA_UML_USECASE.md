# ENVA - UML Use Case Diagram

## Tổng quan
Enva là ứng dụng quản lý sự kiện và mời khách với giao diện minimalist, hỗ trợ đa ngôn ngữ và tích hợp AI.

## UML Use Case Diagram

```mermaid
graph TB
    %% Actors
    User((User))
    Guest((Guest))
    Admin((Admin))
    AI((AI Service))
    Payment((Payment System))
    Notification((Notification System))
    Map((Map Service))
    Cloud((Cloud Storage))
    
    %% Use Cases
    %% Authentication
    UC1((Register))
    UC2((Login))
    UC3((Verify OTP))
    UC4((Complete Profile))
    UC5((Logout))
    UC6((Forgot Password))
    UC7((Google Login))
    UC8((Facebook Login))
    
    %% Event Management
    UC9((Create Event))
    UC10((Edit Event))
    UC11((Delete Event))
    UC12((View Event Details))
    UC13((View Event List))
    UC14((Filter Events))
    UC15((Create with AI))
    UC16((Preview Event))
    UC17((Upload Image))
    UC18((Select Location))
    UC19((Set Event Time))
    
    %% Invitation System
    UC20((Send Invitation))
    UC21((Accept Invitation))
    UC22((Decline Invitation))
    UC23((View Invitees))
    UC24((Search Users))
    UC25((Send Reminder))
    UC26((View Invite Status))
    UC27((RSVP Event))
    
    %% Profile Management
    UC28((View Profile))
    UC29((Update Profile))
    UC30((Change Avatar))
    UC31((View Statistics))
    UC32((Change Language))
    UC33((Change Theme))
    
    %% Notifications
    UC34((Receive Notification))
    UC35((View Notifications))
    UC36((Mark as Read))
    UC37((Delete Notification))
    UC38((Mark All Read))
    
    %% Subscription
    UC39((View Plans))
    UC40((Upgrade Account))
    UC41((Redeem Code))
    UC42((View Limits))
    
    %% Location Services
    UC43((Get Current Location))
    UC44((Pick Location))
    UC45((View Event Map))
    UC46((Open Maps App))
    
    %% Sharing
    UC47((Share Event))
    UC48((Export Event))
    
    %% Relationships
    %% User to Authentication
    User --> UC1
    User --> UC2
    User --> UC3
    User --> UC4
    User --> UC5
    User --> UC6
    User --> UC7
    User --> UC8
    
    %% User to Event Management
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
    
    %% User to Invitation System
    User --> UC20
    User --> UC23
    User --> UC24
    User --> UC25
    User --> UC26
    
    %% User to Profile Management
    User --> UC28
    User --> UC29
    User --> UC30
    User --> UC31
    User --> UC32
    User --> UC33
    
    %% User to Notifications
    User --> UC35
    User --> UC36
    User --> UC37
    User --> UC38
    
    %% User to Subscription
    User --> UC39
    User --> UC40
    User --> UC41
    User --> UC42
    
    %% User to Location Services
    User --> UC43
    User --> UC44
    User --> UC45
    User --> UC46
    
    %% User to Sharing
    User --> UC47
    User --> UC48
    
    %% Guest to Invitation System
    Guest --> UC21
    Guest --> UC22
    Guest --> UC27
    
    %% Admin to Management
    Admin --> UC11
    Admin --> UC42
    
    %% External System Dependencies
    UC17 --> Cloud
    UC30 --> Cloud
    UC44 --> Map
    UC45 --> Map
    UC46 --> Map
    UC15 --> AI
    UC25 --> Notification
    UC34 --> Notification
    UC40 --> Payment
    UC41 --> Payment
    
    %% Include Relationships
    UC9 ..> UC17 : <<include>>
    UC9 ..> UC18 : <<include>>
    UC9 ..> UC19 : <<include>>
    UC10 ..> UC17 : <<include>>
    UC10 ..> UC18 : <<include>>
    UC10 ..> UC19 : <<include>>
    UC20 ..> UC24 : <<include>>
    UC25 ..> UC34 : <<include>>
    
    %% Extend Relationships
    UC15 ..> UC15 : <<extend>>
    UC34 ..> UC34 : <<extend>>
    
    %% Styling
    classDef actor fill:#e1f5fe,stroke:#01579b,stroke-width:3px
    classDef useCase fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef system fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    
    class User,Guest,Admin actor
    class UC1,UC2,UC3,UC4,UC5,UC6,UC7,UC8,UC9,UC10,UC11,UC12,UC13,UC14,UC15,UC16,UC17,UC18,UC19,UC20,UC21,UC22,UC23,UC24,UC25,UC26,UC27,UC28,UC29,UC30,UC31,UC32,UC33,UC34,UC35,UC36,UC37,UC38,UC39,UC40,UC41,UC42,UC43,UC44,UC45,UC46,UC47,UC48 useCase
    class AI,Payment,Notification,Map,Cloud system
```

## Detailed Use Case Descriptions

### Authentication Use Cases

| Use Case | Actor | Description | Preconditions | Postconditions |
|----------|-------|-------------|---------------|----------------|
| Register | User | Create new account with email | User not registered | Account created, OTP sent |
| Login | User | Authenticate user credentials | User registered | User logged in |
| Verify OTP | User | Verify email with OTP code | OTP sent to email | Email verified |
| Complete Profile | User | Update personal information | Email verified | Profile completed |
| Logout | User | End user session | User logged in | User logged out |
| Forgot Password | User | Reset password via email | User registered | Password reset email sent |
| Google Login | User | SSO with Google account | Google account available | User logged in |
| Facebook Login | User | SSO with Facebook account | Facebook account available | User logged in |

### Event Management Use Cases

| Use Case | Actor | Description | Preconditions | Postconditions |
|----------|-------|-------------|---------------|----------------|
| Create Event | User | Create new event card | User logged in | Event created |
| Edit Event | User | Modify existing event | Event exists, user is owner | Event updated |
| Delete Event | User/Admin | Remove event | Event exists, user is owner | Event deleted |
| View Event Details | User | Display full event information | Event exists | Event details shown |
| View Event List | User | Show all user's events | User logged in | Event list displayed |
| Filter Events | User | Filter events by category | Events exist | Filtered events shown |
| Create with AI | User | Generate event content using AI | User logged in | AI-generated content created |
| Preview Event | User | Preview event card | Event data entered | Event preview shown |
| Upload Image | User | Upload event image | User logged in | Image uploaded to cloud |
| Select Location | User | Choose event location on map | Map service available | Location selected |
| Set Event Time | User | Schedule event date/time | User logged in | Event time set |

### Invitation System Use Cases

| Use Case | Actor | Description | Preconditions | Postconditions |
|----------|-------|-------------|---------------|----------------|
| Send Invitation | User | Invite users to event | Event created, users found | Invitations sent |
| Accept Invitation | Guest | Accept event invitation | Invitation received | RSVP status updated |
| Decline Invitation | Guest | Decline event invitation | Invitation received | RSVP status updated |
| View Invitees | User | See list of invited users | Event exists | Invitee list displayed |
| Search Users | User | Find users to invite | User logged in | Search results shown |
| Send Reminder | User | Remind invitees about event | Invitations sent | Reminders sent |
| View Invite Status | User | Check RSVP responses | Invitations sent | Status displayed |
| RSVP Event | Guest | Respond to event invitation | Invitation received | RSVP recorded |

### Profile Management Use Cases

| Use Case | Actor | Description | Preconditions | Postconditions |
|----------|-------|-------------|---------------|----------------|
| View Profile | User | Display user profile | User logged in | Profile displayed |
| Update Profile | User | Modify personal information | User logged in | Profile updated |
| Change Avatar | User | Update profile picture | User logged in | Avatar updated |
| View Statistics | User | See event statistics | User logged in | Statistics displayed |
| Change Language | User | Switch app language | User logged in | Language changed |
| Change Theme | User | Toggle light/dark mode | User logged in | Theme changed |

### Notification Use Cases

| Use Case | Actor | Description | Preconditions | Postconditions |
|----------|-------|-------------|---------------|----------------|
| Receive Notification | System | Get push/local notification | Notification system active | Notification received |
| View Notifications | User | See notification list | User logged in | Notifications displayed |
| Mark as Read | User | Mark notification as read | Notification exists | Notification marked read |
| Delete Notification | User | Remove notification | Notification exists | Notification deleted |
| Mark All Read | User | Mark all notifications as read | Notifications exist | All marked read |

### Subscription Use Cases

| Use Case | Actor | Description | Preconditions | Postconditions |
|----------|-------|-------------|---------------|----------------|
| View Plans | User | See subscription options | User logged in | Plans displayed |
| Upgrade Account | User | Purchase premium plan | User logged in | Account upgraded |
| Redeem Code | User | Use premium code | Valid code available | Premium activated |
| View Limits | User | Check usage limits | User logged in | Limits displayed |

### Location Services Use Cases

| Use Case | Actor | Description | Preconditions | Postconditions |
|----------|-------|-------------|---------------|----------------|
| Get Current Location | User | Get GPS coordinates | Location permission granted | Location obtained |
| Pick Location | User | Select location on map | Map service available | Location selected |
| View Event Map | User | See event location on map | Event has location | Map displayed |
| Open Maps App | User | Open external maps app | Maps app available | Maps app opened |

### Sharing Use Cases

| Use Case | Actor | Description | Preconditions | Postconditions |
|----------|-------|-------------|---------------|----------------|
| Share Event | User | Share event with others | Event exists | Event shared |
| Export Event | User | Export event data | Event exists | Event exported |

## System Architecture

### Frontend Layer
- **Flutter Framework** - Cross-platform UI
- **BLoC Pattern** - State management
- **Provider** - Dependency injection
- **Material Design** - UI components

### Business Logic Layer
- **Services** - Business logic implementation
- **Repositories** - Data access abstraction
- **ViewModels** - UI state management

### Data Layer
- **Supabase** - Backend as a Service
- **Local Storage** - Offline data persistence
- **Cloud Storage** - File storage

### External Services
- **Firebase FCM** - Push notifications
- **Google Gemini AI** - AI content generation
- **Cloudinary** - Image processing
- **Maps API** - Location services

## Database Schema Overview

```sql
-- Core Tables
users (id, email, display_name, avatar_url, created_at, updated_at)
cards (id, title, description, owner_id, image_url, background_image_url, location, latitude, longitude, event_date_time, created_at)
invites (id, card_id, sender_id, receiver_id, status, created_at)
notifications (id, user_id, type, title, message, event_id, is_read, created_at)
subscriptions (id, user_id, plan_type, status, expires_at, created_at)
user_devices (id, user_id, device_token, platform, created_at)
```

## Key Features & Capabilities

### ✅ Implemented Features
- **Real-time synchronization** with Supabase
- **Offline support** with local storage
- **Multi-language support** (English/Vietnamese)
- **Dark/Light theme** toggle
- **Location-based features** with GPS
- **AI-powered content generation**
- **Push notifications** system
- **Subscription management**
- **Image upload & processing**
- **Map integration**

### 🔄 Workflow Patterns
1. **Event Creation Flow**: Login → Create Event → Upload Image → Select Location → Invite Users
2. **Invitation Flow**: Receive Invitation → RSVP → Get Reminders → Attend Event
3. **Profile Management**: View Profile → Update Info → Change Settings → Upgrade Account
4. **Notification Flow**: System Event → Push Notification → User Action → Mark Read 