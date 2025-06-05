import '../enum/app_enums.dart';
import 'package:uuid/uuid.dart';

final Uuid _uuid = Uuid();

// Generates a unique gymId using UUID v4.
// Example output: 123e4567-e89b-12d3-a456-426614174000

// Usage example: final gymId = generateGymId();

String generateGymId() {
  return _uuid.v4();
}

// Generates an equipmentId in the format CAT-XXXX, where:
// - CAT is the catrgory prefix from EquipmentCategory.idPrefix
//- XXXX is a zero-padded sequence number (e.g. 0001)
// Example: BAR-0001

// Usage example: final equipmentId = generateEquipmentId(EquipmentCategory.barbell, 1);

String generateEquipmentId(EquipmentCategory category, int sequenceNumber) {
  String paddedSequence = sequenceNumber.toString().padLeft(4, '0');
  return '${category.idPrefix}-$paddedSequence';
}

