import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trabalheja/app/view/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carregar variáveis de ambiente do arquivo .env
  await dotenv.load(fileName: '.env');

  // Validar que as variáveis necessárias estão presentes
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseUrl.isEmpty) {
    throw Exception(
      'SUPABASE_URL não encontrada no .env. '
      'Por favor, configure o arquivo .env baseado no .env.example',
    );
  }

  if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
    throw Exception(
      'SUPABASE_ANON_KEY não encontrada no .env. '
      'Por favor, configure o arquivo .env baseado no .env.example',
    );
  }

  // Inicializar Supabase com credenciais do .env
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const App());
}