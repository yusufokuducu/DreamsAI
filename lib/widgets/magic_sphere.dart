import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/animation_service.dart';
import '../models/animation_state.dart';

/// Büyülü küre animasyon widget'ı
class MagicSphere extends StatefulWidget {
  final double? width;
  final double? height;
  final Alignment alignment;

  const MagicSphere({
    super.key,
    this.width,
    this.height,
    this.alignment = Alignment.center,
  });

  @override
  State<MagicSphere> createState() => _MagicSphereState();
}

class _MagicSphereState extends State<MagicSphere>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _particleController;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnimationService>(
      builder: (context, animationService, child) {
        final state = animationService.state;
        
        return Container(
          width: widget.width,
          height: widget.height,
          alignment: widget.alignment,
          child: _buildSphereAnimation(state.sphereState),
        );
      },
    );
  }

  Widget _buildSphereAnimation(SphereAnimationState state) {
    switch (state) {
      case SphereAnimationState.hidden:
        return const SizedBox.shrink();
      case SphereAnimationState.appearing:
        return _buildAppearingSphere();
      case SphereAnimationState.glowing:
        return _buildGlowingSphere();
      case SphereAnimationState.exploding:
        return _buildExplodingSphere();
      case SphereAnimationState.disappearing:
        return _buildDisappearingSphere();
    }
  }

  Widget _buildAppearingSphere() {
    _particleController.forward();
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildBaseSphere(),
        );
      },
    );
  }

  Widget _buildGlowingSphere() {
    _glowController.repeat(reverse: true);
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF6C63FF).withOpacity(0.8 + (_glowAnimation.value * 0.2)),
                const Color(0xFF6C63FF).withOpacity(0.4 + (_glowAnimation.value * 0.3)),
                const Color(0xFF6C63FF).withOpacity(0.1 + (_glowAnimation.value * 0.2)),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.5 + (_glowAnimation.value * 0.3)),
                blurRadius: 20 + (_glowAnimation.value * 10),
                spreadRadius: 5 + (_glowAnimation.value * 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome,
            size: 40,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildExplodingSphere() {
    _glowController.stop();
    _particleController.reset();
    _particleController.forward();
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Ana küre
            Transform.scale(
              scale: 1.0 + (_scaleAnimation.value * 0.5),
              child: _buildBaseSphere(),
            ),
            // Parçacık efektleri
            ...List.generate(8, (index) {
              final angle = (index * 45.0) * (3.14159 / 180);
              final distance = 60 + (_scaleAnimation.value * 40);
              final x = distance * math.cos(angle);
              final y = distance * math.sin(angle);
              
              return Transform.translate(
                offset: Offset(x, y),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6C63FF).withOpacity(1.0 - _scaleAnimation.value),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildDisappearingSphere() {
    _particleController.reverse();
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _scaleAnimation.value,
            child: _buildBaseSphere(),
          ),
        );
      },
    );
  }

  Widget _buildBaseSphere() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.8),
            const Color(0xFF6C63FF).withOpacity(0.4),
            const Color(0xFF6C63FF).withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}
