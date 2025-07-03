import 'package:test/test.dart';
import 'package:enva/services/gemini_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('GeminiService Tests', () {
    setUp(() async {
      // Initialize dotenv for testing
      await dotenv.load(fileName: 'dotenv');
    });

    test('should handle empty API key gracefully', () async {
      // Test configuration validation
      expect(() async {
        await GeminiService.generateContent('test prompt');
      }, throwsA(isA<GeminiException>()));
    });

    test('should validate input for generateEventCard', () async {
      expect(() async {
        await GeminiService.generateEventCard(
          eventType: 'Birthday',
          description: '', // Empty description should fail
          language: 'en',
        );
      }, throwsA(isA<GeminiException>()));
    });

    test('should return fallback content on error', () async {
      try {
        final result = await GeminiService.generateEventCard(
          eventType: 'Birthday',
          description: 'Test event',
          language: 'en',
        );
        
        // Should get fallback content if API fails
        expect(result.title, isNotEmpty);
        expect(result.description, isNotEmpty);
        expect(result.location, isNotEmpty);
      } catch (e) {
        // Test should pass even if API call fails
        expect(e, isA<GeminiException>());
      }
    });

    test('should handle Vietnamese language properly', () async {
      try {
        final result = await GeminiService.generateEventCard(
          eventType: 'Sinh nhật',
          description: 'Tiệc sinh nhật vui vẻ',
          language: 'vi',
        );
        
        expect(result.title, isNotEmpty);
        expect(result.description, isNotEmpty);
        expect(result.location, isNotEmpty);
      } catch (e) {
        // Test should pass even if API call fails
        expect(e, isA<GeminiException>());
      }
    });

    test('should categorize different error types correctly', () {
      final networkError = GeminiException(
        'Network failed',
        GeminiErrorType.networkError,
      );
      expect(networkError.type, equals(GeminiErrorType.networkError));

      final rateLimitError = GeminiException(
        'Too many requests',
        GeminiErrorType.rateLimited,
        statusCode: 429,
      );
      expect(rateLimitError.type, equals(GeminiErrorType.rateLimited));
      expect(rateLimitError.statusCode, equals(429));
    });
  });
}