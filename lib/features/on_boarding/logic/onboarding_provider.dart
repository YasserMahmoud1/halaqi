import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_barber/core/shared_preferences/shared_preferences_provider.dart';
import 'package:my_barber/features/on_boarding/data/consts/onboarding_data.dart';
import 'package:my_barber/features/on_boarding/data/models/onboarding_model.dart';

final onBoardingProvider =
    NotifierProvider<OnBoardingNotifier, List<OnBoardingModel>>(
      OnBoardingNotifier.new,
    );

class OnBoardingNotifier extends Notifier<List<OnBoardingModel>> {
  @override
  List<OnBoardingModel> build() {
    return onBoardingData;
  }

  Future<void> setOnBoardingCompleted() async {
    await ref.read(sharedPrefsServiceProvider).setOnboardingSkipped(true);
    ref.invalidate(isOnboardingCompletedProvider);
  }
}

final isOnboardingCompletedProvider = Provider<bool>((ref) {
  final sharedPrefsService = ref.watch(sharedPrefsServiceProvider);
  return sharedPrefsService.onboardingSkipped;
});
