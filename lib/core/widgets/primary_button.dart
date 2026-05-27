import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;

  const PrimaryButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: 54,
      width: isExpanded ? double.infinity : null,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: Colors.white,
          ),
        )
            : Icon(icon ?? Icons.check_rounded),
        label: Text(
          isLoading ? 'İşleniyor...' : text,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );

    return button;
  }
}