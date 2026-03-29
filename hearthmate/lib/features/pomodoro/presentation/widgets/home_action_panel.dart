import 'package:flutter/material.dart';

class HomeActionPanel extends StatelessWidget {
  const HomeActionPanel({
    super.key,
    required this.maxWidth,
    required this.scale,
    required this.voyageLabel,
    required this.selectedCharacter,
    required this.onCharacterTap,
    required this.onVoyageTap,
    required this.onVoyageLongPress,
    required this.onCollectionTap,
  });

  final double maxWidth;
  final double scale;
  final String voyageLabel;
  final String? selectedCharacter;
  final VoidCallback onCharacterTap;
  final VoidCallback onVoyageTap;
  final VoidCallback onVoyageLongPress;
  final VoidCallback onCollectionTap;

  @override
  Widget build(BuildContext context) {
    final double closeSize = (40 * scale).clamp(34, 48);
    final double iconSize = (30 * scale).clamp(22, 34);
    final double headingSize = (30 * scale).clamp(20, 32);
    final double footerSize = (16 * scale).clamp(12, 17);
    final double actionSize = (12 * scale).clamp(10, 13);
    final double buttonTextSize = (20 * scale).clamp(13, 21);

    return Container(
      width: maxWidth,
      padding: EdgeInsets.fromLTRB(14 * scale, 12 * scale, 14 * scale, 14 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22 * scale),
        border: Border.all(color: const Color(0xFF6A4430), width: 2.5),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC4B2F26), Color(0xE62B1A16)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'THE HEARTH ROOM',
                  style: TextStyle(
                    color: const Color(0xFFF1D2A2),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontSize: headingSize,
                  ),
                ),
              ),
              Container(
                width: closeSize,
                height: closeSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6B07A),
                  borderRadius: BorderRadius.circular(closeSize / 2),
                ),
                child: Icon(
                  Icons.close,
                  color: const Color(0xFF4F2F1C),
                  size: 22 * scale,
                ),
              ),
            ],
          ),
          SizedBox(height: 14 * scale),
          Container(
            padding: EdgeInsets.fromLTRB(
              12 * scale,
              10 * scale,
              12 * scale,
              12 * scale,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18 * scale),
              border: Border.all(color: const Color(0xFF6F4A33), width: 2),
              color: const Color(0x4D251713),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _sideAction(
                    scale: scale,
                    onTap: onCharacterTap,
                    icon: Icons.construction,
                    iconSize: iconSize,
                    textSize: actionSize,
                    line1: 'CHARACTER',
                    line2: selectedCharacter == null
                        ? 'SELECT'
                        : selectedCharacter!.toUpperCase(),
                  ),
                ),
                SizedBox(width: 10 * scale),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: (54 * scale).clamp(44, 60),
                    child: ElevatedButton(
                      onPressed: onVoyageTap,
                      onLongPress: onVoyageLongPress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2A649),
                        foregroundColor: const Color(0xFFFDF4E1),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8 * scale),
                          side: const BorderSide(
                            color: Color(0xFF9C6228),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        voyageLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: buttonTextSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10 * scale),
                Expanded(
                  child: _sideAction(
                    scale: scale,
                    onTap: onCollectionTap,
                    icon: Icons.grid_view_rounded,
                    iconSize: iconSize,
                    textSize: actionSize,
                    line1: 'COLLECTION',
                    line2: 'LOG',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12 * scale),
          Text(
            'LEVEL 5 - FRIENDSHIP: WARM EMBERS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFDFC89E),
              fontSize: footerSize,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideAction({
    required double scale,
    required VoidCallback onTap,
    required IconData icon,
    required double iconSize,
    required double textSize,
    required String line1,
    required String line2,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10 * scale),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFD5B077), size: iconSize),
            SizedBox(height: 2 * scale),
            Text(
              line1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFDFC89E),
                fontWeight: FontWeight.w700,
                fontSize: textSize,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              line2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFDFC89E),
                fontWeight: FontWeight.w700,
                fontSize: textSize,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
