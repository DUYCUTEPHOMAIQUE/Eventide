# Gemini AI Integration for Eventide

## Tổng quan

Eventide đã được tích hợp với Google Gemini AI để tạo thẻ sự kiện thông minh với cả text và hình ảnh. Tính năng này sử dụng Gemini 2.0 Flash Preview Image Generation API để tạo ra nội dung sự kiện chất lượng cao.

## Tính năng

### 1. Tạo thẻ sự kiện bằng AI
- **Text Generation**: Tạo tiêu đề, mô tả và địa điểm phù hợp
- **Image Generation**: Tạo hình ảnh minh họa cho sự kiện
- **Đa ngôn ngữ**: Hỗ trợ tiếng Việt và tiếng Anh
- **Prompt Engineering**: Tối ưu hóa prompt để có kết quả tốt nhất

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

## Cấu trúc kỹ thuật

### API Endpoint
```
https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-preview-image-generation:generateContent
```

### Request Body
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

## Files đã thêm/sửa đổi

### Files mới
- `lib/services/gemini_service.dart` - Service chính để gọi Gemini API
- `GEMINI_AI_INTEGRATION.md` - Tài liệu này

### Files đã cập nhật
- `lib/services/services.dart` - Export Gemini service
- `lib/screens/card/ai_card_creation_screen.dart` - Tích hợp AI thật sự

## Xử lý lỗi

### Các loại lỗi thường gặp
1. **API Error**: Lỗi từ Gemini API
2. **Network Error**: Lỗi kết nối mạng
3. **Parsing Error**: Lỗi xử lý response

### Fallback Strategy
- Nếu AI generation thất bại, hệ thống sẽ sử dụng nội dung mặc định
- Hiển thị thông báo lỗi rõ ràng cho người dùng
- Cung cấp tùy chọn "Thử lại"

## Tối ưu hóa

### Prompt Engineering
- Sử dụng prompt có cấu trúc rõ ràng
- Hướng dẫn AI về định dạng output mong muốn
- Tối ưu hóa cho từng ngôn ngữ

### Performance
- Cache response để giảm API calls
- Xử lý async để không block UI
- Error handling robust

## Bảo mật

### API Key
- API key được hardcode trong service (chỉ dành cho demo)
- Trong production, nên sử dụng environment variables
- Không expose API key trong client code

### Rate Limiting
- Gemini API có rate limits
- Implement retry logic với exponential backoff
- Monitor API usage

## Tương lai

### Tính năng có thể thêm
1. **Multiple Image Generation**: Tạo nhiều hình ảnh để chọn
2. **Style Transfer**: Áp dụng style khác nhau cho hình ảnh
3. **Batch Processing**: Tạo nhiều thẻ cùng lúc
4. **Custom Prompts**: Cho phép người dùng tùy chỉnh prompt
5. **Image Editing**: Chỉnh sửa hình ảnh được tạo

### Cải tiến kỹ thuật
1. **Caching**: Cache kết quả AI để tái sử dụng
2. **Offline Mode**: Lưu trữ local cho offline access
3. **Analytics**: Track usage patterns
4. **A/B Testing**: Test different prompt strategies

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