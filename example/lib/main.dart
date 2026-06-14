// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:rive_example/advanced/advanced.dart';
import 'package:rive_example/colors.dart';
import 'package:rive_example/examples/examples.dart';
import 'package:rive/rive.dart' as rive;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await rive.RiveNative.init();

  final prefs = await SharedPreferences.getInstance();
  final darkMode = prefs.getBool('darkMode') ?? true;

  runApp(
    RiveExampleApp(darkMode: darkMode),
  );
}

class RiveExampleApp extends StatefulWidget {
  final bool darkMode;
  const RiveExampleApp({super.key, required this.darkMode});

  static ValueNotifier<RiveFactoryToUse> factoryNotifier =
      ValueNotifier(RiveFactoryToUse.rive);
  static ValueNotifier<bool> isDarkMode = ValueNotifier(true);

  static rive.Factory get getCurrentFactory =>
      switch (factoryNotifier.value) {
        RiveFactoryToUse.rive => rive.Factory.rive,
        RiveFactoryToUse.flutter => rive.Factory.flutter,
      };

  @override
  State<RiveExampleApp> createState() => _RiveExampleAppState();
}

class _RiveExampleAppState extends State<RiveExampleApp> {
  final ScrollController _scrollController = ScrollController();
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.darkMode;
    RiveExampleApp.isDarkMode = ValueNotifier(_darkMode);
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = !_darkMode;
      RiveExampleApp.isDarkMode.value = _darkMode;
      prefs.setBool('darkMode', _darkMode);
    });
  }

  // ── Curated sections ──────────────────────────────────────────────
  final _sections = [
    const _Section('Getting Started', [
      _Page('Shared Texture', ExampleRivePanel(),
          'Example usage of the Shared Texture View widget.'),
      _Page('Manual Shared Texture Management', ExampleRivePanelOverlay(),
          'Use SharedRenderTexture.create + RiveSurface to share a texture with an OverlayEntry'),
    ]),
    const _Section('Rive Features', [
      _Page('Audio', ExampleRiveAudio(), 'Example Rive file with audio.'),
    ]),
    const _Section('Asset Loading', [
      _Page('Network .riv Asset', ExampleNetworkAsset(),
          'Load and display Rive graphics from network URLs.'),
      _Page('Out-of-band Assets', ExampleOutOfBandAssetLoading(),
          'Load Rive files with external assets (images, audio) separately.'),
      _Page('Out-of-band Assets - Audio', ExampleOutOfBandAssetAudioLoading(),
          'Load Rive files with audio assets.'),
      _Page('Out-of-band Assets - Cached', ExampleOutOfBandCachedAssetLoading(),
          'Load Rive files with cached external assets for better immediate availability.'),
    ]),
    const _Section('Painters [Advanced]', [
      _Page('Single Animation Painter', ExampleSingleAnimationPainter(),
          'Advanced: Custom painter for single animation playback.'),
    ]),
    const _Section('Flutter Concepts/Integration', [
      _Page('Flutter Ticker Mode', ExampleTickerMode(),
          'Rive graphics respect Flutter ticker mode.'),
      _Page('Flutter Time Dilation', ExampleTimeDilation(),
          'Rive graphics respect Flutter time dilation.'),
    ]),
    const _Section('Legacy Features [Use data binding instead]', [
      _Page('Inputs [Nested]', ExampleInputs(),
          'Legacy: Handle input [nested] controls in Rive graphics.'),
      _Page('Text Runs [Nested]', ExampleTextRuns(),
          'Legacy: Handle text runs [nested] components in Rive graphics.'),
    ]),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _darkMode ? _darkTheme() : _lightTheme();

    return ValueListenableBuilder<bool>(
      valueListenable: RiveExampleApp.isDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Rive Curated',
          debugShowCheckedModeBanner: false,
          theme: isDark ? _darkTheme() : _lightTheme(),
          home: _HomeScreen(
            sections: _sections,
            scrollController: _scrollController,
            isDark: isDark,
            onToggleTheme: _toggleTheme,
          ),
        );
      },
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurface,
      ),
      textTheme: _textTheme(Brightness.dark),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurface,
      ),
      textTheme: _textTheme(Brightness.light),
    );
  }

  TextTheme _textTheme(Brightness brightness) {
    final primary = brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF1A1A2E);
    final secondary = brightness == Brightness.dark
        ? const Color(0xFFB0B0D0)
        : const Color(0xFF6B6B8D);
    return TextTheme(
      titleLarge: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w500, color: primary),
      bodyLarge: TextStyle(fontSize: 16, color: primary),
      bodyMedium: TextStyle(fontSize: 14, color: secondary),
      labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: primary),
    );
  }
}

// ── Home Screen ─────────────────────────────────────────────────────
class _HomeScreen extends StatelessWidget {
  final List<_Section> sections;
  final ScrollController scrollController;
  final bool isDark;
  final VoidCallback onToggleTheme;

  const _HomeScreen({
    required this.sections,
    required this.scrollController,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Rive Curated',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode,
                color: primaryColor),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Liquid wave background
          Positioned(
            top: 0, left: 0, right: 0, height: 200,
            child: _LiquidWaveBackground(isDark: isDark),
          ),
          Column(
            children: [
              Expanded(
                child: Scrollbar(
                  controller: scrollController,
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverPadding(
                        padding:
                            const EdgeInsets.only(left: 8, right: 8, top: 80),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            int itemIndex = index;
                            int globalButtonIndex = 0;
                            for (int i = 0; i < sections.length; i++) {
                              if (itemIndex == 0) {
                                return _SectionHeader(
                                        sections[i].title, isDark: isDark)
                                    .animate()
                                    .fadeIn(
                                        duration: 400.ms,
                                        delay: (i * 100).ms)
                                    .slideX(
                                        begin: -0.05,
                                        end: 0,
                                        duration: 400.ms,
                                        delay: (i * 100).ms);
                              }
                              itemIndex--;
                              if (itemIndex < sections[i].pages.length) {
                                final page = sections[i].pages[itemIndex];
                                final btn = Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 16.0),
                                  child: _NavButton(
                                      page: page, isDark: isDark),
                                );
                                final w = btn
                                    .animate()
                                    .fadeIn(
                                        duration: 400.ms,
                                        delay:
                                            (globalButtonIndex * 60).ms)
                                    .slideY(
                                        begin: 0.15,
                                        end: 0,
                                        duration: 400.ms,
                                        curve: Curves.easeOutCubic,
                                        delay:
                                            (globalButtonIndex * 60).ms)
                                    .scale(
                                        begin:
                                            const Offset(0.95, 0.95),
                                        end: const Offset(1.0, 1.0),
                                        duration: 400.ms,
                                        delay:
                                            (globalButtonIndex * 60).ms,
                                        curve: Curves.easeOutCubic);
                                globalButtonIndex++;
                                return w;
                              }
                              itemIndex -= sections[i].pages.length;
                            }
                            return null;
                          }, childCount: _totalItemCount()),
                        ),
                      ),
                      // Bottom spacing so factory bar doesn't overlap
                      SliverPadding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height *
                                0.14),
                      ),
                    ],
                  ),
                ),
              ),
              // Factory selector bar
              _FactoryBar(isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }

  int _totalItemCount() {
    int c = 0;
    for (final s in sections) {
      c += 1 + s.pages.length;
    }
    return c;
  }
}

// ── Factory Bar ─────────────────────────────────────────────────────
class _FactoryBar extends StatefulWidget {
  final bool isDark;
  const _FactoryBar({required this.isDark});

  @override
  State<_FactoryBar> createState() => _FactoryBarState();
}

class _FactoryBarState extends State<_FactoryBar> {
  @override
  void initState() {
    super.initState();
    RiveExampleApp.factoryNotifier.addListener(_onFactoryChange);
  }

  @override
  void dispose() {
    RiveExampleApp.factoryNotifier.removeListener(_onFactoryChange);
    super.dispose();
  }

  void _onFactoryChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark
        ? darkSurface.withOpacity(0.92)
        : lightSurface.withOpacity(0.92);
    return ClipRRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 8, top: 12),
          decoration: BoxDecoration(
            color: bg,
            border: Border(
                top: BorderSide(
                    color: primaryColor.withOpacity(0.15), width: 0.5)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _rendererOption(context, 'Rive', RiveFactoryToUse.rive),
                const SizedBox(width: 24),
                _rendererOption(
                    context, 'Flutter', RiveFactoryToUse.flutter),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rendererOption(
      BuildContext context, String label, RiveFactoryToUse value) {
    final selected = RiveExampleApp.factoryNotifier.value == value;
    return GestureDetector(
      onTap: () => RiveExampleApp.factoryNotifier.value = value,
      child: AnimatedContainer(
        duration: 300.ms,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: selected
              ? const LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)
              : null,
          color: selected ? null : Colors.transparent,
          border: Border.all(
              color: selected
                  ? Colors.transparent
                  : primaryColor.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ── Section Header ──────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader(this.title, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                colors: [primaryColor, secondaryColor],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF1A1A2E),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nav Button with Glassmorphism ───────────────────────────────────
class _NavButton extends StatefulWidget {
  final _Page page;
  final bool isDark;
  const _NavButton({required this.page, required this.isDark});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = _isHovered
        ? primaryColor.withOpacity(0.5)
        : primaryColor.withOpacity(0.12);
    final bgColor = _isHovered
        ? primaryColor.withOpacity(0.08)
        : (widget.isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Center(
        child: AnimatedContainer(
          duration: 300.ms,
          curve: Curves.easeInOut,
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                        color: primaryColor.withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 2)
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                  sigmaX: _isHovered ? 12 : 6,
                  sigmaY: _isHovered ? 12 : 6),
              child: Material(
                color: bgColor,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _navigate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [primaryColor, secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            widget.page.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _isHovered
                                  ? primaryColor
                                  : (widget.isDark
                                      ? Colors.white.withOpacity(0.85)
                                      : const Color(0xFF1A1A2E)),
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            size: 20,
                            color: _isHovered
                                ? primaryColor
                                : Colors.white24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigate() {
    Navigator.push(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _WrappedPage(page: widget.page, isDark: widget.isDark),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Stack(
            children: [
              // Liquid reveal effect
              ClipPath(
                clipper: _WaveRevealClipper(animation.value),
                child: child,
              ),
              FadeTransition(
                opacity: animation.drive(Tween(begin: 0.0, end: 1.0)),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                      CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic)),
                  child: child,
                ),
              ),
            ],
          );
        },
        transitionDuration: 400.ms,
      ),
    );
  }
}

// ── Wave Reveal Clipper ─────────────────────────────────────────────
class _WaveRevealClipper extends CustomClipper<Path> {
  final double progress;
  _WaveRevealClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();
    final waveHeight = 20.0 * (1 - progress);
    path.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final y = math.sin((x / size.width) * 2 * math.pi * 2 + progress * 2 * math.pi) *
              waveHeight +
          size.height * (1 - progress);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveRevealClipper old) => old.progress != progress;
}

// ── Wrapped Page ────────────────────────────────────────────────────
class _WrappedPage extends StatelessWidget {
  final _Page page;
  final bool isDark;
  const _WrappedPage({required this.page, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(page.name)),
      body: page.page,
    );
  }
}

// ── Liquid Wave Background ──────────────────────────────────────────
class _LiquidWaveBackground extends StatefulWidget {
  final bool isDark;
  const _LiquidWaveBackground({required this.isDark});

  @override
  State<_LiquidWaveBackground> createState() =>
      _LiquidWaveBackgroundState();
}

class _LiquidWaveBackgroundState extends State<_LiquidWaveBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 3000.ms)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _LiquidWavePainter(
              phase: _controller.value * 2 * math.pi, isDark: widget.isDark),
          size: Size.infinite,
        );
      },
    );
  }
}

class _LiquidWavePainter extends CustomPainter {
  final double phase;
  final bool isDark;

  _LiquidWavePainter({required this.phase, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final baseOpacity = isDark ? 0.25 : 0.12;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withOpacity(baseOpacity),
          primaryColor.withOpacity(baseOpacity * 0.3),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      path.lineTo(
        x,
        math.sin((x / size.width) * 2 * math.pi * 1.5 + phase) * 20 +
            math.sin((x / size.width) * 4 * math.pi + phase * 1.5) * 8 +
            size.height * 0.5,
      );
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withOpacity(baseOpacity * 0.6),
          primaryColor.withOpacity(baseOpacity * 0.1),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(_LiquidWavePainter old) =>
      old.phase != phase || old.isDark != isDark;
}

// ── Helper classes ──────────────────────────────────────────────────
class _Section {
  final String title;
  final List<_Page> pages;
  const _Section(this.title, this.pages);
}

class _Page {
  final String name;
  final Widget page;
  final String description;
  const _Page(this.name, this.page, this.description);
}

enum RiveFactoryToUse { rive, flutter }
