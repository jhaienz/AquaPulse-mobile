/// A DO-crash forecast for one enclosure: whether DO will cross the species
/// threshold within the horizon, plus a plain-language recommended action.
/// Produced by the forecaster (statistical in MVP, ML later — ADR-0002).
class Forecast {
  final String enclosureId;
  final DateTime issuedAt;
  final bool crashLikely;
  final Duration? timeToThreshold; // null when no crash forecast
  final double thresholdMgL; // from the species profile (ADR-0005)
  final double doRatePerHour; // recent DO slope, mg/L per hour (negative = falling)
  final String headline; // e.g. "Hypoxia likely in 6h"
  final String recommendedAction; // e.g. "Pre-stage aeration array"
  final List<ForecastPoint> curve; // history + projected, for the trend chart

  const Forecast({
    required this.enclosureId,
    required this.issuedAt,
    required this.crashLikely,
    required this.timeToThreshold,
    required this.thresholdMgL,
    required this.doRatePerHour,
    required this.headline,
    required this.recommendedAction,
    required this.curve,
  });
}

/// One point on the forecast trend chart. `projected=false` is observed
/// history (solid line); `true` is the forecast tail (dashed line).
class ForecastPoint {
  final DateTime time;
  final double doMgL;
  final bool projected;

  const ForecastPoint({
    required this.time,
    required this.doMgL,
    required this.projected,
  });
}
