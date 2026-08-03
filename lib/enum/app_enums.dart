// lib/enum/app_enums.dart
// Enum definitions used across the Flex Gym Inventory app.
import 'package:flutter/material.dart';

// Upgrade priorities for planned upgrades
enum WishlistPriority { low, medium, high }

extension WishlistPriorityLabel on WishlistPriority {
  String get label {
    switch (this) {
      case WishlistPriority.low:
        return 'Low';
      case WishlistPriority.medium:
        return 'Medium';
      case WishlistPriority.high:
        return 'High';
    }
  }
}

// Equipment categories for gym inventory
enum EquipmentCategory {
  weights, // Plates, dumbbells, barbells, kettlebells
  specialty, // Strongman, sleds, sandbags etc.
  machines, // Cable machines, selectorized machines, and other standalone equipment
  storage, // Plate trees, dbell racks, barbell holders and shelving
  racks, // Power racks, squat racks, half racks etc.
  attachments, // Rack/machine add-ons and handles
  benches, // Flat, incline, decline, adjustable benches
  accessories, // Belts, straps, wraps, sleeves etc.
  safety, // Safety equipment like collars, clips, spotter arms etc.
  other,
}

extension EquipmentCategoryLabel on EquipmentCategory {
  String get label {
    switch (this) {
      case EquipmentCategory.weights:
        return 'Weights';
      case EquipmentCategory.specialty:
        return 'Specialty';
      case EquipmentCategory.machines:
        return 'Machines';
      case EquipmentCategory.storage:
        return 'Storage';
      case EquipmentCategory.racks:
        return 'Racks';
      case EquipmentCategory.attachments:
        return 'Attachments';
      case EquipmentCategory.benches:
        return 'Benches';
      case EquipmentCategory.accessories:
        return 'Accessories';
      case EquipmentCategory.safety:
        return 'Safety';
      case EquipmentCategory.other:
        return 'Other';
    }
  }
}

// Assign a specific color to each equipment category so UI components can
// consistently use the same palette across the app.
extension EquipmentCategoryColor on EquipmentCategory {
  Color get color {
    switch (this) {
      case EquipmentCategory.weights:
        return const Color(0xFFE63946);
      case EquipmentCategory.specialty:
        return const Color(0xFFF4A261);
      case EquipmentCategory.machines:
        return const Color(0xFFE9C46A);
      case EquipmentCategory.storage:
        return const Color(0xFF2A9D8F);
      case EquipmentCategory.racks:
        return const Color(0xFF457B9D);
      case EquipmentCategory.attachments:
        return const Color(0xFF6A4C93);
      case EquipmentCategory.benches:
        return const Color(0xFFA8A8A8);
      case EquipmentCategory.accessories:
        return const Color(0xFF264653);
      case EquipmentCategory.safety:
        return const Color(0xFFDE6D87);
      case EquipmentCategory.other:
        return const Color(0xFF3A8F7D);
    }
  }
}

// Training styles for gym users
enum TrainingStyle {
  general,
  olympicWeightlifting,
  powerlifting,
  strongman,
  bodybuilding,
  crossfit,
  calisthenics,
  hiit,
  circuit,
}

extension TrainingStyleLabel on TrainingStyle {
  String get label {
    switch (this) {
      case TrainingStyle.general:
        return 'General';
      case TrainingStyle.olympicWeightlifting:
        return 'Olympic Weightlifting';
      case TrainingStyle.powerlifting:
        return 'Powerlifting';
      case TrainingStyle.strongman:
        return 'Strongman';
      case TrainingStyle.bodybuilding:
        return 'Bodybuilding';
      case TrainingStyle.crossfit:
        return 'CrossFit';
      case TrainingStyle.calisthenics:
        return 'Calisthenics';
      case TrainingStyle.hiit:
        return 'HIIT';
      case TrainingStyle.circuit:
        return 'Circuit';
    }
  }
}

// Equipment condition states
enum EquipmentCondition { brandNew, excellent, good, fair, damaged, retired }

extension EquipmentConditionLabel on EquipmentCondition {
  String get label {
    switch (this) {
      case EquipmentCondition.brandNew:
        return 'Brand New';
      case EquipmentCondition.excellent:
        return 'Excellent';
      case EquipmentCondition.good:
        return 'Good';
      case EquipmentCondition.fair:
        return 'Fair';
      case EquipmentCondition.damaged:
        return 'Damaged';
      case EquipmentCondition.retired:
        return 'Retired';
    }
  }
}

// File types for export/import
enum FileType { simplePDF, csv, fullPDF }

extension FileTypeLabel on FileType {
  String get label {
    switch (this) {
      case FileType.simplePDF:
        return 'Simple PDF';
      case FileType.csv:
        return 'CSV';
      case FileType.fullPDF:
        return 'Full PDF';
    }
  }
}

// Upgrade types for planned upgrades
enum WishlistType { newItem, replacement }

extension WishlistTypeLabel on WishlistType {
  String get label {
    switch (this) {
      case WishlistType.newItem:
        return 'New Item';
      case WishlistType.replacement:
        return 'Replacement';
    }
  }
}

/// Menu actions for dashboard pop-out menu
enum DashboardMenuAction { addGym, addEquipment, addWishlist }

/// Menu options for adding an image
enum ImageSource { camera, gallery }

extension ImageSourceLabel on ImageSource {
  String get label {
    switch (this) {
      case ImageSource.camera:
        return 'Take Photo';
      case ImageSource.gallery:
        return 'Choose from Gallery';
    }
  }
}

/// Menu actions for equipment detail screen
enum ImageAction { edit, delete }
extension ImageActionLabel on ImageAction {
  String get label {
    switch (this) {
      case ImageAction.edit:
        return 'Edit';
      case ImageAction.delete:
        return 'Delete';
    }
  }
}

enum SupportCategory { bugReport, account, equipment, gym, wishlist, export, subscriptions, featureRequest, generalQuestion, other }
extension SupportCategoryLabel on SupportCategory {
  String get label {  
    switch (this) {
      case SupportCategory.bugReport:
        return 'Bug Report';
      case SupportCategory.account:
        return 'Account';
      case SupportCategory.equipment:
        return 'Equipment';
      case SupportCategory.gym:
        return 'Gym';
      case SupportCategory.wishlist:
        return 'Wishlist';
      case SupportCategory.export:
        return 'Export';
      case SupportCategory.subscriptions:
        return 'Subscriptions';
      case SupportCategory.featureRequest:
        return 'Feature Request';
      case SupportCategory.generalQuestion:
        return 'General Question';
      case SupportCategory.other:
        return 'Other';
    }
  }
} 

enum SupportStatus { open, inProgress, waitingOnUser, resolved, closed }
extension SupportStatusLabel on SupportStatus {
  String get label {
    switch (this) {
      case SupportStatus.open:
        return 'Open';
      case SupportStatus.inProgress:
        return 'In Progress';
      case SupportStatus.waitingOnUser:
        return 'Waiting on User';
      case SupportStatus.resolved:
        return 'Resolved';
      case SupportStatus.closed:
        return 'Closed';
    }
  }
}