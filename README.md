# flicked_cards

<p align="center">
<a href="https://github.com/DanielCardonaRojas/flicked_cards/actions/workflows/test.yaml">
<img alt="Build Status" src="https://github.com/DanielCardonaRojas/flicked_cards/actions/workflows/test.yaml/badge.svg">
</a>
<a href="https://codecov.io/gh/DanielCardonaRojas/flicked_cards">
  <img alt="Codecov" src="https://codecov.io/gh/DanielCardonaRojas/flicked_cards/branch/main/graph/badge.svg?token=NBJEUBQLZR">
</a>


<a href="https://opensource.org/licenses/MIT">
<img alt="MIT License" src="https://img.shields.io/badge/License-MIT-blue.svg">
</a>

</p>

A gesture driven card swipping widget supporting custom animations.

## Features

- Awesome default behaviours provided
- Progress through cards swipping both direction or in a single direction
- Extensible through custom provided animations
- Support piling or popping (depending on animation spec)


## Examples

Here are some of the animation provided out of the box, take a look at the example to see all.

<div align="center">
  <img src="roll_animation.gif">
  <img src="flip_animation.gif">
  <img src="carousel_animation.gif">
  <img src="deck_reversible_animation.gif">
</div>

Cards used in these examples where taken from [Brocodev](https://github.com/brocodev/flutter_projects) 

# Custom animations

`flicked_cards` provides an easy way to create custom animations but it is required to have a basic understanding
of how cards can be layed out and how to position them depending on the drag progress and some of the properties in `AnimationConfig`.


Animations will be provided a `progress` value in the range (-1, 1) you should try to make you animation symmetric around 0
when posible. Like this:

![](current_card_animation.png)

You will have to reason about relative card indices:

![](card_indices.png)

## Interface for animations

All animations will need to implement `CardAnimation` which basically
defines: 

- animation of a particular card depending on swipe progress `required` 
- opacity of a particular card depending on swipe progress `optional` 
- where to apply transformations on cards (Fractional Offset) 

```dart
typedef SwipeAnimation = Matrix4 Function(double progress);
typedef OpacityAnimation = double Function(double progress);

abstract class CardAnimation {
  AnimationConfig get config;
  LayoutConfig get layoutConfig;

  SwipeAnimation animationForCard({required int relativeIndex});

  OpacityAnimation opacityForCard({required int relativeIndex}) {
    return (_) => 1;
  }

  FractionalOffset fractionalOffsetForCard({required int relativeIndex});
}
```

Additionally to make this process a bit easier, 2 extra abstract classes that implement 
`CardAnimation` which are:

- `SymmetricCardAnimation`
- `AsymmetricCardAnimation`

Carousel animation is an example of a `SymmetricCardAnimation` take a look [here](https://github.com/DanielCardonaRojas/flicked_cards/blob/main/lib/src/animations/carousel_animation.dart)

## Available layouts

Internally cards are placed in `Stack` widget so an animation can choose to work with a single or both of the following 
layouts:

![](card_layouts.png)

Note that depending on the index some of cards will not be displayed:

![](cards_initial_layout.png)
![](cards_final_layout.png)


## TODO

- Add sensitivity parameter for wider screens.
- Fix Deck Animation not constant card separation make last and before aligned
