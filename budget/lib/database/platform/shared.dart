// shared.dart

export 'unsupported.dart'
    if (dart.library.ffi) 'native.dart'
    if (dart.library.html) 'web.dart';

class DBFileInfo {
  DBFileInfo(
    this.dbFileBytes,
    this.mediaStream,
  );
  var dbFileBytes;
  Stream<List<int>> mediaStream;
}
