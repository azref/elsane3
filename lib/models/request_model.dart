import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String userId; // ID of the user who made the request
  final String userName;
  final String userPhone;
  final String professionConceptKey; // The general concept of the profession (e.g., 'building')
  final String professionDialectName; // The dialect-specific name of the profession (e.g., 'بناي')
  final String audioUrl; // URL of the audio message
  final String? textDescription; // Optional text description
  final String country; // Country of the request
  final String city; // City of the request
  final GeoPoint location; // Geographic location of the request
  final DateTime createdAt;
  final DateTime expiresAt; // When the request expires (e.g., 48 hours)
  final String status; // e.g., 'active', 'completed', 'expired'
  final String channel; // e.g., 'building_riyadh', 'plastering_cairo'

  RequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.professionConceptKey,
    required this.professionDialectName,
    required this.audioUrl,
    this.textDescription,
    required this.country,
    required this.city,
    required this.location,
    required this.createdAt,
    required this.expiresAt,
    this.status = 'active',
    required this.channel,
  });

  factory RequestModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RequestModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      professionConceptKey: data['professionConceptKey'] ?? '',
      professionDialectName: data['professionDialectName'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      textDescription: data['textDescription'],
      country: data['country'] ?? '',
      city: data['city'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'active',
      channel: data['channel'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'professionConceptKey': professionConceptKey,
      'professionDialectName': professionDialectName,
      'audioUrl': audioUrl,
      'textDescription': textDescription,
      'country': country,
      'city': city,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'status': status,
      'channel': channel,
    };
  }
}


