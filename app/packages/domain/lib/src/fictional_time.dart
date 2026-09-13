/// Heure fictive d'une session, à la minute.
///
/// Limite du POC : une session se déroule sur une seule journée fictive
/// (00:00 à 23:59). Le passage de minuit n'est pas modélisé.
final class FictionalTime implements Comparable<FictionalTime> {
  const FictionalTime._(this.minutesSinceMidnight);

  factory FictionalTime(int hour, int minute) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw ArgumentError('Heure fictive invalide : $hour:$minute');
    }
    return FictionalTime._(hour * 60 + minute);
  }

  /// Lit une heure au format `HH:MM`.
  factory FictionalTime.parse(String text) {
    final match = _pattern.firstMatch(text);
    if (match == null) {
      throw FormatException('Heure fictive attendue au format HH:MM', text);
    }
    return FictionalTime(int.parse(match[1]!), int.parse(match[2]!));
  }

  static final _pattern = RegExp(r'^(\d{2}):(\d{2})$');

  final int minutesSinceMidnight;

  bool isBefore(FictionalTime other) => compareTo(other) < 0;

  bool isAfter(FictionalTime other) => compareTo(other) > 0;

  @override
  int compareTo(FictionalTime other) =>
      minutesSinceMidnight.compareTo(other.minutesSinceMidnight);

  @override
  bool operator ==(Object other) =>
      other is FictionalTime &&
      other.minutesSinceMidnight == minutesSinceMidnight;

  @override
  int get hashCode => minutesSinceMidnight.hashCode;

  @override
  String toString() {
    final hour = (minutesSinceMidnight ~/ 60).toString().padLeft(2, '0');
    final minute = (minutesSinceMidnight % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
