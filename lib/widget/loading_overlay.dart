

import 'package:flutter/material.dart';

import '../extensions/app_extensions.dart';
import '../theme/app_theme.dart';


class LoadingOverlay extends StatelessWidget {
  final String message;

  const LoadingOverlay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
                strokeWidth: 3,
              ),
              addVerticalSpace(20),
              Text(
                message,
                style: Theme.of(context).textTheme.displayMedium!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
