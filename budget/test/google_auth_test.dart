import 'package:budget/struct/googleAuthService.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bộ kiểm thử đơn vị (Unit Test) cho phân hệ Google Authentication
/// Phụ trách: Lê Anh Tuấn (MSV: 2151060296) - Nhóm 16 (65KTPM - ĐH Thủy Lợi)
void main() {
  group('Kiểm thử Phân loại & Nhận diện Đuôi Email (GoogleAuthService)', () {
    test('TC-01: Nhận diện đúng các đuôi email thuộc tên miền trường Đại học Thủy Lợi', () {
      // 1. Đuôi email sinh viên Thủy Lợi (@e.tlu.edu.vn)
      expect(
        GoogleAuthService.isStudentEmail('student@e.tlu.edu.vn'),
        isTrue,
      );
      // 2. Đuôi email trường (@tlu.edu.vn)
      expect(
        GoogleAuthService.isStudentEmail('teacher@tlu.edu.vn'),
        isTrue,
      );
      // 3. Đuôi email trường truyền thống (@thuyloi.edu.vn)
      expect(
        GoogleAuthService.isStudentEmail('staff@thuyloi.edu.vn'),
        isTrue,
      );
    });

    test('TC-02: Phân loại đúng các đuôi email cá nhân thông thường', () {
      // Đuôi @gmail.com
      expect(
        GoogleAuthService.isStudentEmail('user@gmail.com'),
        isFalse,
      );
      // Dù tên có chữ tlu nhưng đuôi @gmail.com thì vẫn là email cá nhân
      expect(
        GoogleAuthService.isStudentEmail('sinhvien_tlu@gmail.com'),
        isFalse,
      );
      // Đuôi @yahoo.com
      expect(
        GoogleAuthService.isStudentEmail('user@yahoo.com'),
        isFalse,
      );
      // Email null
      expect(
        GoogleAuthService.isStudentEmail(null),
        isFalse,
      );
    });

    test('TC-03: Kiểm tra cấp phát huy hiệu (Badge) dựa trên đuôi email', () {
      // Đuôi email trường được cấp huy hiệu Sinh viên Thủy Lợi (TLU)
      expect(
        GoogleAuthService.getAccountBadge('student@e.tlu.edu.vn'),
        equals('Sinh viên Thủy Lợi (TLU)'),
      );
      // Đuôi email thông thường
      expect(
        GoogleAuthService.getAccountBadge('user@gmail.com'),
        equals('Google Account'),
      );
      // Rỗng hoặc null
      expect(
        GoogleAuthService.getAccountBadge(''),
        equals('Khách'),
      );
      expect(
        GoogleAuthService.getAccountBadge(null),
        equals('Khách'),
      );
    });

    test('TC-04: Kiểm tra cấu trúc thông tin User Profile khi chưa đăng nhập', () {
      final service = GoogleAuthService();
      final profile = service.getUserProfile();

      expect(profile['signedIn'], isFalse);
      expect(profile['displayName'], equals('Chưa đăng nhập'));
      expect(profile['email'], isEmpty);
      expect(profile['badge'], equals('Khách'));
      expect(profile['isStudent'], isFalse);
    });
  });
}
