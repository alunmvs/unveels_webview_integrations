class FaceAnalyzerModel {
  final String name;
  final String outputName;
  final List<String>? labels;
  final String? outputLabel;
  final double? outputScore;
  final Map<String, double>? outputData;
  final int? outputIndex;
  final String? outputColor;
  final String? imageData;

  FaceAnalyzerModel(
      {required this.name,
      required this.outputName,
      this.labels,
      this.outputLabel,
      this.outputScore,
      this.outputData,
      this.outputIndex,
      this.outputColor,
      this.imageData});

  factory FaceAnalyzerModel.fromJson(Map<String, dynamic> json) {
    return FaceAnalyzerModel(
      name: json['name'],
      outputName: json['outputName'],
      labels: json['labels'] != null ? List<String>.from(json['labels']) : null,
      outputLabel: json['outputLabel'],
      outputScore:
          json['outputScore'] != null ? json['outputScore'].toDouble() : null,
      outputData: json['outputData'] != null
          ? Map<String, double>.from(json['outputData']
              .map((key, value) => MapEntry(key, value.toDouble())))
          : null,
      outputIndex: json['outputIndex'],
      outputColor: json['outputColor'],
      imageData: json['imageData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'outputName': outputName,
      'labels': labels,
      'outputLabel': outputLabel,
      'outputScore': outputScore,
      'outputData': outputData,
      'outputIndex': outputIndex,
      'outputColor': outputColor,
      'imageData': imageData,
    };
  }

  // Method to create a list of FeatureModel objects from JSON list
  static List<FaceAnalyzerModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => FaceAnalyzerModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
