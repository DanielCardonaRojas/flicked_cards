part of '../card_animation.dart';

class CardStackAnimation extends AsymmetricCardAnimation {
  CardStackAnimation();

  @override
  SwipeAnimation get dismissAnimation {
    return (progress) => Matrix4.identity()
      ..rotateZ(pi / 2 * progress)
      ..translate(progress * 300);
  }

  @override
  SwipeAnimation revealAnimation({required int relativeIndex}) {
    return (progress) {
      final dirFactor = usesInvertedLayout ? -1.0 : 1.0;
      final offset = -50;
      final idx = relativeIndex.toDouble().abs();
      final compression = 1 - (progress * 0.05 + idx * 0.05);

      if (progress == state.config.dismissDirection.value) {
        return Matrix4.identity()..translate(0.0, offset * idx);
      }

      final y = progress * offset + idx * offset;
      return Matrix4.identity()
        ..translate(0.0, y)
        ..scale(compression, compression);
    };
  }
}
