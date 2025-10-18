import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/request_model.dart';
import '../models/user_model.dart';

class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  // إرسال طلب جديد (رسالة صوتية)
  Future<void> sendNewRequest({
    required UserModel user,
    required String professionConceptKey,
    required String professionDialectName,
    required String audioFilePath,
    String? textDescription,
    required String country,
    required String city,
    required GeoPoint location,
  }) async {
    try {
      // 1. رفع الملف الصوتي إلى Firebase Storage
      String requestId = _uuid.v4();
      String audioFileName = 'requests/${user.uid}/$requestId.m4a';
      UploadTask uploadTask = _storage.ref().child(audioFileName).putFile(File(audioFilePath));
      TaskSnapshot snapshot = await uploadTask;
      String audioUrl = await snapshot.ref.getDownloadURL();

      // 2. تحديد تاريخ انتهاء صلاحية الطلب (48 ساعة من الآن)
      DateTime createdAt = DateTime.now();
      DateTime expiresAt = createdAt.add(const Duration(hours: 48));

      // 3. بناء قناة الطلب (مثال: building_riyadh)
      String channel = '${professionConceptKey}_${city.toLowerCase().replaceAll(' ', '_')}';

      // 4. إنشاء نموذج الطلب
      RequestModel newRequest = RequestModel(
        id: requestId,
        userId: user.uid,
        userName: user.name ?? 'Unknown',
        userPhone: user.email,
        professionConceptKey: professionConceptKey,
        professionDialectName: professionDialectName,
        audioUrl: audioUrl,
        textDescription: textDescription,
        country: country,
        city: city,
        location: location,
        createdAt: createdAt,
        expiresAt: expiresAt,
        status: 'active',
        channel: channel,
      );

      // 5. حفظ الطلب في Firestore
      await _firestore.collection('public_requests').doc(requestId).set(newRequest.toFirestore());
    } catch (e) {
      print('Error sending new request: $e');
      rethrow;
    }
  }

  // الحصول على طلبات العمل الموجهة لحرفي معين (استماع محدود ومفلتر)
  Stream<List<RequestModel>> getCraftsmanRequests({
    required String professionConceptKey,
    required List<String> workCities,
  }) {
    // بناء قائمة القنوات التي يستمع إليها الحرفي
    List<String> channelsToListen = [];
    for (String city in workCities) {
      channelsToListen.add('${professionConceptKey}_${city.toLowerCase().replaceAll(' ', '_')}');
    }

    // الاستماع فقط للطلبات النشطة التي تطابق قنوات الحرفي
    return _firestore
        .collection('public_requests')
        .where('channel', whereIn: channelsToListen)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromFirestore(doc))
            .toList());
  }

  // تحديث حالة الطلب (مثال: إلى 'completed' أو 'expired')
  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _firestore.collection('public_requests').doc(requestId).update({
        'status': status,
      });
    } catch (e) {
      print('Error updating request status: $e');
      rethrow;
    }
  }

  // الحصول على طلب واحد بواسطة ID
  Future<RequestModel?> getRequestById(String requestId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('public_requests').doc(requestId).get();
      if (doc.exists) {
        return RequestModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting request by ID: $e');
      return null;
    }
  }
}
