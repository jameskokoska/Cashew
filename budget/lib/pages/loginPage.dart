import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/googleAuthService.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Màn hình Đăng nhập Google & Quản lý Trạng thái Xác thực (Auth State)
/// Phụ trách: Lê Anh Tuấn (MSV: 2151060296) - Nhóm 16 (65KTPM - ĐH Thủy Lợi)
/// Nhánh: letuan-google-auth
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleAuthService _authService = GoogleAuthService();
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final credential = await _authService.signInWithGoogle();
      if (!mounted) return;
      if (credential != null && credential.user != null) {
        final email = credential.user!.email ?? '';
        final isStudent = GoogleAuthService.isStudentEmail(email);
        openSnackbar(
          SnackbarMessage(
            title: isStudent
                ? 'Xin chào Sinh viên Thủy Lợi!'
                : 'Đăng nhập Google thành công!',
            description: 'Đã xác thực tài khoản: $email',
            icon: Icons.check_circle_rounded,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      openSnackbar(
        SnackbarMessage(
          title: 'Đăng nhập không thành công',
          description: e.toString(),
          icon: Icons.error_outline_rounded,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signOut();
      if (!mounted) return;
      openSnackbar(
        SnackbarMessage(
          title: 'Đã đăng xuất',
          description: 'Phiên làm việc đã kết thúc an toàn.',
          icon: Icons.logout_rounded,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      openSnackbar(
        SnackbarMessage(
          title: 'Lỗi đăng xuất',
          description: e.toString(),
          icon: Icons.error_outline_rounded,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color containerColor = appStateSettings['materialYou']
        ? dynamicPastel(
            context,
            Theme.of(context).colorScheme.secondaryContainer,
            amountLight: 0.2,
            amountDark: 0.6,
          )
        : getColor(context, 'lightDarkAccent');

    return PageFramework(
      dragDownToDismiss: true,
      title: 'Xác thực Google Cloud',
      listWidgets: [
        // 1. Banner nhận diện Nhóm 16 & Phân hệ
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_sync_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TextFont(
                          text: 'NHÓM 16 — BÀI TẬP CLOUD DMS',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 3),
                        TextFont(
                          text: 'Lê Anh Tuấn (2151060296) • Module Google Auth',
                          fontSize: 12,
                          textColor: getColor(context, 'textLight'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFont(
                text:
                    'Xác thực một chạm OAuth 2.0 tích hợp Firebase Authentication cho ứng dụng Cashew và hệ thống tài liệu DMS.',
                fontSize: 13,
                maxLines: 3,
                textColor: getColor(context, 'black').withValues(alpha: 0.8),
              ),
            ],
          ),
        ),

        // 2. StreamBuilder lắng nghe trạng thái đăng nhập
        StreamBuilder<User?>(
          stream: _authService.authStateChanges,
          builder: (context, snapshot) {
            final User? user = snapshot.data;
            final bool isSignedIn = user != null;

            if (isSignedIn) {
              return _buildSignedInView(context, user, containerColor);
            } else {
              return _buildSignedOutView(context, containerColor);
            }
          },
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  /// Giao diện khi người dùng ĐÃ ĐĂNG NHẬP
  Widget _buildSignedInView(
      BuildContext context, User user, Color containerColor) {
    final email = user.email ?? '';
    final isStudent = GoogleAuthService.isStudentEmail(email);
    final badge = GoogleAuthService.getAccountBadge(email);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thẻ hồ sơ User
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: boxShadowCheck(boxShadowSharp(context)),
            ),
            child: Column(
              children: [
                // Avatar người dùng
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? TextFont(
                              text: (user.displayName != null &&
                                      user.displayName!.isNotEmpty)
                                  ? user.displayName![0].toUpperCase()
                                  : 'U',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            )
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tên người dùng
                TextFont(
                  text: user.displayName ?? 'Người dùng Google',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Email
                TextFont(
                  text: email,
                  fontSize: 14,
                  textColor: getColor(context, 'textLight'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Huy hiệu tài khoản
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isStudent
                        ? Colors.blue.withValues(alpha: 0.15)
                        : Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isStudent ? Colors.blue : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isStudent ? Icons.school_rounded : Icons.verified_user_rounded,
                        size: 16,
                        color: isStudent ? Colors.blue : Colors.green,
                      ),
                      const SizedBox(width: 6),
                      TextFont(
                        text: badge,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        textColor: isStudent ? Colors.blue : Colors.green,
                      ),
                    ],
                  ),
                ),

                const Divider(height: 30),

                // Chi tiết kỹ thuật phiên đăng nhập (phục vụ kiểm thử & báo cáo)
                _buildInfoRow(
                  context,
                  icon: Icons.fingerprint_rounded,
                  label: 'Firebase UID',
                  value: user.uid,
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  context,
                  icon: Icons.shield_rounded,
                  label: 'Provider ID',
                  value: user.providerData.isNotEmpty
                      ? user.providerData.first.providerId
                      : 'google.com',
                ),
                if (user.metadata.lastSignInTime != null) ...[
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    context,
                    icon: Icons.access_time_rounded,
                    label: 'Đăng nhập gần nhất',
                    value: user.metadata.lastSignInTime
                        .toString()
                        .split('.')
                        .first,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Nút Đăng xuất
          Button(
            label: _isLoading ? 'Đang xử lý...' : 'Đăng xuất khỏi tài khoản',
            icon: Icons.logout_rounded,
            color: Colors.redAccent.withValues(alpha: 0.15),
            textColor: Colors.redAccent,
            expandedLayout: true,
            onTap: _isLoading ? () {} : _handleSignOut,
          ),

          const SizedBox(height: 12),

          // Nút Trở về ứng dụng
          Button(
            label: 'Quay lại Cài đặt',
            icon: Icons.arrow_back_rounded,
            color: Theme.of(context).colorScheme.primary,
            textColor: Colors.white,
            expandedLayout: true,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Giao diện khi người dùng CHƯA ĐĂNG NHẬP
  Widget _buildSignedOutView(BuildContext context, Color containerColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thẻ giới thiệu tính năng
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: boxShadowCheck(boxShadowSharp(context)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 14),
                const TextFont(
                  text: 'Đăng Nhập Tài Khoản',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextFont(
                  text:
                      'Đăng nhập bằng tài khoản Google để đồng bộ dữ liệu chi tiêu và tài liệu học tập lên đám mây Firebase.',
                  fontSize: 14,
                  textAlign: TextAlign.center,
                  textColor: getColor(context, 'textLight'),
                ),
                const SizedBox(height: 20),

                _buildFeatureBullet(
                  context,
                  icon: Icons.bolt_rounded,
                  title: 'Xác thực một chạm',
                  desc: 'Không cần ghi nhớ mật khẩu, bảo mật hai lớp tiêu chuẩn Google.',
                ),
                const SizedBox(height: 12),
                _buildFeatureBullet(
                  context,
                  icon: Icons.school_outlined,
                  title: 'Nhận diện sinh viên Thủy Lợi',
                  desc: 'Hỗ trợ tài khoản @thuyloi.edu.vn và @tlu.edu.vn.',
                ),
                const SizedBox(height: 12),
                _buildFeatureBullet(
                  context,
                  icon: Icons.cloud_done_rounded,
                  title: 'Đồng bộ tức thời',
                  desc: 'Tự động sao lưu và bảo vệ dữ liệu khi đổi thiết bị.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Nút Đăng nhập Google lớn
          Tappable(
            onTap: _isLoading ? () {} : _handleSignIn,
            borderRadius: 18,
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          MoreIcons.google,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 14),
                        TextFont(
                          text: 'Đăng nhập với Google',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: getColor(context, 'textLight')),
        const SizedBox(width: 10),
        SizedBox(
          width: 120,
          child: TextFont(
            text: label,
            fontSize: 12,
            textColor: getColor(context, 'textLight'),
          ),
        ),
        Expanded(
          child: TextFont(
            text: value,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureBullet(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFont(
                text: title,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 2),
              TextFont(
                text: desc,
                fontSize: 12,
                textColor: getColor(context, 'textLight'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
