import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:my_barber/features/home/logic/home_providers.dart';
// import 'package:my_barber/features/home/presentation/widgets/home_ad_banner.dart';
import 'package:my_barber/features/home/presentation/widgets/home_nearest_new.dart';
import 'package:my_barber/features/home/presentation/widgets/home_recommended_new.dart';
import 'package:my_barber/features/home/presentation/widgets/home_search.dart';
import 'package:my_barber/features/home/presentation/widgets/home_welcome_message.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _dialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra == 'register_success' && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Account Created', textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie/success.json',
                  width: 150.w,
                  height: 150.h,
                  repeat: false,
                ),
                SizedBox(height: 16.h),
                const Text(
                  'Your account has been successfully created.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataNotifierProvider);

    return SingleChildScrollView(
      child: Column(
        spacing: 16.h,
        children: [
          SizedBox(height: 24.h),
          const HomeWelcomeMessage(),
          // const HomeAds(),
          const HomeSearch(),

          // Centralized loading/error/data handling
          homeDataAsync.when(
            data: (homeData) {
              // Pass data down to presentation components
              return Column(
                spacing: 16.h,
                children: [
                  HomeMostRecommendedBarbersNew(
                    recommendedShops: homeData.recommended,
                  ),
                  HomeNearestBarbersNew(nearestShops: homeData.nearest),
                ],
              );
            },
            loading: () => SizedBox(
              height: 400.h,
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Failed to load shops',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Please check your internet connection or location access, then try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      // Refresh the provider
                      ref.invalidate(homeDataNotifierProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
