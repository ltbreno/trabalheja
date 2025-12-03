import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';

class ProposalInfoTile extends StatelessWidget {
  final String iconPath;
  final String text;
  final TextStyle? style;

  const ProposalInfoTile({
    super.key,
    required this.iconPath,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    // Estilo padrão se nenhum for fornecido
    final textStyle = style ?? AppTypography.captionRegular.copyWith(color: AppColorsNeutral.neutral600);

    return Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: SvgPicture.asset(
            iconPath,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(AppColorsPrimary.primary900, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: AppSpacing.spacing8),
        Expanded(
          child: Text(
            text,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
