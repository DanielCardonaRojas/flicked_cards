import 'animation_config.dart';
import 'base_types.dart';
part 'animation_progress.dart';

class AnimationState {
  final int cardCount;
  static const defaultScreenWidth = 300.0;

  static const progressThreshold = 0.25;

  // Configuration properties
  late AnimationConfig config;
  double screenWidth = defaultScreenWidth;

  // Mutable state
  AnimationProgress _progress = AnimationProgress();
  int currentIndex = 0;

  double positionX = 0;

  AnimationState({
    required this.cardCount,
    AnimationConfig? config,
  }) {
    if (config != null) {
      this.config = config;
    }

    positionX = defaultScreenWidth * 0.5;
  }

  // Computed
  AnimationProgress get progress => _progress;
  double get signedProgress => _progress.value;

  double get invertedProgress =>
      config.dismissDirection.value - _progress.value.abs() * -1;

  double cardProgress({required int relativeIndex}) {
    final directedProgress = config.reversible
        ? progress.value * config.dismissDirection.value
        : progress.value;

    double result = 0;

    if (relativeIndex == 0) {
      // Current card
      result = 1 - directedProgress.abs();
    } else if (relativeIndex > 0) {
      // Next cards
      result = relativeIndex == 1 && !reversing ? directedProgress.abs() : 0;
    } else if (relativeIndex < 0) {
      // Previous cards
      result = 1;
    }

    return result;
  }

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
    double target = _progress.value.isNegative ? -1 : 1;
    final advances =
        target * config.dismissDirection.value == 1 || !config.reversible;
    final targetIndex = currentIndex + target * config.dismissDirection.value;

    if (_progress.value.abs() < progressThreshold) return 0.0;
    if (targetIndex > cardCount - 1) return 0.0;
    if (!advances && currentIndex == 0) return 0.0;
    return target;
  }

  int get targetIndex {
    if (config.reversible) {
      return (currentIndex +
              targetDirection.sign * config.dismissDirection.value)
          .clamp(0, cardCount - 1)
          .toInt();
    }

    return (currentIndex + 1).clamp(0, cardCount).toInt();
  }

  // Methods
  void update({required double delta}) {
    final advances =
        (delta * config.dismissDirection.value.sign) > 0 || !config.reversible;
    if (config.reversible && !advances && currentIndex == 0) return;
    if (advances && currentIndex == cardCount - 1) return;

    positionX += delta;
    final centeredX = positionX / screenWidth;
    final newProgress = ((centeredX - 0.5) * 2).clamp(-1.0, 1.0);
    _progress.value = newProgress;
    // Convert to range -1, 1
  }

  void scrub({required double target}) {
    _progress.value = target;
  }

  void reset() {
    _progress.value = 0;
    positionX = screenWidth * .5;
  }

  void complete() {
    currentIndex = targetIndex;
  }

  void configure({required AnimationConfig config}) {
    this.config = config;
  }

  void configureWith({
    double? screenWidth,
  }) {
    if (screenWidth != null) this.screenWidth = screenWidth;
  }

  AnimationState copyWith({
    double? signedProgress,
    NumericCompute? calculation,
  }) {
    var state = AnimationState(config: config, cardCount: cardCount);
    state._progress.value = signedProgress ?? _progress.value;
    state.currentIndex = currentIndex;
    state.positionX = positionX;
    state.config = config;
    state._progress = _progress.copyWith(calculation: calculation);
    return state;
  }

  void log() {
    print(
        '% ${_progress.value} reversing: $reversing idx: $currentIndex ref: $hashCode target: $targetDirection');
  }
}
