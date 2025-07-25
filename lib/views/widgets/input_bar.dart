import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../../controllers/home_controller.dart';

class InputBar extends StatefulWidget {
  final HomeController controller;
  const InputBar({super.key, required this.controller});

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final FocusNode _focusNode = FocusNode();
  
  // Speech to text variables
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initSpeech();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Initialize speech to text
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) {
        setState(() {
          _isListening = false;
        });
        _showErrorSnackbar('Speech recognition error: ${error.errorMsg}');
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
          });
        }
      },
    );
    setState(() {});
  }

  Future<void> _handleSend() async {
    final prompt = widget.controller.promptController.text.trim();
    if (prompt.isNotEmpty) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      await widget.controller.handlePrompt(prompt);
      widget.controller.promptController.clear();
      _focusNode.unfocus();
    }
  }

  /// Start listening for speech input
  void _startListening() async {
    if (!_speechEnabled) {
      _showErrorSnackbar('Speech recognition not available');
      return;
    }

    setState(() {
      _isListening = true;
      _lastWords = '';
    });

    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        onDevice: false,
        listenMode: ListenMode.confirmation,
      ),
      localeId: 'en_US',
      onSoundLevelChange: (level) {
        // Optional: You can use this to show sound level visualization
      },
    );
  }

  /// Stop listening for speech input
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  /// Handle speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      widget.controller.promptController.text = _lastWords;
    });

    // If the result is final, automatically send the command
    if (result.finalResult && _lastWords.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _handleSend();
        }
      });
    }
  }

  /// Toggle speech recognition
  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 80, 16), // Extra right padding for FAB
      decoration: BoxDecoration(
        color: widget.controller.backgroundColor.value,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _isListening 
                      ? Colors.red.shade50 
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: _isListening 
                        ? Colors.red 
                        : (_focusNode.hasFocus ? Colors.blue : Colors.transparent),
                    width: 2,
                  ),
                ),
                child: TextField(
                  controller: widget.controller.promptController,
                  focusNode: _focusNode,
                  onSubmitted: (_) => _handleSend(),
                  decoration: InputDecoration(
                    hintText: _isListening 
                        ? 'Listening... Speak now!' 
                        : 'Type or speak your command...',
                    hintStyle: TextStyle(
                      color: _isListening 
                          ? Colors.red.shade600 
                          : Colors.grey.shade600,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    prefixIcon: Icon(
                      _isListening 
                          ? Icons.mic 
                          : Icons.chat_bubble_outline,
                      color: _isListening 
                          ? Colors.red.shade600 
                          : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  maxLines: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Microphone button
            if (_speechEnabled) ...[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isListening 
                        ? [Colors.red, Colors.redAccent]
                        : [Colors.green, Colors.greenAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.red : Colors.green).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: _toggleListening,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          key: ValueKey(_isListening),
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Send button - Enhanced and more prominent
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: _handleSend,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
