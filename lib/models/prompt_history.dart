class PromptHistory {
  final String id;
  final String prompt;
  final DateTime timestamp;
  final bool success;
  final String? errorMessage;
  final int? componentsCreated;
  final String? llmProvider;
  final String? llmModel;

  PromptHistory({
    required this.id,
    required this.prompt,
    required this.timestamp,
    required this.success,
    this.errorMessage,
    this.componentsCreated,
    this.llmProvider,
    this.llmModel,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'errorMessage': errorMessage,
      'componentsCreated': componentsCreated,
      'llmProvider': llmProvider,
      'llmModel': llmModel,
    };
  }

  factory PromptHistory.fromJson(Map<String, dynamic> json) {
    return PromptHistory(
      id: json['id'],
      prompt: json['prompt'],
      timestamp: DateTime.parse(json['timestamp']),
      success: json['success'],
      errorMessage: json['errorMessage'],
      componentsCreated: json['componentsCreated'],
      llmProvider: json['llmProvider'],
      llmModel: json['llmModel'],
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String get statusIcon {
    return success ? '✅' : '❌';
  }

  String get statusText {
    if (success) {
      if (componentsCreated != null && componentsCreated! > 1) {
        return 'Created $componentsCreated components';
      } else {
        return 'Success';
      }
    } else {
      return errorMessage ?? 'Failed';
    }
  }
}