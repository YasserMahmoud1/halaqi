import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/core/widgets/app_button.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _nameController = TextEditingController(text: 'Joe Samanta');
  final _emailController = TextEditingController(text: '5mesamanta@gmail.com');
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _sendHelpRequest() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || email.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your request was sent successfully.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.inverseScaffoldBackground(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help',
          style: TextStyle(
            color: AppColors.inverseScaffoldBackground(context),
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Help Icon and Title
            Center(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.help_outline,
                      size: 48.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'How we can help\nyou today ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primaryColor(context),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Please enter your personal data and\ndescribe your case in detail of something\nhappens',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textGrey(context),
                      fontSize: 12.sp,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            // Name Field
            _buildTextField(
              label: 'Name',
              controller: _nameController,
              prefixIcon: Icons.person_outline,
            ),
            SizedBox(height: 16.h),
            // Email Field
            _buildTextField(
              label: 'Email',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
            ),
            SizedBox(height: 16.h),
            // Description Field
            _buildTextField(
              label: 'Describe',
              controller: _descriptionController,
              prefixIcon: null,
              maxLines: 5,
              hint: 'Enter a description here',
            ),
            SizedBox(height: 32.h),
            AppButton(text: 'Send', onTap: _sendHelpRequest),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? prefixIcon,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.inverseScaffoldBackground(context),
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.tffBorderColor(context),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              color: AppColors.inverseScaffoldBackground(context),
              fontSize: 14.sp,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textGrey(context),
                fontSize: 14.sp,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: AppColors.inverseScaffoldBackground(context),
                      size: 20.sp,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
