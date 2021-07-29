import 'package:flutter/material.dart';

typedef ProgressBuilder = Widget Function(int, double, BuildContext);
typedef SwipeCompletion = void Function(int, SwipeDirection);

enum SwipeDirection { left, right }

extension SwipeDirectionValue on SwipeDirection {
  double get value {
    switch (this) {
      case SwipeDirection.left:
        return -1;
      case SwipeDirection.right:
        return 1;
      default:
        return 0;
    }
  }

  SwipeDirection get opposite {
    if (this == SwipeDirection.left) {
      return SwipeDirection.right;
    }

    return SwipeDirection.left;
  }

  bool get isLeft => this == SwipeDirection.left;
  bool get isRight => this == SwipeDirection.right;
}
