# Setup Cloudinary Integration

## 1. Cấu hình Cloudinary

### Bước 1: Tạo tài khoản Cloudinary
1. Truy cập [Cloudinary](https://cloudinary.com/)
2. Đăng ký tài khoản miễn phí
3. Truy cập Dashboard để lấy thông tin cấu hình

### Bước 2: Lấy thông tin cấu hình
Từ Cloudinary Dashboard, copy các thông tin sau:
- **Cloud Name**: Tên cloud của bạn
- **Upload Preset**: Tạo unsigned upload preset

### Bước 3: Tạo Upload Preset
1. Trong Cloudinary Console, vào **Settings** > **Upload**
2. Scroll xuống **Upload presets**
3. Click **Add upload preset**
4. Đặt tên cho preset (ví dụ: `flutter_app_preset`)
5. Chọn **Signing Mode**: **Unsigned**
6. Cấu hình theo nhu cầu:
   - **Folder**: (optional) để organize ảnh
   - **Transformation**: (optional) để tự động optimize
7. Click **Save**

## 2. Cấu hình Environment Variables

### Tạo file .env
Tạo file `.env` trong thư mục root của project:

```env
CLOUD_NAME=your_cloud_name_here
UPLOAD_PRESET=your_upload_preset_here
```

**Thay thế:**
- `your_cloud_name_here` bằng Cloud Name từ Cloudinary Dashboard
- `your_upload_preset_here` bằng tên upload preset bạn vừa tạo

### Ví dụ:
```env
CLOUD_NAME=my-app-cloud
UPLOAD_PRESET=flutter_app_preset
```

## 3. Dependencies

Các packages đã được cấu hình trong `pubspec.yaml`:

```yaml
dependencies:
  flutter_dotenv: ^5.2.1
  http: ^1.1.0
  image_picker: ^1.0.4
  provider: ^6.1.1
```

## 4. Cách sử dụng

### Import và sử dụng SimpleCardCreationScreen:

```dart
import 'package:your_app/screens/card/simple_card_creation_screen.dart';

// Trong widget của bạn:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const SimpleCardCreationScreen(),
  ),
);
```

### Các tính năng có sẵn:

1. **Form validation**: Kiểm tra title và description
2. **Image picker**: Chọn ảnh từ gallery hoặc camera
3. **Auto upload**: Tự động upload lên Cloudinary khi chọn ảnh
4. **Progress tracking**: Hiển thị tiến trình upload
5. **Error handling**: Xử lý lỗi và hiển thị thông báo
6. **Image preview**: Xem trước ảnh đã chọn
7. **Remove image**: Xóa ảnh đã chọn

## 5. Customization

### Thay đổi folder upload:
Trong `CardCreationViewModel`, bạn có thể thay đổi folder:

```dart
// Background images
folder: 'card_backgrounds',

// Card images  
folder: 'card_images',
```

### Thay đổi UI:
Customize `SimpleCardCreationScreen` theo design của bạn.

### Thêm validation:
Modify `ImagePickerService.isValidImage()` để thêm validation rules.

## 6. Security Notes

- ✅ Sử dụng **unsigned upload preset** cho client-side upload
- ✅ Không expose API Secret trong client code
- ✅ Sử dụng `.env` file để store credentials
- ✅ Add `.env` vào `.gitignore`

## 7. Troubleshooting

### Lỗi "Upload failed":
- Kiểm tra Cloud Name và Upload Preset trong `.env`
- Đảm bảo Upload Preset được cấu hình với **Unsigned** mode
- Kiểm tra internet connection

### Lỗi "File too large":
- Mặc định giới hạn 10MB per file
- Thay đổi trong `ImagePickerService.isValidImage()`

### Lỗi "Invalid file format":
- Chỉ support: jpg, jpeg, png, gif, webp
- Thay đổi `validExtensions` trong `ImagePickerService` 