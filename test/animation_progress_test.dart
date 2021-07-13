import 'package:flickered_cards/src/animation_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'compute expressions on signedProgress that dont modify the underlying value',
      () {
    final sut = AnimationProgress();
    sut.value = -1;
    final computed = sut.computedWith((op) => op.modifiedBy((_) => 1)).computed;

    assert(sut.value == -1);
    assert(computed == 1);
  });

  test('Can mutate instance by chaining operations', () {
    final sut = AnimationProgress();
    sut.value = -1;
    sut.apply((op) => op.offsetBy(1));
    assert(sut.value == -1);
    assert(sut.computed == 0);
  });

  test('Can chain multiple operation', () {
    final sut = AnimationProgress();
    sut.value = -1;
    sut.apply((op) => op.offsetBy(2).scaledBy(0.5));
    assert(sut.value == -1);
    assert(sut.computed == 0.5);
  });
}
