final toBool = (dynamic val) => val is bool ? val : false;

final toInt =
    (dynamic val) => val is int ? val : (val is double ? val.toInt() : 0);

final toString = (dynamic val) => val is String ? val : '';

final toStringMap = (dynamic val) => (val is Map ? val : Map())
    .map((key, value) => MapEntry(toString(key), value));

final toStringStringMap = (dynamic val) => (val is Map ? val : Map())
    .map((key, value) => MapEntry(toString(key), toString(value)));
