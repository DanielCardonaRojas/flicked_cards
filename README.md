# flickered_cards

<p align="center">
<a href="https://github.com/DanielCardonaRojas/flickered_cards/actions/workflows/test.yaml">
<img alt="Build Status" src="https://github.com/DanielCardonaRojas/flickered_cards/actions/workflows/test.yaml/badge.svg">
</a>
 <!--<a href="https://pub.dartlang.org/packages/verify">-->
    <!--<img alt="Pub Package" src="https://img.shields.io/pub/v/verify.svg">-->
  <!--</a>-->

  <a href="https://codecov.io/gh/DanielCardonaRojas/flickered_cards">
    <img alt="Codecov" src="https://codecov.io/gh/DanielCardonaRojas/flickered_cards/branch/main/graph/badge.svg?token=NBJEUBQLZR">
  </a>

<a href="https://opensource.org/licenses/MIT">
<img alt="MIT License" src="https://img.shields.io/badge/License-MIT-blue.svg">
</a>

</p>

A customizable card swipping widget.

## Features

- Awesome default behaviours provided
- Progress through cards swipping both direction or in a single direction
- Extensible through custom provided animations
- Support piling or popping (depending on animation spec)

## TODO

- Add sensitivity parameter for wider screens.
- Piling (stacking) behaviour requested by animation to deck
- Add rolling carousel animation
- Use final drag velocity to calculate completing animation time
- Add a fourth card while dragging or animating to provilde more list like feel (cache widgets for 4th card)

# Custom animations

`flickered_cards` provides an easy way to create custom animations but it is required to have a basic understanding
of how cards can be layed out and how to position them depending on the drag progress and some of the properties in `AnimationConfig`.


Animations will be provided a `progress` value in the range (-1, 1) you should try to make you animation symmetric around 0
when posible. Like this:

![](current_card_animation.png)

You will have to reason about card indices:

![](card_indices.png)


## Available layouts

Internally cards are placed in `Stack` widget so an animation can choose to work with a single or both of the following 
layouts:

![](card_layouts.png)

Note that depending on the index some of cards will not be displayed:

![](cards_initial_layout.png)
![](cards_initial_layout.png)

