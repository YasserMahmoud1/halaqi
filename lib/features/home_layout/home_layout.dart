import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_barber/core/router/routes.dart';
import 'package:my_barber/features/home/logic/home_providers.dart';

class HomeLayout extends ConsumerWidget {
  const HomeLayout({super.key, required this.child});
  final Widget child;

  int _locationToIndex(String location) {
    if (location.startsWith(AppRoutes.booking)) return 1;
    if (location.startsWith(AppRoutes.profile)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _locationToIndex(location),
          onTap: (index) {
            switch (index) {
              case 0:
                ref.invalidate(homeDataNotifierProvider);
                context.go(AppRoutes.home);
                break;
              case 1:
                context.go(AppRoutes.booking);
                break;
              case 2:
                context.go(AppRoutes.profile);
                break;
            }
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: "Bookings",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SafeArea(child: child),
          ),
        ),
      ),
    );
  }
}
