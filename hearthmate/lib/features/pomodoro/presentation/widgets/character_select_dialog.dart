import 'package:flutter/material.dart';

Future<String?> showCharacterSelectDialog(
  BuildContext context, {
  required String? selectedCharacter,
}) async {
  final Size screen = MediaQuery.sizeOf(context);
  final double horizontalInset = (screen.width * 0.06).clamp(14, 28);
  final double verticalInset = (screen.height * 0.08).clamp(16, 40);

  return showDialog<String>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: horizontalInset,
          vertical: verticalInset,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF4A2F1C).withValues(alpha: 0.94),
            border: Border.all(color: const Color(0xFF8B5E3C), width: 3),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Color(0x80000000), blurRadius: 16, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Character Select',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFE1BA),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              _characterOption(
                context,
                title: 'Miner',
                selectedCharacter: selectedCharacter,
              ),
              const SizedBox(height: 12),
              _characterOption(
                context,
                title: 'Botanist',
                selectedCharacter: selectedCharacter,
              ),
              const SizedBox(height: 12),
              _characterOption(
                context,
                title: 'Pirate',
                selectedCharacter: selectedCharacter,
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _characterOption(
  BuildContext context, {
  required String title,
  required String? selectedCharacter,
}) {
  final bool isSelected = selectedCharacter == title;
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      side: BorderSide(
        color: isSelected ? const Color(0xFFFFC680) : const Color(0xFF9D724A),
        width: 2,
      ),
      backgroundColor: isSelected ? const Color(0xFF6A4328) : const Color(0xFF5A3923),
      foregroundColor: const Color(0xFFFFE1BA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    onPressed: () => Navigator.of(context).pop(title),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
