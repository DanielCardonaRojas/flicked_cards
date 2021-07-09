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
