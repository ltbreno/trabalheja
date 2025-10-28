// lib/core/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/src/services/text_formatter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? prefixIconPath; // Caminho para o SVG do ícone inicial
  final String? suffixIconPath; // Caminho para o SVG do ícone final
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.prefixIconPath,
    this.suffixIconPath,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = AppColorsNeutral.neutral500;
    final Color borderColor = AppColorsNeutral.neutral300;
    final Color focusedBorderColor = AppColorsPrimary.primary500;
    final Color fillColor = AppColorsNeutral.neutral50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.captionMedium.copyWith(color: AppColorsNeutral.neutral700),
        ),
        const SizedBox(height: AppSpacing.spacing4),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          focusNode: focusNode,
          inputFormatters: inputFormatters,
          style: AppTypography.contentRegular.copyWith(color: AppColorsNeutral.neutral900), // Estilo do texto digitado
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.contentRegular.copyWith(color: AppColorsNeutral.neutral400), // Estilo do placeholder
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppSpacing.spacing12,
              horizontal: AppSpacing.spacing16,
            ),
            prefixIcon: prefixIconPath != null
                ? Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.spacing12, right: AppSpacing.spacing8),
                    child: SvgPicture.asset(
                      prefixIconPath!,
                      height: 20,
                      width: 20,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  )
                : null,
             prefixIconConstraints: const BoxConstraints(minHeight: 20, minWidth: 20), // Garante tamanho mínimo
             suffixIcon: suffixIconPath != null
                ? InkWell(
                     onTap: onSuffixIconTap,
                     borderRadius: AppRadius.radiusRound,
                     child: Padding(
                       padding: const EdgeInsets.only(left: AppSpacing.spacing8, right: AppSpacing.spacing12),
                       child: SvgPicture.asset(
                         suffixIconPath!,
                         height: 20,
                         width: 20,
                         colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                       ),
                     ),
                   )
                : null,
             suffixIconConstraints: const BoxConstraints(minHeight: 20, minWidth: 20),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radius8,
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radius8,
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radius8,
              borderSide: BorderSide(color: focusedBorderColor, width: 1.5), // Borda mais grossa ao focar
            ),
          ),
        ),
      ],
    );
  }
}