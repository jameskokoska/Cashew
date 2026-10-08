
# ☁️ BÀI TẬP: PHÂN TÍCH VÀ LẬP PHƯƠNG ÁN TÍCH HỢP CLOUD CHO HỆ THỐNG QUẢN LÝ TÀI LIỆU (DMS)

> 📌 **Nhiệm vụ đề bài:**  
> Phân tích chi tiết các thành phần hiện có của một ứng dụng Quản lý tài liệu (Document Management System - DMS) để xác định khả năng chuyển đổi. Đề xuất một phương án tích hợp điện toán đám mây (Cloud) nhằm tối ưu hóa khả năng lưu trữ, bảo mật và truy cập từ xa. Bài làm thể hiện sự so sánh giữa mô hình truyền thống và mô hình sau khi tích hợp Cloud.  
> 📑 **Báo cáo kỹ thuật chi tiết:** [`BAO_CAO_TICH_HOP_CLOUD_DMS.docx`](BAO_CAO_TICH_HOP_CLOUD_DMS.docx) | [`BAO_CAO_TICH_HOP_CLOUD_DMS.md`](BAO_CAO_TICH_HOP_CLOUD_DMS.md)  
> 📊 **Slide thuyết trình báo cáo:** [`Slide_Tich_Hop_Cloud_Firebase_DMS.pptx`](Slide_Tich_Hop_Cloud_Firebase_DMS.pptx)  
> 👥 **Đơn vị thực hiện:** **Nhóm 16** (Lớp 65KTPM — Khoa CNTT — Đại học Thủy Lợi)

### 📋 1. Bảng Đối Soát Hoàn Thành Checklist 7 Mục Theo Yêu Cầu

| STT | Mục Checklist Yêu Cầu | Kết Quả Triển Khai Trong Dự Án & Báo Cáo | Trạng Thái |
|:---:|:---|:---|:---:|
| **1** | **Liệt kê và phân tích các thành phần cốt lõi của ứng dụng Quản lý tài liệu** | Phân tích chi tiết 4 phân hệ: **Frontend** (Flutter Multiplatform / Web SPA), **Backend** (Stateless RESTful API), **Metadata Database** (RDBMS: PostgreSQL/SQLite), **File Storage** (Lưu trữ tệp nhị phân). Đánh giá tính sẵn sàng chuyển đổi Cloud đạt 85-95%. | ✅ Hoàn thành 100% |
| **2** | **Xác định các điểm nghẽn & hạn chế trên hạ tầng truyền thống** | Chỉ rõ 5 điểm nghẽn nghiêm trọng: Giới hạn dung lượng & nghẽn I/O đĩa cứng (Disk Bottleneck), Khó khăn khi mở rộng (Scale-up trần vật lý), Điểm chết đơn lẻ (SPOF) & VPN truy cập từ xa cồng kềnh, Rủi ro Thảm họa/Ransomware (RPO/RTO lớn), Gánh nặng chi phí CapEx/OpEx. | ✅ Hoàn thành 100% |
| **3** | **Lựa chọn mô hình Cloud phù hợp & dịch vụ cụ thể** | So sánh đa tiêu chí giữa Public, Private và Hybrid Cloud. Luận cứ lựa chọn **Public Cloud** với hệ sinh thái **AWS S3 / Google Cloud Storage** nhờ độ bền 11 số 9 (99.999999999%), mạng phân phối toàn cầu CDN, chi phí Pay-As-You-Go linh hoạt. | ✅ Hoàn thành 100% |
| **4** | **Thiết kế sơ đồ kiến trúc Cloud & mô tả luồng dữ liệu** | Xây dựng sơ đồ kiến trúc tổng thể [`scripts/output/cloud_dms_architecture.png`](scripts/output/cloud_dms_architecture.png) và quy trình **Direct Upload Pattern** bypass Backend API; xử lý phi đồng bộ qua Event-Driven (S3 Event -> SQS -> Lambda/Cloud Function sinh Thumbnail/OCR). | ✅ Hoàn thành 100% |
| **5** | **Đánh giá tác động về Bảo mật, Chi phí và Hiệu suất** | • **Bảo mật:** Mã hóa At-Rest (SSE-KMS AES-256) & In-Transit (TLS 1.3), Pre-signed URL có thời hạn, chống ransomware với Object Lock.<br>• **Chi phí:** Chuyển đổi CapEx sang OpEx, tự động hóa vòng đời dữ liệu S3 Lifecycle Rules tiết kiệm 70-90% chi phí lưu trữ dài hạn.<br>• **Hiệu suất:** Tốc độ tải vượt trội qua CloudFront CDN Edge Caching, giảm 75% độ trễ mạng. | ✅ Hoàn thành 100% |
| **6** | **Tích hợp Firebase: Google Sign-In & Cloud Storage cho Flutter** | Nghiên cứu và chuẩn hóa giải pháp tích hợp Firebase theo tài liệu chính thức [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup?hl=vi): Xác thực một chạm OAuth 2.0 bằng Google Sign-In (`firebase_auth`, `google_sign_in`) và lưu trữ tệp tin trên `firebase_storage` với cơ chế Resumable Upload và Security Rules phân quyền. | ✅ Hoàn thành 100% |
| **7** | **Slide báo cáo & Bảng phân chia công việc nhóm** | Thiết kế bộ Slide thuyết trình 11 trang chuẩn 16:9 [`Slide_Tich_Hop_Cloud_Firebase_DMS.pptx`](Slide_Tich_Hop_Cloud_Firebase_DMS.pptx), cập nhật tài liệu README.MD và phân công chi tiết công việc cho cả phần Báo cáo phân tích và phần Lập trình tích hợp tiếp theo. | ✅ Hoàn thành 100% |

---

### 👥 2. Bảng Phân Chia Công Việc: Bài Tập Phân Tích & Lập Phương Án Tích Hợp Cloud DMS

Nhóm 16 đã phân công cụ thể từng đầu việc cho 4 thành viên để hoàn thành toàn bộ bài tập phân tích kiến trúc và đề xuất phương án:

| STT | Thành Viên | Vai Trò | Nhiệm Vụ Phân Tích & Xây Dựng Báo Cáo | Sản Phẩm Bàn Giao | Trạng Thái |
|:---:|:---|:---:|:---|:---|:---:|
| **1** | **Nguyễn Văn Huỳnh** | **Nhóm trưởng** | • Chủ trì nghiên cứu kiến trúc tổng thể DMS.<br>• Thiết kế Sơ đồ kiến trúc Cloud tích hợp (AWS & Firebase) và quy trình luồng dữ liệu Direct Upload Pattern.<br>• So sánh các mô hình Public, Private, Hybrid Cloud và lựa chọn dịch vụ Object Storage.<br>• Tổng hợp, hiệu đính và xuất bản tệp báo cáo kỹ thuật [`BAO_CAO_TICH_HOP_CLOUD_DMS.docx`](BAO_CAO_TICH_HOP_CLOUD_DMS.docx) và Markdown. | Sơ đồ kiến trúc, Báo cáo DOCX & MD, Quản trị Git | ✅ Đã hoàn thành |
| **2** | **Lê Anh Tuấn** | **Thành viên** | • Liệt kê và phân tích chi tiết 4 thành phần cốt lõi của ứng dụng Quản lý tài liệu (Frontend, Backend, Database, File Storage).<br>• Đánh giá tính sẵn sàng chuyển đổi Cloud (Cloud-readiness) của từng thành phần.<br>• So sánh các nền tảng Cloud Storage hàng đầu: Amazon S3, Google Cloud Storage, Azure Blob Storage.<br>• Soạn thảo nội dung mục 1 và mục 3 trong báo cáo. | Nội dung phân tích thành phần & bảng so sánh dịch vụ | ✅ Đã hoàn thành |
| **3** | **NGUYỄN TRUNG KIÊN** | **Thành viên** | • Khảo sát và chỉ ra 5 điểm nghẽn nghiêm trọng của hệ thống DMS khi vận hành trên hạ tầng On-Premises truyền thống.<br>• Thiết kế toàn bộ Slide thuyết trình 11 trang chuẩn 16:9 [`Slide_Tich_Hop_Cloud_Firebase_DMS.pptx`](Slide_Tich_Hop_Cloud_Firebase_DMS.pptx).<br>• Trực quan hóa bảng đối chiếu 8 tiêu chí so sánh giữa mô hình Truyền thống và mô hình Cloud. | Bộ Slide thuyết trình PPTX, Phân tích 5 điểm nghẽn | ✅ Đã hoàn thành |
| **4** | **Trần Anh Tuấn** | **Thành viên** | • Đánh giá chuyên sâu 3 trụ cột tác động sau chuyển đổi: An toàn Bảo mật, Chi phí vận hành (TCO 3 năm) và Hiệu suất.<br>• Xây dựng biểu đồ phân tích bài toán tài chính TCO và tính toán tỷ lệ tiết kiệm chi phí lưu trữ theo vòng đời (S3 Lifecycle).<br>• Phác thảo lộ trình chuyển đổi 5 giai đoạn (Migration Roadmap). | Phân tích TCO, Biểu đồ chi phí, Lộ trình 5 bước | ✅ Đã hoàn thành |

---

### 🔥 3. Tìm Hiểu Giải Pháp Firebase (Google Sign-In & Cloud Storage)

Theo tài liệu chính thức của Google tại [https://firebase.google.com/docs/flutter/setup?hl=vi](https://firebase.google.com/docs/flutter/setup?hl=vi), giải pháp Firebase đem lại khả năng tích hợp vượt trội cho ứng dụng Flutter:

```mermaid
flowchart TD
    subgraph Client["Flutter Multiplatform App"]
        UI["UI / View Layer"]
        AuthProv["Auth State Provider"]
        StorageProv["Storage Service Provider"]
    end

    subgraph FirebaseCloud["Hệ Sinh Thái Google Cloud & Firebase"]
        GoogleAuth["Firebase Authentication\n(Google Sign-In OAuth 2.0)"]
        FStorage["Cloud Storage for Firebase\n(Google Cloud Storage Bucket)"]
        SecRules["Firebase Security Rules\n(RBAC / UID Validation)"]
    end

    UI -->|1. Đăng nhập Google 1 chạm| AuthProv
    AuthProv -->|2. Lấy GoogleCredential & ID Token| GoogleAuth
    GoogleAuth -->|3. Trả về FirebaseUser (UID, Email, Avatar)| AuthProv
    UI -->|4. Tải lên tệp tài liệu (PDF, DOCX)| StorageProv
    StorageProv -->|5. Đẩy tệp kèm Auth Token| FStorage
    FStorage -->|6. Kiểm tra quyền sở hữu| SecRules
    FStorage -->|7. Trả về Download URL / Metadata| StorageProv
```

#### Các Bước Setup Chuẩn Hóa Với Tài Khoản Nhóm 16:
1. **Bước 1: Khởi tạo Project trên Firebase Console**
   - Đăng nhập [Firebase Console](https://console.firebase.google.com/) bằng tài khoản của nhóm.
   - Chọn **Add project** -> Đặt tên dự án: `cashew-study-docs` -> Bật Google Analytics.
2. **Bước 2: Cài đặt công cụ dòng lệnh (CLI)**
   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   ```
3. **Bước 3: Cấu hình tự động ứng dụng Flutter với FlutterFire**
   ```bash
   # Đứng tại thư mục ứng dụng Flutter
   flutterfire configure --project=cashew-study-docs
   ```
   *Lệnh này sẽ tự động đăng ký ứng dụng Android, iOS, Web và sinh mã khởi tạo `lib/firebase_options.dart`.*
4. **Bước 4: Bổ sung dependencies vào `pubspec.yaml`**
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     firebase_core: ^3.6.0
     firebase_auth: ^5.3.1
     google_sign_in: ^6.2.1
     firebase_storage: ^12.3.2
   ```
5. **Bước 5: Kích hoạt dịch vụ trên Firebase Console**
   - **Authentication:** Bật phương thức đăng nhập **Google**, cấu hình SHA-1 fingerprint từ máy phát triển Android.
   - **Storage:** Bật Cloud Storage, chọn vị trí đặt Bucket (khuyến nghị `asia-southeast1` Singapore để độ trễ thấp nhất cho người dùng Việt Nam), cấu hình Security Rules bảo vệ quyền sở hữu tệp.

---

### 🚀 4. Kế Hoạch & Bảng Phân Chia Công Việc Lập Trình Bài Tập Tiếp Theo

Nhóm 16 thống nhất quy trình Git Flow: Mỗi thành viên tạo nhánh riêng `<tiền_tố>-<tên_chức_năng>`, hoàn thiện và tạo Pull Request (PR) để Nhóm trưởng review trước khi merge vào `main`.

| STT | Thành Viên | Vai Trò | Nhiệm Vụ Kỹ Thuật Phụ Trách | Sản Phẩm Bàn Giao | Tên Nhánh Git | Trạng Thái |
|:---:|:---|:---:|:---|:---|:---:|:---:|
| **1** | **Nguyễn Văn Huỳnh** | **Nhóm trưởng** | • Khởi tạo Firebase Project & phân quyền nhóm.<br>• Cấu hình dịch vụ Firebase Storage, thiết lập Security Rules.<br>• Triển khai tầng lưu trữ `FirebaseStorageService` (Upload/Download file, sinh Download URL).<br>• Quản trị Git Flow, review code PR và quản lý tài liệu nộp bài. | Service tệp tin Cloud, Security Rules, tài liệu tổng hợp | `huynh-cloud-storage` | ⏳ Đang triển khai |
| **2** | **Lê Anh Tuấn** | **Thành viên** | • Cài đặt và tích hợp `firebase_auth` & `google_sign_in`.<br>• Triển khai luồng xác thực Google Sign-In một chạm với tài khoản trường sinh viên.<br>• Xây dựng màn hình đăng nhập (Login View) và quản lý Auth State.<br>• Viết kịch bản kiểm thử luồng đăng nhập/đăng xuất và ghi log kiểm thử. | [`LoginPage`](budget/lib/pages/loginPage.dart), [`GoogleAuthService`](budget/lib/struct/googleAuthService.dart), [`Kịch bản kiểm thử`](KICH_BAN_KIEM_THU_GOOGLE_AUTH.md) | `letuan-google-auth` | ✅ **Hoàn thành (Sẵn sàng PR)** |
| **3** | **NGUYỄN TRUNG KIÊN** | **Thành viên** | • Thiết kế giao diện thông tin người dùng (Avatar, Email, Tên hiển thị sau đăng nhập).<br>• Xây dựng thanh tiến trình tải tệp (Upload / Download Progress Bar).<br>• Thiết kế chỉ báo trạng thái Cloud (Cloud Sync Badge, Offline Mode Indicator).<br>• Tối ưu hóa trải nghiệm giao diện người dùng (UI/UX) và chụp ảnh minh chứng. | Giao diện User Profile, Progress UI, Cloud Badges | `kien-cloud-ui` | ⏳ Đang triển khai |
| **4** | **Trần Anh Tuấn** | **Thành viên** | • Xây dựng cơ chế Local Cache kết hợp Cloud: Lưu trữ cục bộ khi Offline.<br>• Tự động đồng bộ tài liệu hai chiều khi kết nối mạng được phục hồi.<br>• Kiểm tra tính toàn vẹn tệp (Checksum MD5/SHA-256) và cập nhật bảng `delete_logs`.<br>• Kiểm thử hiệu năng truyền tải tệp khi mạng yếu. | Cơ chế Offline-First Cache, đồng bộ dữ liệu hai chiều | `trantuan-offline-sync` | ⏳ Đang triển khai |

---

# 📱 ĐỒ ÁN MÔN HỌC: XÂY DỰNG ỨNG DỤNG QUẢN LÝ CHI TIÊU CASHEW

> **Dự án:** Triển khai, kiểm thử và tùy chỉnh ứng dụng quản lý chi tiêu cá nhân dựa trên mã nguồn mở **Cashew**  
> **Repository:** [https://github.com/hhuynh2005/Cashew](https://github.com/hhuynh2005/Cashew) *(Forked from [jameskokoska/Cashew](https://github.com/jameskokoska/Cashew))*  
> **Công nghệ sử dụng:** Flutter, Dart, SQLite (Drift), Material You Design

---

## 👥 1. Danh Sách Thành Viên & Phân Công Vai Trò

| STT | Mã Sinh Viên | Họ và Tên | Vai Trò | Trách Nhiệm Chính | Tiền Tố Nhánh Git (Tên) |
|:---:|:---:|:---|:---:|:---|:---:|
| **1** | **2351170599** | **Nguyễn Văn Huỳnh** | **Nhóm trưởng** | • Quản lý chung dự án & phân công nhiệm vụ cho các thành viên<br>• Fork & cấu hình GitHub Repository, quản lý Git flow (nhánh, PR, merge)<br>• Hỗ trợ kỹ thuật, review code & giải quyết xung đột (conflict)<br>• Đóng gói sản phẩm (Build APK/Release), tổng hợp báo cáo & nộp bài | `huynh-` |
| **2** | **2151060296** | **Lê Anh Tuấn** | **Thành viên** | • Cài đặt các gói phụ thuộc (dependencies) và chuẩn hóa môi trường local<br>• Xây dựng kịch bản kiểm thử (Test Cases)<br>• Thực hiện kiểm thử toàn diện các chức năng cơ bản (CRUD: Thêm/Sửa/Xóa chi tiêu, tài khoản, danh mục)<br>• Ghi chép nhật ký kiểm thử và chụp ảnh màn hình minh chứng kết quả | `letuan-` |
| **3** | **2251172394** | **NGUYỄN TRUNG KIÊN** | **Thành viên** | • Nghiên cứu cấu trúc UI/UX và hệ thống Theme (Material You) của Cashew<br>• Thực hiện tùy chỉnh giao diện (UI): Cá nhân hóa logo/banner nhóm, tùy biến màn hình About/Thông tin nhóm, tinh chỉnh bảng màu sắc (Theme Colors)<br>• Chụp ảnh đối chứng giao diện Trước và Sau khi thay đổi (Before/After) | `kien-` |
| **4** | **2351170629** | **Trần Anh Tuấn** | **Thành viên** | • Nghiên cứu luồng xử lý dữ liệu và logic nghiệp vụ của ứng dụng<br>• Thực hiện tùy chỉnh / bổ sung tính năng (Feature): Tối ưu hóa đơn vị tiền tệ VNĐ mặc định, thêm bộ danh mục chi tiêu đặc thù cho sinh viên, tùy biến bộ lọc thống kê chi tiêu<br>• Kiểm thử độ ổn định tính năng mới và chụp ảnh minh chứng hoạt động | `trantuan-` |

---

## 📋 2. Bảng Phân Chia Công Việc Chi Tiết Theo Checklist 5 Mục

| Mục | Yêu Cầu Checklist | Người Phụ Trách | Người Phối Hợp | Chi Tiết Công Việc & Sản Phẩm Bàn Giao | Tên Nhánh Git (Tên + Chức năng) | Trạng Thái |
|:---:|:---|:---:|:---:|:---|:---|:---:|
| **1** | **Fork và Clone mã nguồn Cashew từ GitHub** | **Nguyễn Văn Huỳnh** | Cả nhóm | • Fork repo `jameskokoska/Cashew` sang `hhuynh2005/Cashew`<br>• Cấu hình collaborators & phân quyền nhánh<br>• Hướng dẫn các thành viên clone mã nguồn về local | `huynh-setup-repo` | ✅ Hoàn thành |
| **2** | **Cài đặt dependencies & cấu hình môi trường** | **Lê Anh Tuấn** | Nguyễn Văn Huỳnh | • Kiểm tra Flutter SDK (v3.47.5), Dart SDK, Android SDK 36<br>• Chạy `flutter pub get` trong thư mục `budget`<br>• Viết báo cáo cài đặt & xử lý dependencies tại [`SETUP_ENVIRONMENT.md`](SETUP_ENVIRONMENT.md) | `letuan-setup-dependencies` | ✅ Hoàn thành |
| **3** | **Khởi chạy local & kiểm tra chức năng cơ bản (CRUD)** | **Lê Anh Tuấn** | NGUYỄN TRUNG KIÊN, Trần Anh Tuấn | • Chạy ứng dụng trên Emulator / thiết bị thật / Web<br>• Kiểm thử chức năng: Thêm, Sửa, Xóa chi tiêu<br>• Kiểm thử số dư, hạn mức danh mục và biểu đồ báo cáo<br>• Chụp 5 ảnh minh chứng lưu tại `screenshots/crud/` | `letuan-test-crud` | ✅ Hoàn thành |
| **4** | **Tùy chỉnh tính năng hoặc thay đổi giao diện (UI)** | **NGUYỄN TRUNG KIÊN** (UI)<br>**Trần Anh Tuấn** (Tính năng) | Nguyễn Văn Huỳnh (Review & Merge) | • **UI (Kiên):** Tùy chỉnh thông tin nhóm tại Settings/About, đổi màu sắc chủ đạo sang Emerald `#00796B`, đổi banner nhận diện nhóm.<br>• **Tính năng (Tuấn):** Bổ sung danh mục chi tiêu học tập sinh viên, định dạng tiền tệ mặc định VNĐ, tối ưu hóa bộ lọc chi tiêu.<br>• Đã hoàn thành, review code và merge vào nhánh `main`. | `kien-custom-ui-branding`<br>`trantuan-custom-currency-vnd`<br>`trantuan-custom-feature` | ✅ Hoàn thành |
| **5** | **Đóng gói sản phẩm & Nộp bài** | **Nguyễn Văn Huỳnh** | Lê Anh Tuấn, NGUYỄN TRUNG KIÊN, Trần Anh Tuấn | • Đóng gói ứng dụng thành bản phát hành Web/PWA (`build/web`) và gói nén `Cashew-Web-Release.zip`<br>• Khởi chạy và kiểm thử live session ứng dụng trên trình duyệt Chrome<br>• Tổng hợp toàn bộ ảnh chụp màn hình minh chứng kết quả<br>• Hoàn thiện README và nộp link GitHub đúng hạn | `huynh-build-release` | ✅ Hoàn thành |

---

## 🌿 3. Quy Định Đặt Tên Nhánh Git & Quy Trình Push Code (Git Workflow)

> ⚠️ **QUY TẮC BẮT BUỘC DÀNH CHO TẤT CẢ THÀNH VIÊN:**  
> - **TUYỆT ĐỐI KHÔNG** commit hoặc push code trực tiếp lên nhánh `main`.  
> - Mỗi thành viên khi làm bất kỳ nhiệm vụ nào **BẮT BUỘC PHẢI TẠO MỘT NHÁNH MỚI** chứa cú pháp: **`<tên_thành_viên>-<tên_chức_năng>`**.  
> - Sau khi hoàn thành và kiểm thử ở local, push nhánh đó lên GitHub và tạo **Pull Request (PR)** để Nhóm trưởng review, giải quyết xung đột (nếu có) và merge vào `main`.

### 📌 Bảng Quy Định Tên Nhánh Chi Tiết Cho Từng Thành Viên:

| Thành Viên | Tiền Tố Tên | Tên Nhánh Khi Push Code | Mục Đích / Chức Năng Phụ Trách | Trạng Thái Nhánh |
|---|:---:|:---|:---|:---:|
| **Nguyễn Văn Huỳnh** | `huynh-` | `huynh-setup-repo`<br>`huynh-build-release` | • Cấu hình dự án, quản lý repo<br>• Đóng gói sản phẩm và hoàn thiện tài liệu nộp bài | ✅ Đã merge<br>✅ Đã hoàn thành |
| **Lê Anh Tuấn** | `letuan-` | `letuan-setup-dependencies`<br>`letuan-test-crud` | • Thiết lập thư viện và tài liệu môi trường<br>• Thực hiện và ghi log kiểm thử Thêm/Sửa/Xóa giao dịch | ✅ Đã merge<br>✅ Đã merge |
| **NGUYỄN TRUNG KIÊN** | `kien-` | `kien-custom-ui-branding`<br>`kien-custom-theme` | • Tùy chỉnh giao diện: màn hình giới thiệu nhóm, logo, banner<br>• Tùy biến màu sắc, theme theo nhận diện nhóm | ✅ Đã merge<br>✅ Đã merge |
| **Trần Anh Tuấn** | `trantuan-` | `trantuan-custom-currency-vnd`<br>`trantuan-custom-feature` | • Tùy chỉnh tiền tệ VNĐ mặc định, format số tiền<br>• Thêm danh mục chi tiêu sinh viên & cải tiến bộ lọc | ✅ Đã merge<br>✅ Đã merge |

*(Lưu ý: Để tránh nhầm lẫn giữa 2 bạn tên Tuấn, quy ước dùng tiền tố `letuan-` cho Lê Anh Tuấn và `trantuan-` cho Trần Anh Tuấn).*

---

### 🚀 Hướng Dẫn Các Bước Tạo Nhánh & Push Code Chi Tiết:

Mỗi khi bắt đầu làm một tính năng, thành viên thực hiện tuần tự theo các lệnh sau trong terminal:

```bash
# Bước 1: Chuyển về nhánh main và kéo code mới nhất về máy
git checkout main
git pull origin main

# Bước 2: Tạo nhánh mới với quy tắc: <tên>-<tên-chức-năng>
# Ví dụ:
git checkout -b huynh-build-release

# Bước 3: Thực hiện code, chỉnh sửa và kiểm thử ứng dụng chạy ổn định ở local

# Bước 4: Kiểm tra các file đã thay đổi
git status

# Bước 5: Thêm file và commit với cú pháp rõ ràng
git add .
git commit -m "[Huynh] Dong goi san pham phat hanh va hoan thien README"

# Bước 6: Push nhánh mới lên remote GitHub
git push origin huynh-build-release

# Bước 7: Mở GitHub repository, chọn 'Compare & pull request' để gửi yêu cầu merge vào nhánh main.
# Nhóm trưởng sẽ review code và duyệt merge.
```

---

## 🌟 4. Chi Tiết Các Tính Năng & Giao Diện Đã Tùy Chỉnh (Customization Details)

Đồ án đã thực hiện cá nhân hóa sâu trên cả hai phương diện: **Giao diện người dùng (UI/UX)** và **Tính năng nghiệp vụ (Business Features)**, đã được nhóm trưởng review và merge chính thức vào nhánh `main`:

### 🎨 4.1. Tùy Biến Giao Diện & Nhận Diện Nhóm (Thực hiện: NGUYỄN TRUNG KIÊN)
- **Banner nhận diện nhóm trên trang Cài đặt (`budget/lib/pages/settingsPage.dart`):**  
  Tích hợp thẻ banner `TeamBrandingBanner` ở vị trí nổi bật, hiển thị tên đồ án, logo ví tiền, các thẻ chip thành viên nhóm với vai trò cụ thể, hỗ trợ cả 2 chế độ Dark Mode/Light Mode và Material You. Khi chạm vào banner sẽ tự động điều hướng sang màn hình giới thiệu đồ án.
- **Cá nhân hóa màn hình Giới thiệu (`budget/lib/pages/aboutPage.dart`):**  
  Thêm danh mục **"NHÓM THỰC HIỆN ĐỒ ÁN"** lên đầu trang với danh thiếp `StudentMemberCard` hiển thị từng thành viên (Họ tên, MSSV, vai trò, công việc). Đồng thời cập nhật liên kết mã nguồn mở dẫn trực tiếp về repository của nhóm: `https://github.com/hhuynh2005/Cashew`.
- **Cập nhật Theme màu sắc mới (`budget/lib/colors.dart` & `defaultPreferences.dart`):**  
  Bổ sung mã màu ngọc lục bảo **Emerald** (`#00796B`) vào bảng màu có thể lựa chọn và thiết lập làm **màu nhấn mặc định (`accentColor`)** khi người dùng mở ứng dụng lần đầu.

### ⚙️ 4.2. Tùy Biến Tính Năng Nghiệp Vụ (Thực hiện: TRẦN ANH TUẤN)
- **Định dạng tiền tệ mặc định sang VNĐ (`budget/lib/functions.dart`, `currencyFunctions.dart`):**  
  Chuyển đổi tiền tệ mặc định của toàn bộ ứng dụng sang **VNĐ (Việt Nam Đồng)**, cấu hình ẩn chữ số thập phân không cần thiết cho VNĐ và định dạng dấu phân cách phần nghìn chuẩn tiếng Việt.
- **Bộ danh mục chi tiêu dành riêng cho Sinh viên (`budget/lib/struct/defaultCategories.dart`):**  
  Bổ sung danh mục chi tiêu học tập - sinh hoạt đặc thù phù hợp thực tế sinh viên Việt Nam: *Học phí, Tiền thuê trọ, Sách vở - Giáo trình, Đồ dùng học tập, v.v.*
- **Nâng cấp bộ lọc tìm kiếm giao dịch (`budget/lib/pages/transactionsSearchPage.dart`):**  
  Tối ưu hóa thao tác tìm kiếm và phân loại chi tiêu theo các danh mục sinh viên.

---

## 🛠️ 5. Hướng Dẫn Cài Đặt Và Khởi Chạy Ứng Dụng (Quick Start)

### Yêu cầu tiên quyết:
- **Flutter SDK:** `>= 3.0.0` (Khuyên dùng Flutter 3.x stable)
- **Dart SDK:** Đi kèm với Flutter
- **Công cụ:** Google Chrome / Edge (cho Web), hoặc Android Studio / VS Code với Android Emulator.

### Các bước thực hiện:

1. **Clone mã nguồn dự án:**
   ```bash
   git clone https://github.com/hhuynh2005/Cashew.git
   cd Cashew/budget
   ```

2. **Cài đặt các gói phụ thuộc (Dependencies):**
   ```bash
   flutter pub get
   ```

3. **Khởi chạy ứng dụng (Debug Mode):**
   ```bash
   # Khởi chạy trên trình duyệt Web (Google Chrome):
   flutter run -d chrome

   # Hoặc khởi chạy trên máy ảo Android (Pixel_34):
   # flutter emulators --launch Pixel_34
   # flutter run
   ```

4. **Đóng gói bản cài đặt phát hành (Release Mode):**
   ```bash
   # Đóng gói bản phát hành Web / PWA:
   flutter build web --release

   # Đóng gói bản cài đặt Android APK (khi cấu hình Android build):
   # flutter build apk --release
   ```
   *Thư mục phát hành sau khi build nằm tại:* `budget/build/web/` hoặc file nén `Cashew-Web-Release.zip` tại thư mục gốc.

---

## 📸 6. Danh Mục Ảnh Chụp Màn Hình Minh Chứng (Screenshots)

Toàn bộ ảnh chụp màn hình kết quả chạy và kiểm thử ứng dụng được lưu trữ tại thư mục `screenshots/`:

### 🧪 6.1. Minh Chứng Kiểm Thử Chức Năng Cơ Bản (CRUD) - Thực hiện: Lê Anh Tuấn
| Tên File Ảnh | Nội Dung Kiểm Thử | Trạng Thái | Đường Dẫn Tệp |
|:---|:---|:---:|:---:|
| `01_create_expense.png` | Kiểm thử thêm mới khoản chi tiêu giao dịch | ✅ Đạt | [`screenshots/crud/01_create_expense.png`](screenshots/crud/01_create_expense.png) |
| `02_update_expense.png` | Kiểm thử chỉnh sửa thông tin khoản chi tiêu | ✅ Đạt | [`screenshots/crud/02_update_expense.png`](screenshots/crud/02_update_expense.png) |
| `03_delete_expense.png` | Kiểm thử xóa khoản chi tiêu khỏi hệ thống | ✅ Đạt | [`screenshots/crud/03_delete_expense.png`](screenshots/crud/03_delete_expense.png) |
| `04_categories_budget.png` | Kiểm tra giao diện danh mục & hạn mức ngân sách | ✅ Đạt | [`screenshots/crud/04_categories_budget.png`](screenshots/crud/04_categories_budget.png) |
| `05_analytics_chart.png` | Kiểm tra biểu đồ phân tích chi tiêu & cập nhật số dư | ✅ Đạt | [`screenshots/crud/05_analytics_chart.png`](screenshots/crud/05_analytics_chart.png) |

### 🎨 6.2. Minh Chứng Tùy Chỉnh Giao Diện & Tính Năng - Thực hiện: Kiên & Tuấn
| Tên File Ảnh | Nội Dung Minh Chứng | Người Thực Hiện | Đường Dẫn Tệp |
|:---|:---|:---:|:---:|
| `setting.png` | Banner nhận diện đồ án & nhóm trên trang Cài đặt | Nguyễn Trung Kiên | [`screenshots/customization/setting.png`](screenshots/customization/setting.png) |
| `about.png` | Màn hình About hiển thị thông tin nhóm đồ án & MSSV | Nguyễn Trung Kiên | [`screenshots/customization/about.png`](screenshots/customization/about.png) |
| `home.png` | Giao diện chính màn hình Home với Theme màu Emerald mới | Nguyễn Trung Kiên | [`screenshots/customization/home.png`](screenshots/customization/home.png) |
| `defaultmoney.png` | Cấu hình tiền tệ mặc định sang VNĐ (Việt Nam Đồng) | Trần Anh Tuấn | [`screenshots/customization/defaultmoney.png`](screenshots/customization/defaultmoney.png) |
| `student_categories.png` | Danh mục chi tiêu học tập - sinh hoạt cho sinh viên | Trần Anh Tuấn | [`screenshots/customization/student_categories.png`](screenshots/customization/student_categories.png) |

### 📦 6.3. Minh Chứng Đóng Gói Sản Phẩm (Release Packaging) - Thực hiện: Nguyễn Văn Huỳnh
| Sản Phẩm Bàn Giao | Mô Tả | Trạng Thái | Vị Trí Lưu Trữ |
|:---|:---|:---:|:---:|
| `build/web/` | Bản build phát hành Web/PWA hoàn chỉnh với tối ưu AOT & Tree-shaking | ✅ Đạt | `budget/build/web/` |
| `Cashew-Web-Release.zip` | Gói nén zip toàn bộ bundle phát hành độc lập để triển khai | ✅ Đạt | Thư mục gốc dự án |
| `screenshots/build/` | Tài liệu minh chứng quy trình đóng gói và triển khai sản phẩm | ✅ Đạt | [`screenshots/build/README.md`](screenshots/build/README.md) |


---


# 📖 TÀI LIỆU GỐC DỰ ÁN CASHEW (ORIGINAL CASHEW DOCUMENTATION)

<h1 align="center" style="font-size:28px; line-height:1"><b>Cashew</b></h1>


<div align="center">
  <a href="https://cashewapp.web.app/">
    <img alt="Icon" src="promotional/icons/icon.png" width="150px" >
  </a>
</div>


<br />

<div align="center">
  <a href="https://apps.apple.com/us/app/cashew-expense-budget-tracker/id6463662930">
    <img alt="iOS App Store Badge" src="promotional/store-banners/app-store-badge.png" height="60px">
  </a>
  <a href="https://play.google.com/store/apps/details?id=com.budget.tracker_app">
    <img alt="Google Play Badge" src="promotional/store-banners/google-play-badge.png" height="60px">
  </a>
  <a href="https://github.com/jameskokoska/Cashew/releases/">
    <img alt="GitHub Badge" src="promotional/store-banners/github-badge.png" height="60px">
  </a>
  <a href="https://budget-track.web.app/">
    <img alt="PWA Badge" src="promotional/store-banners/pwa-badge.png" height="60px">
  </a>
</div>

<h3 align="center" style="font-size:28px; line-height:1">
  <a href="https://github.com/jameskokoska/Cashew/issues/725">🚀 Cashew Beta Testing</a>
</h3>

---

<br />

<a href="https://cashewapp.web.app/">
  <div align="center">
    <img width="95%" src="promotional/GitHub/SocialPreviewGitHub.png" alt="Promo banner">
  </div>
</a>

<br />

Cashew is a full-fledged, feature-rich application designed to empower users in managing their finances effectively. Built using Flutter - with Drift's SQL package, and Firebase - this app offers a seamless and intuitive user experience across various devices. Development started in September 2021.

---

## Features

<a href="https://www.youtube.com/watch?v=Oar9pkc7BSc&t=235s">
  <div align="center">
    <img width="80%" src="promotional/youtube-promo/thumbnail-oss.png" alt="Review Video">
  </div>
</a>
<p align="center">
  Cashew was featured on <a href="https://www.youtube.com/watch?v=Oar9pkc7BSc&t=235s">YouTube</a> on 'The Best Free and Open Source Apps in 2024!' (and in the thumbnail!)
</p>

<br />

<a href="https://www.youtube.com/watch?v=NYZd7IKn1oY&t=536s">
  <div align="center">
    <img width="80%" src="promotional/youtube-promo/thumbnail-year-best.png" alt="Review Video">
  </div>
</a>
<p align="center">
  Cashew was featured on <a href="https://www.youtube.com/watch?v=NYZd7IKn1oY&t=536s">YouTube</a> on 'The Best Apps of 2023!'
</p>

<br>

<a href="https://www.youtube.com/watch?v=2MwWmqcn--s&t=261s">
  <div align="center">
    <img width="80%" src="promotional/youtube-promo/thumbnail.png" alt="Review Video">
  </div>
</a>
<p align="center">
  Cashew was featured on <a href="https://www.youtube.com/watch?v=2MwWmqcn--s&t=261s">YouTube</a> on 'Top Android Apps! (November 2023)'
</p>

<br>

<div align="center">
  <img width="80%" src="promotional/play-store-feature/play-store-feature.png" alt="Play Store Feature">
</div>
<p align="center">
  Cashew was featured on <a href="https://play.google.com/store/apps/editorial?id=mc_apps_new_on_play_fcp">Google Play's Editorial 'New Apps We Love'</a> (November 2023)!
</p>

<br>

<a href="https://github.com/nyas1/Material-You-app-list?tab=readme-ov-file#-economy:~:text=MDY%20Celenganku-,MDY%20Cashew,-MDY%20Allowance%20FOSS">
  <div align="center">
    <img width="80%" src="promotional/material-apps-feature/material-apps-feature.png" alt="Material Apps List Feature">
  </div>
</a>
<p align="center">
  Cashew was featured in the <a href="https://github.com/nyas1/Material-You-app-list?tab=readme-ov-file#-economy:~:text=MDY%20Celenganku-,MDY%20Cashew,-MDY%20Allowance%20FOSS">Material You Apps List</a>!
</p>

## Release

Check out the [official website](https://cashewapp.web.app/)!

This application is available on the [App Store](https://apps.apple.com/us/app/cashew-expense-budget-tracker/id6463662930), [Google Play](https://play.google.com/store/apps/details?id=com.budget.tracker_app), [GitHub](https://github.com/jameskokoska/Cashew/releases/) and as a [Web App (PWA)](https://budget-track.web.app/).

### Changelog

Changes and progress about development is all heavily documented in GitHub [commits](https://github.com/jameskokoska/Cashew/commits/main) and in the [changelog](https://github.com/jameskokoska/Cashew/blob/main/budget/lib/widgets/showChangelog.dart)

## Key Features

### 💸 Budget Management

- Custom Budgets and Time Periods: Set up personalized budgets with flexible time periods, such as monthly, weekly, daily, or any custom time period that suits your financial planning needs. A custom time period is useful if you plan on setting a one-time travel budget!
- Added Budgets: Selectively add transactions to specific budgets, allowing you to focus on specific expense categories.
- Category Spending Limits per Budget: Set limits for each category within a budget, ensuring responsible spending.
- Past Budget History Viewing: Analyze your spending habits over time by accessing past budget history, enabling comparison and tracking of financial progress.
- Goals: Create spending and saving goals and put transactions towards different purchases or savings. Track your progress towards achieving your financial goals.

### 💰 Transaction Management

- Support for Different Transaction Types: Categorize transactions effectively based on types such as upcoming, subscription, repeating, debts (borrowed), and credit (lent). Each type behaves in certain ways in the interface. Pay your upcoming transactions when you're ready, or mark your lent out transactions as collected.
- Custom Categories: Create personalized categories to organize transactions according to your unique spending habits. Search through multiple icons and select the default option as expenses or income when adding transactions.
- Custom Titles: Automatically assign transactions with the same name to specific categories, saving time and ensuring consistency. These titles are stored in memory and popup when you add another transaction with a similar name.
- Search and Filters: Easily search and filter transactions based on various criteria such as date, category, amount, or custom tags, enabling quick access to information.
- Easy Editing: Long-press and swipe to select multiple budgets, edit accordingly as needed or delete multiple at once.

### 💱 Financial Flexibility

- Multiple Currencies and Accounts: Manage finances across different currencies and accounts with up-to-date conversion rates for accurate calculations and effortless currency conversions. The interface shows the original amount added and the converted amount to the selected account.
- Switch Accounts and Currencies with Ease: On the homepage, easily select a different account and currency and everything will be converted automatically in an instant.

### 🔒 Enhanced Security and Accessibility

- Biometric Lock: Secure budget data using biometric authentication, adding an extra layer of privacy.
- Google Login: Conveniently log in to the app using your Google account, ensuring a streamlined and hassle-free authentication process.

### 🎨 User Experience and Design

- Material You Design: Enjoy a visually appealing and modern interface, following the principles of Material You design for a delightful user experience.
- Custom Accent Color: Personalize the app by selecting a custom accent color that suits your style, or follow that of the system.
- Light and Dark Mode: Seamlessly switch between light and dark themes to optimize visibility and reduce eye strain.
- Customizable Home Screen: Tailor the home screen layout and widgets to display the financial information that matters most to you, providing a personalized and efficient dashboard.
- Detailed Graph Visuals: Gain valuable insights into spending patterns through detailed and interactive graphs, visualizing financial data at a glance.
- Beautiful Adaptive UI: A responsive user interface that adapts flawlessly to both web and mobile platforms, providing an immersive and consistent user experience across devices.

### ☁ Backup and Syncing

- Cross-Device Sync: Keep budget data synchronized across all devices, ensuring access to financial information wherever you go.
- Google Drive Backup: Safeguard budget data by utilizing Google Drive's backup functionality, allowing easy restoration of data if needed.

### 💿 Smart Automation

- Notifications: Stay informed about important financial events and receive timely reminders for budget goals, transactions, and upcoming due dates.
- Import CSV Files: Seamlessly import financial data by uploading CSV files, facilitating a smooth transition from other applications or platforms.
- Import Google Sheets: Seamlessly import Google Sheets tables, quickly importing many transactions from a spreadsheet.
- App Links: Automatically create transactions with pre-filled data using app linking (documentation below)

## Automation

See the `Automation` section on the FAQ website for information on how to add transactions automatically: https://cashewapp.web.app/faq.html#automation

## Bundled Packages

This repository contains, bundled in, modified versions of the discontinued packages listed below. They can be found in the folder `/budget/packages`

- https://pub.dev/packages/implicitly_animated_reorderable_list
- https://pub.dev/packages/sliding_sheet

## Translations

The translations are available here: https://docs.google.com/spreadsheets/d/1QQqt28cmrby6JqxLm-oxUXCuM3alniLJ6IRhcPJDOtk/edit?usp=sharing. If you would like to help translate, please reach out on email: dapperappdeveloper@gmail.com

### To Update Translations

1. Run `budget\assets\translations\generate-translations.py`
2. Restart the application

## Developer Notes

### Pull Requests and Contributions

Unfortunately, I am currently not accepting contributions due to licensing and credits. Since this application turns some profits, I want to avoid any muddy water when it comes to compensation for contributions. You are free to submit an [issue](https://github.com/jameskokoska/Cashew/issues) and I can consider it!

### Android Release

- To build an app-bundle Android release, run `flutter build appbundle --release`

Note: required Android SDK.

### iOS Release

- To build an IPA iOS release, run `flutter build ipa`

Note: requires MacOS.

### Firebase Deployment

- To deploy to firebase, run `firebase deploy`

Note: required Firebase.

### GitHub release

- Create a tag for the current version specified in `pubspec.yaml`
- `git tag <version>`
- Push the tag
- `git push origin <version>`
- Create the release and upload binaries
- https://github.com/jameskokoska/Cashew/releases/new

### Scripts

`deploy_and_build_windows.bat`

- Deploy to Firebase and build the apk and appbundle

`open_release_builds.bat`

- Opens the location of the built apk and appbundle

`update_translations.bat`

- Downloads the latest version of Cashew translations. Runs `budget\assets\translations\generate-translations.py`

### Develop Wirelessly on Android

- `adb tcpip 5555`
- `adb connect <IP>`
- Get the phone's IP by going to `About Phone` > `Status Information` > `IP Address`

### Migrate Database

1. Make any database changes to the schema and tables
2. Bump the schema version
   - Change `int schemaVersionGlobal = ...+1` in `tables.dart`
3. Make sure you are in application root directory
   - `cd .\budget\`
4. Generate database code
   - Run `dart run build_runner build`
5. Export the new schema
   - Generate schema dump for the newly created schema
   - Replace `[schemaVersion]` in the command below with the value of `schemaVersionGlobal`
   - Run `dart run drift_dev schema dump lib\database\tables.dart drift_schemas//drift_schema_v[schemaVersion].json`
   - Read more: https://drift.simonbinder.eu/docs/advanced-features/migrations/#exporting-the-schema
6. Generate step-by-step migrations
   - Run `dart run drift_dev schema steps drift_schemas/ lib\database\schema_versions.dart`
7. Implement migration strategy
   - Edit `await stepByStep(...)` function in `tables.dart` and add the migration strategy for the new version migration

### Get Platform

- Use `getPlatform()` from `functions.dart`
- Since `Platform` is not supported on web, we must create a wrapper and always use this to determine the current platform

### Push Route

- If we want to navigate to a new page, stick to `pushRoute(context, page)` function from `functions.dart`
- It handles the platform routing and `PageRouteBuilder`

### Wallets vs. Accounts

- `Wallets` have been been renamed to `Accounts` on the front-end but internally, the name `Wallet` is still used.

### Objectives vs. Goals

- `Objectives` have been been renamed to `Goals` on the front-end but internally, the name `Objectives` is still used.

### Long Term Loans

- Long term loans create a goal. However, the goals total is not used. Instead the total of the goal is calculated by totalling the proper polarity of transactions of the opposite type. For example, if it was a loan of 100$ lent out, the initial transaction would be 100$ of negative polarity (expense) and that would be the total of the goal. When a payment is made, it is made in the opposite (positive) polarity (income) and added to the total 'paid back'. We can easily find how much is remaining by taking the difference (or the addition including polarities).
