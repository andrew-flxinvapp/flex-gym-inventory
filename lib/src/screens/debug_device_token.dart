import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/src/services/device_token_manager.dart';

class DebugDeviceTokenScreen extends StatefulWidget {
  const DebugDeviceTokenScreen({super.key});

  @override
  State<DebugDeviceTokenScreen> createState() => _DebugDeviceTokenScreenState();
}

class _DebugDeviceTokenScreenState extends State<DebugDeviceTokenScreen> {
  final _tokenController = TextEditingController();
  final _deviceIdController = TextEditingController();
  String _platform = 'android';
  bool _loading = false;

  @override
  void dispose() {
    _tokenController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = _tokenController.text.trim();
    final deviceId = _deviceIdController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a token')));
      return;
    }

    setState(() => _loading = true);
      try {
        await DeviceTokenManager.instance.registerToken(
          token: token,
          platform: _platform,
          deviceId: deviceId.isEmpty ? null : deviceId,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Token upserted via DeviceTokenManager')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug: Device Token')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paste a provider token (APNs / FCM / OneSignal) below for testing.'),
            const SizedBox(height: 12),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(labelText: 'Token'),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _deviceIdController,
              decoration: const InputDecoration(labelText: 'Device ID (optional)'),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _platform,
              items: const [
                DropdownMenuItem(value: 'android', child: Text('android')),
                DropdownMenuItem(value: 'ios', child: Text('ios')),
                DropdownMenuItem(value: 'other', child: Text('other')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _platform = v);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? const CircularProgressIndicator() : const Text('Upsert token'),
            ),
          ],
        ),
      ),
    );
  }
}
