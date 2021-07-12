import 'base_types.dart';
part 'animation_progress.dart';

class AnimationConfig {
  static const defaultScreenWidth = 300.0;
  final int cardCount;

  SwipeDirection dismissDirection;
  double screenWidth;
  bool reversible;

  AnimationConfig({
    required this.cardCount,
    required this.dismissDirection,
    this.reversible = false,
    this.screenWidth = defaultScreenWidth,
  });
}

class AnimationState {
  static const progressThreshold = 0.25;

  // Configuration
  late AnimationConfig config;

  // Mutable state
  AnimationProgress _progress = AnimationProgress();
  int currentIndex = 0;

  double positionX = 0;

  AnimationState({
    AnimationConfig? config,
  }) {
    if (config != null) {
      this.config = config;
    }

    positionX = AnimationConfig.defaultScreenWidth * 0.5;
  }

  // Computed
  AnimationProgress get progress => _progress;
  double get signedProgress => _progress.value;

  double get invertedProgress =>
      config.dismissDirection.value - _progress.value.abs() * -1;
  double get visibleCardProgress => reversing ? 0 : _progress.value;
  double get reversedCardProgress =>
      reversing ? invertedProgress : config.dismissDirection.value;

  SwipeDirection? get movingDirection {
    if (_progress.value < 0.0) return SwipeDirection.left;
    if (_progress.value > 0.0) return SwipeDirection.right;
    return null;
  }

  bool get reversing {
    return movingDirection != config.dismissDirection &&
        config.reversible &&
        movingDirection != null;
  }

  double get targetDirection {
    final double target = _progress.value.isNegative ? -1 : 1;
    final advances = target * config.dismissDirection.value == 1;
    final targetIndex = currentIndex + target * config.dismissDirection.value;

    if (_progress.value.abs() < progressThreshold) return 0.0;
    if (targetIndex > config.cardCount - 1) return 0.0;
    if (!advances && currentIndex == 0) return 0.0;
    return target;
  }

  int get targetIndex {
    if (config.reversible) {
      return (currentIndex +
              targetDirection.sign * config.dismissDirection.value)
          .clamp(0, config.cardCount - 1)
          .toInt();
    }

    return (currentIndex + 1).clamp(0, config.cardCount).toInt();
  }

  // Methods
  void update({required double delta}) {
    final advances =
        (delta * config.dismissDirection.value.sign) > 0 || !config.reversible;
    if (config.reversible && !advances && currentIndex == 0) return;
    if (advances && currentIndex == config.cardCount - 1) return;

    positionX += delta;
    final centeredX = positionX / config.screenWidth;
    final newProgress = ((centeredX - 0.5) * 2).clamp(-1.0, 1.0);
    _progress.value = newProgress;
    // Convert to range -1, 1
  }

  void scrub({required double target}) {
    _progress.value = target;
  }

  void reset() {
    _progress.value = 0;
    positionX = config.screenWidth * .5;
  }

  void complete() {
    currentIndex = targetIndex;
  }

  void configure({required AnimationConfig config}) {
    this.config = config;
  }

  void configureWith({
    double? screenWidth,
    bool? isReversible,
    SwipeDirection? dismissDirection,
  }) {
    if (screenWidth != null) this.config.screenWidth = screenWidth;
    if (isReversible != null) this.config.reversible = isReversible;
    if (dismissDirection != null)
      this.config.dismissDirection = dismissDirection;
  }

  AnimationState copyWith({
    double? signedProgress,
    NumericCompute? calculation,
  }) {
    var state = AnimationState(config: config);
    state._progress.value = signedProgress ?? _progress.value;
    state.currentIndex = currentIndex;
    state.positionX = positionX;
    state.config.screenWidth = config.screenWidth;
    state._progress = _progress.copyWith(calculation: calculation);
    return state;
  }

  void log() {
    print(
        '% ${_progress.value} reversing: $reversing idx: $currentIndex ref: $hashCode target: $targetDirection');
  }
}
