# 🧪 KỊCH BẢN KIỂM THỬ (TEST PLAN) & NHẬT KÝ KIỂM THỬ MODULE GOOGLE AUTHENTICATION

> 👥 **Người thực hiện:** Lê Anh Tuấn  
> 🆔 **Mã sinh viên:** 2151060296  
> 🏷️ **Vai trò:** Thành viên Nhóm 16 (Lớp 65KTPM — Trường CNTT — Đại học Thủy Lợi)  
> 🌿 **Nhánh Git phụ trách:** `letuan-google-auth`  
> 📱 **Ứng dụng:** Hệ thống Cashew & Phân hệ Quản lý Tài liệu Cloud DMS  
> ⚙️ **Công nghệ:** Flutter, Dart, Firebase Authentication, Google Sign-In  

---

## 📋 1. Mục Tiêu Kiểm Thử
1. Xác thực tính đúng đắn của việc tích hợp `firebase_auth` (v5.3.1+) và `google_sign_in` (v6.2.1+).
2. Kiểm tra luồng đăng nhập một chạm OAuth 2.0: Lấy Token Google ➡️ Xác thực Firebase Credential.
3. Xác minh tính năng nhận diện đuôi tên miền email trường Thủy Lợi (`@e.tlu.edu.vn`, `@tlu.edu.vn`, `@thuyloi.edu.vn`) và cấp phát huy hiệu tương ứng.
4. Kiểm tra khả năng hiển thị thời gian thực của `Stream<User?> authStateChanges` trên giao diện `LoginPage`.
5. Kiểm tra tính toàn vẹn khi đăng xuất (xóa phiên làm việc, dọn dẹp thông tin tài khoản an toàn).

---

## 📑 2. Danh Sách Các Ca Kiểm Thử (Test Cases)

### TC-01: Kiểm thử Đơn vị (Unit Test) - Nhận diện Đuôi Tên Miền Email & Cấp phát Huy hiệu
- **Mã kiểm thử:** `TC-AUTH-01`
- **Loại kiểm thử:** Automated Unit Test (`test/google_auth_test.dart`)
- **Mục tiêu:** Kiểm tra hàm `isStudentEmail()` và `getAccountBadge()` trong `GoogleAuthService` (kiểm tra phần đuôi domain bằng `endsWith`).
- **Dữ liệu đầu vào (Kiểm tra phần đuôi domain):**
  - Đuôi email sinh viên: `student@e.tlu.edu.vn` ➡️ Kỳ vọng: `isStudent = true`, Badge = `Sinh viên Thủy Lợi (TLU)`
  - Đuôi email trường: `teacher@tlu.edu.vn` ➡️ Kỳ vọng: `isStudent = true`, Badge = `Sinh viên Thủy Lợi (TLU)`
  - Đuôi email trường truyền thống: `staff@thuyloi.edu.vn` ➡️ Kỳ vọng: `isStudent = true`, Badge = `Sinh viên Thủy Lợi (TLU)`
  - Đuôi email cá nhân: `user@gmail.com` ➡️ Kỳ vọng: `isStudent = false`, Badge = `Google Account`
  - `null` hoặc rỗng `""` ➡️ Kỳ vọng: Badge = `Khách`
- **Kết quả kỳ vọng:** 100% các assertion trong test case đều đạt (`Pass`).

---

### TC-02: Kiểm tra Luồng Xác thực Google Sign-In 1 Chạm (OAuth 2.0)
- **Mã kiểm thử:** `TC-AUTH-02`
- **Loại kiểm thử:** Functional UI & Integration Test
- **Môi trường:** Thiết bị Android (hoặc Web/Emulator) đã liên kết `google-services.json` và cấu hình SHA-1 Fingerprint `7A:DE:A9:EB:BC:56:18:6D:7B:BD:84:59:63:7B:F2:E4:18:18:EE:AB`.
- **Các bước thực hiện:**
  1. Mở ứng dụng Cashew ➡️ Vào **Cài đặt** (Settings).
  2. Chọn mục **Xác thực Google Cloud (Nhóm 16)** để mở `LoginPage`.
  3. Bấm nút **"Đăng nhập với Google"**.
  4. Chọn một tài khoản Google (tài khoản cá nhân hoặc tài khoản sinh viên).
- **Kết quả kỳ vọng:**
  - Hộp thoại đăng nhập Google đóng lại sau khi cấp quyền.
  - Thông báo Snackbar hiển thị: *"Đăng nhập Google thành công!"* kèm theo email.
  - Giao diện tự động chuyển từ màn hình Chưa đăng nhập sang **Thẻ hồ sơ người dùng (User Profile Card)**.

---

### TC-03: Kiểm tra Hiển thị Trạng thái Hồ sơ Người dùng (Auth State)
- **Mã kiểm thử:** `TC-AUTH-03`
- **Loại kiểm thử:** UI Validation Test
- **Điều kiện tiên quyết:** Đã đăng nhập thành công ở `TC-AUTH-02`.
- **Các bước thực hiện:**
  1. Quan sát thẻ User Profile trên màn hình `LoginPage`.
  2. Đối chiếu các trường thông tin:
     - **Ảnh đại diện (Avatar):** Tải ảnh từ Google PhotoURL (có fallback chữ cái đầu).
     - **Họ và tên:** Trùng khớp tên tài khoản Google.
     - **Email:** Trùng khớp email người dùng.
     - **Firebase UID:** Chuỗi ID duy nhất do Firebase Authentication cấp.
     - **Huy hiệu (Badge):** Hiển thị nhãn xanh lá *"Google Account"* hoặc nhãn xanh dương *"Sinh viên Thủy Lợi (TLU)"*.
     - **Thời gian đăng nhập gần nhất:** Định dạng ngày giờ chuẩn.
- **Kết quả kỳ vọng:** Toàn bộ thông tin hiển thị chính xác, bố cục trực quan, không bị tràn viền (overflow).

---

### TC-04: Kiểm tra Luồng Đăng xuất An Toàn (Sign Out)
- **Mã kiểm thử:** `TC-AUTH-04`
- **Loại kiểm thử:** Functional Test
- **Điều kiện tiên quyết:** Người dùng đang trong trạng thái đã đăng nhập.
- **Các bước thực hiện:**
  1. Trên màn hình `LoginPage`, bấm nút **"Đăng xuất khỏi tài khoản"**.
  2. Quan sát phản hồi hệ thống.
- **Kết quả kỳ vọng:**
  - Hệ thống gọi `FirebaseAuth.instance.signOut()` và `GoogleSignIn().signOut()`.
  - Hiển thị Snackbar: *"Đã đăng xuất - Phiên làm việc đã kết thúc an toàn."*
  - Stream `authStateChanges` phát tín hiệu `null`.
  - Giao diện lập tức tự động chuyển về trạng thái **Chưa đăng nhập** với nút bấm "Đăng nhập với Google".
  - Dữ liệu `currentUserEmail` trong cài đặt Cashew được đưa về rỗng.

---

## 📊 3. Bảng Nhật Ký Thực Hiện Kiểm Thử Thực Tế (Execution Log)

| Mã Ca KT | Tên Ca Kiểm Thử | Người Thực Hiện | Ngày Kiểm Thử | Trạng Thái | Ghi Chú |
|:---:|:---|:---:|:---:|:---:|:---|
| **TC-AUTH-01** | Unit Test phân loại đuôi tên miền email trường TLU & cấp phát Badge | Lê Anh Tuấn | 08/10/2026 | **PASSED (4/4 test)** | Chạy lệnh `flutter test test/google_auth_test.dart` thành công 100% trong 00:00s. |
| **TC-AUTH-02** | Luồng xác thực Google Sign-In 1 chạm OAuth 2.0 | Lê Anh Tuấn | 08/10/2026 | **PASSED** | Đã cấu hình SHA-1 trên Firebase Console; sinh `firebase_options.dart`. |
| **TC-AUTH-03** | Hiển thị Auth State, Avatar và Firebase UID | Lê Anh Tuấn | 08/10/2026 | **PASSED** | Giao diện Material You nhận diện Nhóm 16 hiển thị đầy đủ thông số. |
| **TC-AUTH-04** | Luồng đăng xuất (Sign Out) và xóa phiên | Lê Anh Tuấn | 08/10/2026 | **PASSED** | Xóa sạch session an toàn, cập nhật trạng thái UI tức thời. |

---

## 🚀 4. Lệnh Chạy Kiểm Thử Nhanh

```bash
# Đứng tại thư mục budget
cd budget

# Chạy bộ test tự động của Lê Anh Tuấn
flutter test test/google_auth_test.dart
```

---

> ✍️ **Ký xác nhận hoàn thành phân hệ:**  
> **Thành viên phụ trách:** Lê Anh Tuấn (2151060296)  
> **Nhóm trưởng duyệt:** Nguyễn Văn Huỳnh (2351170599)  
