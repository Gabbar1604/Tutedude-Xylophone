import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  bool _isPlaying = false;

  final List<Color> _keyColors = [
    const Color(0xFFE53E3E), // Red
    const Color(0xFFFF8C00), // Orange
    const Color(0xFFFFC107), // Yellow
    const Color(0xFF4CAF50), // Green
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFF2196F3), // Blue
    const Color(0xFF9C27B0), // Purple
  ];

  final List<String> _noteNames = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      7,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers
        .map(
          (controller) => Tween<double>(begin: 1.0, end: 0.95).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void playSound(int noteNumber) async {
    if (_isPlaying) return;

    setState(() => _isPlaying = true);
    HapticFeedback.lightImpact();
    _animationControllers[noteNumber - 1].forward().then((_) {
      _animationControllers[noteNumber - 1].reverse();
    });

    try {
      final player = AudioPlayer();
      await player.play(AssetSource('assets_note$noteNumber.wav'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Widget buildKey({
    required Color color,
    required int noteNumber,
    required String noteName,
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Expanded(
      child: AnimatedBuilder(
        animation: _scaleAnimations[noteNumber - 1],
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimations[noteNumber - 1].value,
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 8.0 : 6.0,
                horizontal: isLargeScreen ? 24.0 : 16.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(-2, -2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 20),
                  onTap: () => playSound(noteNumber),
                  child: Container(
                    padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              noteName,
                              style: TextStyle(
                                fontSize: isLargeScreen ? 32 : 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Note $noteNumber',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 16 : 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.music_note_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: isLargeScreen ? 32 : 28,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final isTablet = screenWidth > 768;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.music_note_rounded,
              color: Colors.white,
              size: isLargeScreen ? 36 : 32,
            ),
            const SizedBox(width: 12),
            Text(
              'Xylophone Pro',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isLargeScreen ? 32 : 28,
                color: Colors.white,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        toolbarHeight: isLargeScreen ? 100 : 80,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withOpacity(0.1),
              const Color(0xFFF093FB).withOpacity(0.1),
              const Color(0xFF764ba2).withOpacity(0.1),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: isLargeScreen ? 20 : 16,
              bottom: isLargeScreen ? 20 : 16,
              left: isTablet ? 40 : 0,
              right: isTablet ? 40 : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isLargeScreen) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(
                      'Tap the keys to play beautiful notes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF667eea),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      return buildKey(
                        color: _keyColors[index],
                        noteNumber: index + 1,
                        noteName: _noteNames[index],
                        context: context,
                      );
                    },
                  ),
                ),
                if (isLargeScreen) ...[
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF667eea),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Professional Xylophone Experience',
                            style: TextStyle(
                              color: Color(0xFF667eea),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
