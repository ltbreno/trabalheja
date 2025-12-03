// lib/features/chat/view/chat_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/chat/widgets/message_bubble.dart';

class ChatDetailPage extends StatefulWidget {
  final String conversationId;
  final String? otherParticipantId;
  final String name;
  final String initials;

  const ChatDetailPage({
    super.key,
    required this.conversationId,
    this.otherParticipantId,
    required this.name,
    required this.initials,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _messageController = TextEditingController();
  final _supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  RealtimeChannel? _realtimeChannel;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser?.id;
    _loadMessages();
    _subscribeToMessages();
    
    // Listener para enviar ao pressionar Enter
    _messageController.addListener(() {
      // Será tratado no onChanged ou no botão
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _supabase
          .from('messages')
          .select('''
            *,
            sender:profiles!messages_sender_id_fkey (
              id,
              full_name
            )
          ''')
          .eq('conversation_id', widget.conversationId)
          .order('created_at', ascending: false);

      setState(() {
        _messages = List<Map<String, dynamic>>.from(messages);
        _isLoading = false;
      });

      // Marcar mensagens como lidas
      if (widget.otherParticipantId != null) {
        await _markMessagesAsRead();
      }

      // Scroll para o topo (última mensagem)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    } catch (e) {
      print('Erro ao carregar mensagens: $e');
      setState(() => _isLoading = false);
    }
  }

  void _subscribeToMessages() {
    // Escutar novas mensagens em tempo real
    _realtimeChannel = _supabase
        .channel('messages_${widget.conversationId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: widget.conversationId,
          ),
          callback: (payload) {
            final newMessage = payload.newRecord;
            
            // Buscar dados do sender
            _supabase
                .from('profiles')
                .select('id, full_name')
                .eq('id', newMessage['sender_id'])
                .maybeSingle()
                .then((sender) {
                  setState(() {
                    _messages.insert(0, {
                      ...newMessage,
                      'sender': sender,
                    });
                  });

                  // Marcar como lida se não for minha mensagem
                  if (newMessage['sender_id'] != _currentUserId) {
                    _markMessagesAsRead();
                  }

                  // Scroll para nova mensagem
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                });
          },
        )
        .subscribe();
  }

  Future<void> _markMessagesAsRead() async {
    if (_currentUserId == null || widget.otherParticipantId == null) return;

    try {
      await _supabase
          .from('messages')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('conversation_id', widget.conversationId)
          .eq('sender_id', widget.otherParticipantId!)
          .isFilter('read_at', null);
    } catch (e) {
      print('Erro ao marcar mensagens como lidas: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending || _currentUserId == null) return;

    setState(() => _isSending = true);

    try {
      await _supabase.from('messages').insert({
        'conversation_id': widget.conversationId,
        'sender_id': _currentUserId,
        'content': text,
      });

      _messageController.clear();
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar mensagem: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSending = false);
    }
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
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColorsPrimary.primary700,
                      ),
                    )
                  : _messages.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhuma mensagem ainda',
                            style: AppTypography.contentRegular.copyWith(
                              color: AppColorsNeutral.neutral500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.all(AppSpacing.spacing16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final sender = message['sender'] as Map<String, dynamic>?;
                            final senderId = sender?['id'] as String?;
                            final isSender = senderId == _currentUserId;
                            final content = message['content'] as String? ?? '';

                            return MessageBubble(
                              text: content,
                              isSender: isSender,
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColorsPrimary.primary50,
      elevation: 1,
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
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_isSending,
              decoration: InputDecoration(
                hintText: 'Digite sua mensagem...',
                hintStyle: AppTypography.contentRegular.copyWith(
                  color: AppColorsNeutral.neutral400,
                ),
                filled: true,
                fillColor: AppColorsNeutral.neutral50,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.spacing12,
                  horizontal: AppSpacing.spacing16,
                ),
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
              style: AppTypography.contentRegular.copyWith(
                color: AppColorsNeutral.neutral900,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: AppSpacing.spacing12),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: AppColorsPrimary.primary900,
              padding: const EdgeInsets.all(AppSpacing.spacing12),
              disabledBackgroundColor: AppColorsNeutral.neutral300,
            ),
            icon: _isSending
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColorsNeutral.neutral0,
                    ),
                  )
                : SvgPicture.asset(
                    'assets/icons/send.svg',
                    height: 24,
                    width: 24,
                    colorFilter: ColorFilter.mode(
                      AppColorsNeutral.neutral0,
                      BlendMode.srcIn,
                    ),
                  ),
            onPressed: _isSending ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}
