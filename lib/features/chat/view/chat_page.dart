import 'package:flutter/material.dart';
import 'chat_list_page.dart'; // Importe a nova ChatListPage

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // A tela ChatPage agora apenas serve como um wrapper para ChatListPage
    // Isso permite que o MainAppShell mude para esta "feature"
    // e o ChatListPage gerencie sua própria AppBar e estado.
    return const ChatListPage();
  }
}