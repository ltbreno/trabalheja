// lib/features/chat/view/chat_list_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _subscribeToConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Buscar conversas onde o usuário é participante
      final conversations = await _supabase
          .from('conversations')
          .select('''
            *,
            participant1:profiles!conversations_participant1_id_fkey (
              id,
              full_name,
              profile_picture_url
            ),
            participant2:profiles!conversations_participant2_id_fkey (
              id,
              full_name,
              profile_picture_url
            )
          ''')
          .or('participant1_id.eq.${user.id},participant2_id.eq.${user.id}')
          .order('updated_at', ascending: false);

      // Buscar última mensagem e contagem de não lidas para cada conversa
      final enrichedConversations = <Map<String, dynamic>>[];
      
      for (var conv in conversations) {
        final participant1 = conv['participant1'] as Map<String, dynamic>?;
        final participant2 = conv['participant2'] as Map<String, dynamic>?;
        
        // Determinar o outro participante
        final otherParticipant = participant1?['id'] == user.id 
            ? participant2 
            : participant1;
        
        final otherName = otherParticipant?['full_name'] as String? ?? 'Usuário';
        final otherId = otherParticipant?['id'] as String?;
        
        // Buscar última mensagem
        final lastMessageData = await _supabase
            .from('messages')
            .select('content, created_at, sender_id')
            .eq('conversation_id', conv['id'])
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        // Contar mensagens não lidas (mensagens do outro participante não lidas)
        int unreadCount = 0;
        if (otherId != null) {
          final unreadMessages = await _supabase
              .from('messages')
              .select('id')
              .eq('conversation_id', conv['id'])
              .eq('sender_id', otherId)
              .isFilter('read_at', null);
          
          unreadCount = (unreadMessages as List).length;
        }

        final lastMessage = lastMessageData?['content'] as String?;
        final lastMessageTime = lastMessageData?['created_at'] as String?;
        final isSender = lastMessageData?['sender_id'] == user.id;
        
        enrichedConversations.add({
          ...conv,
          'other_participant': otherParticipant,
          'other_name': otherName,
          'other_initials': _getInitials(otherName),
          'last_message': lastMessage != null 
              ? (isSender ? 'Você: $lastMessage' : lastMessage)
              : null,
          'last_message_time': lastMessageTime,
          'unread_count': unreadCount,
        });
      }

      setState(() {
        _conversations = enrichedConversations;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar conversas: $e');
      setState(() => _isLoading = false);
    }
  }

  void _subscribeToConversations() {
    // Escutar mudanças nas mensagens para atualizar lista
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _supabase
        .channel('conversations_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            // Recarregar conversas quando nova mensagem chegar (apenas se não for do próprio usuário)
            if (payload.newRecord['sender_id'] != user.id) {
              _loadConversations();
            }
          },
        )
        .subscribe();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Agora';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}min';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d';
      } else {
        return '${date.day}/${date.month}';
      }
    } catch (e) {
      return '';
    }
  }

  List<Map<String, dynamic>> _getFilteredConversations() {
    if (_searchQuery.isEmpty) {
      return _conversations;
    }
    
    return _conversations.where((conv) {
      final name = conv['other_name'] as String? ?? '';
      return name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsPrimary.primary50,
      appBar: AppBar(
        backgroundColor: AppColorsPrimary.primary50,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColorsNeutral.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chat',
          style: AppTypography.heading2.copyWith(
            color: AppColorsPrimary.primary900,
          ),
        ),
        centerTitle: false,
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
                label: '',
                hintText: 'Pesquisar',
                controller: _searchController,
                prefixIconPath: 'assets/icons/search.svg',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            
            // Lista de Conversas
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColorsPrimary.primary700,
                      ),
                    )
                  : _getFilteredConversations().isEmpty
                      ? Center(
                          child: Text(
                            'Nenhuma conversa encontrada',
                            style: AppTypography.contentRegular.copyWith(
                              color: AppColorsNeutral.neutral500,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadConversations,
                          color: AppColorsPrimary.primary700,
                          child: ListView.separated(
                            itemCount: _getFilteredConversations().length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColorsNeutral.neutral100,
                              indent: AppSpacing.spacing24,
                              endIndent: AppSpacing.spacing24,
                            ),
                            itemBuilder: (context, index) {
                              final conversation = _getFilteredConversations()[index];
                              final conversationId = conversation['id'] as String;
                              final otherParticipant = conversation['other_participant'] as Map<String, dynamic>?;
                              
                              return ChatListTile(
                                initials: conversation['other_initials'] as String? ?? 'U',
                                name: conversation['other_name'] as String? ?? 'Usuário',
                                lastMessage: conversation['last_message'] as String? ?? 'Sem mensagens',
                                time: _formatTime(conversation['last_message_time'] as String?),
                                unreadCount: conversation['unread_count'] as int? ?? 0,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatDetailPage(
                                        conversationId: conversationId,
                                        otherParticipantId: otherParticipant?['id'] as String?,
                                        name: conversation['other_name'] as String? ?? 'Usuário',
                                        initials: conversation['other_initials'] as String? ?? 'U',
                                      ),
                                    ),
                                  ).then((_) {
                                    // Recarregar ao voltar para atualizar contador
                                    _loadConversations();
                                  });
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
