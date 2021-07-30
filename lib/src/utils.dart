/// A function used to map numeric intervals
typedef RangeMapper = num Function(num);

/// Extension for dealing with numeric intervals
extension MapRange on num {
  /// Maps an interval [inMin, inMax] to a new interval [outMin, outMax]
  /// with a line function
  static RangeMapper withIntervals(
      {required num inMin,
      required num inMax,
      required num outMin,
      required num outMax}) {
    return (num value) =>
        (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
  }
}
