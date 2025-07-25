import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../models/prompt_history.dart';
import '../services/llm_service.dart';

class HistoryService {
  static final GetStorage _storage = GetStorage();
  static const String _historyKey = 'prompt_history';
  static const int _maxHistoryItems = 100; // Limit to prevent storage bloat

  /// Initialize the history service
  static Future<void> initialize() async {
    await GetStorage.init();
  }

  /// Add a new prompt to history
  static Future<void> addPrompt({
    required String prompt,
    required bool success,
    String? errorMessage,
    int? componentsCreated,
  }) async {
    try {
      final config = LLMService.getConfiguration();
      
      final historyItem = PromptHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        prompt: prompt,
        timestamp: DateTime.now(),
        success: success,
        errorMessage: errorMessage,
        componentsCreated: componentsCreated,
        llmProvider: config['provider'],
        llmModel: config['model'],
      );

      final history = await getHistory();
      history.insert(0, historyItem); // Add to beginning

      // Limit history size
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      await _saveHistory(history);
    } catch (e) {
      print('Failed to add prompt to history: $e');
    }
  }

  /// Get all history items
  static Future<List<PromptHistory>> getHistory() async {
    try {
      final historyData = _storage.read(_historyKey);
      if (historyData == null) return [];

      final List<dynamic> historyList = jsonDecode(historyData);
      return historyList
          .map((item) => PromptHistory.fromJson(item))
          .toList();
    } catch (e) {
      print('Failed to load history: $e');
      return [];
    }
  }

  /// Get history filtered by success status
  static Future<List<PromptHistory>> getHistoryByStatus(bool success) async {
    final history = await getHistory();
    return history.where((item) => item.success == success).toList();
  }

  /// Get recent successful prompts (for quick reuse)
  static Future<List<PromptHistory>> getRecentSuccessful({int limit = 10}) async {
    final history = await getHistoryByStatus(true);
    return history.take(limit).toList();
  }

  /// Search history by prompt text
  static Future<List<PromptHistory>> searchHistory(String query) async {
    if (query.trim().isEmpty) return await getHistory();
    
    final history = await getHistory();
    final lowerQuery = query.toLowerCase();
    
    return history.where((item) => 
      item.prompt.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Get history statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    final history = await getHistory();
    
    if (history.isEmpty) {
      return {
        'totalPrompts': 0,
        'successfulPrompts': 0,
        'failedPrompts': 0,
        'successRate': 0.0,
        'totalComponents': 0,
        'mostUsedProvider': null,
        'mostUsedModel': null,
      };
    }

    final successful = history.where((item) => item.success).length;
    final failed = history.length - successful;
    final totalComponents = history
        .where((item) => item.componentsCreated != null)
        .fold(0, (sum, item) => sum + item.componentsCreated!);

    // Find most used provider and model
    final providerCounts = <String, int>{};
    final modelCounts = <String, int>{};
    
    for (final item in history) {
      if (item.llmProvider != null) {
        providerCounts[item.llmProvider!] = 
            (providerCounts[item.llmProvider!] ?? 0) + 1;
      }
      if (item.llmModel != null) {
        modelCounts[item.llmModel!] = 
            (modelCounts[item.llmModel!] ?? 0) + 1;
      }
    }

    String? mostUsedProvider;
    String? mostUsedModel;
    
    if (providerCounts.isNotEmpty) {
      mostUsedProvider = providerCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }
    
    if (modelCounts.isNotEmpty) {
      mostUsedModel = modelCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    return {
      'totalPrompts': history.length,
      'successfulPrompts': successful,
      'failedPrompts': failed,
      'successRate': successful / history.length,
      'totalComponents': totalComponents,
      'mostUsedProvider': mostUsedProvider,
      'mostUsedModel': mostUsedModel,
    };
  }

  /// Clear all history
  static Future<void> clearHistory() async {
    try {
      await _storage.remove(_historyKey);
    } catch (e) {
      print('Failed to clear history: $e');
    }
  }

  /// Remove a specific history item
  static Future<void> removeHistoryItem(String id) async {
    try {
      final history = await getHistory();
      history.removeWhere((item) => item.id == id);
      await _saveHistory(history);
    } catch (e) {
      print('Failed to remove history item: $e');
    }
  }

  /// Save history to storage
  static Future<void> _saveHistory(List<PromptHistory> history) async {
    try {
      final historyJson = history.map((item) => item.toJson()).toList();
      await _storage.write(_historyKey, jsonEncode(historyJson));
    } catch (e) {
      print('Failed to save history: $e');
    }
  }

  /// Export history as JSON string
  static Future<String> exportHistory() async {
    try {
      final history = await getHistory();
      final export = {
        'exportDate': DateTime.now().toIso8601String(),
        'totalItems': history.length,
        'history': history.map((item) => item.toJson()).toList(),
      };
      return jsonEncode(export);
    } catch (e) {
      print('Failed to export history: $e');
      return '{}';
    }
  }

  /// Get history grouped by date
  static Future<Map<String, List<PromptHistory>>> getHistoryGroupedByDate() async {
    final history = await getHistory();
    final grouped = <String, List<PromptHistory>>{};
    
    for (final item in history) {
      final dateKey = _getDateKey(item.timestamp);
      grouped[dateKey] ??= [];
      grouped[dateKey]!.add(item);
    }
    
    return grouped;
  }

  /// Get date key for grouping
  static String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);
    
    if (itemDate == today) {
      return 'Today';
    } else if (itemDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(itemDate).inDays < 7) {
      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return weekdays[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}