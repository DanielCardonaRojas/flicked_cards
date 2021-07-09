import 'package:flutter_test/flutter_test.dart';

import 'package:flickered_cards/flickered_cards.dart';

void main() {
  test('adds one to input values', () {
    final config = AnimationState(
        dismissDirection: SwipeDirection.left,
        reversible: true,
        reversing: false,
        signedProgress: 0);

    assert(config.signedProgress == 0);
  });
}
