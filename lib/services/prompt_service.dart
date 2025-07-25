import 'package:flutter/material.dart';
import '../models/layout_instruction.dart';
import '../models/multi_instruction.dart';
import 'llm_service.dart';

class PromptService {
  static Future<LayoutInstruction?> getInstruction(String prompt) async {
    if (prompt.isEmpty) return null;

    // Try LLM service first if configured
    if (LLMService.isConfigured()) {
      try {
        final instruction = await LLMService.generateInstruction(prompt);
        if (instruction != null) {
          return instruction;
        }
      } catch (e) {
        print('LLM service failed, falling back to hardcoded mappings: $e');
      }
    }

    // Fallback to hardcoded mappings
    return _getHardcodedInstruction(prompt);
  }

  /// Get multiple instructions for complex commands
  static Future<MultiInstruction?> getMultiInstruction(String prompt) async {
    if (prompt.isEmpty) return null;

    // Try LLM service first if configured
    if (LLMService.isConfigured()) {
      try {
        final multiInstruction = await LLMService.generateMultiInstruction(
          prompt,
        );
        if (multiInstruction != null) {
          return multiInstruction;
        }
      } catch (e) {
        print('LLM service failed, falling back to hardcoded mappings: $e');
      }
    }

    // Fallback to hardcoded mappings - convert single to multi
    final singleInstruction = _getHardcodedInstruction(prompt);
    if (singleInstruction != null) {
      return MultiInstruction.fromSingle(singleInstruction);
    }

    return null;
  }

  static LayoutInstruction? _getHardcodedInstruction(String prompt) {
    final cleanPrompt = prompt.toLowerCase().trim();

    try {
      // Background changes
      if (_containsAnyPattern(cleanPrompt, [
        'change background to',
        'set background',
        'background to',
        'make background',
      ])) {
        final color = _extractColor(cleanPrompt);
        if (color != null) {
          return LayoutInstruction(action: 'change_background', color: color);
        }
      }

      // Button additions
      if (_containsAnyPattern(cleanPrompt, [
        'add a button',
        'add button',
        'create button',
        'make a button',
        'new button',
        'add a red button',
        'add a blue button',
        'add a green button',
      ])) {
        final color = _extractColor(cleanPrompt) ?? 'blue';
        final label = _extractLabel(cleanPrompt) ?? 'Tap Me';
        return LayoutInstruction(
          action: 'add_component',
          component: 'button',
          color: color,
          label: label,
        );
      }

      // Container additions
      if (_containsAnyPattern(cleanPrompt, [
        'add a container',
        'add container',
        'create container',
        'make a container',
        'new container',
        'add a red container',
        'add a blue container',
        'add a green container',
      ])) {
        final color = _extractColor(cleanPrompt) ?? 'grey';
        final label = _extractLabel(cleanPrompt) ?? 'Container';
        return LayoutInstruction(
          action: 'add_component',
          component: 'container',
          color: color,
          label: label,
        );
      }

      // TextField additions
      if (_containsAnyPattern(cleanPrompt, [
        'add a textfield',
        'add textfield',
        'add text field',
        'add a text field',
        'create textfield',
        'create text field',
        'make a textfield',
        'make textfield',
        'new textfield',
        'add input field',
        'add input',
        'create input',
      ])) {
        final label =
            _extractLabel(cleanPrompt) ??
            _extractPlaceholder(cleanPrompt) ??
            'Enter text...';
        return LayoutInstruction(
          action: 'add_component',
          component: 'textfield',
          label: label,
        );
      }

      // Card additions
      if (_containsAnyPattern(cleanPrompt, [
        'add a card',
        'add card',
        'create card',
        'make a card',
        'new card',
      ])) {
        final label = _extractLabel(cleanPrompt) ?? 'Card';
        return LayoutInstruction(
          action: 'add_component',
          component: 'card',
          label: label,
        );
      }

      // Text additions
      if (_containsAnyPattern(cleanPrompt, [
        'add text',
        'add a text',
        'create text',
        'make text',
        'new text',
        'add label',
        'create label',
      ])) {
        final color = _extractColor(cleanPrompt);
        final label = _extractLabel(cleanPrompt) ?? 'Sample Text';
        final size = _extractSize(cleanPrompt);
        return LayoutInstruction(
          action: 'add_component',
          component: 'text',
          color: color,
          label: label,
          size: size,
        );
      }

      // Title changes
      if (_containsAnyPattern(cleanPrompt, [
        'change title to',
        'set title to',
        'title to',
        'rename to',
      ])) {
        final label = _extractTitleLabel(cleanPrompt);
        if (label != null && label.isNotEmpty) {
          return LayoutInstruction(action: 'change_title', label: label);
        }
      }

      // Reset commands
      if (_containsAnyPattern(cleanPrompt, [
        'reset',
        'clear',
        'start over',
        'clean',
        'remove all',
        'clear all',
      ])) {
        return LayoutInstruction(action: 'reset');
      }

      // Fallback for exact matches
      return _getExactInstruction(cleanPrompt);
    } catch (e) {
      return null;
    }
  }

  static bool _containsAnyPattern(String prompt, List<String> patterns) {
    try {
      return patterns.any((pattern) => prompt.contains(pattern));
    } catch (e) {
      return false;
    }
  }

  static String? _extractColor(String prompt) {
    try {
      final colorMap = {
        'red': 'red',
        'blue': 'blue',
        'green': 'green',
        'yellow': 'yellow',
        'purple': 'purple',
        'orange': 'orange',
        'pink': 'pink',
        'black': 'black',
        'white': 'white',
        'grey': 'grey',
        'gray': 'grey',
        'brown': 'brown',
      };

      for (final entry in colorMap.entries) {
        if (prompt.contains(entry.key)) {
          return entry.value;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static String? _extractLabel(String prompt) {
    try {
      final labelPatterns = [
        RegExp(r'with text "([^"]+)"'),
        RegExp(r"with text '([^']+)'"),
        RegExp(r'labeled "([^"]+)"'),
        RegExp(r"labeled '([^']+)'"),
        RegExp(r'saying "([^"]+)"'),
        RegExp(r"saying '([^']+)'"),
        RegExp(r'text "([^"]+)"'),
        RegExp(r"text '([^']+)'"),
        RegExp(r'with text\s+(\w+)'),
        RegExp(r'labeled\s+(\w+)'),
        RegExp(r'saying\s+(\w+)'),
      ];

      for (final pattern in labelPatterns) {
        final match = pattern.firstMatch(prompt);
        if (match != null && match.group(1) != null) {
          return match.group(1)!.trim();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static String? _extractTitleLabel(String prompt) {
    try {
      final titlePatterns = [
        RegExp(r'change title to\s+(.+)'),
        RegExp(r'set title to\s+(.+)'),
        RegExp(r'title to\s+(.+)'),
        RegExp(r'rename to\s+(.+)'),
      ];

      for (final pattern in titlePatterns) {
        final match = pattern.firstMatch(prompt);
        if (match != null && match.group(1) != null) {
          return match.group(1)!.trim();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static String? _extractPlaceholder(String prompt) {
    try {
      final placeholderPatterns = [
        RegExp(r'placeholder "([^"]+)"'),
        RegExp(r"placeholder '([^']+)'"),
        RegExp(r'hint "([^"]+)"'),
        RegExp(r"hint '([^']+)'"),
        RegExp(r'with placeholder "([^"]+)"'),
        RegExp(r"with placeholder '([^']+)'"),
        RegExp(r'with hint "([^"]+)"'),
        RegExp(r"with hint '([^']+)'"),
      ];

      for (final pattern in placeholderPatterns) {
        final match = pattern.firstMatch(prompt);
        if (match != null && match.group(1) != null) {
          return match.group(1)!.trim();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static double? _extractSize(String prompt) {
    try {
      final sizePatterns = [
        RegExp(r'size (\d+)'),
        RegExp(r'font size (\d+)'),
        RegExp(r'(\d+)px'),
        RegExp(r'small'),
        RegExp(r'medium'),
        RegExp(r'large'),
        RegExp(r'big'),
      ];

      for (final pattern in sizePatterns) {
        final match = pattern.firstMatch(prompt);
        if (match != null) {
          final sizeStr = match.group(0)!.toLowerCase();
          if (sizeStr.contains('small')) return 12.0;
          if (sizeStr.contains('medium')) return 16.0;
          if (sizeStr.contains('large') || sizeStr.contains('big')) return 20.0;

          final numberMatch = match.group(1);
          if (numberMatch != null) {
            return double.tryParse(numberMatch);
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static LayoutInstruction? _getExactInstruction(String prompt) {
    try {
      switch (prompt) {
        case 'change background to blue':
          return LayoutInstruction(action: 'change_background', color: 'blue');
        case 'change background to red':
          return LayoutInstruction(action: 'change_background', color: 'red');
        case 'change background to green':
          return LayoutInstruction(action: 'change_background', color: 'green');
        case 'change background to yellow':
          return LayoutInstruction(
            action: 'change_background',
            color: 'yellow',
          );
        case 'change background to white':
          return LayoutInstruction(action: 'change_background', color: 'white');
        case 'change background to black':
          return LayoutInstruction(action: 'change_background', color: 'black');
        case 'add a red button':
          return LayoutInstruction(
            action: 'add_component',
            component: 'button',
            color: 'red',
            label: 'Tap Me',
          );
        case 'add a blue button':
          return LayoutInstruction(
            action: 'add_component',
            component: 'button',
            color: 'blue',
            label: 'Tap Me',
          );
        case 'add a green button':
          return LayoutInstruction(
            action: 'add_component',
            component: 'button',
            color: 'green',
            label: 'Tap Me',
          );
        case 'reset':
          return LayoutInstruction(action: 'reset');
        case 'change title to welcome':
          return LayoutInstruction(action: 'change_title', label: 'Welcome!');
        case 'add a green container':
          return LayoutInstruction(
            action: 'add_component',
            component: 'container',
            color: 'green',
          );
        case 'add a red container':
          return LayoutInstruction(
            action: 'add_component',
            component: 'container',
            color: 'red',
          );
        case 'add a blue container':
          return LayoutInstruction(
            action: 'add_component',
            component: 'container',
            color: 'blue',
          );
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Color? getColorFromString(String? color) {
    if (color == null || color.isEmpty) return null;

    try {
      switch (color.toLowerCase().trim()) {
        case 'blue':
          return Colors.blue;
        case 'red':
          return Colors.red;
        case 'green':
          return Colors.green;
        case 'yellow':
          return Colors.yellow;
        case 'purple':
          return Colors.purple;
        case 'orange':
          return Colors.orange;
        case 'pink':
          return Colors.pink;
        case 'black':
          return Colors.black;
        case 'white':
          return Colors.white;
        case 'brown':
          return Colors.brown;
        case 'grey':
        case 'gray':
          return Colors.grey;
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  static List<String> getSampleCommands() {
    return [
      // Button commands
      'add a red button',
      'add button with text "Click Me"',
      'create a blue button',

      // Container commands
      'add a green container',
      'create container labeled "My Box"',
      'add a purple container',

      // TextField commands
      'add a textfield',
      'add textfield with placeholder "Enter name"',
      'create input field',
      'add text field with hint "Type here"',

      // Text commands
      'add text saying "Hello World"',
      'create large text',
      'add red text with size 18',
      'make small blue text',

      // Card commands
      'add a card',
      'create card labeled "Info Card"',

      // Background and title commands
      'change background to green',
      'change title to My App',
      'set background yellow',

      // Utility commands
      'reset',
      'clear all',
    ];
  }

  static List<String> getAvailableColors() {
    return [
      'red',
      'blue',
      'green',
      'yellow',
      'purple',
      'orange',
      'pink',
      'black',
      'white',
      'grey',
    ];
  }

  static List<String> getAvailableComponents() {
    return ['button', 'container', 'textfield', 'text', 'card'];
  }

  static bool isValidCommand(String command) {
    if (command.isEmpty) return false;

    try {
      final cleanCommand = command.toLowerCase().trim();

      final validPatterns = [
        'add',
        'create',
        'make',
        'new',
        'change',
        'set',
        'update',
        'reset',
        'clear',
        'remove',
      ];

      return validPatterns.any((pattern) => cleanCommand.contains(pattern));
    } catch (e) {
      return false;
    }
  }

  /// Check if LLM service is configured
  static bool isLLMConfigured() {
    return LLMService.isConfigured();
  }
}
