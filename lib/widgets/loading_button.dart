import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Submit button that swaps its label for a spinner while busy — the
/// ElevatedButton+CircularProgressIndicator pattern repeated across every
/// submit screen (login/otp/registration/donor details/create request/...).
class LoadingButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final bool outlined;

  const LoadingButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.whiteTextOnPrimary),
          )
        : Text(label);

    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(onPressed: isLoading ? null : onPressed, child: child)
          : ElevatedButton(onPressed: isLoading ? null : onPressed, child: child),
    );
  }
}
