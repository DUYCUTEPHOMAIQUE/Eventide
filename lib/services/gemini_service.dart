import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-preview-image-generation:generateContent';
  
  // Rate limiting configuration
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(seconds: 1);
  static const Duration _requestTimeout = Duration(seconds: 30);
  
  // Cache for responses to reduce API calls
  static final Map<String, GeminiResponse> _responseCache = {};
  static const int _cacheMaxSize = 50;
  
  // Analytics and monitoring
  static int _totalRequests = 0;
  static int _successfulRequests = 0;
  static int _failedRequests = 0;
  static int _cachedResponses = 0;
  
  /// Get service statistics for monitoring
  static Map<String, dynamic> getServiceStats() {
    return {
      'totalRequests': _totalRequests,
      'successfulRequests': _successfulRequests,
      'failedRequests': _failedRequests,
      'cachedResponses': _cachedResponses,
      'cacheSize': _responseCache.length,
      'successRate': _totalRequests > 0 ? (_successfulRequests / _totalRequests * 100).toStringAsFixed(2) : '0.00',
    };
  }
  
  /// Clear cache (useful for memory management)
  static void clearCache() {
    _responseCache.clear();
    print('Gemini response cache cleared');
  }

  /// Generate both text and image content using Gemini AI with caching and retry logic
  static Future<GeminiResponse> generateContent(String prompt) async {
    _totalRequests++;
    
    // Validate API key
    if (_apiKey.isEmpty) {
      _failedRequests++;
      throw GeminiException(
        'Gemini API key not configured. Please check your environment variables.',
        GeminiErrorType.configuration,
      );
    }
    
    // Check cache first
    final cacheKey = _generateCacheKey(prompt);
    if (_responseCache.containsKey(cacheKey)) {
      _cachedResponses++;
      print('Returning cached response for prompt');
      return _responseCache[cacheKey]!;
    }
    
    // Manage cache size
    if (_responseCache.length >= _cacheMaxSize) {
      _responseCache.clear();
    }
    
    GeminiException? lastException;
    
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl?key=$_apiKey'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {
              'responseModalities': ['TEXT', 'IMAGE']
            }
          }),
        ).timeout(_requestTimeout);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final geminiResponse = GeminiResponse.fromJson(data);
          
          // Cache successful response
          _responseCache[cacheKey] = geminiResponse;
          _successfulRequests++;
          
          print('Gemini API request successful (attempt ${attempt + 1})');
          return geminiResponse;
        } else if (response.statusCode == 429) {
          // Rate limited - exponential backoff
          lastException = GeminiException(
            'Rate limit exceeded. Please try again later.',
            GeminiErrorType.rateLimited,
            statusCode: response.statusCode,
          );
          if (attempt < _maxRetries - 1) {
            final delay = _baseDelay * (1 << attempt); // Exponential backoff
            print('Rate limited, waiting ${delay.inSeconds} seconds before retry ${attempt + 1}');
            await Future.delayed(delay);
          }
        } else if (response.statusCode >= 500) {
          // Server error - retry
          lastException = GeminiException(
            'Server error occurred. Retrying...',
            GeminiErrorType.serverError,
            statusCode: response.statusCode,
          );
          if (attempt < _maxRetries - 1) {
            await Future.delayed(_baseDelay * (attempt + 1));
          }
        } else {
          // Client error - don't retry
          _failedRequests++;
          throw GeminiException(
            'API request failed: ${response.statusCode} - ${response.body}',
            GeminiErrorType.apiError,
            statusCode: response.statusCode,
          );
        }
      } catch (e) {
        if (e is GeminiException) {
          lastException = e;
        } else {
          lastException = GeminiException(
            'Network error: $e',
            GeminiErrorType.networkError,
          );
        }
        
        if (attempt < _maxRetries - 1) {
          print('Attempt ${attempt + 1} failed, retrying: $e');
          await Future.delayed(_baseDelay * (attempt + 1));
        }
      }
    }
    
    _failedRequests++;
    throw lastException ?? GeminiException(
      'Failed to generate content after $_maxRetries attempts',
      GeminiErrorType.unknown,
    );
  }
  
  /// Generate a cache key from the prompt
  static String _generateCacheKey(String prompt) {
    return prompt.hashCode.toString();
  }

  /// Generate event card content based on event type and description with enhanced error handling
  static Future<EventCardContent> generateEventCard({
    required String eventType,
    required String description,
    required String language, // 'en' or 'vi'
  }) async {
    // Validate inputs
    if (description.trim().isEmpty) {
      throw GeminiException(
        language == 'vi' 
          ? 'Mô tả sự kiện không được để trống'
          : 'Event description cannot be empty',
        GeminiErrorType.invalidInput,
      );
    }
    
    String prompt;

    if (language == 'vi') {
      prompt = '''
Tạo một thẻ sự kiện cho một $eventType với mô tả: $description

Yêu cầu:
1. Tạo tiêu đề sự kiện hấp dẫn (tối đa 50 ký tự)
2. Tạo mô tả chi tiết về sự kiện (100-200 từ)
3. Đề xuất địa điểm phù hợp (tên địa điểm cụ thể)
4. Tạo hình ảnh minh họa phù hợp với chủ đề sự kiện

LƯU Ý: Không sử dụng bất kỳ định dạng markdown nào (**, *, _, v.v.). Chỉ trả về text thuần túy.

Định dạng trả về:
Tiêu đề: [tiêu đề]
Mô tả: [mô tả]
Địa điểm: [địa điểm]
''';
    } else {
      prompt = '''
Create an event card for a $eventType with description: $description

Requirements:
1. Create an engaging event title (max 50 characters)
2. Create a detailed event description (100-200 words)
3. Suggest a suitable location (specific venue name)
4. Create an illustration image suitable for the event theme

IMPORTANT: Do not use any markdown formatting (**, *, _, etc.). Return plain text only.

Return format:
Title: [title]
Description: [description]
Location: [location]
''';
    }

    try {
      final geminiResponse = await generateContent(prompt);

      // Parse the text response to extract structured data
      final textContent = geminiResponse.textContent;
      final imageData = geminiResponse.imageData;

      print('Gemini Response Text: $textContent');

      // Extract structured data from text
      final structuredData = _parseEventCardText(textContent, language);

      return EventCardContent(
        title: structuredData['title'] ??
            (language == 'vi' ? 'Sự kiện mới' : 'New Event'),
        description: structuredData['description'] ??
            (language == 'vi'
                ? 'Mô tả sự kiện sẽ được tạo tự động dựa trên thông tin bạn cung cấp.'
                : 'Event description will be automatically generated based on your information.'),
        location: structuredData['location'] ??
            (language == 'vi'
                ? 'Địa điểm sẽ được đề xuất'
                : 'Location will be suggested'),
        imageData: imageData,
      );
    } on GeminiException catch (e) {
      print('Gemini API exception in generateEventCard: ${e.message}');
      // Return fallback content with more specific error information
      return _getFallbackEventCard(language, e);
    } catch (e) {
      print('Unexpected error in generateEventCard: $e');
      // Return basic fallback content for unknown errors
      return _getFallbackEventCard(language, null);
    }
  }
  
  /// Get fallback event card content when AI generation fails
  static EventCardContent _getFallbackEventCard(String language, GeminiException? exception) {
    String title, description, location;
    
    if (language == 'vi') {
      title = 'Sự kiện mới';
      if (exception?.type == GeminiErrorType.networkError) {
        description = 'Không thể kết nối tới AI. Vui lòng kiểm tra kết nối mạng và thử lại.';
      } else if (exception?.type == GeminiErrorType.rateLimited) {
        description = 'Đã vượt quá giới hạn sử dụng AI. Vui lòng thử lại sau vài phút.';
      } else if (exception?.type == GeminiErrorType.configuration) {
        description = 'Cấu hình AI chưa đúng. Vui lòng liên hệ quản trị viên.';
      } else {
        description = 'Mô tả sự kiện sẽ được tạo tự động dựa trên thông tin bạn cung cấp.';
      }
      location = 'Địa điểm sẽ được đề xuất';
    } else {
      title = 'New Event';
      if (exception?.type == GeminiErrorType.networkError) {
        description = 'Unable to connect to AI. Please check your network connection and try again.';
      } else if (exception?.type == GeminiErrorType.rateLimited) {
        description = 'AI usage limit exceeded. Please try again in a few minutes.';
      } else if (exception?.type == GeminiErrorType.configuration) {
        description = 'AI configuration error. Please contact administrator.';
      } else {
        description = 'Event description will be automatically generated based on your information.';
      }
      location = 'Location will be suggested';
    }
    
    return EventCardContent(
      title: title,
      description: description,
      location: location,
      imageData: null,
    );
  }

  /// Parse the AI-generated text to extract structured event data
  static Map<String, String> _parseEventCardText(String text, String language) {
    final Map<String, String> result = {};

    // Extract title
    final titlePattern = language == 'vi'
        ? RegExp(r'Tiêu đề:\s*(.+)', caseSensitive: false)
        : RegExp(r'Title:\s*(.+)', caseSensitive: false);
    final titleMatch = titlePattern.firstMatch(text);
    if (titleMatch != null) {
      result['title'] = _cleanMarkdownText(titleMatch.group(1)?.trim() ?? '');
    }

    // Extract description
    final descPattern = language == 'vi'
        ? RegExp(r'Mô tả:\s*(.+)', caseSensitive: false, dotAll: true)
        : RegExp(r'Description:\s*(.+)', caseSensitive: false, dotAll: true);
    final descMatch = descPattern.firstMatch(text);
    if (descMatch != null) {
      result['description'] =
          _cleanMarkdownText(descMatch.group(1)?.trim() ?? '');
    }

    // Extract location
    final locationPattern = language == 'vi'
        ? RegExp(r'Địa điểm:\s*(.+)', caseSensitive: false)
        : RegExp(r'Location:\s*(.+)', caseSensitive: false);
    final locationMatch = locationPattern.firstMatch(text);
    if (locationMatch != null) {
      result['location'] =
          _cleanMarkdownText(locationMatch.group(1)?.trim() ?? '');
    }

    // If no structured data found, try to extract from general text
    if (result.isEmpty) {
      final lines = text.split('\n');
      if (lines.isNotEmpty) {
        result['title'] = _cleanMarkdownText(lines[0].trim());
        if (lines.length > 1) {
          result['description'] =
              _cleanMarkdownText(lines.sublist(1).join(' ').trim());
        }
        result['location'] =
            language == 'vi' ? 'Địa điểm phù hợp' : 'Suitable location';
      }
    }

    return result;
  }

  /// Clean markdown formatting from text (remove **, *, _, etc.)
  static String _cleanMarkdownText(String text) {
    return text
        // Remove bold markdown (**text**)
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'\1')
        // Remove italic markdown (*text*)
        .replaceAll(RegExp(r'\*(.+?)\*'), r'\1')
        // Remove underline markdown (_text_)
        .replaceAll(RegExp(r'_(.+?)_'), r'\1')
        // Remove any remaining asterisks or underscores
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('_', '')
        // Clean extra whitespace
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class GeminiResponse {
  final String textContent;
  final Uint8List? imageData;

  GeminiResponse({
    required this.textContent,
    this.imageData,
  });

  factory GeminiResponse.fromJson(Map<String, dynamic> json) {
    String textContent = '';
    Uint8List? imageData;

    if (json['candidates'] != null && json['candidates'].isNotEmpty) {
      final candidate = json['candidates'][0];
      if (candidate['content'] != null &&
          candidate['content']['parts'] != null) {
        final parts = candidate['content']['parts'] as List;

        for (final part in parts) {
          if (part['text'] != null) {
            textContent += part['text'];
          }

          if (part['inlineData'] != null) {
            final inlineData = part['inlineData'];
            if (inlineData['data'] != null) {
              // Decode base64 image data
              try {
                imageData = base64Decode(inlineData['data']);
                print(
                    'Image data decoded successfully: ${imageData.length} bytes');
              } catch (e) {
                print('Error decoding image data: $e');
              }
            }
          }
        }
      }
    }

    return GeminiResponse(
      textContent: textContent.trim(),
      imageData: imageData,
    );
  }
}

class EventCardContent {
  final String title;
  final String description;
  final String location;
  final Uint8List? imageData;

  EventCardContent({
    required this.title,
    required this.description,
    required this.location,
    this.imageData,
  });
}

/// Custom exception class for Gemini API errors
class GeminiException implements Exception {
  final String message;
  final GeminiErrorType type;
  final int? statusCode;

  GeminiException(
    this.message,
    this.type, {
    this.statusCode,
  });

  @override
  String toString() => 'GeminiException: $message (Type: $type, Status: $statusCode)';
}

/// Types of Gemini API errors
enum GeminiErrorType {
  networkError,
  apiError,
  rateLimited,
  serverError,
  configuration,
  invalidInput,
  unknown,
}
