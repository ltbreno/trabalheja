import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/view/home_page.dart';
import 'package:trabalheja/features/account/view/account_page.dart';
import 'package:trabalheja/features/proposals/view/proposals_page.dart';
import 'package:trabalheja/features/chat/view/chat_page.dart';

//TODO: Adicionar as outras telas
// FreelancersPage(), // 1: Freelancers

/// Um "shell" principal para o app que gerencia a navegação
/// por barra inferior (BottomNavigationBar).
class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0; // Controla o índice da aba selecionada (inicia em Minha conta)

  // Lista de telas que serão exibidas
  static const List<Widget> _pages = <Widget>[
    HomePage(), // 0: Início
    // 1: Propostas
    ProposalsPage(),
    // 2: Chat
    ChatPage(),
    // 3: Minha conta
    AccountPage(),
  ];

  // Função chamada quando um item da barra é tocado
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Cores da barra de navegação
  final Color _selectedColor = AppColorsPrimary.primary900; // Roxo para selecionado
  final Color _unselectedColor = AppColorsNeutral.neutral500; // Cinza para não selecionado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Exibe a página correspondente ao índice selecionado
      // IndexedStack preserva o estado de cada página
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          // Item 1: Início
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/home.svg', // Certifique-se que este SVG existe
              height: 24,
              colorFilter: ColorFilter.mode(_unselectedColor, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/home.svg',
              height: 24,
              colorFilter: ColorFilter.mode(_selectedColor, BlendMode.srcIn),
            ),
            label: 'Início',
          ),
          // Item 2: Propostas
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/document.svg', // Ícone de propostas
              height: 24,
              colorFilter: ColorFilter.mode(_unselectedColor, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/document.svg',
              height: 24,
              colorFilter: ColorFilter.mode(_selectedColor, BlendMode.srcIn),
            ),
            label: 'Propostas',
          ),
          // Item 3: Chat
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/chat.svg', // Certifique-se que este SVG existe
              height: 24,
              colorFilter: ColorFilter.mode(_unselectedColor, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/chat.svg',
              height: 24,
              colorFilter: ColorFilter.mode(_selectedColor, BlendMode.srcIn),
            ),
            label: 'Chat',
          ),
          // Item 4: Minha conta
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/person.svg', // Certifique-se que este SVG existe
              height: 24,
              colorFilter: ColorFilter.mode(_unselectedColor, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/person.svg',
              height: 24,
              colorFilter: ColorFilter.mode(_selectedColor, BlendMode.srcIn),
            ),
            label: 'Minha conta',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Estilização para combinar com o design
        type: BottomNavigationBarType.fixed, // Mostra todos os labels
        backgroundColor: AppColorsNeutral.neutral0, // Fundo branco
        elevation: 10, // Sombra leve
        showUnselectedLabels: true,
        selectedItemColor: _selectedColor, // Cor do label selecionado
        unselectedItemColor: _unselectedColor, // Cor do label não selecionado
        selectedLabelStyle: AppTypography.footnoteBold.copyWith(color: _selectedColor), // Texto selecionado em negrito
        unselectedLabelStyle: AppTypography.footnoteRegular.copyWith(color: _unselectedColor), // Texto normal
      ),
    );
  }
}
