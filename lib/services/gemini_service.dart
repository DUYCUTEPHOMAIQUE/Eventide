import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyBZI34fVdMwwaPA1tKdCDffr1JQIiC12GE';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-preview-image-generation:generateContent';

  /// Generate both text and image content using Gemini AI
  static Future<GeminiResponse> generateContent(String prompt) async {
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
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GeminiResponse.fromJson(data);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to generate content: ${response.statusCode}');
      }
    } catch (e) {
      print('Gemini API Error: $e');
      throw Exception('Error generating content: $e');
    }
  }

  /// Generate event card content based on event type and description
  static Future<EventCardContent> generateEventCard({
    required String eventType,
    required String description,
    required String language, // 'en' or 'vi'
  }) async {
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
    } catch (e) {
      print('Error in generateEventCard: $e');
      // Fallback to default content if AI generation fails
      return EventCardContent(
        title: language == 'vi' ? 'Sự kiện mới' : 'New Event',
        description: language == 'vi'
            ? 'Mô tả sự kiện sẽ được tạo tự động dựa trên thông tin bạn cung cấp.'
            : 'Event description will be automatically generated based on your information.',
        location: language == 'vi'
            ? 'Địa điểm sẽ được đề xuất'
            : 'Location will be suggested',
        imageData: null,
      );
    }
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
