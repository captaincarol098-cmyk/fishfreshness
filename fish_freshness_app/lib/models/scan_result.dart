class ScanResult {
  final int? id;
  final String classification; // "fresh" or "not_fresh"
  final double freshConfidence;
  final double notFreshConfidence;
  final DateTime timestamp;
  final String? imagePath;

  ScanResult({
    this.id,
    required this.classification,
    required this.freshConfidence,
    required this.notFreshConfidence,
    required this.timestamp,
    this.imagePath,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classification': classification,
      'freshConfidence': freshConfidence,
      'notFreshConfidence': notFreshConfidence,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classification': classification,
      'fresh_confidence': freshConfidence,
      'not_fresh_confidence': notFreshConfidence,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'image_path': imagePath,
    };
  }

  // Create from JSON
  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      id: json['id'] as int?,
      classification: json['classification'] as String,
      freshConfidence: json['freshConfidence'] as double,
      notFreshConfidence: json['notFreshConfidence'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
      imagePath: json['imagePath'] as String?,
    );
  }

  // Create from database Map
  factory ScanResult.fromMap(Map<String, dynamic> map) {
    return ScanResult(
      id: map['id'] as int?,
      classification: map['classification'] as String,
      freshConfidence: map['fresh_confidence'] as double,
      notFreshConfidence: map['not_fresh_confidence'] as double,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      imagePath: map['image_path'] as String?,
    );
  }

  // Whether the model was not confident enough to decide
  bool get isUncertain => classification == 'uncertain';

  // Get confidence percentage
  double getConfidencePercentage() {
    return double.parse((max(freshConfidence, notFreshConfidence) * 100).toStringAsFixed(1));
  }

  // Get recommendation message
  String getRecommendation() {
    if (classification == 'fresh') {
      return '✓ This fish is fresh and safe to eat!';
    } else if (classification == 'not_fresh') {
      return '✗ This fish is NOT fresh. Do not consume.';
    } else {
      return '⚠ Confidence too low. Take another photo in better lighting.';
    }
  }

  // Get freshness status with confidence
  String getDetailedStatus() {
    final confidence = getConfidencePercentage();
    if (classification == 'fresh') {
      return 'Fresh ($confidence% confidence)';
    } else if (classification == 'not_fresh') {
      return 'Not Fresh ($confidence% confidence)';
    } else {
      return 'Uncertain ($confidence% confidence)';
    }
  }

  // Copy with new values
  ScanResult copyWith({
    int? id,
    String? classification,
    double? freshConfidence,
    double? notFreshConfidence,
    DateTime? timestamp,
    String? imagePath,
  }) {
    return ScanResult(
      id: id ?? this.id,
      classification: classification ?? this.classification,
      freshConfidence: freshConfidence ?? this.freshConfidence,
      notFreshConfidence: notFreshConfidence ?? this.notFreshConfidence,
      timestamp: timestamp ?? this.timestamp,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

double max(double a, double b) => a > b ? a : b;
