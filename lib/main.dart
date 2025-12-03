import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/app/view/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jymcnfzlxcfaahzquezb.supabase.co',
    anonKey: 'sb_publishable_pK2vnLhlvxpgaEbnCPK7Rg_0xmetAbm',
  );
  runApp(const App());
}