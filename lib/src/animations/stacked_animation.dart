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
    this.stackOffset = 50,
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
        return _peekAnimation2(progress: progress.value, index: 1);
      }

      return _peekAnimation2(progress: progress.value, index: 1);
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
        return _peekAnimation2(progress: progress.value, index: 0);
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

  Matrix4 _peekAnimation2({required double progress, required int index}) {
    final offset = -stackOffset * .5;
    final y = offset * progress + index.toDouble() * offset;
    final compression = 1 - (progress * 0.05 + index.toDouble() * 0.05);

    return Matrix4.identity()
      ..translate(0.0, y)
      ..scale(compression, compression);
  }
}
