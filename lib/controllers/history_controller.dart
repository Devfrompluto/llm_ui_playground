import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/prompt_history.dart';
import '../services/history_service.dart';

class HistoryController extends GetxController {
  final searchController = TextEditingController();
  
  var history = <PromptHistory>[].obs;
  var filteredHistory = <PromptHistory>[].obs;
  var groupedHistory = <String, List<PromptHistory>>{}.obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var selectedFilter = 'all'.obs; // all, success, failed
  var viewMode = 'list'.obs; // list, grouped
  var statistics = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
    loadStatistics();
    
    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      filterHistory();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Load history from storage
  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      final historyData = await HistoryService.getHistory();
      history.value = historyData;
      filterHistory();
      
      if (viewMode.value == 'grouped') {
        await loadGroupedHistory();
      }
    } catch (e) {
      _showErrorSnackbar('Failed to load history: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load grouped history
  Future<void> loadGroupedHistory() async {
    try {
      final grouped = await HistoryService.getHistoryGroupedByDate();
      groupedHistory.value = grouped;
    } catch (e) {
      _showErrorSnackbar('Failed to load grouped history: ${e.toString()}');
    }
  }

  /// Load statistics
  Future<void> loadStatistics() async {
    try {
      final stats = await HistoryService.getStatistics();
      statistics.value = stats;
    } catch (e) {
      print('Failed to load statistics: $e');
    }
  }

  /// Filter history based on search and filter criteria
  void filterHistory() {
    var filtered = history.toList();
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((item) => 
        item.prompt.toLowerCase().contains(query)
      ).toList();
    }
    
    // Apply status filter
    switch (selectedFilter.value) {
      case 'success':
        filtered = filtered.where((item) => item.success).toList();
        break;
      case 'failed':
        filtered = filtered.where((item) => !item.success).toList();
        break;
      case 'all':
      default:
        // No additional filtering
        break;
    }
    
    filteredHistory.value = filtered;
  }

  /// Set filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
    filterHistory();
  }

  /// Set view mode
  void setViewMode(String mode) {
    viewMode.value = mode;
    if (mode == 'grouped') {
      loadGroupedHistory();
    }
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filterHistory();
  }

  /// Reuse a prompt
  void reusePrompt(String prompt) {
    // Navigate back to home with the prompt as an argument
    Get.back();
    Get.offAndToNamed('/', arguments: {'prompt': prompt});
    _showSuccessSnackbar('Prompt loaded: $prompt');
  }

  /// Remove history item
  Future<void> removeHistoryItem(String id) async {
    try {
      await HistoryService.removeHistoryItem(id);
      await loadHistory();
      await loadStatistics();
      _showSuccessSnackbar('History item removed');
    } catch (e) {
      _showErrorSnackbar('Failed to remove item: ${e.toString()}');
    }
  }

  /// Clear all history
  Future<void> clearAllHistory() async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Clear History'),
          content: const Text('Are you sure you want to clear all history? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await HistoryService.clearHistory();
        await loadHistory();
        await loadStatistics();
        _showSuccessSnackbar('History cleared');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to clear history: ${e.toString()}');
    }
  }

  /// Export history
  Future<void> exportHistory() async {
    try {
      final exportData = await HistoryService.exportHistory();
      // In a real app, you'd save this to a file or share it
      // For now, we'll just show a success message
      _showSuccessSnackbar('History exported (${exportData.length} characters)');
    } catch (e) {
      _showErrorSnackbar('Failed to export history: ${e.toString()}');
    }
  }

  /// Refresh history
  Future<void> refreshHistory() async {
    await loadHistory();
    await loadStatistics();
  }

  /// Get recent successful prompts for quick access
  Future<List<PromptHistory>> getRecentSuccessful() async {
    try {
      return await HistoryService.getRecentSuccessful(limit: 5);
    } catch (e) {
      return [];
    }
  }

  void _showSuccessSnackbar(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.error, color: Colors.white),
      ),
    );
  }
}