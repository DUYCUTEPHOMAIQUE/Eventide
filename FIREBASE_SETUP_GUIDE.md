# Hướng dẫn Setup Firebase Service Account cho FCM v1 API

## Bước 1: Tạo Service Account trong Firebase Console

1. **Mở Firebase Console**: https://console.firebase.google.com/
2. **Chọn project** của bạn
3. **Vào Settings** (⚙️) → **Project settings**
4. **Tab Service accounts**
5. **Chọn "Firebase Admin SDK"**
6. **Click "Generate new private key"**
7. **Download file JSON** (chứa thông tin service account)

## Bước 2: Cấu hình trong .env file

Thêm các biến môi trường vào file `.env`:

```env
# Firebase Project ID (lấy từ Firebase Console)
FIREBASE_PROJECT_ID=your-project-id-here

# Firebase Service Account JSON (toàn bộ nội dung file JSON)
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account","project_id":"your-project-id","private_key_id":"...","private_key":"-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n","client_email":"firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com","client_id":"...","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_x509_cert_url":"https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40your-project-id.iam.gserviceaccount.com"}
```

## Bước 3: Cấu hình FCM trong Firebase Console

1. **Vào Firebase Console** → **Project settings**
2. **Tab Cloud Messaging**
3. **Enable "Cloud Messaging API (V1)"**
4. **Disable "Cloud Messaging API (Legacy)"** (nếu đang bật)

## Bước 4: Cấu hình Android (nếu cần)

1. **Download google-services.json** từ Firebase Console
2. **Đặt vào android/app/google-services.json**
3. **Cập nhật android/app/build.gradle**:

```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

4. **Thêm vào cuối android/app/build.gradle**:

```gradle
apply plugin: 'com.google.gms.google-services'
```

## Bước 5: Cấu hình iOS (nếu cần)

1. **Download GoogleService-Info.plist** từ Firebase Console
2. **Đặt vào ios/Runner/GoogleService-Info.plist**
3. **Thêm vào ios/Runner/Info.plist**:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

## Lưu ý quan trọng

1. **Bảo mật**: Không commit file service account JSON vào git
2. **Environment Variables**: Sử dụng .env file để lưu thông tin nhạy cảm
3. **Permissions**: Service account cần có quyền gửi FCM messages
4. **Testing**: Sử dụng method `testFCMConnection()` để kiểm tra setup

## Troubleshooting

### Lỗi "Service Account JSON not found"
- Kiểm tra file .env có đúng format không
- Đảm bảo FIREBASE_SERVICE_ACCOUNT_JSON chứa toàn bộ JSON content

### Lỗi "Project ID not found"
- Kiểm tra FIREBASE_PROJECT_ID trong .env
- Đảm bảo project ID đúng với Firebase Console

### Lỗi "Access token expired"
- Service account tự động refresh token
- Kiểm tra internet connection

### Lỗi "FCM v1 request failed"
- Kiểm tra FCM API đã được enable chưa
- Kiểm tra service account có đủ permissions không 