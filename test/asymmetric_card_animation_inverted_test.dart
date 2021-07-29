import 'package:flicked_cards/flicked_cards.dart';
import 'package:flicked_cards/src/animation_config.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_stack_animation.dart';

void main() {
  late TestStackAnimation sut;

  setUp(() {
    sut = TestStackAnimation();
    sut.layoutConfig.usesInvertedLayout = true;
    sut.config = AnimationConfig();
  });

  test(
      'Current card animation evaluates to the identity matrix when progress is 0',
      () {
    sut.config = sut.config.copyWith(dismissDirection: SwipeDirection.left);
    final currentCardAnimation = sut.animationForCard(relativeIndex: 0);
    final result = currentCardAnimation(0);
    assert(result.isIdentity());
  });

  test(
      'Next card animation at dismissDirection is equal to the currentCard at 0',
      () {
    const dismissDir = SwipeDirection.right;
    sut.config = sut.config.copyWith(dismissDirection: dismissDir);
    final nextCardAnimation =
        sut.animationForCard(relativeIndex: 1).call(dismissDir.value);
    final currentCardAnimation = sut.animationForCard(relativeIndex: 0).call(0);
    assert(nextCardAnimation == currentCardAnimation);
  });

  test(
      'Current card at opposite of dismissDirection (reversing) is equal to previous card animation at 0',
      () {
    const dismissDir = SwipeDirection.right;
    sut.config = sut.config.copyWith(dismissDirection: dismissDir);

    final currentCardAnimation =
        sut.animationForCard(relativeIndex: 0).call(dismissDir.opposite.value);
    final previousCardAnimation =
        sut.animationForCard(relativeIndex: -1).call(0);

    assert(currentCardAnimation == previousCardAnimation);
  });
}
