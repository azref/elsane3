import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';
import '../models/user_model.dart';
import '../services/request_service.dart';

class RequestProvider with ChangeNotifier {
  final RequestService _requestService = RequestService();
  
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  String? _successMessage;
  
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  String? get successMessage => _successMessage;
  
  Future<void> sendRequest({
    required UserModel user,
    required String professionConceptKey,
    required String professionDialectName,
    required String audioFilePath,
    String? textDescription,
    required String country,
    required String city,
    required GeoPoint location,
  }) async {
    _isSending = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _requestService.sendNewRequest(
        user: user,
        professionConceptKey: professionConceptKey,
        professionDialectName: professionDialectName,
        audioFilePath: audioFilePath,
        textDescription: textDescription,
        country: country,
        city: city,
        location: location,
      );

      _isSending = false;
      _successMessage = 'تم إرسال الطلب بنجاح';
    } catch (e) {
      _isSending = false;
      _error = 'فشل في إرسال الطلب: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _requestService.updateRequestStatus(requestId, status);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = 'فشل في تحديث حالة الطلب: ${e.toString()}';
    }
    notifyListeners();
  }

  Stream<List<RequestModel>> getCraftsmanRequests({
    required String professionConceptKey,
    required List<String> workCities,
  }) {
    return _requestService.getCraftsmanRequests(
      professionConceptKey: professionConceptKey,
      workCities: workCities,
    );
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}

