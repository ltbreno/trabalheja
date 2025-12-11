import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/core/locale/locale_cubit.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final isPortuguese = locale.languageCode == 'pt';
        
        return PopupMenuButton<String>(
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColorsNeutral.neutral0,
          onSelected: (value) {
            if (value == 'pt') {
              context.read<LocaleCubit>().setPortuguese();
            } else {
              context.read<LocaleCubit>().setEnglish();
            }
          },
          itemBuilder: (context) => [
            _buildMenuItem(
              value: 'pt',
              label: 'PT',
              flagAsset: 'assets/icons/flag_brazil.svg',
              isSelected: isPortuguese,
            ),
            _buildMenuItem(
              value: 'en',
              label: 'EN',
              flagAsset: 'assets/icons/flag_usa.svg',
              isSelected: !isPortuguese,
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing8,
              vertical: AppSpacing.spacing4,
            ),
            decoration: BoxDecoration(
              color: AppColorsNeutral.neutral100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SvgPicture.asset(
                    isPortuguese 
                        ? 'assets/icons/flag_brazil.svg' 
                        : 'assets/icons/flag_usa.svg',
                    width: 20,
                    height: 14,
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing4),
                Text(
                  isPortuguese ? 'PT' : 'EN',
                  style: AppTypography.captionBold.copyWith(
                    color: AppColorsNeutral.neutral800,
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColorsNeutral.neutral600,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required String label,
    required String flagAsset,
    required bool isSelected,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SvgPicture.asset(
              flagAsset,
              width: 24,
              height: 16,
            ),
          ),
          const SizedBox(width: AppSpacing.spacing12),
          Text(
            label,
            style: AppTypography.contentMedium.copyWith(
              color: isSelected 
                  ? AppColorsPrimary.primary700 
                  : AppColorsNeutral.neutral800,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          if (isSelected)
            Icon(
              Icons.check,
              size: 18,
              color: AppColorsPrimary.primary700,
            ),
        ],
      ),
    );
  }
}
