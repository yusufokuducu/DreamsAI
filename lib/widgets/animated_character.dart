import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/animation_service.dart';
import '../models/animation_state.dart';

/// Animasyonlu karakter widget'ı
class AnimatedCharacter extends StatelessWidget {
  final double? width;
  final double? height;
  final Alignment alignment;

  const AnimatedCharacter({
    super.key,
    this.width,
    this.height,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AnimationService>(
      builder: (context, animationService, child) {
        final state = animationService.state;
        
        return Container(
          width: width,
          height: height,
          alignment: alignment,
          child: _buildCharacterAnimation(state.characterState),
        );
      },
    );
  }

  Widget _buildCharacterAnimation(AnimationState state) {
    // Şimdilik placeholder animasyonlar kullanacağız
    // Gerçek Lottie dosyaları eklendikten sonra bunlar değiştirilecek
    
    switch (state) {
      case AnimationState.idle:
        return _buildIdleAnimation();
      case AnimationState.thinking:
        return _buildThinkingAnimation();
      case AnimationState.processing:
        return _buildProcessingAnimation();
      case AnimationState.success:
        return _buildSuccessAnimation();
      case AnimationState.error:
        return _buildErrorAnimation();
    }
  }

  Widget _buildIdleAnimation() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.3),
            const Color(0xFF6C63FF).withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: const Icon(
        Icons.auto_awesome,
        size: 60,
        color: Color(0xFF6C63FF),
      ),
    ).animate()
        .scale(duration: 2.seconds, curve: Curves.easeInOut)
        .then()
        .scale(duration: 2.seconds, curve: Curves.easeInOut);
  }

  Widget _buildThinkingAnimation() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.4),
            const Color(0xFF4CAF50).withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
      child: const Icon(
        Icons.psychology,
        size: 60,
        color: Color(0xFF4CAF50),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
        .scale(duration: 1.seconds, curve: Curves.easeInOut)
        .then()
        .scale(duration: 1.seconds, curve: Curves.easeInOut);
  }

  Widget _buildProcessingAnimation() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFFF9800).withOpacity(0.4),
            const Color(0xFFFF9800).withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
      child: const Icon(
        Icons.sync,
        size: 60,
        color: Color(0xFFFF9800),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
        .rotate(duration: 2.seconds, curve: Curves.linear);
  }

  Widget _buildSuccessAnimation() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.6),
            const Color(0xFF4CAF50).withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: const Icon(
        Icons.check_circle,
        size: 60,
        color: Color(0xFF4CAF50),
      ),
    ).animate()
        .scale(duration: 0.5.seconds, curve: Curves.elasticOut)
        .then()
        .shimmer(duration: 1.seconds, color: const Color(0xFF4CAF50).withOpacity(0.3));
  }

  Widget _buildErrorAnimation() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFF44336).withOpacity(0.4),
            const Color(0xFFF44336).withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
      child: const Icon(
        Icons.error,
        size: 60,
        color: Color(0xFFF44336),
      ),
    ).animate()
        .shake(duration: 0.5.seconds, curve: Curves.elasticIn);
  }
}
