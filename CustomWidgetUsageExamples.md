# Custom Widget Usage Examples

Below are usage examples for each custom widget in your `lib/src/widgets` folder and its subfolders. Replace parameters as needed for your app context.

---

## Buttons

### PrimaryButton
```dart
PrimaryButton(
  label: 'Save',
  onPressed: () {},
)
```

### SecondaryButton
```dart
SecondaryButton(
  label: 'Cancel',
  onPressed: () {},
)
```

### WarningButton
```dart
WarningButton(
  label: 'Delete',
  onPressed: () {},
)
```

### DisabledButton
```dart
DisabledButton(
  label: 'Disabled',
  onPressed: () {}, // Typically null or a no-op
)
```

---

## Snackbars

### Success
```dart
FlexSnackbar(
    title: 'Success!',
    subtitle: 'Your equipment was added.',
    type: SnackbarType.success,
    onClose: () {},
),
```

### Warning
```dart
FlexSnackbar(
    title: 'Warning!',
    subtitle: 'Check your equipment details.',
    type: SnackbarType.warning,
    onClose: () {},
),
```

### Update
```dart
FlexSnackbar(
    title: 'Update!',
    subtitle: 'App features have been updated.',
    type: SnackbarType.update,
    onClose: () {},
),
```

### Stop
```dart
FlexSnackbar(
    title: 'Stop!',
    subtitle: 'Action not allowed.',
    type: SnackbarType.stop,
    onClose: () {},
),
```
---

## Form Components

## Custom Text Input Field
```dart
CustomTextInputField(
    hintText: 'Field Name Here',
    showAsterisk: true,
),
```

## Gym ID Disply Field
```dart
GymIdDisplayField(gymId: 'GYM-0001'),
```

## Custom Toggle Input
```dart
ToggleInput(
    leftPlaceholder: 'Quantity',
    showAsterisk: true,
    rightLabel: 'Pair:',
    value: false, // TODO: Connect to state
    onChanged: (val) {
    // TODO: Handle toggle change
    },
),
```

## Custom Dropdown Field
```dart
CustomDropdownField<WishlistPriority>(
    hintText: 'Wishlist Priority',
    items: WishlistPriority.values,
    value: selectedPriority,
    showAsterisk: true,
    getLabel: (item) => item.label,
    onChanged: (value) {
        setState(() {
        selectedPriority = value;
        });
    },
),
```

## Custom Multiline Text Input
```dart
CustomMultilineTextInput(
    hintText: 'Multiline Field Here',
),
```

## Custom Date Input
```dart
CustomDateInput(
    hintText: 'Purchase Date',
    onDateChanged: (date) {
     // Handle selected date if needed
    },
),
```

---

## Cards

### Dashboard Gym Card
```dart
DashboardGymCard(
  gymName: 'Flex Home Gym',
  equipmentCount: 27,
  lastUpdated: DateTime.now(),
)
```

### Details Card
```dart
DetailsCard(
    details: [
        const MapEntry('Brand', 'Rogue'),
        const MapEntry('Model', 'Barbell'),
        const MapEntry('Category', 'Strength'),
        const MapEntry('Training Style', 'Black'),
        const MapEntry('Quantity', 'Excellent'),
    ],
),
```

### Purchase Card
```dart
PurchaseCard(
    details: [
        const MapEntry('Purchase Price', '295.00'),
        MapEntry('Purchase Date', purchaseDate),
        MapEntry('Age', age),
        const MapEntry('Warranty', 'Lifetime'),
    ],
),
```

### Wishlist Card
```dart
WishlistCard(
    details: const [
        MapEntry('Brand', 'Rogue'),
        MapEntry('Category', 'Rig'),
        MapEntry('Type', 'Replacement'),
        MapEntry('Priority', 'Medium'),
        MapEntry('Link', 'https://www.roguefitness.com/rogue-adjustable-bench-3-0'),
    ],
),
```

### Equipment Card
```dart
EquipmentCard(
    itemName: 'Rogue Ohio Bar',
    quantity: 2,
    value: 325.00,
),
```

### Gym Stats Card
```dart
GymStatsCard(
    itemCount: 27,
    estimatedValue: 4200.00,
    lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
),
```

---

## Dialogs

### ConfirmDialog
```dart
ConfirmDialog(
  title: 'Confirm Action',
  content: 'Are you sure?',
  confirmText: 'Yes',
  onConfirm: () {},
)
```
---

## Top App Bar

### TopAppBar
```dart
TopAppBar(
  title: 'Dashboard',
  showBackArrow: true,
  onBackArrowPressed: () {},
)
```

---


// ...add similar examples for other widgets as needed.

---

> For widgets with more parameters or advanced usage, see their respective Dart files for full details.
