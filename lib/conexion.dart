import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseBD {
  static final SupabaseBD _instance = SupabaseBD._internal();

  factory SupabaseBD() {
    return _instance;
  }

  SupabaseBD._internal();

  Future<void> conexionSupa() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url: 'https://bwgyppoavqimjggvlnjw.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3Z3lwcG9hdnFpbWpnZ3Zsbmp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ2NjA4NjIsImV4cCI6MjA3MDIzNjg2Mn0.I6hcHQBPR9f59F66u_6xbsYN9lKjx6LQfS0-2UwvogI',
    );
  }
}
