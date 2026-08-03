import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../enum/app_enums.dart';
import '../widgets/inputs/dropdown_field.dart';
import '../widgets/inputs/image_input.dart';
import '../widgets/cards/info_card.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/inputs/text_input_field.dart';
import '../widgets/inputs/multiline_text_input.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  late final TextEditingController _messageController;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messageController.addListener(() {
      setState(() {
        _charCount = _messageController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: const TopAppBar(
        title: 'Support',
        showBackArrow: true,
        showRightIcon: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need help?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Have a question, found a bug, or need assistance? Send us a support request and we will typically respond within 48 hours.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.normal,
                color: AppTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            CustomDropdownField<SupportCategory>(
              hintText: 'Category',
              items: SupportCategory.values,
              value: null,
              showAsterisk: true,
              getLabel: (item) => item.label,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            CustomTextInputField(hintText: 'Subject', showAsterisk: true),
            const SizedBox(height: 16),
            Text(
              'Screenshot (Optional)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a screenshot to help us better understand the issue.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.normal,
                color: AppTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ImageInput(),
            const SizedBox(height: 16),
            CustomMultilineTextInput(
              hintText: 'Describe your issue or question in detail...',
              showAsterisk: true,
              controller: _messageController,
              maxLines: 45,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$_charCount/2000',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'Diagnostic information included',
              subtitle: 'We include your app version, device, and OS details to help diagnose issues.',
            ),
            const SizedBox(height: 32),
            PrimaryButton(label: 'Submit Support Request', onPressed: () {}),
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Cancel',
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }
}
