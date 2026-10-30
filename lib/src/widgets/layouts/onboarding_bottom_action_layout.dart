import 'package:flutter/material.dart';

class OnboardingBottomActionLayout extends StatelessWidget {
  final Widget content;
  final Widget action;

  const OnboardingBottomActionLayout({
    super.key,
    required this.content,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(child: SingleChildScrollView(child: content)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
            child: action,
          ),
        ],
      ),
    );
  }
}
