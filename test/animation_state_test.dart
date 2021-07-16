import 'package:flickered_cards/flickered_cards.dart';
import 'package:flickered_cards/src/animation_config.dart';
import 'package:flickered_cards/src/animation_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AnimationState sut;

  setUp(() {
    sut = AnimationState(cardCount: 10);
    final configuration = AnimationConfig(
      dismissDirection: SwipeDirection.left,
    );
    sut.configure(config: configuration);
  });
  test('target direction is not center when drag threshold has been exceeded',
      () {
    final configuration = AnimationConfig(
        dismissDirection: SwipeDirection.right, reversible: true);
    sut.configure(config: configuration);
    sut.currentIndex = 1;

    sut.scrub(target: 0.3);
    assert(sut.targetDirection.abs() == 1);
  });

  test('target direction is center when drag does not exceed threshold', () {
    final configuration = AnimationConfig(
        dismissDirection: SwipeDirection.right, reversible: true);
    sut.configure(config: configuration);

    sut.currentIndex = 1;

    sut.scrub(target: 0.1);
    assert(sut.targetDirection.abs() == 0);
  });

  test('moving direction is left for negative delta updates', () {
    final configuration = AnimationConfig(
        dismissDirection: SwipeDirection.right, reversible: true);

    sut.configure(config: configuration);

    sut.currentIndex = 1;
    sut.update(delta: -5);
    assert(sut.movingDirection == SwipeDirection.left);
  });

  test('moving direction is right for positive delta updates', () {
    sut.configure(
      config: AnimationConfig(
        dismissDirection: SwipeDirection.left,
        reversible: false,
      ),
    );

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
    sut.configure(
      config: AnimationConfig(
        dismissDirection: SwipeDirection.left,
        reversible: true,
      ),
    );

    sut.currentIndex = initialIndex;
    sut.scrub(target: SwipeDirection.left.value * 0.5);
    sut.complete();
    assert(sut.currentIndex == initialIndex + 1);
  });

  test(
      'does not increments index when swiped in opposite direction of configured dismissDirection',
      () {
    final initialIndex = 1;

    sut.configure(
      config: AnimationConfig(
        dismissDirection: SwipeDirection.left,
        reversible: true,
      ),
    );

    sut.currentIndex = initialIndex;
    sut.scrub(target: SwipeDirection.right.value * 0.5);
    sut.complete();
    assert(sut.currentIndex != initialIndex + 1);
  });

  group('configured as reversible', () {});
  test('does not drag when reversing and on index 0', () {
    sut.configure(
      config: AnimationConfig(
        dismissDirection: SwipeDirection.left,
        reversible: true,
      ),
    );

    final signedProgressBefore = sut.progress.value;
    sut.update(delta: SwipeDirection.right.value * 0.1);

    final signedProgressAfter = sut.progress.value;

    assert(signedProgressAfter == signedProgressBefore);
  });

  test('does not drag when advance and index has reached last card', () {
    sut.configure(
      config: AnimationConfig(
        dismissDirection: SwipeDirection.left,
        reversible: true,
      ),
    );

    final signedProgressBefore = sut.progress.value;

    sut.currentIndex = 9;
    sut.update(delta: SwipeDirection.left.value * 0.1);

    final signedProgressAfter = sut.signedProgress;

    assert(signedProgressAfter == signedProgressBefore);
  });

  test('returns new instance with copyWith', () {
    sut.configure(
      config: AnimationConfig(
        dismissDirection: SwipeDirection.left,
        reversible: true,
      ),
    );

    final newInstance = sut.copyWith();

    assert(sut.hashCode != newInstance.hashCode);
  });
  test('advances when targetDirection is the same as dismissDirection', () {});

  test('target direction is which ever way swiped when threshold exceeded', () {
    final dir = SwipeDirection.left;
    sut.configure(
      config: AnimationConfig(
        dismissDirection: dir.opposite,
        reversible: false,
      ),
    );
    sut.update(delta: sut.screenWidth * dir.value * 0.3);
    final target = sut.targetDirection;

    assert(target == dir.value);
  });
}
