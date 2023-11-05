List<T> cloneList<T>(Iterable<T> original) {
  List<T> list = [];
  list.addAll(original);
  return list;
}
