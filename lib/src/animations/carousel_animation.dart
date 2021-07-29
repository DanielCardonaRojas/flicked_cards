part of '../card_animation.dart';

/// A Carousel animation
class CarouselAnimation extends SymmetricCardAnimation {
  /// Spacing between subsequent cards
  final double cardSpacing;

  /// The dismiss direction
  final SwipeDirection dismissDirection;

  // ignore: public_member_api_docs
  CarouselAnimation({
    required this.dismissDirection,
    this.cardSpacing = 500,
  });
  @override
  AnimationConfig get config =>
      AnimationConfig(dismissDirection: dismissDirection, reversible: true);

  @override
  LayoutConfig get layoutConfig => LayoutConfig();

  @override
  SwipeAnimation get revealAnimation {
    return (progress) => Matrix4.identity()..translate(cardSpacing * progress);
  }
}
