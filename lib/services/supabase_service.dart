import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://mbwvfjoayhfnsiabrgcf.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1id3Zmam9heWhmbnNpYWJyZ2NmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1ODIwNTksImV4cCI6MjA5ODE1ODA1OX0.Fi9N-Jh8e3QwevUXr-ZQlPIrdhFuyyZM8UgL0iMQRnw',
    );
  }

  static SupabaseClient get client =>
      Supabase.instance.client;
}