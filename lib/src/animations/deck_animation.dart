part of '../card_animation.dart';

class DeckAnimation extends AsymmetricCardAnimation {
  DeckAnimation();

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
      double p = progress * dirValue;
      p = canReverse ? p : -p.abs();
      final offset = -50;
      final idx = relativeIndex.toDouble().abs();
      final compression = 1 - (p * 0.05 + idx * 0.05);

      if (progress == dirValue) {
        return Matrix4.identity()..translate(0.0, offset * idx);
      }

      final y = p * offset + idx * offset;
      return Matrix4.identity()
        ..translate(0.0, y)
        ..scale(compression, compression);
    };
  }
}
