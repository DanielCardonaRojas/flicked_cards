import 'base_types.dart';

class LayoutConfig {
  final int cardsAfter;
  final int cardsBefore;

  /// Animations can opt in to support 2 types of animations the either incrementally pile or removes from a pile
  /// When false cards are layed out inside a Stack widget like this: [Previous, Current, Next]
  /// otherwise will be stack in the following manner: [Next, Current, Previous]
  /// Also note that for the index 0 Previous will not be shown.
  bool usesInvertedLayout = false;

  LayoutConfig({
    this.cardsAfter = 1,
    this.cardsBefore = 1,
  });
}

class AnimationConfig {
  final SwipeDirection dismissDirection;
  final bool reversible;

  AnimationConfig({
    this.dismissDirection = SwipeDirection.left,
    this.reversible = false,
  });

  AnimationConfig copyWith({
    SwipeDirection? dismissDirection,
    bool? reversible,
  }) {
    return AnimationConfig(
        dismissDirection: dismissDirection ?? this.dismissDirection,
        reversible: reversible ?? this.reversible);
  }
}
