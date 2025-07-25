import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/layout_instruction.dart';
import '../services/prompt_service.dart';
import '../services/llm_service.dart';
import '../services/history_service.dart';

class HomeController extends GetxController {
  var title = 'LLM UI Playground'.obs;
  var backgroundColor = Colors.white.obs;
  var components = <LayoutInstruction>[].obs;
  var isLoading = false.obs;

  final TextEditingController promptController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    LLMService.initialize();

    // Check if there's a prompt argument from history reuse
    final arguments = Get.arguments;
    if (arguments != null &&
        arguments is Map &&
        arguments.containsKey('prompt')) {
      final prompt = arguments['prompt'] as String;
      promptController.text = prompt;
    }
  }

  Future<void> handlePrompt(String prompt) async {
    if (prompt.trim().isEmpty) return;

    final trimmedPrompt = prompt.trim();
    isLoading.value = true;

    try {
      // Try multi-instruction first for complex commands
      final multiInstruction = await PromptService.getMultiInstruction(
        trimmedPrompt,
      );

      isLoading.value = false;

      if (multiInstruction == null || multiInstruction.instructions.isEmpty) {
        // Add failed prompt to history
        await HistoryService.addPrompt(
          prompt: trimmedPrompt,
          success: false,
          errorMessage: 'Command not recognized',
        );

        _showErrorSnackbar(
          'Command not recognized',
          'Try: "add a red button", "create a login form", or "reset"',
        );
        return;
      }

      // Apply all instructions
      for (final instruction in multiInstruction.instructions) {
        applyInstruction(instruction);
      }

      // Add successful prompt to history
      await HistoryService.addPrompt(
        prompt: trimmedPrompt,
        success: true,
        componentsCreated: multiInstruction.instructions.length,
      );

      // Show success message
      if (multiInstruction.instructions.length > 1) {
        _showSuccessSnackbar(
          'Created ${multiInstruction.instructions.length} components successfully!',
        );
      } else {
        _showSuccessSnackbar('Command executed successfully!');
      }
    } catch (e) {
      isLoading.value = false;

      // Add failed prompt to history
      await HistoryService.addPrompt(
        prompt: trimmedPrompt,
        success: false,
        errorMessage: e.toString(),
      );

      _showErrorSnackbar('Error', 'Failed to process command: ${e.toString()}');
    }
  }

  void applyInstruction(LayoutInstruction instruction) {
    switch (instruction.action) {
      case 'change_title':
        title.value = instruction.label ?? title.value;
        break;
      case 'change_background':
        final newColor = PromptService.getColorFromString(instruction.color);
        if (newColor != null) {
          backgroundColor.value = newColor;
        }
        break;
      case 'add_component':
        components.add(instruction);
        break;
      case 'reset':
        reset();
        break;
      default:
        _showErrorSnackbar(
          'Unknown Action',
          'Action ${instruction.action} is not supported',
        );
    }
  }

  void removeComponent(int index) {
    if (index >= 0 && index < components.length) {
      components.removeAt(index);
      _showSuccessSnackbar('Component removed');
    }
  }

  void reset() {
    title.value = 'LLM UI Playground';
    backgroundColor.value = Colors.white;
    components.clear();
    promptController.clear();
    _showSuccessSnackbar('Playground reset successfully');
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

  void _showErrorSnackbar(String title, String message) {
    Get.showSnackbar(
      GetSnackBar(
        titleText: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        messageText: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.error, color: Colors.white),
      ),
    );
  }

  @override
  void onClose() {
    promptController.dispose();
    super.onClose();
  }
}
