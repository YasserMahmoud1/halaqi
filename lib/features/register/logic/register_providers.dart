import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_barber/core/supabase/supabase_provider.dart';
import 'package:my_barber/features/register/data/api/register_service.dart';
import 'package:my_barber/features/register/data/repo/register_repo.dart';


final authServiceProvider = Provider<RegisterService>((ref) {
  final supabase = ref.read(supabaseProvider);
  return RegisterService(supabase);
});


final registerRepoProvider = Provider<RegisterRepo>((ref) {
  final registerService = ref.read(authServiceProvider);
  return RegisterRepo(registerService);
});
