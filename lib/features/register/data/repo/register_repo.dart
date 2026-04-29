import 'package:my_barber/core/error_handling/app_error_handler.dart';
import 'package:my_barber/features/register/data/api/register_service.dart';
import 'package:my_barber/features/register/data/models/register_model.dart';


class RegisterRepo {
  final RegisterService _registerService;

  RegisterRepo(this._registerService);

  Future<void> signUp({required RegisterModel registerModel}) async {
    try {
      await _registerService.signUp(registerModel: registerModel);
    } catch (e) {
      throw AppErrorHandler.handle(e);
    }
  }

  Future<void> verifyOtp({required String email, required String token}) async {
    try {
      await _registerService.verifyOtp(email: email, token: token);
    } catch (e) {
      throw AppErrorHandler.handle(e);
    }
  }

  Future<void> resendOtp({required String email}) async {
    try {
      await _registerService.resendOtp(email: email);
    } catch (e) {
      throw AppErrorHandler.handle(e);
    }
  }
}
