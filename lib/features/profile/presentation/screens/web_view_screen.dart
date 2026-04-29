import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  static const Set<String> _allowedHosts = {'www.halaqi.com', 'halaqi.com'};

  bool _isTrustedUri(Uri uri) {
    if (!uri.hasScheme || uri.scheme != 'https') {
      return false;
    }
    return _allowedHosts.contains(uri.host.toLowerCase());
  }

  @override
  void initState() {
    super.initState();
    final initialUri = Uri.tryParse(widget.url);
    if (initialUri == null || !_isTrustedUri(initialUri)) {
      _hasError = true;
      _isLoading = false;
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null || !_isTrustedUri(uri)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(initialUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor(context),
        foregroundColor: AppColors.scaffoldBackground(context),
        elevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.scaffoldBackground(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.scaffoldBackground(context),
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 64.sp,
                    color: AppColors.primaryColor(
                      context,
                    ).withValues(alpha: 0.5),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Unable to load page',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inverseScaffoldBackground(context),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Please check your internet connection\nand try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.inverseScaffoldBackground(
                        context,
                      ).withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _isLoading = true;
                      });
                      _controller.reload();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor(context),
                      foregroundColor: AppColors.scaffoldBackground(context),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            WebViewWidget(controller: _controller),
          if (_isLoading && !_hasError)
            Container(
              color: AppColors.scaffoldBackground(context),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primaryColor(context),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.inverseScaffoldBackground(
                          context,
                        ).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
