import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/core/themes/app_mode_provider.dart';
import 'package:my_barber/features/login/logic/login_provider.dart';
import 'package:my_barber/features/profile/logic/delete_account_provider.dart';
import 'package:my_barber/features/profile/presentation/screens/web_view_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current user from Supabase
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'User Name';
    final userEmail = user?.email ?? 'email@example.com';
    final userPhone = user?.userMetadata?['phone'] ?? 'Not provided';

    // Get screen height for header
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      // AppBar removed as requested
      body: Column(
        children: [
          // Header with user info - 25% of screen height with background color text
          Container(
            width: double.infinity,
            height: screenHeight * 0.25, // 25% of screen height
            padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
            decoration: BoxDecoration(color: AppColors.primaryColor(context)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    color: AppColors.scaffoldBackground(
                      context,
                    ), // Background color text
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16.sp,
                      color: AppColors.scaffoldBackground(
                        context,
                      ), // Background color
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        userEmail,
                        style: TextStyle(
                          color: AppColors.scaffoldBackground(
                            context,
                          ), // Background color text
                          fontSize: 14.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 16.sp,
                      color: AppColors.scaffoldBackground(
                        context,
                      ), // Background color
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      userPhone,
                      style: TextStyle(
                        color: AppColors.scaffoldBackground(
                          context,
                        ), // Background color text
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Theme settings at the start (top-left)
          Container(
            padding: EdgeInsets.all(24.w),
            color: AppColors.scaffoldBackground(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    color: AppColors.inverseScaffoldBackground(context),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildThemeDropdown(context, ref),
                SizedBox(height: 8.h),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.description_outlined,
                  label: 'Terms and Conditions',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WebViewScreen(
                        title: 'Terms and Conditions',
                        url: 'https://www.halaqi.com/terms-and-conditions',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WebViewScreen(
                        title: 'Privacy Policy',
                        url: 'https://www.halaqi.com/privacy-policy',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Spacer to push logout to bottom
          Spacer(),

          // Logout + Delete Account buttons at the bottom
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            color: AppColors.scaffoldBackground(context),
            child: Column(
              children: [
                // Logout button
                InkWell(
                  onTap: () async {
                    await ref.read(loginProvider.notifier).logout();
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Log out',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                // Delete Account button (required by Google Play policy)
                _buildDeleteAccountButton(context, ref),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context, WidgetRef ref) {
    final deleteState = ref.watch(deleteAccountProvider);

    return InkWell(
      onTap: deleteState.isLoading
          ? null
          : () => _confirmDeleteAccount(context, ref),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: deleteState.isLoading
            ? Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    color: Colors.red,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.scaffoldBackground(ctx),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.red, size: 24.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Delete Account',
                style: TextStyle(
                  color: AppColors.inverseScaffoldBackground(ctx),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete your account?\n\n'
          'This will remove all your data including bookings and personal information. '
          'This action cannot be undone.',
          style: TextStyle(
            color: AppColors.textGrey(ctx),
            fontSize: 14.sp,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textGrey(ctx),
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(deleteAccountProvider.notifier).deleteAccount();
      final state = ref.read(deleteAccountProvider);
      if (state.errorMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primaryColor(context).withValues(alpha: 0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.primaryColor(context)),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.inverseScaffoldBackground(context),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: AppColors.inverseScaffoldBackground(
                context,
              ).withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeDropdown(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(appModeProvider);
    final List<String> themeOptions = [
      'Light Theme',
      'Dark Theme',
      'As System',
    ];

    String selectedTheme = 'As System';
    switch (currentThemeMode) {
      case ThemeMode.light:
        selectedTheme = 'Light Theme';
        break;
      case ThemeMode.dark:
        selectedTheme = 'Dark Theme';
        break;
      case ThemeMode.system:
        selectedTheme = 'As System';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      // Divider removed as requested
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Theme',
            style: TextStyle(
              color: AppColors.inverseScaffoldBackground(context),
              fontSize: 16.sp,
            ),
          ),
          DropdownButton2<String>(
            value: selectedTheme,
            items: themeOptions.map((String theme) {
              return DropdownMenuItem<String>(
                value: theme,
                child: Text(
                  theme,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.inverseScaffoldBackground(context),
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                late ThemeMode newMode;
                switch (newValue) {
                  case 'Light Theme':
                    newMode = ThemeMode.light;
                    break;
                  case 'Dark Theme':
                    newMode = ThemeMode.dark;
                    break;
                  case 'As System':
                    newMode = ThemeMode.system;
                    break;
                  default:
                    newMode = ThemeMode.system;
                }
                ref.read(appModeProvider.notifier).setMode(newMode);
              }
            },
            buttonStyleData: ButtonStyleData(
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primaryColor(context)),
                color: AppColors.scaffoldBackground(context),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.scaffoldBackground(context),
              ),
            ),
            iconStyleData: IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: AppColors.primaryColor(context),
              ),
            ),
            underline: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
