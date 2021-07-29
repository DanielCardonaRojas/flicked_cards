import 'dart:async';

import 'package:flicked_cards/flicked_cards.dart';
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
          return SizedBox(key: cardKey, height: 900, width: 300);
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

/*
  testWidgets('card 0 is hit testable', (WidgetTester tester) async {
    final cardZeroFinder = find.byKey(Key('Card0Key'));
    final widget = _createWidgetForTesting();

    await tester.pumpMyWidget(widget);
    await tester.pumpAndSettle();
    final hitTestable = cardZeroFinder.hitTestable();
    expect(hitTestable, findsOneWidget);
  });
  */

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
    // final finder = find.byType(FlickeredCards);
    final finder = find.byKey(Key('FlickedCardsGesture'));
    // final finder = find.byKey(Key('Card0Key'));

    final widget = _createWidgetForTesting(inspector: (idx, progress) {
      cardBuilder.call(idx);
    });

    await tester.pumpMyWidget(widget);
    await tester.pumpAndSettle();
    reset(cardBuilder);
    print(finder.first.description);
    await tester.drag(finder, Offset(80, 100));
    // TestGesture gesture = await tester.startGesture(Offset(20, 100));
    // for (var i = 0; i < 5; i++) {
    //   await gesture.moveBy(Offset(10, 0));
    // }

    // tester.pump();

    // await gesture.up(timeStamp: const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    verify(() => cardBuilder(any()));
  });
  */
}

extension WidgetTesterX on WidgetTester {
  Future<void> pumpMyWidget(FlickeredCards widget) {
    return pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: widget,
                ),
              ]),
        ),
      ),
      const Duration(milliseconds: 100),
    );
  }
}
