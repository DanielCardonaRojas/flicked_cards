import 'package:flickered_cards/flickered_cards.dart';
import 'package:flickered_cards/src/animation_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AnimationState sut;

  setUp(() {
    sut = AnimationState();
    final configuration = AnimationConfig(
      cardCount: 10,
      dismissDirection: SwipeDirection.left,
    );
    sut.configure(config: configuration);
  });
  test('target direction is not center when drag threshold has been exceeded',
      () {
    sut.configureWith(dismissDirection: SwipeDirection.right);
    sut.currentIndex = 1;

    sut.scrub(target: 0.3);
    assert(sut.targetDirection.abs() == 1);
  });

  test('target direction is center when drag does not exceed threshold', () {
    final configuration = AnimationConfig(
        cardCount: 10,
        dismissDirection: SwipeDirection.right,
        reversible: true);
    sut.configure(config: configuration);

    sut.currentIndex = 1;

    sut.scrub(target: 0.1);
    assert(sut.targetDirection.abs() == 0);
  });

  test('moving direction is left for negative delta updates', () {
    final configuration = AnimationConfig(
        cardCount: 10,
        dismissDirection: SwipeDirection.right,
        reversible: true);

    sut.configure(config: configuration);

    sut.currentIndex = 1;
    sut.update(delta: -5);
    assert(sut.movingDirection == SwipeDirection.left);
  });

  test('moving direction is right for positive delta updates', () {
    sut.configureWith(
        dismissDirection: SwipeDirection.left, isReversible: false);

    sut.currentIndex = 1;
    sut.update(delta: 5);
    final value = sut.progress.value;
    assert(sut.movingDirection == SwipeDirection.right);
  });

  test('initial progress is 0', () {
    assert(sut.progress.value == 0);
  });

  test(
      'increments index when swiped in the same direction as configured by dismissDirection',
      () {
    final initialIndex = 1;
    sut.configureWith(
        dismissDirection: SwipeDirection.left, isReversible: true);

    sut.currentIndex = initialIndex;
    sut.scrub(target: SwipeDirection.left.value * 0.5);
    sut.complete();
    assert(sut.currentIndex == initialIndex + 1);
  });

  test(
      'does not increments index when swiped in opposite direction of configured dismissDirection',
      () {
    final initialIndex = 1;

    sut.configureWith(
        dismissDirection: SwipeDirection.left, isReversible: true);

    sut.currentIndex = initialIndex;
    sut.scrub(target: SwipeDirection.right.value * 0.5);
    sut.complete();
    assert(sut.currentIndex != initialIndex + 1);
  });

  group('configured as reversible', () {});
  test('does not drag when reversing and on index 0', () {
    sut.configureWith(
        dismissDirection: SwipeDirection.left, isReversible: true);

    final signedProgressBefore = sut.progress.value;
    sut.update(delta: SwipeDirection.right.value * 0.1);

    final signedProgressAfter = sut.progress.value;

    assert(signedProgressAfter == signedProgressBefore);
  });

  test('does not drag when advance and index has reached last card', () {
    sut.configureWith(
        dismissDirection: SwipeDirection.left, isReversible: true);

    final signedProgressBefore = sut.progress.value;

    sut.currentIndex = 9;
    sut.update(delta: SwipeDirection.left.value * 0.1);

    final signedProgressAfter = sut.signedProgress;

    assert(signedProgressAfter == signedProgressBefore);
  });

  test('returns new instance with copyWith', () {
    sut.configureWith(
        dismissDirection: SwipeDirection.left, isReversible: true);

    final newInstance = sut.copyWith();

    assert(sut.hashCode != newInstance.hashCode);
  });
  test('advances when targetDirection is the same as dismissDirection', () {});

  test('target direction is which ever way swiped when threshold exceeded', () {
    final dir = SwipeDirection.left;
    sut.configureWith(dismissDirection: dir.opposite, isReversible: false);
    sut.update(delta: sut.config.screenWidth * dir.value * 0.3);
    final target = sut.targetDirection;

    assert(target == dir.value);
  });
}
