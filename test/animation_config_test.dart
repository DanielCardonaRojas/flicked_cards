import 'package:flicked_cards/flicked_cards.dart';
import 'package:flicked_cards/src/animation_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collection/collection.dart';

void main() {
  Function eq = const ListEquality().equals;
  test('returns range with non negative indices when current index is zero',
      () {
    final sut = LayoutConfig(cardsAfter: 2, cardsBefore: 1);
    final result = sut.indicesForLayout(currentIndex: 0, cardCount: 10);
    assert(eq(result, [0, 1, 2]));
  });

  test('does not return indices that exceed upper bound according to cardCount',
      () {
    final sut = LayoutConfig(cardsAfter: 3, cardsBefore: 0);
    final result = sut.indicesForLayout(currentIndex: 9, cardCount: 10);
    assert(eq(result, [9]));
  });
  test(
      'returns range that has length cardsAfter + cardsBefore when range does not exceed array bounds',
      () {
    final sut = LayoutConfig(cardsAfter: 2, cardsBefore: 1);
    final result = sut.indicesForLayout(currentIndex: 1, cardCount: 10);
    assert(eq(result, [0, 1, 2, 3]));
  });

  test('returns reversed array when invertedLayout is enabled', () {
    final sut =
        LayoutConfig(cardsAfter: 2, cardsBefore: 1, usesInvertedLayout: true);
    final result = sut.indicesForLayout(currentIndex: 1, cardCount: 10);
    assert(eq(result, [3, 2, 1, 0]));
  });

  test(
      'relativeIndicesForLayout always returns an array of size cardsAfter + cardsBefore + 1',
      () {
    final before = 7;
    final after = 2;
    final count = before + after + 1;
    final sut = LayoutConfig(cardsAfter: after, cardsBefore: before);
    assert(sut.relativeIndicesForLayout(cardCount: 10).length == count);
  });
}
