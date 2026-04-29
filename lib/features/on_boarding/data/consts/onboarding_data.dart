import 'package:my_barber/core/assets/app_assets.dart';
import 'package:my_barber/features/on_boarding/data/models/onboarding_model.dart';

final List<OnBoardingModel> onBoardingData = [
  OnBoardingModel(
    title: 'Welcome To Halaqi',
    description:
        'Discover the finest premium grooming experiences in your city with a single tap. Your perfect look awaits!',
    imagePath: AppAssets.onboarding1Image,
  ),
  OnBoardingModel(
    title: 'Find Your Perfect Barber',
    description:
        'Locate top-rated barbershops near you instantly. seamless booking for a sharp, confident style.',
    imagePath: AppAssets.onboarding2Image,
  ),
  OnBoardingModel(
    title: 'Style at Your Fingertips',
    description:
        'With Halaqi, effortless booking and elite grooming are just a click away. Elevate your daily look.',
    imagePath: AppAssets.onboarding3Image,
  ),
];
