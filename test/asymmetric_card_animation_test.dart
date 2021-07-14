import 'package:flickered_cards/flickered_cards.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_stack_animation.dart';

void main() {
  late TestStackAnimation sut;

  setUp(() {
    sut = TestStackAnimation();
    sut.state = AnimationState(
      config: AnimationConfig(
        cardCount: 10,
        dismissDirection: SwipeDirection.right,
      ),
    );
  });

  test(
      'Current card animation evaluates to the identity matrix when progress is 0',
      () {
    sut.state.configureWith(dismissDirection: SwipeDirection.left);
    final currentCardAnimation = sut.animationForCard(relativeIndex: 0);
    final result = currentCardAnimation(0);
    assert(result.isIdentity());
  });

  test(
      'Previous card animation at 0 is equal current card animation at dismissDirection',
      () {
    sut.state.configureWith(dismissDirection: SwipeDirection.left);
    final currentCardAnimation = sut.animationForCard(relativeIndex: 0);
    final previousCardAnimation = sut.animationForCard(relativeIndex: -1);
    final areEqual = previousCardAnimation(0) ==
        currentCardAnimation(SwipeDirection.left.value);
    assert(areEqual);
  });

  test(
      'Next card animation evaluates to the currentCard at 0 when progress is completed and advancing',
      () {
    final dismissDir = SwipeDirection.right;
    sut.state.configureWith(dismissDirection: dismissDir);
    final nextCardAnimation =
        sut.animationForCard(relativeIndex: 1).call(dismissDir.value);
    final currentCardAnimation = sut.animationForCard(relativeIndex: 1).call(0);
    assert(nextCardAnimation == currentCardAnimation);
  });

  test(
      'Previous card animation evaluates to the identity matrix when progress is completed and reversing',
      () {
    final dismissDir = SwipeDirection.left;
    sut.state.configureWith(isReversible: true, dismissDirection: dismissDir);
    sut.state.scrub(target: dismissDir.opposite.value * 0.3);

    final previousCardAnimation = sut.animationForCard(relativeIndex: -1);
    final result = previousCardAnimation(SwipeDirection.right.value);

    assert(result.isIdentity());
  });
  test(
      'Current card animation matches nextCards animation when progress complete and reversing',
      () {
    final dismissDir = SwipeDirection.left;

    sut.state.configureWith(
      isReversible: true,
      dismissDirection: dismissDir,
    );

    // Update state to be reversing
    sut.state.scrub(target: dismissDir.opposite.value * 0.3);

    final currentCardAnimation =
        sut.animationForCard(relativeIndex: 0).call(dismissDir.opposite.value);
    final nextCardAnimation = sut.animationForCard(relativeIndex: 1).call(0);

    assert(currentCardAnimation == nextCardAnimation);
  });
}
