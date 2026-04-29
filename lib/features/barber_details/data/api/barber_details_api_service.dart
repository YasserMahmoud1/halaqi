import 'package:my_barber/features/barber_details/data/api/barber_details_api_consts.dart';
import 'package:my_barber/features/barber_details/data/models/barber_details_request/barber_details_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/barber_details_response/barber_details_model.dart';

class BarberDetailsApiService {
  final SupabaseClient _supabase;

  BarberDetailsApiService(this._supabase);

  Future<BarberDetailsResponse> getShopDetails({
    required BarberDetailsRequest request,
  }) async {
    final response = await _supabase.rpc(
      BarberDetailsApiConsts.getBarberDetailsRPC,
      params: request.toJson(),
    );

    final barberDetails = BarberDetailsResponse.fromJson(
      response as Map<String, dynamic>,
    );

    return barberDetails;
  }
}
