# Step-by-Step Guide: Implementing Export Screen (PDF)

This guide will help you implement a simple export screen with two PDF export options in your Flex Gym Inventory app.

---

## 1. Create the Export Screen UI
- **File:** `lib/src/screens/export_screen.dart`
- Add UI elements for:
  - Export for Trainer/Coach/Friend
  - Export for Insurance
- Add buttons to trigger each export type.

## 2. Update/Implement Export Service
- **File:** `lib/service/export_service.dart`
- Use the `pdf` package to generate PDFs.
- Add two methods:
  - `exportForTrainer(List<Equipment> equipment, Gym gym)`
  - `exportForInsurance(List<Equipment> equipment, Gym gym)`
- Each method should generate a PDF with the required fields:
  - **Trainer:** Gym name, equipment name, quantity
  - **Insurance:** Gym name, equipment name, serial number, model, value

## 3. Add File Sharing Functionality
- Use the `share_plus` package to share the generated PDF.
- Integrate sharing logic in the export service or screen.

## 4. Ensure Data Models Have Required Fields
- **Files:** `lib/src/models/gym.dart`, `lib/src/models/equipment.dart`
- Equipment model should include: name, quantity, serial number, model, value
- Gym model should include: name

## 5. Add Routing for Export Screen
- **File:** `lib/routes/routes.dart`
- Add a route for the new export screen.

## 6. (Optional) Add ViewModel/Provider for Export Logic
- **File:** `lib/view_models/export_view_model.dart`
- Use Riverpod or your preferred state management for export state.

## 7. Update Platform Permissions
- **Files:** `android/`, `ios/` platform config files
- Ensure permissions for file storage and sharing are set.

## 8. (Optional) Style the PDF
- Use custom fonts or images from `lib/assets/` for branding.

---

## Example File Structure

```
lib/
  src/
    screens/
      export_screen.dart
    models/
      gym.dart
      equipment.dart
  service/
    export_service.dart
  view_models/
    export_view_model.dart (optional)
  routes/
    routes.dart
  assets/
    fonts/
    images/
```

---

## Packages to Add
- `pdf` (for PDF generation)
- `share_plus` (for sharing files)

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  pdf: ^3.10.4
  share_plus: ^7.2.1
```

---

## Next Steps
- Implement the UI and service logic as described above.
- Test both export options on your target platforms.
- Adjust PDF formatting and data as needed.

---

For detailed code samples or further breakdowns, just ask!
