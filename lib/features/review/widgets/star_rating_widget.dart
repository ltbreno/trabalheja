import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';

class StarRatingWidget extends StatefulWidget {
  final int starCount;
  final Function(int rating) onRatingChanged;

  const StarRatingWidget({
    super.key,
    this.starCount = 5,
    required this.onRatingChanged,
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  int _rating = 0; // 0 = sem nota, 1 = 1 estrela, etc.

  Widget _buildStar(int index) {
    // Caminhos dos ícones
    final String starIconPath = 'assets/icons/star.svg';
    
    // Cor amarela para estrelas selecionadas
    final Color selectedColor = AppColorsAlert.alert400; // Amarelo
    // Cor cinza para estrelas não selecionadas
    final Color unselectedColor = AppColorsNeutral.neutral300; // Cinza claro

    bool isSelected = index < _rating;

    return IconButton(
      onPressed: () {
        setState(() {
          _rating = index + 1; // Define a nota
          widget.onRatingChanged(_rating); // Chama o callback
        });
      },
      icon: SvgPicture.asset(
        starIconPath, // Usar sempre o ícone de estrela cheia
        height: 32,
        width: 32,
        colorFilter: ColorFilter.mode(
          isSelected ? selectedColor : unselectedColor, // Apenas muda a cor
          BlendMode.srcIn,
        ),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Centraliza as estrelas
      children: List.generate(widget.starCount, (index) => _buildStar(index)),
    );
  }
}
