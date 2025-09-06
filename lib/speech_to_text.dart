import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextScreen extends StatefulWidget {
  final bool autoStart;

  const SpeechToTextScreen({super.key, this.autoStart = false});

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  bool isListening = false;
  late stt.SpeechToText _speechToText;
  String text = "Press the button and start speaking";
  double confidence = 1.0;
  List<String> detectedEmojis = [];

  final Map<String, String> emotionMap = {
    "happy": "😀",
    "joy": "😁",
    "smile": "😊",
    "sad": "☹️",
    "cry": "😭",
    "angry": "😡",
    "mad": "🤬",
    "excited": "🤩",
    "love": "❤️",
    "tired": "🥱",
    "sleepy": "😴",
    "fear": "😨",
    "scared": "😱",
    "calm": "😌",
  };

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.autoStart) {
        _captureVoice();
      }
    });
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confidence: ${(confidence * 100).toStringAsFixed(1)}%"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        glowColor: Colors.blue,
        duration: const Duration(milliseconds: 1000),
        repeat: true,
        child: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          onPressed: _captureVoice,
          child: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(
                text,
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (detectedEmojis.isNotEmpty)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: detectedEmojis
                      .map((emoji) => Text(
                    emoji,
                    style: const TextStyle(fontSize: 40),
                  ))
                      .toList(),
                )
              else
                const Text(
                  "🎤 Speak to see your emotions!",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _captureVoice() async {
    if (!isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => isListening = true);
        _speechToText.listen(
          onResult: (result) => setState(() {
            text = result.recognizedWords;
            detectedEmojis = _detectEmotions(text);
            if (result.hasConfidenceRating && result.confidence > 0) {
              confidence = result.confidence;
            }
          }),
        );
      } else {
        setState(() {
          text = "Speech recognition not available";
        });
      }
    } else {
      setState(() => isListening = false);
      _speechToText.stop();
    }
  }

  /// ✅ Detect multiple emotions
  List<String> _detectEmotions(String input) {
    List<String> found = [];
    String lower = input.toLowerCase();

    emotionMap.forEach((keyword, emoji) {
      if (lower.contains(keyword)) {
        found.add(emoji);
      }
    });

    return found;
  }
}
