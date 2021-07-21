import 'dart:async';

import 'package:flickered_cards/flickered_cards.dart';
import 'package:flickered_cards/src/flickered_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

abstract class Callable<T> {
  void call([T? arg]) {}
}

class MockCallable<T> extends Mock implements Callable<T> {}

typedef BuildInspector = void Function(int, double);

void main() {
  FlickeredCards _createWidgetForTesting({BuildInspector? inspector}) {
    final widget = FlickeredCards(
        builder: (idx, progress, context) {
          inspector?.call(idx, progress);
          final cardKey = Key('Card${idx}Key');
          return SizedBox(key: cardKey, height: 600, width: 300);
        },
        count: 10,
        animationStyle:
            CarouselAnimation(dismissDirection: SwipeDirection.right));
    return widget;
  }

  testWidgets(
    'calls animation style to get layout and transform for first card',
    (WidgetTester tester) async {},
  );

  testWidgets('Finds card 0 on first build', (WidgetTester tester) async {
    final cardZeroFinder = find.byKey(Key('Card0Key'));
    final widget = _createWidgetForTesting();

    await tester.pumpMyWidget(widget);
    await tester.pumpAndSettle();
    expect(cardZeroFinder, findsOneWidget);
  });

  testWidgets('Calls builder for card 0 on first build',
      (WidgetTester tester) async {
    final cardBuilder = MockCallable<int>();

    final widget = _createWidgetForTesting(inspector: (idx, progress) {
      cardBuilder.call(idx);
    });

    await tester.pumpMyWidget(widget);
    await tester.pumpAndSettle();
    verify(() => cardBuilder(0));
  });

  testWidgets(
      'Calls builder as many times as specified by animation layout config',
      (WidgetTester tester) async {
    final cardBuilder = MockCallable<int>();

    final widget = _createWidgetForTesting(inspector: (idx, progress) {
      cardBuilder.call(idx);
    });

    await tester.pumpMyWidget(widget);
    await tester.pumpAndSettle();

    final indices = widget.animationStyle.layoutConfig
        .indicesForLayout(currentIndex: 0, cardCount: 10);

    verify(() => cardBuilder(any())).called(indices.length);
  });

  testWidgets('can find geture detector inner gesture',
      (WidgetTester tester) async {
    final gestureWidgetFinder = find.byKey(Key('FlickedCardsGesture'));

    final widget = _createWidgetForTesting();

    await tester.pumpMyWidget(widget);
    await tester.pumpAndSettle();
    expect(gestureWidgetFinder, findsOneWidget);
    final size = tester.getSize(gestureWidgetFinder);
    assert(size != Size.zero);
  });

  testWidgets('widget is found and has non zero size',
      (WidgetTester tester) async {
    final finder = find.byType(FlickeredCards);
    final widget = _createWidgetForTesting();

    await tester.pumpMyWidget(widget);

    expect(finder, findsOneWidget);
    final size = tester.getSize(finder);
    assert(size != Size.zero);
  });

/*
  testWidgets('calls builder after full swipe', (WidgetTester tester) async {
    final cardBuilder = MockCallable<int>();
    final finder = find.byType(FlickeredCards);

    final widget = _createWidgetForTesting(inspector: (idx, progress) {
      cardBuilder.call(idx);
    });

    await tester.pumpMyWidget(widget);
    reset(cardBuilder);
    print(finder.first.description);
    TestGesture gesture =
        await tester.startGesture(Offset(20, 100), pointer: 7);
    await gesture.moveTo(Offset(250, 100));
    await gesture.up(timeStamp: const Duration(milliseconds: 250));

    verify(() => cardBuilder(any()));
  });
  */
}

extension WidgetTesterX on WidgetTester {
  Future<void> pumpMyWidget(FlickeredCards widget) {
    return pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: widget,
          ),
        ),
      ),
      const Duration(milliseconds: 100),
    );
  }
}
