import 'gym_model.dart';
import 'equipment_model.dart';
import 'wishlist_model.dart';
import 'users_model.dart';
import '../../enum/app_enums.dart';

final List<Gym> dummyGyms = [
  Gym(
    gymId: 'gym1',
    name: 'Flex Home Gym',
    location: '123 Main St, Hometown',
    gymNotes: 'Main home gym setup.',
    createdDate: DateTime(2023, 1, 10),
  ),
  Gym(
    gymId: 'gym2',
    name: 'Flex Commercial',
    location: '456 Fitness Ave, City',
    gymNotes: 'Small commercial gym.',
    createdDate: DateTime(2024, 3, 5),
  ),
];

final List<Equipment> dummyEquipment = [
  Equipment(
    gymId: 'gym1',
    name: 'Olympic Barbell',
    category: 'implement',
    brand: 'Rogue',
    model: 'Ohio Power Bar',
    trainingStyle: 'powerlifting',
    quantity: 1,
    isPair: false,
    condition: 'excellent',
    purchaseDate: DateTime(2023, 2, 1),
    value: 295.0,
    isEstimate: false,
    serialNumber: 'RB-2023-001',
    maintenanceNotes: 'Wipe down monthly.',
    equipmentId: 'eq1',
  ),
  Equipment(
    gymId: 'gym1',
    name: 'Adjustable Dumbbells',
    category: 'weight',
    brand: 'Bowflex',
    model: 'SelectTech 552',
    trainingStyle: 'general',
    quantity: 2,
    isPair: true,
    condition: 'good',
    purchaseDate: DateTime(2022, 8, 15),
    value: 399.0,
    isEstimate: false,
    serialNumber: 'DB-2022-002',
    maintenanceNotes: 'Check locking mechanism.',
    equipmentId: 'eq2',
  ),
  Equipment(
    gymId: 'gym2',
    name: 'Treadmill',
    category: 'machine',
    brand: 'NordicTrack',
    model: 'Commercial 1750',
    trainingStyle: 'cardio',
    quantity: 1,
    isPair: false,
    condition: 'excellent',
    purchaseDate: DateTime(2024, 4, 10),
    value: 1799.0,
    isEstimate: false,
    serialNumber: 'TM-2024-003',
    maintenanceNotes: 'Lubricate belt every 3 months.',
    equipmentId: 'eq3',
  ),
];

final List<Wishlist> dummyWishlist = [
  Wishlist(
    name: 'New Power Rack',
    wishlistType: WishlistType.newItem.name,
    category: EquipmentCategory.rig.name,
    brand: 'REP',
    priority: WishlistPriority.high.name,
    productUrl: 'https://repfitness.com/products/pr-4000',
    notes: 'Add for more squat/bench options.',
  ),
  Wishlist(
    name: 'Replace Bench',
    wishlistType: WishlistType.replacement.name,
    category: EquipmentCategory.rig.name,
    brand: 'Rogue',
    priority: WishlistPriority.medium.name,
    productUrl: 'https://www.roguefitness.com/rogue-adjustable-bench-3-0',
    notes: 'Old bench is wobbly.',
  ),
];

final List<Users> dummyUsers = [
  Users(
    userId: 'user1',
    firstName: 'Alex',
    lastName: 'Flexer',
    email: 'alex@flexgym.com',
    plan: 'PRO',
    createdDate: DateTime(2023, 1, 1),
  ),
  Users(
    userId: 'user2',
    firstName: 'Jamie',
    lastName: 'Rackley',
    email: 'jamie@flexgym.com',
    plan: 'FREE',
    createdDate: DateTime(2024, 2, 15),
  ),
  Users(
    userId: 'user3',
    firstName: 'Taylor',
    lastName: 'Smith',
    email: 'taylor@flexgym.com',
    plan: 'PRO',
    createdDate: DateTime(2024, 5, 10),
  ),
];
