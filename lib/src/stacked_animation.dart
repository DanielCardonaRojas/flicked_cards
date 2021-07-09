part of './card_deck.dart';

class CardDeckStackedAnimation extends CardDeckAnimation {
  final double rotationAngle;
  final double sizeCompressionFactor;
  final double stackOffset;

  CardDeckStackedAnimation(
      {this.rotationAngle = pi / 2,
      this.sizeCompressionFactor = 0.8,
      this.stackOffset = 90});

  @override
  CardDeckAnimator get nextCardAnimation {
    return (config) {
      if (config.asStack) {
        return _rotateAnimation(config
            .offsetBy(config.dismissDirection.value * -1)
            .clamped(outMin: -1, outMax: 1));
      }

      return _peekAnimation(
          config.scaledBy(config.dismissDirection.value * -1));
    };
  }

  @override
  CardDeckAnimator get previousCardAnimation {
    return (config) {
      if (config.reversing && config.asStack) {
        return Matrix4.identity();
      }
      return _rotateAnimation(config
          .offsetBy(config.dismissDirection.value)
          .clamped(outMin: -1, outMax: 1));
    };
  }

  @override
  CardDeckAnimator get visibleCardAnimation {
    return (config) {
      config.log();
      if (!config.reversing && config.asStack) {
        return Matrix4.identity();
      } else if (config.reversing && !config.asStack) {
        return _peekAnimation(config
            .modifiedBy((p) => 0.5 * p + 0.5 * config.dismissDirection.value));
      }
      return _rotateAnimation(
          !config.asStack ? config.freezedWhenReversed() : config);
    };
  }

  Matrix4 _rotateAnimation(AnimationConfig config) {
    return Matrix4.identity()
      ..rotateZ(pi / 2 * config.signedProgress)
      ..translate(config.signedProgress * 300);
  }

  Matrix4 _peekAnimation(AnimationConfig config) {
    final verticalDisplacement = MapRange.withIntervals(
            inMin: -1.0,
            inMax: 1.0,
            outMin: 0.0,
            outMax: stackOffset.abs() * -1)
        .call(config.signedProgress)
        .toDouble();

    final widthCompression = MapRange.withIntervals(
            inMin: -1.0, inMax: 1.0, outMin: 1, outMax: sizeCompressionFactor)
        .call(config.signedProgress)
        .toDouble();

    return Matrix4.identity()
      ..translate(0.0, verticalDisplacement)
      ..scale(widthCompression, widthCompression);
  }
}
