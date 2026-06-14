// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:rive_example/advanced/advanced.dart';
import 'package:rive_example/colors.dart';
import 'package:rive_example/examples/examples.dart';
import 'package:rive/rive.dart' as rive;
import 'package:flutter_animate/flutter_animate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await rive.RiveNative.init();

  runApp(
    MaterialApp(
      title: 'Rive Example',
      home: const RiveExampleApp(),
      debugShowCheckedModeBanner: false,
      // showPerformanceOverlay: true,
      darkTheme: ThemeData(
        fontFamily: 'JetBrainsMono',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(backgroundColor: appBarColor),
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
        ).copyWith(primary: primaryColor),
      ),
      themeMode: ThemeMode.dark,
    ),
  );
}

/// Determines which factory/renderer to use for the Rive examples.
///
/// In your app you can combine the usage of the Rive Renderer and the Flutter
/// Renderer. For this example app we have a static variable to determine which
/// factory to use app wide.
///
/// - `rive` uses the Rive Renderer
/// - `flutter` uses the Flutter Renderer (Skia / Impeller)
enum RiveFactoryToUse { rive, flutter }

/// An example application demoing Rive.
class RiveExampleApp extends StatefulWidget {
  const RiveExampleApp({Key? key}) : super(key: key);

  static RiveFactoryToUse factoryToUse = RiveFactoryToUse.rive;

  static rive.Factory get getCurrentFactory => switch (factoryToUse) {
        RiveFactoryToUse.rive => rive.Factory.rive,
        RiveFactoryToUse.flutter => rive.Factory.flutter,
      };

  @override
  State<RiveExampleApp> createState() => _RiveExampleAppState();
}

class _RiveExampleAppState extends State<RiveExampleApp> {
  // ScrollController for the CustomScrollView
  final ScrollController _scrollController = ScrollController();

  // Examples organized into sections — curated selection
  final _sections = [
    const _Section('Getting Started', [
      _Page(
        'Shared Texture',
        ExampleRivePanel(),
        'Example usage of the Shared Texture View widget.',
      ),
      _Page(
        'Manual Shared Texture Management',
        ExampleRivePanelOverlay(),
        'Use SharedRenderTexture.create + RiveSurface to share a texture '
            'with an OverlayEntry',
      ),
    ]),
    const _Section('Rive Features', [
      _Page('Audio', ExampleRiveAudio(), 'Example Rive file with audio.'),
    ]),
    const _Section('Asset Loading', [
      _Page(
        'Network .riv Asset',
        ExampleNetworkAsset(),
        'Load and display Rive graphics from network URLs.',
      ),
      _Page(
        'Out-of-band Assets',
        ExampleOutOfBandAssetLoading(),
        'Load Rive files with external assets (images, audio) separately.',
      ),
      _Page(
        'Out-of-band Assets - Audio',
        ExampleOutOfBandAssetAudioLoading(),
        'Load Rive files with audio assets.',
      ),
      _Page(
        'Out-of-band Assets - Cached',
        ExampleOutOfBandCachedAssetLoading(),
        'Load Rive files with cached external assets for better immediate availability.',
      ),
    ]),
    const _Section('Painters [Advanced]', [
      _Page(
        'Single Animation Painter',
        ExampleSingleAnimationPainter(),
        'Advanced: Custom painter for single animation playback.',
      ),
    ]),
    const _Section('Flutter Concepts/Integration', [
      _Page(
        'Flutter Ticker Mode',
        ExampleTickerMode(),
        'Rive graphics respect Flutter ticker mode.',
      ),
      _Page(
        'Flutter Time Dilation',
        ExampleTimeDilation(),
        'Rive graphics respect Flutter time dilation.',
      ),
    ]),
    const _Section('Legacy Features [Use data binding instead]', [
      _Page(
        'Inputs [Nested]',
        ExampleInputs(),
        'Legacy: Handle input [nested] controls in Rive graphics.',
      ),
      _Page(
        'Text Runs [Nested]',
        ExampleTextRuns(),
        'Legacy: Handle text runs [nested] components in Rive graphics.',
      ),
    ]),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Rive Examples'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Decorative liquid wave background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: _LiquidWaveBackground(),
          ),
          Column(
            children: [
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 80),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            int itemIndex = index;
                            int globalButtonIndex = 0;

                            for (int i = 0; i < _sections.length; i++) {
                              if (itemIndex == 0) {
                                return _SectionHeader(_sections[i].title)
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

                              if (itemIndex < _sections[i].pages.length) {
                                final page = _sections[i].pages[itemIndex];
                                final btn = Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 16.0),
                                  child: _NavButton(page: page),
                                );
                                final btnWidget = btn
                                    .animate()
                                    .fadeIn(
                                        duration: 400.ms,
                                        delay: (globalButtonIndex * 60).ms)
                                    .slideY(
                                        begin: 0.15,
                                        end: 0,
                                        duration: 400.ms,
                                        curve: Curves.easeOutCubic,
                                        delay: (globalButtonIndex * 60).ms)
                                    .scale(
                                        begin: const Offset(0.95, 0.95),
                                        end: const Offset(1.0, 1.0),
                                        duration: 400.ms,
                                        delay: (globalButtonIndex * 60).ms,
                                        curve: Curves.easeOutCubic);
                                globalButtonIndex++;
                                return btnWidget;
                              }
                              itemIndex -= _sections[i].pages.length;
                            }
                            return null;
                          }, childCount: _getTotalItemCount()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ColoredBox(
                color: Colors.black,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Factory to use:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<RiveFactoryToUse>(
                                value: RiveFactoryToUse.rive,
                                groupValue: RiveExampleApp.factoryToUse,
                                onChanged: (value) {
                                  setState(() {
                                    RiveExampleApp.factoryToUse =
                                        value as RiveFactoryToUse;
                                  });
                                },
                              ),
                              const Text(
                                'Rive Renderer',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<RiveFactoryToUse>(
                                value: RiveFactoryToUse.flutter,
                                groupValue: RiveExampleApp.factoryToUse,
                                onChanged: (value) {
                                  setState(() {
                                    RiveExampleApp.factoryToUse =
                                        value as RiveFactoryToUse;
                                  });
                                },
                              ),
                              const Text(
                                'Flutter Renderer',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getTotalItemCount() {
    int count = 0;
    for (final section in _sections) {
      count += 1; // Section header
      count += section.pages.length; // Pages in section
    }
    return count;
  }
}

/// Class used to organize demo sections.
class _Section {
  final String title;
  final List<_Page> pages;

  const _Section(this.title, this.pages);
}

/// Class used to organize demo pages.
class _Page {
  final String name;
  final Widget page;
  final String description;

  const _Page(this.name, this.page, this.description);
}

/// Section header widget with divider.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: primaryColor),
          ),
        ),
        const Divider(color: primaryColor, thickness: 0.5, height: 1),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Button to navigate to demo pages with hover overlay.
class _NavButton extends StatefulWidget {
  const _NavButton({required this.page});

  final _Page page;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _removeOverlay();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy - 80, // Position above the button
        left: position.dx + (size.width / 2) - 150, // Center horizontally
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.page.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _showOverlay();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _removeOverlay();
      },
      child: Center(
        child: AnimatedContainer(
          duration: 300.ms,
          curve: Curves.easeInOut,
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: _isHovered
                ? LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.2),
                      primaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                    sigmaX: _isHovered ? 12 : 6,
                    sigmaY: _isHovered ? 12 : 6),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isHovered
                          ? primaryColor.withOpacity(0.5)
                          : primaryColor.withOpacity(0.15),
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isHovered
                          ? primaryColor.withOpacity(0.15)
                          : primaryColor.withOpacity(0.05),
                      elevation: _isHovered ? 8 : 2,
                      shadowColor: primaryColor.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                    child: Text(
                      widget.page.name,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: _isHovered
                                ? primaryColor
                                : Colors.white.withOpacity(0.85),
                          ),
                    ),
                    onPressed: () {
                      _removeOverlay();
                      Navigator.push(
                        context,
                        PageRouteBuilder<void>(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  _WrappedPage(page: widget.page),
                          transitionsBuilder: (context, animation,
                              secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.95, end: 1.0)
                                    .animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic)),
                                child: child,
                              ),
                            );
                          },
                          transitionDuration: 350.ms,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Scaffold wrapper for the page.
class _WrappedPage extends StatelessWidget {
  const _WrappedPage({required this.page});

  final _Page page;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(page.name)),
      body: page.page,
    );
  }
}

/// Decorative liquid wave background using sine deformation.
class _LiquidWaveBackground extends StatefulWidget {
  @override
  State<_LiquidWaveBackground> createState() => _LiquidWaveBackgroundState();
}

class _LiquidWaveBackgroundState extends State<_LiquidWaveBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: 3000.ms,
    )..repeat();
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
          painter: _LiquidWavePainter(phase: _controller.value * 2 * math.pi),
          size: Size.infinite,
        );
      },
    );
  }
}

class _LiquidWavePainter extends CustomPainter {
  final double phase;

  _LiquidWavePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withOpacity(0.3),
          primaryColor.withOpacity(0.05),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = math.sin((x / size.width) * 2 * math.pi * 1.5 + phase) * 20 +
          math.sin((x / size.width) * 4 * math.pi + phase * 1.5) * 8 +
          size.height * 0.5;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Glow pass
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withOpacity(0.15),
          primaryColor.withOpacity(0.02),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(_LiquidWavePainter oldDelegate) =>
      oldDelegate.phase != phase;
}
