import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/llm_service.dart';

class SettingsController extends GetxController {
  final apiKeyController = TextEditingController();
  final testPromptController = TextEditingController();
  
  final selectedProvider = 'openai'.obs;
  final selectedModel = 'gpt-3.5-turbo'.obs;
  final showApiKey = false.obs;
  final isConfigured = false.obs;
  final isLoading = false.obs;
  final testResult = ''.obs;
  final testSuccess = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadConfiguration();
    testPromptController.text = 'add a red button';
  }

  @override
  void onClose() {
    apiKeyController.dispose();
    testPromptController.dispose();
    super.onClose();
  }

  void _loadConfiguration() {
    final config = LLMService.getConfiguration();
    
    if (config['apiKey'] != null) {
      apiKeyController.text = config['apiKey']!;
    }
    
    selectedProvider.value = config['provider'] ?? 'openai';
    selectedModel.value = config['model'] ?? 'gpt-3.5-turbo';
    isConfigured.value = LLMService.isConfigured();
  }

  void setProvider(String provider) {
    selectedProvider.value = provider;
    
    // Update model to first available for this provider
    final availableModels = LLMService.getAvailableModels(provider);
    if (availableModels.isNotEmpty) {
      selectedModel.value = availableModels.first;
    }
  }

  void setModel(String model) {
    selectedModel.value = model;
  }

  void toggleApiKeyVisibility() {
    showApiKey.value = !showApiKey.value;
  }

  Future<void> testConfiguration() async {
    if (apiKeyController.text.trim().isEmpty) {
      _showTestResult(false, 'Please enter an API key');
      return;
    }

    if (testPromptController.text.trim().isEmpty) {
      _showTestResult(false, 'Please enter a test prompt');
      return;
    }

    isLoading.value = true;
    testResult.value = '';

    try {
      // Temporarily set configuration for testing
      LLMService.setConfiguration(
        apiKey: apiKeyController.text.trim(),
        provider: selectedProvider.value,
        model: selectedModel.value,
      );

      print('Testing with provider: ${selectedProvider.value}, model: ${selectedModel.value}');
      print('API Key length: ${apiKeyController.text.trim().length}');

      final instruction = await LLMService.generateInstruction(
        testPromptController.text.trim(),
      );

      if (instruction != null) {
        _showTestResult(
          true, 
          'Successfully generated instruction:\n'
          'Action: ${instruction.action}\n'
          'Component: ${instruction.component ?? 'N/A'}\n'
          'Color: ${instruction.color ?? 'N/A'}\n'
          'Label: ${instruction.label ?? 'N/A'}\n'
          'Size: ${instruction.size ?? 'N/A'}'
        );
      } else {
        _showTestResult(false, 'Failed to generate instruction from prompt. Check console for details.');
      }
    } catch (e) {
      print('Test configuration error: $e');
      String errorMessage = 'Error: ${e.toString()}';
      
      // Provide more specific error messages
      if (e.toString().contains('401')) {
        errorMessage = 'Authentication failed. Please check your API key.';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access forbidden. Please verify your API key permissions.';
      } else if (e.toString().contains('429')) {
        errorMessage = 'Rate limit exceeded. Please try again later.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }
      
      _showTestResult(false, errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  void _showTestResult(bool success, String message) {
    testSuccess.value = success;
    testResult.value = message;
  }

  void saveConfiguration() {
    if (apiKeyController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an API key',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      LLMService.setConfiguration(
        apiKey: apiKeyController.text.trim(),
        provider: selectedProvider.value,
        model: selectedModel.value,
      );

      isConfigured.value = LLMService.isConfigured();

      Get.snackbar(
        'Success',
        'Configuration saved successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Go back to home
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save configuration: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}