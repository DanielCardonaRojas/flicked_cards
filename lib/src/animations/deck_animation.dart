part of '../card_animation.dart';

class DeckAnimation extends AsymmetricCardAnimation {
  final bool reversible;
  final SwipeDirection dismissDirection;
  final double separationToNextCard;
  final bool usesInvertedLayout;

  DeckAnimation({
    required this.reversible,
    required this.dismissDirection,
    double cardSeparation = 35,
    this.usesInvertedLayout = false,
  }) : separationToNextCard = cardSeparation.abs() * -1;

  @override
  SwipeAnimation get dismissAnimation {
    return (progress) => Matrix4.identity()
      ..rotateZ(pi / 2 * progress)
      ..translate(progress * 300);
  }

  @override
  SwipeAnimation revealAnimation({required int relativeIndex}) {
    return (progress) {
      final dirValue = config.dismissDirection.opposite.value;
      const compressionDiff = 0.06;
      double p = progress * dirValue;
      p = config.reversible ? p : -p.abs();
      p = layoutConfig.usesInvertedLayout ? -p : p;
      final idx = relativeIndex.toDouble().abs();
      final compression = 1 - (p * compressionDiff + idx * compressionDiff);

      final y = p * separationToNextCard + idx * separationToNextCard;
      return Matrix4.identity()
        ..translate(0.0, y)
        ..scale(compression, compression);
    };
  }

  @override
  AnimationConfig get config => AnimationConfig(
      reversible: reversible, dismissDirection: dismissDirection);

  @override
  LayoutConfig get layoutConfig => LayoutConfig(
      cardsBefore: reversible ? 1 : 0,
      cardsAfter: usesInvertedLayout ? 1 : 2,
      usesInvertedLayout: usesInvertedLayout);
}
