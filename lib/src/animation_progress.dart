part of 'animation_state.dart';

/// Represents the animation value in the range (-1, 1)
/// also provides useful helpers to map the current value to other ranges
/// by composing calculation on this value
class AnimationProgress {
  double value = 0;

  NumericCompute _calculation = (v) => v;

  double get computed => _calculation(value);

  AnimationProgress computedWith(
      NumericCompute Function(NumericCompute) operations) {
    final newCalculation = operations(_calculation);
    return copyWith(calculation: newCalculation);
  }

  void apply(NumericCompute Function(NumericCompute) operations) {
    final newCalculation = operations(_calculation);
    _calculation = newCalculation;
  }

  AnimationProgress copyWith({NumericCompute? calculation}) {
    final newProgress = AnimationProgress();
    newProgress.value = value;

    if (calculation != null) {
      newProgress._calculation = calculation;
    }

    return newProgress;
  }

  void log() {
    print('Calculated $computed, from $value');
  }
}

typedef NumericCompute = double Function(double);

extension Math on NumericCompute {
  NumericCompute _sequence(NumericCompute next) {
    return (v) => next(this.call(v));
  }

  NumericCompute modifiedBy(NumericCompute next) {
    return (v) => next(this.call(v));
  }

  NumericCompute clamped({required double outMin, required double outMax}) {
    return _sequence((v) => v.clamp(outMin, outMax));
  }

  NumericCompute mappedBy({required double outMin, required double outMax}) {
    return _sequence((v) => MapRange.withIntervals(
            inMin: -1, inMax: 1, outMin: outMin, outMax: outMax)
        .call(v)
        .toDouble());
  }

  NumericCompute offsetBy(double offset) {
    return _sequence((v) => v + offset);
  }

  NumericCompute scaledBy(double factor) {
    return _sequence((v) => v * factor);
  }
}

typedef RangeMapper = num Function(num);

extension MapRange on num {
  static RangeMapper withIntervals(
      {required num inMin,
      required num inMax,
      required num outMin,
      required num outMax}) {
    return (num value) =>
        (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
  }
}
