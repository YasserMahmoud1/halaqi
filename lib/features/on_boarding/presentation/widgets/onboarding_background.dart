import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:my_barber/core/assets/app_assets.dart';
import 'package:my_barber/core/themes/app_colors.dart';

class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;
        return SizedBox(
          width: double.infinity,
          height: isLandscape ? constraints.maxHeight : constraints.maxHeight * 0.75,
          child: SvgPicture.asset(
            AppAssets.backgroundSvgImage,
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(
              Theme.of(context).brightness == Brightness.dark
                  ? AppColors.white
                  : AppColors.black,
              BlendMode.xor,
            ),
          ),
        );
      },
    );
  }
}
