import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_barber/core/router/routes.dart';
import 'package:my_barber/core/themes/app_colors.dart';
import 'package:my_barber/core/widgets/app_button.dart';
import 'package:my_barber/features/on_boarding/data/models/onboarding_model.dart';
import 'package:my_barber/features/on_boarding/logic/onboarding_provider.dart';

class OnboardingContent extends ConsumerStatefulWidget {
  const OnboardingContent({super.key, required this.onBoardingData});

  final List<OnBoardingModel> onBoardingData;

  @override
  ConsumerState<OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends ConsumerState<OnboardingContent> {
  int _currentPage = 0;

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;

          // Build PageView Slider
          Widget buildImageSlider() {
            return PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.onBoardingData.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  widget.onBoardingData[index].imagePath,
                  width: double.infinity,
                  fit: BoxFit.contain, // Safely fit without squishing
                );
              },
            );
          }

          // Build Bottom Sheet Action Box
          Widget buildBottomContent() {
            return Container(
              height: isLandscape ? double.infinity : null, // fill height in landscape
              constraints: isLandscape ? null : BoxConstraints(minHeight: constraints.maxHeight * 0.35),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.black
                    : AppColors.white,
                borderRadius: isLandscape
                    ? BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        bottomLeft: Radius.circular(24.r),
                      )
                    : BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: isLandscape ? MainAxisSize.max : MainAxisSize.min,
                  spacing: 16.h,
                  children: [
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0.2, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        key: ValueKey<int>(_currentPage),
                        spacing: 8.h,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.onBoardingData[_currentPage].title,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            widget.onBoardingData[_currentPage].description,
                            style: TextStyle(fontSize: 12.sp),
                            textAlign: TextAlign.start,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.onBoardingData.length,
                        (index) => AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          height: 8.h,
                          width: _currentPage == index ? 32.w : 8.w,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Theme.of(context).primaryColor
                                : (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white70
                                    : Colors.black26),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ),
                    AppButton(
                      onTap: () {
                        if (_currentPage < widget.onBoardingData.length - 1) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          ref
                              .read(onBoardingProvider.notifier)
                              .setOnBoardingCompleted();
                          context.go(AppRoutes.login);
                        }
                      },
                      text: _currentPage == widget.onBoardingData.length - 1
                          ? 'Get Started'
                          : 'Next',
                    ),
                  ],
                ),
              ),
            );
          }

          if (isLandscape) {
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: buildImageSlider(),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: buildBottomContent(),
                ),
              ],
            );
          }

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 40.h, bottom: 20.h),
                  child: buildImageSlider(),
                ),
              ),
              buildBottomContent(),
            ],
          );
        },
      ),
    );
  }
}
