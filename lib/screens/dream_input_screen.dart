import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gemini_service.dart';
import '../services/advanced_gemini_service.dart';
import '../services/animation_service.dart';
import '../services/limit_service.dart';
import '../services/performance_service.dart';
import '../models/animation_state.dart';
import '../widgets/animated_character.dart';
import '../widgets/magic_sphere.dart';
import 'dream_result_screen.dart';
import 'premium_screen.dart';

class DreamInputScreen extends StatefulWidget {
  const DreamInputScreen({super.key});

  @override
  State<DreamInputScreen> createState() => _DreamInputScreenState();
}

class _DreamInputScreenState extends State<DreamInputScreen> {
  final TextEditingController _dreamController = TextEditingController();
  bool _isLoading = false;
  final AdvancedGeminiService _geminiService = AdvancedGeminiService();

  @override
  void dispose() {
    _dreamController.dispose();
    super.dispose();
    // Cancel any ongoing API calls if needed
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

    // Performans izleme başlat
    PerformanceService.startOperation('dream_interpretation');

    // Limit kontrolü
    final limitStatus = await LimitService.getLimitStatus();
    if (limitStatus['isLimitReached'] == true) {
      _showLimitReachedDialog();
      return;
    }

    final animationService = Provider.of<AnimationService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Rüya yorumlama sürecini başlat
      animationService.startDreamProcessing();
      
      final dreamText = _dreamController.text.trim();
      
      // Performans izleme - API çağrısı
      PerformanceService.startOperation('api_call');
      final interpretation = await _geminiService.interpretDream(dreamText);
      PerformanceService.endOperation('api_call');
      
      if (mounted) {
        // Limit kullanımını kaydet
        await LimitService.useDreamInterpretation();
        
        // Başarılı yorumlama
        animationService.showSuccess();
        
        // Kısa bir gecikme sonrası sonuç ekranına git
        await Future.delayed(const Duration(seconds: 2));
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DreamResultScreen(
              dream: dreamText,
              interpretation: interpretation,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Hata durumu
        animationService.showError();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorumlama hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Performans izleme bitir
      PerformanceService.endOperation('dream_interpretation');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        child: Stack(
          children: [
            Padding(
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
                    onChanged: (text) {
                      final animationService = Provider.of<AnimationService>(context, listen: false);
                      if (text.trim().isNotEmpty) {
                        animationService.startDreamWriting();
                      } else {
                        animationService.setCharacterState(AnimationState.idle);
                      }
                    },
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
            // Animasyonlu karakter ve küre
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const AnimatedCharacter(),
                  const SizedBox(height: 20),
                  const MagicSphere(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C63FF).withOpacity(0.2),
                border: Border.all(
                  color: const Color(0xFF6C63FF),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.lock,
                color: Color(0xFF6C63FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Haftalık Limit Doldu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bu hafta 3 ücretsiz rüya yorumu hakkınızı kullandınız.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Premium Paketler',
                    style: TextStyle(
                      color: Color(0xFF6C63FF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Haftalık limitinizi artırın ve sınırsız rüya yorumu yapın!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Daha Sonra',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PremiumScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Premium\'a Geç',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
