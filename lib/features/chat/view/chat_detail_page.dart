import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/chat/widgets/message_bubble.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';

class ChatDetailPage extends StatefulWidget {
  final String name;
  final String initials;

  const ChatDetailPage({
    super.key,
    required this.name,
    required this.initials,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _messageController = TextEditingController();

  // Lista de mensagens mocada
  final List<Map<String, dynamic>> _messages = [
    {"isSender": false, "text": "Maravilha, te aguardo..."},
    {"isSender": true, "text": "Combinado. Estarei aí às 14h."},
    {"isSender": false, "text": "Você pode trazer a furadeira?"},
    {
      "isSender": true,
      "text": "Posso sim. Levo todo o material necessário."
    },
    {
      "isSender": true,
      "text":
          "O valor fica R\$ 120,00, conforme conversamos. Está tudo certo?"
    },
    {"isSender": false, "text": "Perfeito, pode confirmar."},
  ];

  void _sendMessage() {
    final text = _messageController.text;
    if (text.isEmpty) return;

    // TODO: Adicionar lógica de envio ao Supabase (Realtime)
    setState(() {
      _messages.insert(0, {"isSender": true, "text": text});
      _messageController.clear();
    });
    print('Mensagem enviada: $text');
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsPrimary.primary50,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            // Lista de Mensagens
            Expanded(
              child: ListView.builder(
                reverse: true, // Começa de baixo para cima
                padding: const EdgeInsets.all(AppSpacing.spacing16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return MessageBubble(
                    text: message['text'],
                    isSender: message['isSender'],
                  );
                },
              ),
            ),
            // Barra de Input
            _buildInputBar(context),
          ],
        ),
      ),
    );
  }

  // AppBar customizada
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColorsPrimary.primary50,
      elevation: 1, // Sombra leve
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColorsNeutral.neutral900),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColorsPrimary.primary900.withOpacity(0.1),
            child: Text(
              widget.initials,
              style: AppTypography.contentBold
                  .copyWith(color: AppColorsPrimary.primary900),
            ),
          ),
          const SizedBox(width: AppSpacing.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: AppTypography.contentBold
                      .copyWith(color: AppColorsNeutral.neutral900),
                  overflow: TextOverflow.ellipsis,
                ),
                InkWell(
                  onTap: () {
                    // TODO: Navegar para o perfil do usuário
                    print('Ver perfil');
                  },
                  child: Text(
                    'Ver perfil',
                    style: AppTypography.captionRegular
                        .copyWith(color: AppColorsPrimary.primary700),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Barra de input de mensagem
  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing16,
        vertical: AppSpacing.spacing12,
      ),
      decoration: BoxDecoration(
        color: AppColorsPrimary.primary50,
        border: Border(
          top: BorderSide(color: AppColorsNeutral.neutral100, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Campo de Texto
          Expanded(
            child: AppTextField(
              label: '', // Sem label
              hintText: 'Digite sua mensagem...',
              controller: _messageController,
              // Reduzindo o padding interno para ficar mais compacto
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.spacing12,
                horizontal: AppSpacing.spacing16,
              ),
              // Remover bordas padrão para parecer mais com um chat
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusRound,
                borderSide: BorderSide(color: AppColorsNeutral.neutral200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusRound,
                borderSide: BorderSide(color: AppColorsNeutral.neutral200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusRound,
                borderSide: BorderSide(color: AppColorsPrimary.primary500),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.spacing12),
          // Botão Enviar
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: AppColorsPrimary.primary900,
              padding: const EdgeInsets.all(AppSpacing.spacing12),
            ),
            icon: SvgPicture.asset(
              'assets/icons/send.svg',
              height: 24,
              width: 24,
              colorFilter:
                  ColorFilter.mode(AppColorsNeutral.neutral0, BlendMode.srcIn),
            ),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}