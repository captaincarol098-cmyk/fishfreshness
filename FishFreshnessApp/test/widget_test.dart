import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fish_freshness_app/models/scan_result.dart';
import 'package:fish_freshness_app/services/ml_service.dart';

void main() {
  group('Fish Freshness App Tests', () {
    test('ScanResult model serialization', () {
      final result = ScanResult(
        classification: 'fresh',
        freshConfidence: 0.8,
        notFreshConfidence: 0.2,
        timestamp: DateTime.parse('2024-01-01T00:00:00'),
        imagePath: '/test/path.jpg',
      );

      final json = result.toJson();
      expect(json['classification'], equals('fresh'));
      expect(json['freshConfidence'], equals(0.8));
      expect(json['imagePath'], equals('/test/path.jpg'));
    });

    test('ML Service mock results are realistic', () {
      final mockResult = MLService.createMockResult('/path/to/fresh_fish.jpg');
      
      // Verify valid confidence ranges
      expect(mockResult.freshConfidence, greaterThanOrEqualTo(0.0));
      expect(mockResult.freshConfidence, lessThanOrEqualTo(1.0));
      expect(mockResult.notFreshConfidence, greaterThanOrEqualTo(0.0));
      expect(mockResult.notFreshConfidence, lessThanOrEqualTo(1.0));
      
      // Verify confidences sum to approximately 1.0
      expect(
        mockResult.freshConfidence + mockResult.notFreshConfidence,
        closeTo(1.0, 0.01)
      );
      
      // Verify classification matches confidence
      if (mockResult.classification == 'fresh') {
        expect(mockResult.freshConfidence, greaterThan(mockResult.notFreshConfidence));
      } else if (mockResult.classification == 'not_fresh') {
        expect(mockResult.notFreshConfidence, greaterThan(mockResult.freshConfidence));
      }
    });

    test('ML Service model info', () {
      final info = MLService.getModelInfo();
      expect(info.containsKey('modelType'), isTrue);
      expect(info.containsKey('version'), isTrue);
      expect(info.containsKey('isInitialized'), isTrue);
      expect(info.containsKey('labels'), isTrue);
    });

    group('Model Accuracy Tests', () {
      test('Mock results show expected bias for filename hints', () {
        // Test multiple results for fresh-named files
        final freshResults = <ScanResult>[];
        for (int i = 0; i < 10; i++) {
          freshResults.add(MLService.createMockResult('/images/fresh_fish_$i.jpg'));
        }
        
        // Should have more fresh classifications than not fresh for fresh-named files
        final freshCount = freshResults.where((r) => r.classification == 'fresh').length;
        expect(freshCount, greaterThan(5)); // At least 50% should be fresh
        
        // Test for not fresh files
        final notFreshResults = <ScanResult>[];
        for (int i = 0; i < 10; i++) {
          notFreshResults.add(MLService.createMockResult('/images/not_fresh_fish_$i.jpg'));
        }
        
        final notFreshCount = notFreshResults.where((r) => r.classification == 'not_fresh').length;
        expect(notFreshCount, greaterThan(4)); // At least 40% should be not fresh
      });

      test('Confidence scores are reasonable', () {
        final result = MLService.createMockResult('/test/random_fish.jpg');
        
        // Confidence should not be too extreme (avoiding overconfident predictions)
        expect(result.freshConfidence, lessThan(0.96));
        expect(result.freshConfidence, greaterThan(0.05));
        expect(result.notFreshConfidence, lessThan(0.96));
        expect(result.notFreshConfidence, greaterThan(0.05));
      });
    });
  });
}
