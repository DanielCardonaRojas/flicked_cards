part of '../card_deck_animation.dart';

class CardDeckStackedAnimation extends CardDeckAnimation {
  final double rotationAngle;
  final double sizeCompressionFactor;
  final double stackOffset;
  final bool inverted;
  final bool reversible;

  CardDeckStackedAnimation({
    this.rotationAngle = pi / 2,
    this.reversible = true,
    this.inverted = false,
    this.sizeCompressionFactor = 0.8,
    this.stackOffset = 90,
  });

  @override
  bool get usesInvertedLayout => inverted;

  @override
  bool get canReverse => reversible;

  bool get asStack => usesInvertedLayout;

  @override
  CardDeckAnimator get nextCardAnimation {
    return (progress) {
      if (asStack) {
        return _rotateAnimation(progress.computedWith((p) => p
            .offsetBy(state.config.dismissDirection.value * -1)
            .clamped(outMin: -1, outMax: 1)));
      }

      if (!state.config.reversible) {
        return _peekAnimation(
            progress.computedWith((p) => p.modifiedBy((p) => -p.abs())));
      }

      return _peekAnimation(progress.computedWith(
          (p) => p.scaledBy(state.config.dismissDirection.value * -1)));
    };
  }

  @override
  CardDeckAnimator get previousCardAnimation {
    return (progress) {
      if (state.reversing && asStack) {
        return Matrix4.identity();
      }
      return _rotateAnimation(progress.computedWith((p) => p
          .offsetBy(state.config.dismissDirection.value)
          .clamped(outMin: -1, outMax: 1)));
    };
  }

  @override
  CardDeckAnimator get currentCardAnimation {
    return (progress) {
      if (!state.reversing && asStack) {
        return Matrix4.identity();
      } else if (state.reversing && !asStack) {
        return _peekAnimation(progress.computedWith((p) => p.modifiedBy(
            (p) => 0.5 * p + 0.5 * state.config.dismissDirection.value)));
      }

      final freezedWhenReversed = progress
          .computedWith((p) => p.modifiedBy((p) => state.reversing ? 0 : p));
      return _rotateAnimation(!asStack ? freezedWhenReversed : progress);
    };
  }

  Matrix4 _rotateAnimation(AnimationProgress progress) {
    progress.log();
    return Matrix4.identity()
      ..rotateZ(pi / 2 * progress.computed)
      ..translate(progress.computed * 300);
  }

  Matrix4 _peekAnimation(AnimationProgress state) {
    final verticalDisplacement = MapRange.withIntervals(
            inMin: -1.0,
            inMax: 1.0,
            outMin: 0.0,
            outMax: stackOffset.abs() * -1)
        .call(state.value)
        .toDouble();

    final widthCompression = MapRange.withIntervals(
            inMin: -1.0, inMax: 1.0, outMin: 1, outMax: sizeCompressionFactor)
        .call(state.value)
        .toDouble();

    return Matrix4.identity()
      ..translate(0.0, verticalDisplacement)
      ..scale(widthCompression, widthCompression);
  }
}
