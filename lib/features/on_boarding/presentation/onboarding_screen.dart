import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_barber/features/on_boarding/logic/onboarding_provider.dart';
import 'package:my_barber/features/on_boarding/presentation/widgets/onboarding_background.dart';
import 'package:my_barber/features/on_boarding/presentation/widgets/onboarding_content.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final onBoardingData = ref.watch(onBoardingProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).brightness,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            const OnboardingBackground(),
            OnboardingContent(onBoardingData: onBoardingData),
          ],
        ),
      ),
    );
  }
}
