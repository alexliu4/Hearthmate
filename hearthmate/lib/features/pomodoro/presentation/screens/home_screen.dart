import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:hearthmate/core/voyage_timer_logic.dart';
import 'package:hearthmate/game/game.dart';

class PomodoroHomeScreen extends StatefulWidget {
  const PomodoroHomeScreen({super.key});

  @override
  State<PomodoroHomeScreen> createState() => _PomodoroHomeScreenState();
}

class _PomodoroHomeScreenState extends State<PomodoroHomeScreen> {
  late final HearthGame _game;
  late final VoyageTimerLogic _timer;
  Duration _elapsed = Duration.zero;
  String? _selectedCharacter;

  @override
  void initState() {
    super.initState();
    _game = HearthGame();
    _timer = VoyageTimerLogic();
  }

  @override
  void dispose() {
    _timer.dispose();
    _game.pauseEngine();
    super.dispose();
  }

  void _handleTick(Duration next) {
    if (!mounted) {
      return;
    }
    setState(() {
      _elapsed = next;
    });
  }

  void _toggleVoyage() {
    if (_timer.isRunning) {
      _timer.pause(_handleTick);
      return;
    }
    _timer.start(_handleTick);
  }

  Future<void> _openCharacterSelect() async {
    final Size screen = MediaQuery.sizeOf(context);
    final double horizontalInset = (screen.width * 0.06).clamp(14, 28);
    final double verticalInset = (screen.height * 0.08).clamp(16, 40);

    final String? picked = await showDialog<String>(
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
                _characterOption(context, 'Miner'),
                const SizedBox(height: 12),
                _characterOption(context, 'Botanist'),
                const SizedBox(height: 12),
                _characterOption(context, 'Pirate'),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      _selectedCharacter = picked;
    });
  }

  Widget _characterOption(BuildContext context, String title) {
    final bool isSelected = _selectedCharacter == title;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        side: BorderSide(
          color: isSelected ? const Color(0xFFFFC680) : const Color(0xFF9D724A),
          width: 2,
        ),
        backgroundColor: isSelected
            ? const Color(0xFF6A4328)
            : const Color(0xFF5A3923),
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

  Future<void> _openCollectionLog() async {
    final Size screen = MediaQuery.sizeOf(context);
    final double horizontalInset = (screen.width * 0.05).clamp(12, 24);
    final double verticalInset = (screen.height * 0.08).clamp(14, 30);

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (BuildContext context) {
        return _CollectionOverlayDialog(
          horizontalInset: horizontalInset,
          verticalInset: verticalInset,
        );
      },
    );
  }

  String _formatClock(Duration value) {
    final int hours = value.inHours;
    final int minutes = value.inMinutes.remainder(60);
    final int seconds = value.inSeconds.remainder(60);
    return
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final String voyageLabel = _timer.isRunning
        ? _formatClock(_elapsed)
        : _elapsed == Duration.zero
            ? 'START NEW VOYAGE'
            : 'RESUME ${_formatClock(_elapsed)}';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _game)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.28),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double scale = _phoneScale(context);
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    16 * scale,
                    12 * scale,
                    16 * scale,
                    18 * scale,
                  ),
                  child: Column(
                    children: [
                      const Spacer(),
                      _buildHomePanel(voyageLabel, scale, constraints.maxWidth),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _phoneScale(BuildContext context) {
    final double shortestSide = MediaQuery.sizeOf(context).shortestSide;
    return (shortestSide / 390).clamp(0.82, 1.25);
  }

  Widget _buildHomePanel(String voyageLabel, double scale, double maxWidth) {
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
                    onTap: _openCharacterSelect,
                    icon: Icons.construction,
                    iconSize: iconSize,
                    textSize: actionSize,
                    line1: 'CHARACTER',
                    line2: _selectedCharacter == null
                        ? 'SELECT'
                        : _selectedCharacter!.toUpperCase(),
                  ),
                ),
                SizedBox(width: 10 * scale),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: (54 * scale).clamp(44, 60),
                    child: ElevatedButton(
                      onPressed: _toggleVoyage,
                      onLongPress: () => _timer.reset(_handleTick),
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
                    onTap: _openCollectionLog,
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
              color: Color(0xFFDFC89E),
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
                color: Color(0xFFDFC89E),
                fontWeight: FontWeight.w700,
                fontSize: textSize,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              line2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFDFC89E),
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

class _CollectionOverlayDialog extends StatefulWidget {
  const _CollectionOverlayDialog({
    required this.horizontalInset,
    required this.verticalInset,
  });

  final double horizontalInset;
  final double verticalInset;

  @override
  State<_CollectionOverlayDialog> createState() => _CollectionOverlayDialogState();
}

class _CollectionOverlayDialogState extends State<_CollectionOverlayDialog> {
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
    final bool achievementsSelected = _activeTabIndex == 1;
    final String title = achievementsSelected ? 'Achievements' : 'Collection Log';
    final double panelHeight = (MediaQuery.sizeOf(context).height * 0.62).clamp(320, 620);
    const double tabLift = 34;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: widget.horizontalInset,
        vertical: widget.verticalInset,
      ),
      child: SizedBox(
        height: panelHeight + tabLift,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              top: tabLift,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F2818).withValues(alpha: 0.95),
                  border: Border.all(color: const Color(0xFF8B5E3C), width: 4),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Color(0x88000000), blurRadius: 18, offset: Offset(0, 10)),
                  ],
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
              top: 0,
              left: 12,
              child: Row(
                children: [
                  _folderTab(
                    label: 'Collection',
                    selected: _activeTabIndex == 0,
                    onTap: () => setState(() => _activeTabIndex = 0),
                  ),
                  const SizedBox(width: 8),
                  _folderTab(
                    label: 'Achievements',
                    selected: _activeTabIndex == 1,
                    onTap: () => setState(() => _activeTabIndex = 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _folderTab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7A4D31) : const Color(0xFF573624),
          border: Border.all(
            color: selected ? const Color(0xFFFFC680) : const Color(0xFF8B5E3C),
            width: 2,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFFFFE7BF) : const Color(0xFFC69D72),
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.3,
          ),
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
