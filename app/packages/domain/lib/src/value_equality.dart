/// Égalité de valeur légère, sans dépendance externe.
library;

abstract base class ValueObject {
  const ValueObject();

  /// Composantes participant à l'égalité, dans un ordre stable.
  List<Object?> get props;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ValueObject &&
          other.runtimeType == runtimeType &&
          deepEquals(props, other.props));

  @override
  int get hashCode => Object.hashAll(props.map(deepHash));

  @override
  String toString() => '$runtimeType(${props.join(', ')})';
}

bool deepEquals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a is List<Object?> && b is List<Object?>) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!deepEquals(a[i], b[i])) return false;
    }
    return true;
  }
  if (a is Set<Object?> && b is Set<Object?>) {
    return a.length == b.length && a.containsAll(b);
  }
  if (a is Map<Object?, Object?> && b is Map<Object?, Object?>) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || !deepEquals(entry.value, b[entry.key])) {
        return false;
      }
    }
    return true;
  }
  return a == b;
}

int deepHash(Object? value) => switch (value) {
  final List<Object?> list => Object.hashAll(list.map(deepHash)),
  final Set<Object?> set => Object.hashAllUnordered(set.map(deepHash)),
  final Map<Object?, Object?> map => Object.hashAllUnordered(
    map.entries.map((e) => Object.hash(deepHash(e.key), deepHash(e.value))),
  ),
  _ => value.hashCode,
};
