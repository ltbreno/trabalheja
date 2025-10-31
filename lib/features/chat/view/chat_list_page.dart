import 'package:flutter/material.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/chat/view/chat_detail_page.dart';
import 'package:trabalheja/features/chat/widgets/chat_list_tile.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Dados mocados para a lista
  final List<Map<String, dynamic>> _chatList = [
    {
      "name": "José Carlos Pereira da Silva Oliveira",
      "initials": "JC",
      "lastMessage": "Maravilha, te aguardo...",
      "time": "10min",
      "unreadCount": 1,
    },
    {
      "name": "Maria Antônia",
      "initials": "MA",
      "lastMessage": "Ok, combinado!",
      "time": "1h",
      "unreadCount": 0,
    },
    {
      "name": "Serviço de Pintura",
      "initials": "SP",
      "lastMessage": "Você: [Proposta enviada]",
      "time": "Ontem",
      "unreadCount": 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Esta tela não precisa de AppBar própria se já estiver no MainAppShell
    // Mas a imagem de referência mostra um "Voltar", então vamos adicionar uma.
    return Scaffold(
      backgroundColor: AppColorsPrimary.primary50,
      appBar: AppBar(
        backgroundColor: AppColorsPrimary.primary50,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColorsNeutral.neutral900),
          onPressed: () {
            // TODO: Implementar lógica de voltar (talvez fechar o app se for root)
            // Se estiver dentro do MainAppShell, talvez não precise de 'Voltar'
          },
        ),
        title: Text(
          'Chat',
          style: AppTypography.heading2.copyWith(
            color: AppColorsPrimary.primary900, // Título Roxo
          ),
        ),
        centerTitle: false, // Alinhar à esquerda
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de Pesquisa
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing24,
                vertical: AppSpacing.spacing16,
              ),
              child: AppTextField(
                label: '', // Sem label visível
                hintText: 'Pesquisar',
                controller: _searchController,
                prefixIconPath: 'assets/icons/search.svg', // Ícone de busca
                onChanged: (value) {
                  // TODO: Implementar lógica de filtro da lista
                  print('Buscando por: $value');
                },
              ),
            ),
            
            // Lista de Conversas
            Expanded(
              child: ListView.separated(
                itemCount: _chatList.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColorsNeutral.neutral100,
                  indent: AppSpacing.spacing24,
                  endIndent: AppSpacing.spacing24,
                ),
                itemBuilder: (context, index) {
                  final chat = _chatList[index];
                  return ChatListTile(
                    initials: chat['initials'],
                    name: chat['name'],
                    lastMessage: chat['lastMessage'],
                    time: chat['time'],
                    unreadCount: chat['unreadCount'],
                    onTap: () {
                      // Navegar para a tela de detalhes do chat
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailPage(
                            name: chat['name'],
                            initials: chat['initials'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}