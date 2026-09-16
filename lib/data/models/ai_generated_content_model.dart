class SummaryResult {
  final String shortSummary;
  final String detailedSummary;
  final List<String> keyPoints;
  final Map<String, String> importantTerms; // Term : Definition

  SummaryResult({
    required this.shortSummary,
    required this.detailedSummary,
    required this.keyPoints,
    required this.importantTerms,
  });

  factory SummaryResult.fromJson(Map<String, dynamic> json) {
    return SummaryResult(
      shortSummary: json['shortSummary'] ?? '',
      detailedSummary: json['detailedSummary'] ?? '',
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
      importantTerms: Map<String, String>.from(json['importantTerms'] ?? {}),
    );
  }
}