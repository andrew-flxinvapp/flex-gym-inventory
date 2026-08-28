import 'package:flex_gym_inventory/src/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/selectors/delete_account_selector.dart';
// unused imports removed - not needed for this screen
// import '../widgets/inputs/multiline_text_input.dart';
// import '../widgets/buttons/warning_button.dart';
// import '../widgets/buttons/secondary_button.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import '../widgets/snackbar.dart';
import 'package:flex_gym_inventory/src/data/repositories/gym_repository.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flex_gym_inventory/service/supabase_service.dart';

class DefaultGymScreen extends StatefulWidget {
  const DefaultGymScreen({super.key});

  @override
  State<DefaultGymScreen> createState() => _DefaultGymScreenState();
}

class _DefaultGymScreenState extends State<DefaultGymScreen> {
  // Currently selected gym index. Use -1 for none selected.
  int _selectedIndex = -1;

  Future<List<Gym>> _fetchGyms() async {
    final auth = SupabaseAuthService();
    final userId = auth.currentUser?.id ?? 'local';
    final repo = GymRepository();
    return repo.getAllForUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: TopAppBar(
          title: 'Default Gym',
          showBackArrow: true,
          showRightIcon: false,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pick your main gym.',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Second text section placeholder
                      Text(
                        'This will be the one you see first every time you open Flex Gym Inventory.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 32),

                      // Render gym list as radio selectors
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select your default gym',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                              FutureBuilder<List<Gym>>(
                                future: _fetchGyms(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error loading gyms', style: Theme.of(context).textTheme.bodySmall);
                                  }
                                  final gyms = snapshot.data ?? [];
                                  if (gyms.isEmpty) {
                                    return Text('No gyms found', style: Theme.of(context).textTheme.bodySmall);
                                  }

                                  return Column(
                                    children: List<Widget>.generate(gyms.length, (index) {
                                      final g = gyms[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 0),
                                        child: DeleteAccountSelector(
                                          selected: _selectedIndex == index,
                                          text: g.name,
                                          onTap: () {
                                            setState(() {
                                              _selectedIndex = index;
                                            });
                                          },
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom action area — anchored and respects safe area
            Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Set Default Gym',
                  onPressed: () async {
                    final gyms = await _fetchGyms();
                    if (_selectedIndex < 0 ||
                        _selectedIndex >= gyms.length) {
                      showFlexSnackbar(
                        context,
                        title: 'Please select a gym first.',
                        subtitle: null,
                        type: SnackbarType.warning,
                      );
                      return;
                    }

                    final selectedGym = gyms[_selectedIndex];
                    // TODO: persist the selection to app settings / backend

                    showFlexSnackbar(
                      context,
                      title: 'Set "${selectedGym.name}" as your default gym.',
                      subtitle: null,
                      type: SnackbarType.success,
                    );

                    // Optionally pop back after setting
                    // Navigator.of(context).pop(selectedGym);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
