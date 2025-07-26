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

      // Title changes - FIXED: Added more patterns and improved extraction
      if (_containsAnyPattern(cleanPrompt, [
        'change title to',
        'set title to',
        'title to',
        'rename to',
        'change title',
        'set title',
        'update title',
        'make title',
        'change the title to',
        'set the title to',
        'change app title to',
        'set app title to',
      ])) {
        final label = _extractTitleLabel(cleanPrompt);
        if (label != null && label.isNotEmpty) {
          return LayoutInstruction(action: 'change_title', label: label);
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
      print('Error in _getHardcodedInstruction: $e');
      return null;
    }
  }

  static bool _containsAnyPattern(String prompt, List<String> patterns) {
    try {
      return patterns.any((pattern) => prompt.contains(pattern));
    } catch (e) {
      print('Error in _containsAnyPattern: $e');
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
      print('Error in _extractColor: $e');
      return null;
    }
  }

  static String? _extractLabel(String prompt) {
    try {
      // FIXED: Using raw strings and proper escaping
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
        try {
          final match = pattern.firstMatch(prompt);
          if (match != null && match.groupCount >= 1) {
            final group = match.group(1);
            if (group != null && group.trim().isNotEmpty) {
              return group.trim();
            }
          }
        } catch (e) {
          print('Error matching pattern ${pattern.pattern}: $e');
          continue;
        }
      }
      return null;
    } catch (e) {
      print('Error in _extractLabel: $e');
      return null;
    }
  }

  // FIXED: Improved title label extraction with better error handling
  static String? _extractTitleLabel(String prompt) {
    try {
      // FIXED: Using raw strings and safer regex patterns
      final titlePatterns = [
        // Exact patterns with "to"
        RegExp(r'change title to\s+(.+)', caseSensitive: false),
        RegExp(r'set title to\s+(.+)', caseSensitive: false),
        RegExp(r'title to\s+(.+)', caseSensitive: false),
        RegExp(r'rename to\s+(.+)', caseSensitive: false),
        RegExp(r'change the title to\s+(.+)', caseSensitive: false),
        RegExp(r'set the title to\s+(.+)', caseSensitive: false),
        RegExp(r'change app title to\s+(.+)', caseSensitive: false),
        RegExp(r'set app title to\s+(.+)', caseSensitive: false),

        // Patterns without "to" but with context
        RegExp(r'change title\s+(.+)', caseSensitive: false),
        RegExp(r'set title\s+(.+)', caseSensitive: false),
        RegExp(r'update title\s+(.+)', caseSensitive: false),
        RegExp(r'make title\s+(.+)', caseSensitive: false),

        // Patterns with quotes - FIXED: Better quote handling
        RegExp(r'''title\s*["']([^"']+)["']''', caseSensitive: false),
        RegExp(r'''change.*title.*["']([^"']+)["']''', caseSensitive: false),
        RegExp(r'''set.*title.*["']([^"']+)["']''', caseSensitive: false),
      ];

      for (final pattern in titlePatterns) {
        try {
          final match = pattern.firstMatch(prompt);
          if (match != null && match.groupCount >= 1) {
            final group = match.group(1);
            if (group != null) {
              String title = group.trim();

              // Clean up the extracted title
              title = title.replaceAll(
                RegExp(r'''^["']+|["']+$'''),
                '',
              ); // Remove surrounding quotes
              title = title.replaceAll(
                RegExp(r'\s+'),
                ' ',
              ); // Normalize whitespace

              if (title.isNotEmpty) {
                return title;
              }
            }
          }
        } catch (e) {
          print('Error matching title pattern ${pattern.pattern}: $e');
          continue;
        }
      }

      // Fallback: Look for common title phrases
      if (prompt.contains('my app')) {
        return 'My App';
      }
      if (prompt.contains('welcome')) {
        return 'Welcome';
      }
      if (prompt.contains('home')) {
        return 'Home';
      }

      return null;
    } catch (e) {
      print('Error extracting title label: $e');
      return null;
    }
  }

  static String? _extractPlaceholder(String prompt) {
    try {
      // FIXED: Using raw strings for better readability and safety
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
        try {
          final match = pattern.firstMatch(prompt);
          if (match != null && match.groupCount >= 1) {
            final group = match.group(1);
            if (group != null && group.trim().isNotEmpty) {
              return group.trim();
            }
          }
        } catch (e) {
          print('Error matching placeholder pattern ${pattern.pattern}: $e');
          continue;
        }
      }
      return null;
    } catch (e) {
      print('Error in _extractPlaceholder: $e');
      return null;
    }
  }

  static double? _extractSize(String prompt) {
    try {
      // FIXED: Using raw strings and better error handling
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
        try {
          final match = pattern.firstMatch(prompt);
          if (match != null) {
            final matchedText = match.group(0);
            if (matchedText != null) {
              final sizeStr = matchedText.toLowerCase();
              if (sizeStr.contains('small')) return 12.0;
              if (sizeStr.contains('medium')) return 16.0;
              if (sizeStr.contains('large') || sizeStr.contains('big'))
                return 20.0;

              // Try to extract number
              if (match.groupCount >= 1) {
                final numberMatch = match.group(1);
                if (numberMatch != null) {
                  final parsedSize = double.tryParse(numberMatch);
                  if (parsedSize != null &&
                      parsedSize > 0 &&
                      parsedSize <= 100) {
                    return parsedSize;
                  }
                }
              }
            }
          }
        } catch (e) {
          print('Error matching size pattern ${pattern.pattern}: $e');
          continue;
        }
      }
      return null;
    } catch (e) {
      print('Error in _extractSize: $e');
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
        // FIXED: Added more title change exact matches
        case 'change title to welcome':
          return LayoutInstruction(action: 'change_title', label: 'Welcome');
        case 'change title to my app':
          return LayoutInstruction(action: 'change_title', label: 'My App');
        case 'change title to home':
          return LayoutInstruction(action: 'change_title', label: 'Home');
        case 'set title to welcome':
          return LayoutInstruction(action: 'change_title', label: 'Welcome');
        case 'set title to my app':
          return LayoutInstruction(action: 'change_title', label: 'My App');
        case 'title to my app':
          return LayoutInstruction(action: 'change_title', label: 'My App');
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
      print('Error in _getExactInstruction: $e');
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
      print('Error in getColorFromString: $e');
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
      'change title to Welcome',

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
      print('Error in isValidCommand: $e');
      return false;
    }
  }

  /// Check if LLM service is configured
  static bool isLLMConfigured() {
    return LLMService.isConfigured();
  }
}
