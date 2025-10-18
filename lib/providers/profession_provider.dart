import 'package:flutter/foundation.dart';
import '../models/profession_model.dart';

class ProfessionProvider with ChangeNotifier {
  final ProfessionsData _professionsData = ProfessionsData();
  
  ProfessionsData get professionsData => _professionsData;
  
  List<Profession> getAllProfessions() {
    return _professionsData.getAllProfessions();
  }
  
  Profession? getProfessionByConceptKey(String conceptKey) {
    return _professionsData.getProfessionByConceptKey(conceptKey);
  }
  
  String getLocalizedProfessionName(String conceptKey, String dialect) {
    return _professionsData.getLocalizedProfessionName(conceptKey, dialect);
  }
}

