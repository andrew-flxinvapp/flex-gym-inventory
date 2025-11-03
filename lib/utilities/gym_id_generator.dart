class GymIdGenerator {
  GymIdGenerator({
    this.prefix = 'GYM',
    this.width = 3,
    int? startAt,
  }) : _lastNumber = startAt ?? 0;

  final String prefix;
  final int width;

  int _lastNumber;

  String next() {
    _lastNumber ++;
    final padded = _lastNumber.toString().padLeft(width, '0');
    return '$prefix-$padded';
  }

  void setLastNumber(int n) => _lastNumber = n;

  int get lastNumber => _lastNumber;

  int? parseNumber(String id) {
    final re = RegExp('^${RegExp.escape(prefix)}-(\\d{$width,})\$');
    final m = re.firstMatch(id);
    if (m == null) return null;
    return int.tryParse(m.group(1)!);
  }

  bool isValid(String id) => parseNumber(id) != null;
}