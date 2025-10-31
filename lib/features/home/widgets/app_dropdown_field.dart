// lib/core/widgets/app_dropdown_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';

class DropdownItem<T> {
  final T value;
  final String label;

  DropdownItem({required this.value, required this.label});
}

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final String? hintText;
  final List<DropdownItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final String? prefixIconPath;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.selectedValue,
    required this.onChanged,
    this.hintText,
    this.validator,
    this.prefixIconPath,
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
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: AppTypography.captionMedium.copyWith(color: AppColorsNeutral.neutral700),
          ),
          const SizedBox(height: AppSpacing.spacing4),
        ],
        DropdownButtonFormField<T>(
          value: selectedValue,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item.value,
              child: Text(
                item.label,
                style: AppTypography.contentRegular.copyWith(color: AppColorsNeutral.neutral900),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          // Estilo do dropdown em si
          style: AppTypography.contentRegular.copyWith(color: AppColorsNeutral.neutral900),
          icon: Padding( // Ícone da seta padrão
             padding: const EdgeInsets.only(right: AppSpacing.spacing8),
             child: SvgPicture.asset(
               'assets/icons/arrow_down.svg', // Crie este SVG!
               height: 16,
               width: 16,
               colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.contentRegular.copyWith(color: AppColorsNeutral.neutral400),
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
             prefixIconConstraints: const BoxConstraints(minHeight: 20, minWidth: 20),
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
              borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
            ),
            ),
          dropdownColor: AppColorsNeutral.neutral0,
           borderRadius: AppRadius.radius8,
        ),
      ],
    );
  }
}