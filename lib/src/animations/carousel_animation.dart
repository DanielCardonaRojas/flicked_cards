part of '../card_animation.dart';

/// A Carousel animation
class CarouselAnimation extends SymmetricCardAnimation {
  /// Spacing between subsequent cards
  final double cardSpacingWidthFactor;

  /// The dismiss direction
  final SwipeDirection dismissDirection;

  // ignore: public_member_api_docs
  CarouselAnimation({
    required this.dismissDirection,
    this.cardSpacingWidthFactor = 1,
  });
  @override
  AnimationConfig get config =>
      AnimationConfig(dismissDirection: dismissDirection, reversible: true);

  @override
  SwipeAnimation get revealAnimation {
    return (progress) => Matrix4.identity()
      ..translate(
          cardSpacingWidthFactor * (screenSize?.width ?? 500) * progress);
  }
}
