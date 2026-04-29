import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteAccountState {
  final bool isLoading;
  final String? errorMessage;
  final bool isDeleted;

  const DeleteAccountState({
    this.isLoading = false,
    this.errorMessage,
    this.isDeleted = false,
  });

  DeleteAccountState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isDeleted,
  }) {
    return DeleteAccountState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

class DeleteAccountNotifier extends Notifier<DeleteAccountState> {
  @override
  DeleteAccountState build() => const DeleteAccountState();

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No authenticated user found.',
        );
        return;
      }

      // Call Supabase Edge Function to delete user and all their data
      // This runs server-side with admin privileges so it can delete
      // the auth user record and related database rows atomically.
      await supabase.functions.invoke(
        'delete-account',
        body: {
          'user_id': supabase.auth.currentUser!.id,
          'reason': 'User requested account deletion',
        },
      );


      // Sign out locally
      await supabase.auth.signOut();

      // Clear all local preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      state = state.copyWith(isLoading: false, isDeleted: true);
    } on FunctionException catch (e) {
      final details = e.details?.toString() ?? '';
      final message = details.toLowerCase().contains('delete-account')
          ? 'Account deletion service is not available right now. Please try again later or contact support.'
          : (details.isNotEmpty
                ? details
                : 'Failed to delete account. Please try again.');
      state = state.copyWith(isLoading: false, errorMessage: message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }
}

final deleteAccountProvider =
    NotifierProvider<DeleteAccountNotifier, DeleteAccountState>(
      DeleteAccountNotifier.new,
    );
