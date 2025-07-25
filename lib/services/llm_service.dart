import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../models/layout_instruction.dart';
import '../models/multi_instruction.dart';

class LLMService {
  static final Dio _dio = Dio();
  static final GetStorage _storage = GetStorage();
  
  // Configuration keys
  static const String _apiKeyKey = 'llm_api_key';
  static const String _providerKey = 'llm_provider';
  static const String _modelKey = 'llm_model';
  
  // Default configuration
  static const String _defaultProvider = 'openai';
  static const String _defaultModel = 'gpt-3.5-turbo';
  
  // API endpoints
  static const Map<String, String> _endpoints = {
    'openai': 'https://api.openai.com/v1/chat/completions',
    'anthropic': 'https://api.anthropic.com/v1/messages',
    'groq': 'https://api.groq.com/openai/v1/chat/completions',
  };

  /// Initialize the LLM service
  static Future<void> initialize() async {
    await GetStorage.init();
    
    // Set default configuration if not exists
    if (!_storage.hasData(_providerKey)) {
      _storage.write(_providerKey, _defaultProvider);
    }
    if (!_storage.hasData(_modelKey)) {
      _storage.write(_modelKey, _defaultModel);
    }
  }

  /// Set API configuration
  static void setConfiguration({
    required String apiKey,
    String? provider,
    String? model,
  }) {
    _storage.write(_apiKeyKey, apiKey);
    if (provider != null) _storage.write(_providerKey, provider);
    if (model != null) _storage.write(_modelKey, model);
  }

  /// Get current configuration
  static Map<String, String?> getConfiguration() {
    return {
      'apiKey': _storage.read(_apiKeyKey),
      'provider': _storage.read(_providerKey) ?? _defaultProvider,
      'model': _storage.read(_modelKey) ?? _defaultModel,
    };
  }

  /// Check if LLM service is configured
  static bool isConfigured() {
    return _storage.hasData(_apiKeyKey) && 
           _storage.read(_apiKeyKey)?.toString().isNotEmpty == true;
  }

  /// Generate layout instruction from natural language prompt
  static Future<LayoutInstruction?> generateInstruction(String prompt) async {
    // First try multi-component generation
    final multiResult = await generateMultiInstruction(prompt);
    if (multiResult != null && multiResult.instructions.isNotEmpty) {
      // Return the first instruction for backward compatibility
      return multiResult.instructions.first;
    }
    return null;
  }

  /// Generate multiple layout instructions from complex natural language prompt
  static Future<MultiInstruction?> generateMultiInstruction(String prompt) async {
    if (!isConfigured()) {
      throw Exception('LLM service not configured. Please set API key.');
    }

    try {
      final config = getConfiguration();
      final provider = config['provider']!;
      final model = config['model']!;
      final apiKey = config['apiKey']!;

      print('LLM Service: Using provider: $provider, model: $model');
      print('LLM Service: Processing prompt: $prompt');

      final systemPrompt = _buildMultiSystemPrompt();
      final userPrompt = _buildUserPrompt(prompt);

      final response = await _makeRequest(
        provider: provider,
        model: model,
        apiKey: apiKey,
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
      );

      print('LLM Service: Raw response: $response');
      return _parseMultiResponse(response);
    } catch (e) {
      print('LLM Service Error: $e');
      if (e is DioException) {
        print('DioException details: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
      }
      rethrow; // Re-throw to show user the actual error
    }
  }

  /// Build multi-component system prompt for the LLM
  static String _buildMultiSystemPrompt() {
    return '''
You are a Flutter UI component generator. Your task is to convert natural language descriptions into structured JSON instructions for creating Flutter UI components.

IMPORTANT: Respond with ONLY valid JSON. Do not include any explanatory text, prefixes, or markdown formatting.

Available components:
- button: Creates an ElevatedButton with customizable color and label
- container: Creates a Container with customizable color and label
- textfield: Creates a TextField with customizable placeholder text
- text: Creates a Text widget with customizable color, size, and content
- card: Creates a Card widget with customizable label
- switch: Creates a toggle switch with customizable color and label
- slider: Creates a slider with customizable color and label
- checkbox: Creates a checkbox with customizable color and label
- radio: Creates radio buttons with customizable color and label
- dropdown: Creates a dropdown selector with customizable color and label
- image: Creates an image placeholder with customizable color and label
- icon: Creates an icon with customizable color and smart icon selection
- divider: Creates a divider/separator with customizable color and label
- progress: Creates a progress bar with customizable color and label
- listitem: Creates a list item with customizable color and label
- chip: Creates a chip/tag with customizable color and label
- badge: Creates a notification badge with customizable color and label
- fab: Creates a floating action button with customizable color and label
- iconbutton: Creates an icon button with customizable color and label
- textbutton: Creates a text button with customizable color and label
- outlinedbutton: Creates an outlined button with customizable color and label
- passwordfield: Creates a password input field with customizable label
- emailfield: Creates an email input field with customizable label
- numberfield: Creates a number input field with customizable label
- textarea: Creates a multi-line text area with customizable label

Available actions:
- add_component: Add a new UI component
- change_background: Change the background color
- change_title: Change the app title
- reset: Clear all components

Available colors: red, blue, green, yellow, purple, orange, pink, black, white, grey

For complex requests that involve multiple components, respond with an array of instructions:
{
  "instructions": [
    {
      "action": "add_component|change_background|change_title|reset",
      "component": "button|container|textfield|text|card|switch|slider|checkbox|radio|dropdown|image|icon|divider|progress|listitem|chip|badge|fab|iconbutton|textbutton|outlinedbutton|passwordfield|emailfield|numberfield|textarea",
      "color": "color_name",
      "label": "text_content",
      "size": 16.0
    }
  ],
  "description": "Brief description of what was created"
}

For simple single-component requests, respond with a single instruction:
{
  "action": "add_component",
  "component": "button",
  "color": "red",
  "label": "Click Me"
}

Examples:
Input: "add a red button"
Output: {"action": "add_component", "component": "button", "color": "red", "label": "Click Me"}

Input: "add a toggle switch"
Output: {"action": "add_component", "component": "switch", "color": "blue", "label": "Enable notifications"}

Input: "add a heart icon"
Output: {"action": "add_component", "component": "icon", "color": "red", "label": "heart"}

Input: "create a login form with username field and blue submit button"
Output: {
  "instructions": [
    {"action": "add_component", "component": "text", "label": "Login", "size": 20.0},
    {"action": "add_component", "component": "textfield", "label": "Username"},
    {"action": "add_component", "component": "passwordfield", "label": "Password"},
    {"action": "add_component", "component": "button", "color": "blue", "label": "Submit"}
  ],
  "description": "Login form with username and password fields"
}

Remember: Return ONLY the JSON object, no additional text.
''';
  }

  /// Build user prompt
  static String _buildUserPrompt(String prompt) {
    return 'Convert this instruction to JSON: "$prompt"';
  }

  /// Parse multi-component LLM response
  static MultiInstruction? _parseMultiResponse(String response) {
    try {
      // Clean the response to extract JSON
      String cleanResponse = response.trim();
      
      // Remove common prefixes that LLMs add
      final prefixesToRemove = [
        'Here is the JSON instruction:',
        'Here is the JSON:',
        'JSON:',
        'Response:',
        'Output:',
        'Result:',
      ];
      
      for (final prefix in prefixesToRemove) {
        if (cleanResponse.startsWith(prefix)) {
          cleanResponse = cleanResponse.substring(prefix.length).trim();
        }
      }
      
      // Remove markdown code blocks if present
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.startsWith('```')) {
        cleanResponse = cleanResponse.substring(3);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      
      cleanResponse = cleanResponse.trim();
      
      // Try to find JSON in the response if it's still not clean
      if (!cleanResponse.startsWith('{')) {
        final jsonStart = cleanResponse.indexOf('{');
        if (jsonStart != -1) {
          cleanResponse = cleanResponse.substring(jsonStart);
        }
      }
      
      // Find the end of JSON if there's trailing text
      if (cleanResponse.contains('}')) {
        final lastBrace = cleanResponse.lastIndexOf('}');
        if (lastBrace != -1) {
          cleanResponse = cleanResponse.substring(0, lastBrace + 1);
        }
      }
      
      print('Cleaned response for parsing: $cleanResponse');
      
      final jsonData = jsonDecode(cleanResponse);
      
      // Check if it's a multi-instruction response
      if (jsonData.containsKey('instructions')) {
        return MultiInstruction.fromJson(jsonData);
      } else {
        // Single instruction - convert to multi for consistency
        final singleInstruction = LayoutInstruction(
          action: jsonData['action'],
          component: jsonData['component'],
          color: jsonData['color'],
          label: jsonData['label'],
          size: jsonData['size']?.toDouble(),
        );
        return MultiInstruction.fromSingle(singleInstruction);
      }
    } catch (e) {
      print('Failed to parse multi LLM response: $e');
      print('Response was: $response');
      return null;
    }
  }

  /// Make request to LLM provider
  static Future<String> _makeRequest({
    required String provider,
    required String model,
    required String apiKey,
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final endpoint = _endpoints[provider];
    if (endpoint == null) {
      throw Exception('Unsupported provider: $provider');
    }

    Map<String, dynamic> requestBody;
    Map<String, String> headers;

    switch (provider) {
      case 'openai':
      case 'groq':
        headers = {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        };
        requestBody = {
          'model': model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.1,
          'max_tokens': 500,
        };
        break;
      
      case 'anthropic':
        headers = {
          'x-api-key': apiKey,
          'Content-Type': 'application/json',
          'anthropic-version': '2023-06-01',
        };
        requestBody = {
          'model': model,
          'max_tokens': 200,
          'messages': [
            {'role': 'user', 'content': '$systemPrompt\n\n$userPrompt'},
          ],
        };
        break;
      
      default:
        throw Exception('Unsupported provider: $provider');
    }

    final response = await _dio.post(
      endpoint,
      data: requestBody,
      options: Options(headers: headers),
    );

    if (response.statusCode != 200) {
      throw Exception('API request failed: ${response.statusCode}');
    }

    return _extractContent(response.data, provider);
  }

  /// Extract content from API response
  static String _extractContent(Map<String, dynamic> response, String provider) {
    switch (provider) {
      case 'openai':
      case 'groq':
        return response['choices'][0]['message']['content'];
      
      case 'anthropic':
        return response['content'][0]['text'];
      
      default:
        throw Exception('Unsupported provider: $provider');
    }
  }

  /// Get available models for a provider
  static List<String> getAvailableModels(String provider) {
    switch (provider) {
      case 'openai':
        return ['gpt-3.5-turbo', 'gpt-4', 'gpt-4-turbo'];
      case 'anthropic':
        return ['claude-3-haiku-20240307', 'claude-3-sonnet-20240229', 'claude-3-opus-20240229'];
      case 'groq':
        return ['llama3-8b-8192', 'llama3-70b-8192', 'mixtral-8x7b-32768'];
      default:
        return [];
    }
  }

  /// Get available providers
  static List<String> getAvailableProviders() {
    return _endpoints.keys.toList();
  }

  /// Debug method to test API connectivity
  static Future<Map<String, dynamic>> debugApiCall({
    required String provider,
    required String model,
    required String apiKey,
  }) async {
    try {
      final endpoint = _endpoints[provider];
      if (endpoint == null) {
        return {'success': false, 'error': 'Unsupported provider: $provider'};
      }

      Map<String, dynamic> requestBody;
      Map<String, String> headers;

      switch (provider) {
        case 'openai':
        case 'groq':
          headers = {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          };
          requestBody = {
            'model': model,
            'messages': [
              {'role': 'user', 'content': 'Say "test" in JSON format: {"test": "success"}'},
            ],
            'temperature': 0.1,
            'max_tokens': 50,
          };
          break;
        
        case 'anthropic':
          headers = {
            'x-api-key': apiKey,
            'Content-Type': 'application/json',
            'anthropic-version': '2023-06-01',
          };
          requestBody = {
            'model': model,
            'max_tokens': 50,
            'messages': [
              {'role': 'user', 'content': 'Say "test" in JSON format: {"test": "success"}'},
            ],
          };
          break;
        
        default:
          return {'success': false, 'error': 'Unsupported provider: $provider'};
      }

      print('Debug API Call:');
      print('Endpoint: $endpoint');
      print('Headers: $headers');
      print('Body: $requestBody');

      final response = await _dio.post(
        endpoint,
        data: requestBody,
        options: Options(headers: headers),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final content = _extractContent(response.data, provider);
        return {
          'success': true,
          'response': content,
          'statusCode': response.statusCode,
          'fullResponse': response.data,
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}',
          'response': response.data,
        };
      }
    } catch (e) {
      print('Debug API Call Error: $e');
      if (e is DioException) {
        print('DioException details: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
        return {
          'success': false,
          'error': e.toString(),
          'statusCode': e.response?.statusCode,
          'responseData': e.response?.data,
        };
      }
      return {'success': false, 'error': e.toString()};
    }
  }
}