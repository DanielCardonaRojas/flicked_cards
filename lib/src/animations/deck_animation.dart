part of '../card_animation.dart';

class DeckAnimation extends AsymmetricCardAnimation {
  final double separationToNextCard = -35;

  DeckAnimation();

  @override
  int get cardsAfterNext => 0;

  @override
  SwipeAnimation get dismissAnimation {
    return (progress) => Matrix4.identity()
      ..rotateZ(pi / 2 * progress)
      ..translate(progress * 300);
  }

  @override
  SwipeAnimation revealAnimation({required int relativeIndex}) {
    return (progress) {
      final dirValue = state.config.dismissDirection.opposite.value;
      final compressionDiff = 0.06;
      double p = progress * dirValue;
      p = canReverse ? p : -p.abs();
      p = usesInvertedLayout ? -p : p;
      final idx = relativeIndex.toDouble().abs();
      final compression = 1 - (p * compressionDiff + idx * compressionDiff);

      if (progress == dirValue) {
        return Matrix4.identity()..translate(0.0, separationToNextCard * idx);
      }

      final y = p * separationToNextCard + idx * separationToNextCard;
      return Matrix4.identity()
        ..translate(0.0, y)
        ..scale(compression, compression);
    };
  }
}
