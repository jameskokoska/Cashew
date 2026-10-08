import 'package:budget/struct/settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service quản lý Xác thực Google Sign-In & Firebase Authentication
/// Phụ trách: Lê Anh Tuấn (MSV: 2151060296) - Nhóm 16 (65KTPM - ĐH Thủy Lợi)
/// Nhánh: letuan-google-auth
class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  bool get _isFirebaseInitialized {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth get _auth => FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  /// Stream theo dõi thay đổi trạng thái đăng nhập thời gian thực
  Stream<User?> get authStateChanges =>
      _isFirebaseInitialized ? _auth.authStateChanges() : const Stream<User?>.empty();

  /// Lấy thông tin người dùng Firebase hiện tại
  User? get currentUser =>
      _isFirebaseInitialized ? _auth.currentUser : null;

  /// Kiểm tra xem người dùng đã đăng nhập hay chưa
  bool get isSignedIn => currentUser != null;

  /// Kiểm tra xem email có phải là tài khoản sinh viên / cán bộ Thủy Lợi hay không
  /// Định dạng email sinh viên TLU chuẩn: <Mã_SV>@e.tlu.edu.vn
  static bool isStudentEmail(String? email) {
    if (email == null) return false;
    final lower = email.toLowerCase().trim();
    return lower.endsWith('@e.tlu.edu.vn') ||
        lower.endsWith('@tlu.edu.vn') ||
        lower.endsWith('@thuyloi.edu.vn');
  }

  /// Phân loại loại tài khoản đăng nhập
  static String getAccountBadge(String? email) {
    if (email == null || email.isEmpty) return 'Khách';
    if (isStudentEmail(email)) {
      return 'Sinh viên Thủy Lợi (TLU)';
    }
    return 'Google Account';
  }

  /// Thực hiện đăng nhập Google một chạm (Google Sign-In -> Firebase Auth)
  Future<UserCredential?> signInWithGoogle({bool silent = false}) async {
    try {
      debugPrint('[GoogleAuthService] Bắt đầu luồng đăng nhập Google...');

      GoogleSignInAccount? googleAccount;
      if (silent && !kIsWeb) {
        googleAccount = await _googleSignIn.signInSilently();
      } else {
        googleAccount = await _googleSignIn.signIn();
      }

      if (googleAccount == null) {
        debugPrint('[GoogleAuthService] Người dùng đã hủy đăng nhập Google.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user != null) {
        debugPrint(
            '[GoogleAuthService] Đăng nhập Firebase Auth thành công: ${user.email} (${user.uid})');

        // Đồng bộ email người dùng vào settings của Cashew
        await updateSettings(
          'currentUserEmail',
          user.email ?? '',
          pagesNeedingRefresh: <int>[],
          updateGlobalState: true,
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('[GoogleAuthService] Lỗi FirebaseAuth: [${e.code}] ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[GoogleAuthService] Lỗi ngoại lệ Google Sign-In: $e');
      rethrow;
    }
  }

  /// Đăng xuất khỏi Firebase Auth và Google Sign-In
  Future<void> signOut() async {
    try {
      debugPrint('[GoogleAuthService] Đang thực hiện đăng xuất...');
      await _auth.signOut();
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      // Xóa email người dùng trong settings của Cashew
      await updateSettings(
        'currentUserEmail',
        '',
        pagesNeedingRefresh: <int>[],
        updateGlobalState: true,
      );
      debugPrint('[GoogleAuthService] Đã đăng xuất thành công.');
    } catch (e) {
      debugPrint('[GoogleAuthService] Lỗi khi đăng xuất: $e');
      rethrow;
    }
  }

  /// Lấy thông tin tóm tắt của User hiện tại phục vụ hiển thị UI
  Map<String, dynamic> getUserProfile() {
    final User? user = currentUser;
    if (user == null) {
      return <String, dynamic>{
        'signedIn': false,
        'displayName': 'Chưa đăng nhập',
        'email': '',
        'photoUrl': null,
        'uid': '',
        'badge': 'Khách',
        'isStudent': false,
      };
    }

    final email = user.email ?? '';
    return <String, dynamic>{
      'signedIn': true,
      'displayName': user.displayName ?? (email.isNotEmpty ? email.split('@')[0] : 'Người dùng'),
      'email': email,
      'photoUrl': user.photoURL,
      'uid': user.uid,
      'badge': getAccountBadge(email),
      'isStudent': isStudentEmail(email),
      'creationTime': user.metadata.creationTime,
      'lastSignInTime': user.metadata.lastSignInTime,
    };
  }
}
