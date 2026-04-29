import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_barber/core/error_handling/failure.dart';
import 'package:my_barber/features/register/data/models/register_model.dart';
import 'package:my_barber/features/register/logic/register_providers.dart';

final registerProvider = NotifierProvider<RegisterNotifier, AsyncValue<void>>(
  RegisterNotifier.new,
);

class RegisterNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> register({required RegisterModel registerModel}) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(registerRepoProvider);
      await repo.signUp(registerModel: registerModel);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      // Repo throws Failure, so we cast if possible or handle generic
      if (e is Failure) {
        state = AsyncValue.error(e.message, st);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> verifyOtp({required String email, required String token}) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(registerRepoProvider);
      await repo.verifyOtp(email: email, token: token);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      if (e is Failure) {
        state = AsyncValue.error(e.message, st);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> resendOtp({required String email}) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(registerRepoProvider);
      await repo.resendOtp(email: email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      if (e is Failure) {
        state = AsyncValue.error(e.message, st);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }
}
