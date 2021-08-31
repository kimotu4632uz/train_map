extension MapValueWithIndex<T> on List<T> {
  Iterable<E> mapEnum<E>(E Function(int i, T e) f) =>
    this.asMap().map((key, value) => MapEntry(key, f(key, value))).values;
}

extension MapValue<K, V> on Map<K, V> {
  Iterable<E> mapValue<E>(E Function(K k, V v) f) =>
    this.map((key, value) => MapEntry(key, f(key, value))).values;
}
