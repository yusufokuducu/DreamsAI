import 'package:flutter/material.dart';
import '../models/animation_state.dart';

/// Animasyon durumlarını yöneten servis
class AnimationService extends ChangeNotifier {
  AnimationStateModel _state = const AnimationStateModel();

  AnimationStateModel get state => _state;

  /// Karakter animasyonunu değiştir
  void setCharacterState(AnimationState newState) {
    _state = _state.copyWith(
      characterState: newState,
      isAnimating: newState != AnimationState.idle,
    );
    notifyListeners();
  }

  /// Küre animasyonunu değiştir
  void setSphereState(SphereAnimationState newState) {
    _state = _state.copyWith(sphereState: newState);
    notifyListeners();
  }

  /// Animasyon asset'ini ayarla
  void setAnimationAsset(String assetPath) {
    _state = _state.copyWith(currentAnimationAsset: assetPath);
    notifyListeners();
  }

  /// Animasyonu durdur
  void stopAnimation() {
    _state = _state.copyWith(
      isAnimating: false,
      characterState: AnimationState.idle,
      sphereState: SphereAnimationState.hidden,
    );
    notifyListeners();
  }

  /// Rüya yazma sürecini başlat
  void startDreamWriting() {
    setCharacterState(AnimationState.thinking);
  }

  /// Rüya yorumlama sürecini başlat
  void startDreamProcessing() {
    setCharacterState(AnimationState.processing);
    setSphereState(SphereAnimationState.appearing);
  }

  /// Başarılı yorumlama
  void showSuccess() {
    setCharacterState(AnimationState.success);
    setSphereState(SphereAnimationState.exploding);
    
    // 3 saniye sonra animasyonu durdur
    Future.delayed(const Duration(seconds: 3), () {
      stopAnimation();
    });
  }

  /// Hata durumu
  void showError() {
    setCharacterState(AnimationState.error);
    setSphereState(SphereAnimationState.disappearing);
    
    // 2 saniye sonra animasyonu durdur
    Future.delayed(const Duration(seconds: 2), () {
      stopAnimation();
    });
  }

  /// Animasyon asset path'lerini döndür
  String getCharacterAnimationAsset(AnimationState state) {
    switch (state) {
      case AnimationState.idle:
        return 'assets/animations/character_idle.json';
      case AnimationState.thinking:
        return 'assets/animations/character_thinking.json';
      case AnimationState.processing:
        return 'assets/animations/character_processing.json';
      case AnimationState.success:
        return 'assets/animations/character_success.json';
      case AnimationState.error:
        return 'assets/animations/character_error.json';
    }
  }
}
