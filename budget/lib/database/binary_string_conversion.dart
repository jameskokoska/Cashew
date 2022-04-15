import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

/// Converts [Uint8List]s to binary strings. Used internally by drift to store
/// a database inside `window.localStorage`.
const bin2str = _BinaryStringConversion();

class _BinaryStringConversion extends Codec<Uint8List, String> {
  const _BinaryStringConversion();

  @override
  Converter<String, Uint8List> get decoder => const _String2Bin();

  @override
  Converter<Uint8List, String> get encoder => const _Bin2String();
}

class _String2Bin extends Converter<String, Uint8List> {
  const _String2Bin();

  @override
  Uint8List convert(String input) {
    final codeUnits = input.codeUnits;
    final list = Uint8List(codeUnits.length);

    for (var i = 0; i < codeUnits.length; i++) {
      list[i] = codeUnits[i];
    }
    return list;
  }
}

class _Bin2String extends Converter<Uint8List, String> {
  const _Bin2String();

  // There is a browser limit on the amount of chars one can give to
  // String.fromCharCodes https://github.com/sql-js/sql.js/wiki/Persisting-a-Modified-Database#save-a-database-to-a-string
  static const int _chunkSize = 0xffff;

  @override
  String convert(Uint8List input) {
    final buffer = StringBuffer();

    for (var pos = 0; pos < input.length; pos += _chunkSize) {
      final endPos = math.min(pos + _chunkSize, input.length);
      buffer.write(String.fromCharCodes(input.sublist(pos, endPos)));
    }

    return buffer.toString();
  }
}
