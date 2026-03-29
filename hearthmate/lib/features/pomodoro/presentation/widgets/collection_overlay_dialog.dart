import 'package:flutter/material.dart';

class CollectionOverlayDialog extends StatefulWidget {
  const CollectionOverlayDialog({
    super.key,
    required this.horizontalInset,
    required this.verticalInset,
  });

  final double horizontalInset;
  final double verticalInset;

  @override
  State<CollectionOverlayDialog> createState() => _CollectionOverlayDialogState();
}

class _CollectionOverlayDialogState extends State<CollectionOverlayDialog> {
  static const Color _panelColor = Color(0xFF3F2818);
  static const Color _panelBorderColor = Color(0xFF8B5E3C);
  static const Color _inactiveTabColor = Color(0xFF4B3123);
  static const double _borderWidth = 1;
  static const double _tabHeight = 34;
  static const double _tabRadius = 10;
  static const double _tabOverlap = 2;
  static const double _stripGap = 2;
  static const double _tabSpacing = 10;
  static const double _tabWidth = 150;
  static const double _inactiveLift = 4;
  int _activeTabIndex = 0;
  final ScrollController _collectionController = ScrollController();
  final ScrollController _achievementController = ScrollController();

  @override
  void dispose() {
    _collectionController.dispose();
    _achievementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = _activeTabIndex == 1 ? 'Achievements' : 'Collection Log';
    final double panelHeight = (MediaQuery.sizeOf(context).height * 0.62).clamp(320, 620);
    final double panelTop = _tabHeight - _tabOverlap + _stripGap;
    final double tabTop = panelTop - _tabHeight + _tabOverlap;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: widget.horizontalInset,
        vertical: widget.verticalInset,
      ),
      child: SizedBox(
        height: panelHeight,
        child: Stack(
          children: [
            Positioned.fill(
              top: panelTop,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                decoration: BoxDecoration(
                  color: _panelColor.withValues(alpha: 0.95),
                  border: Border.all(color: _panelBorderColor, width: _borderWidth),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFFFE1BA),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: IndexedStack(
                        index: _activeTabIndex,
                        children: [
                          _woodShelfGrid(
                            context,
                            controller: _collectionController,
                            columns: 5,
                            itemCount: 100,
                          ),
                          _woodShelfGrid(
                            context,
                            controller: _achievementController,
                            columns: 3,
                            itemCount: 60,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: tabTop,
              child: _TabBarOverlay(
                activeIndex: _activeTabIndex,
                onSelect: (int index) => setState(() => _activeTabIndex = index),
                activeColor: _panelColor.withValues(alpha: 0.95),
                inactiveColor: _inactiveTabColor,
                borderColor: _panelBorderColor,
                height: _tabHeight,
                width: _tabWidth,
                radius: _tabRadius,
                spacing: _tabSpacing,
                borderWidth: _borderWidth,
                activeOverlap: _tabOverlap,
                inactiveLift: _inactiveLift,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _woodShelfGrid(
    BuildContext context, {
    required ScrollController controller,
    required int columns,
    required int itemCount,
  }) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double gridWidth = (screenWidth - 96).clamp(260, 560);
    final double gap = (gridWidth * 0.012).clamp(4, 8);
    final double slotSize = ((gridWidth - (gap * (columns - 1))) / columns).clamp(44, 90);

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(gap),
      decoration: BoxDecoration(
        color: const Color(0xFF4D2F1B),
        border: Border.all(color: const Color(0xFF9D724A), width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Scrollbar(
        controller: controller,
        thumbVisibility: true,
        interactive: true,
        child: GridView.builder(
          controller: controller,
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            childAspectRatio: 1,
          ),
          itemBuilder: (BuildContext context, int index) {
            return Container(
              width: slotSize,
              height: slotSize,
              decoration: BoxDecoration(
                color: const Color(0xFF6C472E),
                border: Border.all(color: const Color(0xFF2D1A0E), width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TabBarOverlay extends StatelessWidget {
  const _TabBarOverlay({
    required this.activeIndex,
    required this.onSelect,
    required this.activeColor,
    required this.inactiveColor,
    required this.borderColor,
    required this.height,
    required this.width,
    required this.radius,
    required this.spacing,
    required this.borderWidth,
    required this.activeOverlap,
    required this.inactiveLift,
  });

  final int activeIndex;
  final ValueChanged<int> onSelect;
  final Color activeColor;
  final Color inactiveColor;
  final Color borderColor;
  final double height;
  final double width;
  final double radius;
  final double spacing;
  final double borderWidth;
  final double activeOverlap;
  final double inactiveLift;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _GameTab(
              label: 'Collection',
              isActive: activeIndex == 0,
              height: height - 2,
              width: width,
              radius: radius,
              color: inactiveColor,
              borderColor: borderColor,
              borderWidth: borderWidth,
              onTap: () => onSelect(0),
              offsetDown: -inactiveLift,
            ),
            SizedBox(width: spacing),
            _GameTab(
              label: 'Achievements',
              isActive: activeIndex == 1,
              height: height - 2,
              width: width,
              radius: radius,
              color: inactiveColor,
              borderColor: borderColor,
              borderWidth: borderWidth,
              onTap: () => onSelect(1),
              offsetDown: -inactiveLift,
            ),
          ],
        ),
        Positioned(
          left: (width + spacing) * activeIndex,
          top: activeOverlap,
          child: _GameTab(
            label: activeIndex == 0 ? 'Collection' : 'Achievements',
            isActive: true,
            height: height,
            width: width,
            radius: radius,
            color: activeColor,
            borderColor: borderColor,
            borderWidth: borderWidth,
            onTap: () => onSelect(activeIndex),
            offsetDown: 0,
            removeBottomBorder: true,
          ),
        ),
      ],
    );
  }
}

class _GameTab extends StatelessWidget {
  const _GameTab({
    required this.label,
    required this.isActive,
    required this.height,
    required this.width,
    required this.radius,
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.onTap,
    required this.offsetDown,
    this.removeBottomBorder = false,
  });

  final String label;
  final bool isActive;
  final double height;
  final double width;
  final double radius;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback onTap;
  final double offsetDown;
  final bool removeBottomBorder;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offsetDown),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        ),
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            border: Border(
              top: BorderSide(color: borderColor, width: borderWidth),
              left: BorderSide(color: borderColor, width: borderWidth),
              right: BorderSide(color: borderColor, width: borderWidth),
              bottom: removeBottomBorder
                  ? BorderSide.none
                  : BorderSide(color: borderColor, width: borderWidth),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFFFF2D0) : const Color(0xFFD7B78F),
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
