import 'base_types.dart';

class LayoutConfig {
  final int cardsAfter;
  final int cardsBefore;

  /// Animations can opt in to support 2 types of animations the either incrementally pile or removes from a pile
  /// When false cards are layed out inside a Stack widget like this: [Previous, Current, Next]
  /// otherwise will be stack in the following manner: [Next, Current, Previous]
  /// Also note that for the index 0 Previous will not be shown.
  bool usesInvertedLayout;

  LayoutConfig({
    this.cardsAfter = 1,
    this.cardsBefore = 1,
    this.usesInvertedLayout = false,
  });

  List<int> relativeIndicesForLayout({required cardCount}) {
    var result = <int>[];
    for (var i = -cardsBefore; i <= cardsAfter; i++) {
      if (i >= cardCount) continue;
      result.add(i);
    }

    if (usesInvertedLayout) return result.reversed.toList();

    return result;
  }

  List<int> indicesForLayout({required int currentIndex, required cardCount}) {
    final relativeIndices = relativeIndicesForLayout(cardCount: cardCount);
    final result = relativeIndices
        .map((e) => e + currentIndex)
        .where((element) => element >= 0 && element < cardCount)
        .toList();
    return result;
  }
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
