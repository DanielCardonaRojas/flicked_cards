import 'base_types.dart';

/// A configuration object for [CardAnimation] used to
/// determine the number of cards used in the animation
class LayoutConfig {
  /// The number of cards after the current card
  final int cardsAfter;

  /// The number of cards before the current card
  final int cardsBefore;

  /// Animations can opt in to support 2 types of animations the either incrementally pile or removes from a pile
  /// When false cards are layed out inside a Stack widget like this: [Previous, Current, Next]
  /// otherwise will be stack in the following manner: [Next, Current, Previous]
  /// Also note that for the index 0 Previous will not be shown.
  bool usesInvertedLayout;

  /// A configuration object for [CardAnimation] used to
  /// determine the number of cards used in the animation
  /// [cardsAfter] the required cards after the current used in the animation
  /// [cardsBefore] the required cards before the current used in the animation
  LayoutConfig({
    this.cardsAfter = 1,
    this.cardsBefore = 1,
    this.usesInvertedLayout = false,
  });

  /// returns a list of relative indices from current card index
  /// as specified by cardsAfter and cardsBefore
  List<int> relativeIndicesForLayout({required int cardCount}) {
    final result = <int>[];
    for (var i = -cardsBefore; i <= cardsAfter; i++) {
      if (i >= cardCount) continue;
      result.add(i);
    }

    if (usesInvertedLayout) return result.reversed.toList();

    return result;
  }

  /// returns a list of absolute indices from current card index
  /// as specified by cardsAfter and cardsBefore
  List<int> indicesForLayout(
      {required int currentIndex, required int cardCount}) {
    final relativeIndices = relativeIndicesForLayout(cardCount: cardCount);
    final result = relativeIndices
        .map((e) => e + currentIndex)
        .where((element) => element >= 0 && element < cardCount)
        .toList();
    return result;
  }
}

/// A configuration object used to determine the
/// gesture behaviour of a [CardAnimation]
class AnimationConfig {
  /// Swipe direction for dismissing the current card
  final SwipeDirection dismissDirection;

  /// Can go back to previous card ?
  final bool reversible;

  /// CardAnimation swipe configuration [dissmissDirection] either left of right,
  /// [reversible] determines if can navigate to previous cards or can only walk through the
  /// cards once.
  AnimationConfig({
    this.dismissDirection = SwipeDirection.left,
    this.reversible = false,
  });

  /// Returns a copy of this object by ovewriting properties with
  /// the supplied arguments
  AnimationConfig copyWith({
    SwipeDirection? dismissDirection,
    bool? reversible,
  }) {
    return AnimationConfig(
        dismissDirection: dismissDirection ?? this.dismissDirection,
        reversible: reversible ?? this.reversible);
  }
}
