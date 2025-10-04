import 'package:flutter/material.dart';

class DreamInputScreen extends StatefulWidget {
  const DreamInputScreen({super.key});

  @override
  State<DreamInputScreen> createState() => _DreamInputScreenState();
}

class _DreamInputScreenState extends State<DreamInputScreen> {
  final TextEditingController _dreamController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _dreamController.dispose();
    super.dispose();
  }

  void _interpretDream() async {
    if (_dreamController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen rüyanızı yazın'),
          backgroundColor: Color(0xFF1A1A1A),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: AI entegrasyonu yapılacak
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI entegrasyonu yakında eklenecek'),
          backgroundColor: Color(0xFF6C63FF),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dreams AI',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Rüyanızı Anlatın',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Yapay zeka sizin için rüyanızı yorumlayacak',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF1A1A1A),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _dreamController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Rüyanızı detaylıca yazın...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontWeight: FontWeight.w300,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _interpretDream,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: const Color(0xFF1A1A1A),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Yorumla',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
