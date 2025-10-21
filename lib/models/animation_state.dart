/// Animasyon durumlarını yöneten enum
enum AnimationState {
  idle,        // Boşta durum
  thinking,    // Düşünme animasyonu (rüya yazılırken)
  processing,  // İşleme animasyonu (API çağrısı sırasında)
  success,     // Başarı animasyonu (yorum tamamlandığında)
  error,       // Hata animasyonu
}

/// Küre animasyon durumları
enum SphereAnimationState {
  hidden,      // Gizli
  appearing,   // Belirme
  glowing,     // Işıldama
  exploding,   // Patlama efektleri
  disappearing, // Kaybolma
}

/// Animasyon servisi için state modeli
class AnimationStateModel {
  final AnimationState characterState;
  final SphereAnimationState sphereState;
  final bool isAnimating;
  final String? currentAnimationAsset;

  const AnimationStateModel({
    this.characterState = AnimationState.idle,
    this.sphereState = SphereAnimationState.hidden,
    this.isAnimating = false,
    this.currentAnimationAsset,
  });

  AnimationStateModel copyWith({
    AnimationState? characterState,
    SphereAnimationState? sphereState,
    bool? isAnimating,
    String? currentAnimationAsset,
  }) {
    return AnimationStateModel(
      characterState: characterState ?? this.characterState,
      sphereState: sphereState ?? this.sphereState,
      isAnimating: isAnimating ?? this.isAnimating,
      currentAnimationAsset: currentAnimationAsset ?? this.currentAnimationAsset,
    );
  }
}
