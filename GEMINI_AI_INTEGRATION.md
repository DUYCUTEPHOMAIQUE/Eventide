# Gemini AI Integration for Eventide (Enhanced)

## Tổng quan

Eventide đã được tích hợp với Google Gemini AI để tạo thẻ sự kiện thông minh với cả text và hình ảnh. Tính năng này sử dụng Gemini 2.0 Flash Preview Image Generation API để tạo ra nội dung sự kiện chất lượng cao với các cải tiến về bảo mật, hiệu suất và trải nghiệm người dùng.

## Tính năng

### 1. Tạo thẻ sự kiện bằng AI (Nâng cao)
- **Text Generation**: Tạo tiêu đề, mô tả và địa điểm phù hợp
- **Image Generation**: Tạo hình ảnh minh họa cho sự kiện
- **Đa ngôn ngữ**: Hỗ trợ tiếng Việt và tiếng Anh
- **Prompt Engineering**: Tối ưu hóa prompt để có kết quả tốt nhất
- **Caching**: Cache kết quả để giảm thời gian phản hồi
- **Retry Logic**: Tự động thử lại khi gặp lỗi tạm thời
- **Rate Limiting**: Ngăn chặn spam requests
- **Error Handling**: Xử lý lỗi chi tiết với thông báo rõ ràng

### 2. Cải tiến bảo mật
- **Environment Variables**: API key được lưu trong biến môi trường
- **Input Validation**: Kiểm tra dữ liệu đầu vào
- **Request Validation**: Ngăn chặn requests không hợp lệ

### 2. Cách sử dụng

1. **Truy cập tính năng AI**:
   - Mở ứng dụng Eventide
   - Vào màn hình chính
   - Nhấn nút "Tạo thẻ bằng AI" ở cuối màn hình

2. **Chọn loại sự kiện**:
   - Chọn từ danh sách các loại sự kiện có sẵn
   - Hoặc chọn "Custom Event" để tùy chỉnh

3. **Nhập mô tả**:
   - Viết mô tả chi tiết về sự kiện
   - Càng chi tiết càng tốt để AI tạo ra nội dung phù hợp

4. **Tạo thẻ**:
   - Nhấn nút "Tạo thẻ bằng AI"
   - Chờ AI xử lý (thường mất 5-10 giây)
   - Xem kết quả với text và hình ảnh

5. **Sử dụng thẻ**:
   - Nhấn "Sử dụng" để chuyển sang màn hình chỉnh sửa
   - Hoặc nhấn "Tạo lại" để tạo thẻ mới

## Cấu trúc kỹ thuật (Cập nhật)

### Environment Variables Setup
```bash
# Copy template and configure
cp dotenv.template dotenv

# Edit dotenv file with your values:
GEMINI_API_KEY=your_actual_api_key_here
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
```

### API Endpoint
```
https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-preview-image-generation:generateContent
```

### Enhanced Request Configuration
```json
{
  "contents": [
    {
      "parts": [
        {"text": "Prompt bằng tiếng Anh hoặc tiếng Việt"}
      ]
    }
  ],
  "generationConfig": {
    "responseModalities": ["TEXT", "IMAGE"]
  }
}
```

### Response Caching và Rate Limiting
- **Cache Size**: Tối đa 50 responses
- **Request Timeout**: 30 giây
- **Max Retries**: 3 lần với exponential backoff
- **Rate Limiting**: Tối thiểu 5 giây giữa các requests

### Error Types
```dart
enum GeminiErrorType {
  networkError,      // Lỗi mạng
  apiError,          // Lỗi API
  rateLimited,       // Vượt quá giới hạn
  serverError,       // Lỗi server
  configuration,     // Lỗi cấu hình
  invalidInput,      // Dữ liệu không hợp lệ
  unknown,           // Lỗi không xác định
}
```

### Response Structure
```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "Generated text content"
          },
          {
            "inlineData": {
              "mimeType": "image/png",
              "data": "base64_encoded_image_data"
            }
          }
        ]
      }
    }
  ]
}
```

## Files đã thêm/sửa đổi (Cập nhật)

### Files mới
- `lib/services/gemini_service.dart` - Service chính với cải tiến bảo mật và hiệu suất
- `test/services/gemini_service_test.dart` - Test suite cho Gemini service
- `dotenv.template` - Template cho environment variables
- `GEMINI_AI_INTEGRATION.md` - Tài liệu chi tiết (updated)

### Files đã cập nhật
- `lib/services/services.dart` - Export Gemini service
- `lib/screens/card/ai_card_creation_screen.dart` - Enhanced error handling và UX
- `pubspec.yaml` - Thêm test dependencies
- `dotenv` - Environment variables configuration

### Files cấu hình
- `dotenv.template` - Template cho production setup
- `dotenv` - Development configuration (demo keys)

## Xử lý lỗi (Nâng cao)

### Các loại lỗi và xử lý tự động
1. **API Error (4xx)**: Lỗi từ Gemini API - không retry
2. **Network Error**: Lỗi kết nối mạng - retry với backoff
3. **Server Error (5xx)**: Lỗi server - retry với delay
4. **Rate Limited (429)**: Vượt giới hạn - exponential backoff
5. **Configuration Error**: API key không có - thông báo ngay
6. **Input Validation**: Dữ liệu không hợp lệ - thông báo cụ thể

### Enhanced Fallback Strategy
- **Smart Fallback**: Nội dung fallback dựa trên loại lỗi
- **User Feedback**: Thông báo lỗi chi tiết và hướng dẫn khắc phục
- **Retry Options**: Nút "Thử lại" thông minh
- **Graceful Degradation**: App vẫn hoạt động khi AI offline

### Error Messages (Bilingual)
```dart
// Vietnamese
'Không thể kết nối tới AI. Vui lòng kiểm tra kết nối mạng.'
'Đã vượt quá giới hạn sử dụng AI. Vui lòng thử lại sau vài phút.'
'Cấu hình AI chưa đúng. Vui lòng liên hệ quản trị viên.'

// English  
'Unable to connect to AI. Please check your network connection.'
'AI usage limit exceeded. Please try again in a few minutes.'
'AI configuration error. Please contact administrator.'
```

## Tối ưu hóa (Nâng cao)

### Performance Improvements
- **Response Caching**: Cache 50 responses gần nhất
- **Request Debouncing**: Ngăn chặn multiple simultaneous requests
- **Memory Management**: Tự động clear cache khi đầy
- **Connection Monitoring**: Theo dõi trạng thái kết nối
- **Analytics**: Track usage patterns và success rates

### Prompt Engineering
- **Structured Prompts**: Sử dụng prompt có cấu trúc rõ ràng
- **Language Optimization**: Tối ưu hóa cho từng ngôn ngữ
- **Output Format**: Hướng dẫn AI về định dạng mong muốn
- **Context Enhancement**: Thêm context từ event type và tone

### Service Analytics
```dart
// Get real-time stats
final stats = GeminiService.getServiceStats();
print('Success Rate: ${stats['successRate']}%');
print('Cache Hit Rate: ${stats['cachedResponses']}/${stats['totalRequests']}');
```

### Memory Management
```dart
// Clear cache when needed
GeminiService.clearCache();
```

## Bảo mật (Cải tiến)

### API Key Management
- **Environment Variables**: API key được lưu trong `dotenv` file
- **Template System**: `dotenv.template` cho setup production
- **Validation**: Kiểm tra API key trước khi gọi API
- **No Hardcoding**: Không còn hardcode API key trong source code

### Production Security Checklist
1. **Environment Setup**:
   ```bash
   # Copy template
   cp dotenv.template .env
   
   # Set production values
   GEMINI_API_KEY=your_production_key
   ```

2. **API Key Protection**:
   - Không commit `.env` files vào git
   - Sử dụng secrets management trong CI/CD
   - Rotate API keys định kỳ

3. **Input Validation**:
   - Validate tất cả user inputs
   - Sanitize prompts trước khi gửi
   - Giới hạn độ dài input

### Rate Limiting & Monitoring
- **Request Throttling**: Tối thiểu 5s giữa requests
- **Usage Analytics**: Track API usage patterns
- **Error Monitoring**: Log và monitor error rates
- **Abuse Prevention**: Ngăn chặn spam và abuse

## Testing & Quality Assurance

### Test Coverage
- **Unit Tests**: Test service logic và error handling
- **Integration Tests**: Test AI workflow end-to-end  
- **Error Scenario Tests**: Test các loại lỗi khác nhau
- **Performance Tests**: Test caching và retry logic

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/gemini_service_test.dart

# Run with coverage
flutter test --coverage
```

### Quality Metrics
- **Success Rate**: % requests thành công
- **Response Time**: Thời gian phản hồi trung bình
- **Cache Hit Rate**: % requests từ cache
- **Error Distribution**: Phân bố các loại lỗi

## Monitoring & Analytics

### Real-time Monitoring
```dart
// Check service health
final stats = GeminiService.getServiceStats();
print('Service Stats: $stats');

// Monitor in real-time
print('Current cache size: ${stats['cacheSize']}');
print('Success rate: ${stats['successRate']}%');
```

### Key Metrics to Track
1. **Performance Metrics**:
   - Average response time
   - Cache hit ratio
   - Request success rate

2. **Usage Metrics**:
   - Daily/weekly request counts
   - Popular event types
   - User engagement with AI features

3. **Error Metrics**:
   - Error rate by type
   - Failed request patterns
   - Recovery success rate

## Troubleshooting

### Lỗi thường gặp và cách khắc phục

1. **"Failed to generate content"**
   - Kiểm tra kết nối mạng
   - Thử lại sau vài giây
   - Kiểm tra API key

2. **"Error decoding image data"**
   - Lỗi xử lý hình ảnh từ API
   - Thử tạo lại thẻ
   - Kiểm tra response format

3. **"No structured data found"**
   - AI không trả về đúng format
   - Thử mô tả chi tiết hơn
   - Sử dụng fallback content

## Kết luận

Tích hợp Gemini AI đã mang lại trải nghiệm tạo thẻ sự kiện thông minh và sáng tạo cho người dùng Eventide. Tính năng này không chỉ tạo ra nội dung chất lượng cao mà còn cung cấp hình ảnh minh họa phù hợp, giúp người dùng tạo ra những thẻ sự kiện đẹp mắt và chuyên nghiệp một cách dễ dàng. 