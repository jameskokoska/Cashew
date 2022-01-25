// shared.dart

export 'unsupported.dart'
    if (dart.library.ffi) 'native.dart'
    if (dart.library.html) 'web.dart';
