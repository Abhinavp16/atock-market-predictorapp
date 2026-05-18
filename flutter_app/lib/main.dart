import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'core/app_repository.dart';
import 'core/providers.dart';

typedef JsonMap = Map<String, dynamic>;
const appBrandName = 'NiveshIQ';
const appLogoAssetPath = 'assets/images/logo_light.png';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = AppRepository();
  await repository.restoreSession();
  runApp(
    ProviderScope(
      overrides: [appRepositoryProvider.overrideWithValue(repository)],
      child: LstmInsightApp(repository: repository),
    ),
  );
}

class LstmInsightApp extends StatelessWidget {
  const LstmInsightApp({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData(brightness: Brightness.light).textTheme;
    final textTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: 48,
        height: 56 / 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.96,
        color: AppColors.onSurface,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.32,
        color: AppColors.onSurface,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 16,
        height: 24 / 16,
        color: AppColors.onSurfaceVariant,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        color: AppColors.onSurfaceVariant,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: AppColors.onSurfaceVariant,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appBrandName,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.95,
              maxScaleFactor: 1.08,
            ),
          ),
          child: child!,
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surfaceLowest,
        ),
        textTheme: textTheme,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceLowest,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.outlineSoft),
          ),
        ),
      ),
      home: AppLaunchGate(repository: repository),
      routes: {
        '/login': (_) => LoginScreen(repository: repository),
        '/register': (_) => RegisterScreen(repository: repository),
        '/home': (_) => HomeDashboardScreen(repository: repository),
        '/market': (_) => MarketAnalyticsScreen(repository: repository),
        '/predict': (_) =>
            PredictionScreen(repository: repository, symbol: 'INFY'),
        '/watchlist': (_) => WatchlistScreen(repository: repository),
        '/profile': (_) => ProfileScreen(repository: repository),
        '/notifications': (_) => NotificationsScreen(repository: repository),
        '/settings': (_) => SettingsScreen(repository: repository),
        '/admin': (_) => AdminPanelScreen(repository: repository),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/stock') {
          final symbol = settings.arguments as String? ?? 'RELIANCE';
          return MaterialPageRoute<void>(
            builder: (_) =>
                StockDetailsScreen(repository: repository, symbol: symbol),
          );
        }
        if (settings.name == '/prediction-detail') {
          final symbol = settings.arguments as String? ?? 'INFY';
          return MaterialPageRoute<void>(
            builder: (_) =>
                PredictionScreen(repository: repository, symbol: symbol),
          );
        }
        return null;
      },
    );
  }
}

class AppColors {
  static const background = Color(0xFFFCF8FF);
  static const surface = Color(0xFFF5F2FF);
  static const surfaceLow = Color(0xFFF0ECF9);
  static const surfaceHigh = Color(0xFFEAE6F4);
  static const surfaceHighest = Color(0xFFE4E1EE);
  static const surfaceLowest = Colors.white;
  static const onSurface = Color(0xFF1B1B24);
  static const onSurfaceVariant = Color(0xFF464555);
  static const outline = Color(0xFF777587);
  static const outlineVariant = Color(0xFFC7C4D8);
  static const outlineSoft = Color(0x33C7C4D8);
  static const primary = Color(0xFF3525CD);
  static const primaryContainer = Color(0xFF4F46E5);
  static const onPrimary = Colors.white;
  static const onPrimaryContainer = Color(0xFFDAD7FF);
  static const secondary = Color(0xFF006591);
  static const secondaryContainer = Color(0xFF39B8FD);
  static const tertiary = Color(0xFF7E3000);
  static const tertiaryContainer = Color(0xFFA44100);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const success = Color(0xFF10B981);
  static const page = Color(0xFFF8FAFC);
}

enum NavTab { home, market, predict, watch, profile }

class AppLaunchGate extends StatelessWidget {
  const AppLaunchGate({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    if (repository.isAuthenticated) {
      return HomeDashboardScreen(repository: repository);
    }
    if (repository.hasSeenSplash) {
      return LoginScreen(repository: repository);
    }
    return SplashScreen(repository: repository);
  }
}

class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.child,
    this.activeTab,
    this.actions = const [],
    this.showTopBar = true,
    this.brandAction,
  });

  final Widget child;
  final NavTab? activeTab;
  final List<Widget> actions;
  final bool showTopBar;
  final VoidCallback? brandAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (showTopBar)
            SafeArea(
              bottom: false,
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceLowest,
                  border: Border(
                    bottom: BorderSide(color: AppColors.outlineSoft),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 12,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap:
                          brandAction ??
                          () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (_) => false,
                          ),
                      borderRadius: BorderRadius.circular(12),
                      child: const Row(
                        children: [
                          BrandLockup(
                            color: AppColors.primary,
                            logoSize: 22,
                            fontSize: 20,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ...actions,
                  ],
                ),
              ),
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: activeTab == null
          ? null
          : SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: NavTab.values
                      .map(
                        (tab) => Expanded(
                          child: NavItem(tab: tab, active: tab == activeTab),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
    );
  }
}

class NavItem extends StatelessWidget {
  const NavItem({super.key, required this.tab, required this.active});

  final NavTab tab;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final route = switch (tab) {
      NavTab.home => '/home',
      NavTab.market => '/market',
      NavTab.predict => '/predict',
      NavTab.watch => '/watchlist',
      NavTab.profile => '/profile',
    };
    final icon = switch (tab) {
      NavTab.home => Icons.home_outlined,
      NavTab.market => Icons.query_stats,
      NavTab.predict => Icons.online_prediction_outlined,
      NavTab.watch => Icons.visibility_outlined,
      NavTab.profile => Icons.person_outline,
    };
    final label = switch (tab) {
      NavTab.home => 'Home',
      NavTab.market => 'Market',
      NavTab.predict => 'Predict',
      NavTab.watch => 'Watch',
      NavTab.profile => 'Profile',
    };

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: active
                    ? AppColors.onPrimary
                    : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AsyncPage extends StatelessWidget {
  const AsyncPage({
    super.key,
    required this.future,
    required this.builder,
    this.padding = const EdgeInsets.all(16),
  });

  final Future<JsonMap> future;
  final Widget Function(BuildContext context, JsonMap data) builder;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<JsonMap>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: padding,
              child: SurfaceCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_tethering_error_rounded,
                      color: AppColors.error,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Unable to load data',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return builder(context, snapshot.data ?? <String, dynamic>{});
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      showTopBar: false,
      child: AsyncPage(
        future: repository.fetchBootstrap(),
        builder: (context, data) {
          final splash = asMap(data['splash']);
          final stats = asListOfMaps(splash['stats']);
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 28),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFF3EFFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.14),
                                AppColors.secondaryContainer.withValues(
                                  alpha: 0.08,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(36),
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x12000000),
                                    blurRadius: 30,
                                    offset: Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: BrandMark(
                                  size: 82,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.14),
                            ),
                          ),
                          child: Text(
                            'Next-Gen Forecasting',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          splash['title']?.toString() ?? appBrandName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                color: AppColors.onSurface,
                                fontSize: 44,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          splash['subtitle']?.toString() ?? '',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await repository.markSplashSeen();
                              if (!context.mounted) return;
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (_) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Get Started'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SurfaceCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 22,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: stats
                          .map(
                            (item) => Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    item['value']?.toString() ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['label']?.toString() ?? '',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      showTopBar: false,
      child: AsyncPage(
        future: widget.repository.fetchBootstrap(),
        builder: (context, data) {
          final slides = asListOfMaps(data['onboarding']);
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const BrandLockup(
                        color: AppColors.primary,
                        logoSize: 22,
                        fontSize: 20,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (_) => false,
                        ),
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: slides.length,
                    onPageChanged: (value) => setState(() => _page = value),
                    itemBuilder: (context, index) {
                      final slide = slides[index];
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: index == 1
                                    ? const Color(0xFFF6F4FF)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: AppColors.outlineSoft,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0D000000),
                                    blurRadius: 18,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                height: 250,
                                child: index == 0
                                    ? const OnboardingHeroOne()
                                    : index == 1
                                    ? const OnboardingHeroTwo()
                                    : const OnboardingHeroThree(),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (index == 1
                                            ? AppColors.secondaryContainer
                                            : AppColors.primary)
                                        .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                slide['kicker']?.toString() ?? '',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: index == 1
                                          ? AppColors.secondary
                                          : AppColors.primary,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              slide['title']?.toString() ?? '',
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(fontSize: 40, height: 1.05),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              slide['description']?.toString() ?? '',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    height: 1.6,
                                  ),
                            ),
                            const SizedBox(height: 20),
                            if (index == 0)
                              Row(
                                children: asListOfMaps(slide['stats'])
                                    .map(
                                      (item) => Expanded(
                                        child: SurfaceCard(
                                          padding: const EdgeInsets.all(18),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['value']?.toString() ?? '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium
                                                    ?.copyWith(
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                item['label']?.toString() ?? '',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList()
                                    .separated(const SizedBox(width: 12)),
                              ),
                            if (index == 1)
                              ...asListOfStrings(slide['highlights']).map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(item)),
                                    ],
                                  ),
                                ),
                              ),
                            if (index == 2)
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: asListOfStrings(slide['assets'])
                                    .map(
                                      (item) => SignalPill(
                                        label: item,
                                        tone: SignalTone.primary,
                                      ),
                                    )
                                    .toList(),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Row(
                    children: [
                      ...List.generate(
                        slides.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: _page == index ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _page == index
                                ? AppColors.primary
                                : AppColors.outlineVariant,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (_page == slides.length - 1) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/register',
                              (_) => false,
                            );
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _page == slides.length - 1 ? 'Continue' : 'Next',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController(text: 'password!');
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final response = await widget.repository.register(
        _fullName.text,
        _email.text,
        _password.text,
      );
      if (!mounted) return;
      setState(() => _message = response['message']?.toString());
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (error) {
      setState(
        () => _message = error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      showTopBar: false,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BrandLockup(
                    color: AppColors.primary,
                    logoSize: 22,
                    fontSize: 20,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Login'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Signal-Driven Market Intelligence',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Begin Your\nForecast',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 56, height: 1),
              ),
              const SizedBox(height: 18),
              Text(
                'Unlock high-precision predictive modeling powered by Long Short-Term Memory neural networks. Transform raw market data into actionable intelligence with transparent accuracy metrics.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 24),
              const FeatureTile(
                icon: Icons.speed,
                title: 'Real-time Inference',
                description:
                    'Low-latency predictions processed across distributed global nodes.',
              ),
              const SizedBox(height: 16),
              const FeatureTile(
                icon: Icons.shield_outlined,
                title: 'Encrypted Tensors',
                description:
                    'Your proprietary datasets are isolated and secured with enterprise-grade encryption.',
              ),
              const SizedBox(height: 24),
              SurfaceCard(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                accent: AppColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Join the community of precision analysts.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    LabeledField(
                      label: 'FULL NAME',
                      controller: _fullName,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),
                    LabeledField(
                      label: 'EMAIL ADDRESS',
                      controller: _email,
                      icon: Icons.mail_outline,
                    ),
                    const SizedBox(height: 14),
                    LabeledField(
                      label: 'PASSWORD',
                      controller: _password,
                      icon: Icons.lock_outline,
                      obscureText: true,
                      helper:
                          'Must be at least 8 characters with one special character.',
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _message!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Create Account'),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: AppColors.outlineSoft),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: AppColors.outlineSoft),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: const [
                        Expanded(
                          child: SocialButton(
                            icon: Icons.g_mobiledata_rounded,
                            label: 'Google',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: SocialButton(
                            icon: Icons.terminal_rounded,
                            label: 'GitHub',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text.rich(
                      TextSpan(
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.6),
                        children: const [
                          TextSpan(
                            text:
                                'By clicking "Create Account", you agree to our ',
                          ),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: Text(
                  '© 2026 NiveshIQ. All rights reserved. Built for disciplined, data-led investing.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'pradeep@niveshiq.in');
  final _password = TextEditingController(text: 'password!');
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final response = await widget.repository.login(
        _email.text,
        _password.text,
      );
      if (!mounted) return;
      setState(() => _message = response['message']?.toString());
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (error) {
      setState(
        () => _message = error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _socialLogin(String provider) async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final response = await widget.repository.socialLogin(provider);
      if (!mounted) return;
      setState(() => _message = response['message']?.toString());
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (error) {
      setState(
        () => _message = error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      showTopBar: false,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: BrandMark(
                        size: 32,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    appBrandName,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Modern Market Intelligence',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  SurfaceCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        LabeledField(
                          label: 'WORK EMAIL',
                          controller: _email,
                          icon: Icons.mail_outline,
                        ),
                        const SizedBox(height: 16),
                        LabeledField(
                          label: 'PASSWORD',
                          controller: _password,
                          icon: Icons.lock_outline,
                          obscureText: true,
                          actionLabel: 'Forgot?',
                        ),
                        if (_message != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            _message!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.primary),
                          ),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Sign In'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: AppColors.outlineSoft),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: Text(
                                'Or continue with',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: AppColors.outlineSoft),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: SocialButton(
                                icon: Icons.g_mobiledata_rounded,
                                label: 'Google',
                                onPressed: _loading
                                    ? null
                                    : () => _socialLogin('google'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SocialButton(
                                icon: Icons.apple,
                                label: 'Apple',
                                onPressed: _loading
                                    ? null
                                    : () => _socialLogin('apple'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Contact Administrator'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  JsonMap? _dashboard;
  String? _error;
  bool _loading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard({bool keepExisting = false}) async {
    setState(() {
      _error = null;
      if (!keepExisting || _dashboard == null) {
        _loading = true;
      }
    });
    try {
      final data = await widget.repository.fetchDashboard();
      if (!mounted) return;
      setState(() {
        _dashboard = data;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    await _loadDashboard(keepExisting: true);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      activeTab: NavTab.home,
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Builder(
            builder: (context) {
              if (_loading && _dashboard == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loading your market dashboard',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Fetching the latest Indian market data and model signals.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 22),
                    const SurfaceCard(
                      padding: EdgeInsets.all(24),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.6,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Dashboard is loading. Pull down to retry if it takes too long.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              if (_dashboard == null) {
                return SurfaceCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_tethering_error_rounded,
                        color: AppColors.error,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Unable to load the home dashboard',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error ?? 'Unknown error',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _loadDashboard(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final data = _dashboard!;
              final liveCards = asListOfMaps(data['liveCards']);
              final highReturn = asMap(data['highReturn']);
              final highReturnItems = asListOfMaps(highReturn['items']);
              final trending = asListOfMaps(data['trendingInsights']);
              final watchlist = asListOfMaps(data['watchlistPreview']);
              final aiPrediction = asMap(data['aiPrediction']);
              final featured = asMap(data['featuredAnalysis']);
              final highReturnSourceLabel =
                  highReturn['sourceLabel']?.toString() ?? '';
              final highReturnBadgeColor = highReturnSourceLabel == 'Live'
                  ? AppColors.success
                  : highReturnSourceLabel == 'Mostly Live'
                  ? AppColors.secondary
                  : highReturnSourceLabel == 'Market Closed'
                  ? AppColors.tertiaryContainer
                  : AppColors.onSurfaceVariant;
              final compactHome = MediaQuery.sizeOf(context).width < 390;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) ...[
                    SurfaceCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.tertiaryContainer,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Showing the latest loaded dashboard. Pull down to retry the refresh.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    data['greeting']?.toString() ?? '',
                    style: (compactHome
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.headlineLarge)
                        ?.copyWith(fontWeight: FontWeight.w600, height: 1.1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['subtitle']?.toString() ?? '',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 18),
                  SearchField(
                    placeholder:
                        data['searchPlaceholder']?.toString() ?? 'Search',
                    readOnly: true,
                    onTap: () async {
                      final selected = await showSymbolSearchSheet(
                        context,
                        widget.repository,
                      );
                      if (!context.mounted || selected == null) {
                        return;
                      }
                      final symbol = selected['symbol']?.toString();
                      if (symbol == null || symbol.isEmpty) {
                        return;
                      }
                      Navigator.pushNamed(context, '/stock', arguments: symbol);
                    },
                  ),
                  const SizedBox(height: 18),
                  ...liveCards.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/stock',
                          arguments: item['symbol']?.toString(),
                        ),
                        child: SurfaceCard(
                          padding: const EdgeInsets.all(18),
                          accent: item['accent']?.toString() == 'error'
                              ? AppColors.error
                              : AppColors.secondaryContainer,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['symbol']?.toString() ?? '',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['name']?.toString() ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    number(item['changePct']) >= 0
                                        ? Icons.trending_up_rounded
                                        : Icons.trending_down_rounded,
                                    color: number(item['changePct']) >= 0
                                        ? AppColors.secondary
                                        : AppColors.error,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    money(number(item['price'])),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    signedPercent(number(item['changePct'])),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: number(item['changePct']) >= 0
                                              ? AppColors.secondary
                                              : AppColors.error,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 56,
                                child: SparklineChart(
                                  values: numbers(item['sparkline']),
                                  color: number(item['changePct']) >= 0
                                      ? AppColors.secondary
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (highReturnItems.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          highReturn['title']?.toString() ?? 'High Return',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (highReturnSourceLabel.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: highReturnSourceLabel == 'Live'
                                  ? AppColors.success.withValues(alpha: 0.12)
                                  : highReturnBadgeColor.withValues(
                                      alpha: 0.08,
                                    ),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: highReturnBadgeColor.withValues(
                                  alpha: 0.24,
                                ),
                              ),
                            ),
                            child: Text(
                              highReturnSourceLabel,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: highReturnBadgeColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      highReturn['subtitle']?.toString() ??
                          'Top-return ideas ranked from the latest tracked Indian market snapshot',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    SurfaceCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Company',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 3,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Market price',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...highReturnItems.asMap().entries.map((entry) {
                            final item = entry.value;
                            final changePct = number(item['changePct']);
                            final priceChange = number(item['priceChange']);
                            final toneColor = changePct >= 0
                                ? AppColors.success
                                : AppColors.error;
                            final changeLabel =
                                '${priceChange >= 0 ? '+' : '-'}${money(priceChange.abs(), decimals: 2, compact: false)} (${changePct.abs().toStringAsFixed(2)}%)';
                            final priceLabel = money(
                              number(item['price']),
                              decimals: 2,
                              compact: false,
                            );

                            return InkWell(
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/stock',
                                arguments: item['symbol']?.toString(),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: entry.key == 0
                                        ? BorderSide.none
                                        : const BorderSide(
                                            color: AppColors.outlineSoft,
                                          ),
                                  ),
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final compact = constraints.maxWidth < 360;
                                    final sparklineWidth = compact
                                        ? 72.0
                                        : 92.0;
                                    final rightColumnWidth = compact
                                        ? 124.0
                                        : 148.0;
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['name']?.toString() ??
                                                    item['symbol']
                                                        ?.toString() ??
                                                    '',
                                                maxLines: compact ? 3 : 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height: 1.18,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item['symbol']?.toString() ??
                                                    '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium
                                                    ?.copyWith(
                                                      color: AppColors
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: compact ? 10 : 14),
                                        SizedBox(
                                          width: sparklineWidth,
                                          height: 42,
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    height: 1,
                                                    color:
                                                        AppColors.outlineSoft,
                                                  ),
                                                ),
                                              ),
                                              Positioned.fill(
                                                child: SparklineChart(
                                                  values: numbers(
                                                    item['sparkline'],
                                                  ),
                                                  color: toneColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: compact ? 10 : 14),
                                        SizedBox(
                                          width: rightColumnWidth,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  priceLabel,
                                                  textAlign: TextAlign.right,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  changeLabel,
                                                  textAlign: TextAlign.right,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium
                                                      ?.copyWith(
                                                        color: toneColor,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Text(
                        'Trending Insights',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...trending.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SurfaceCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleBadge(
                              icon: iconFromName(item['icon']?.toString()),
                              color: accentColor(item['color']?.toString()),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title']?.toString() ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(item['description']?.toString() ?? ''),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item['age']?.toString() ?? '',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Watchlist',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SurfaceCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Asset',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Price',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Trend',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...watchlist.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['symbol']?.toString() ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppColors.onSurface,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      Text(item['name']?.toString() ?? ''),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    money(
                                      number(item['price']),
                                      decimals: 2,
                                      compact: false,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      signedPercent(
                                        number(item['changePct']),
                                        digits: 1,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: number(item['changePct']) > 0
                                                ? AppColors.secondary
                                                : number(item['changePct']) < 0
                                                ? AppColors.error
                                                : AppColors.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: TextButton(
                            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/watchlist',
                              (_) => false,
                            ),
                            child: const Text('Edit Watchlist'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  SurfaceCard(
                    padding: const EdgeInsets.all(18),
                    accent: AppColors.primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            SignalPill(
                              label:
                                  aiPrediction['badge']?.toString() ??
                                  'AI PREDICTION',
                              tone: SignalTone.primary,
                            ),
                            Text(
                              aiPrediction['symbol']?.toString() ?? '',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          aiPrediction['title']?.toString() ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: (compactHome
                                  ? Theme.of(context).textTheme.titleLarge
                                  : Theme.of(context).textTheme.headlineSmall)
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          aiPrediction['description']?.toString() ?? '',
                          maxLines: compactHome ? 4 : 5,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(height: 1.45),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: compactHome ? 200 : 230,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Confidence',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${number(aiPrediction['confidence']).toStringAsFixed(1)}%',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Icon(
                                  Icons.online_prediction_outlined,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0C1724), Color(0xFF1E2B3B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SignalPill(
                          label: featured['label']?.toString() ?? 'DEEP DIVE',
                          tone: SignalTone.primary,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          featured['title']?.toString() ?? '',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          featured['description']?.toString() ?? '',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late Future<JsonMap> _future;
  bool _isAddingAsset = false;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.fetchWatchlist();
  }

  Future<void> _openSymbolSearch({required bool addToWatchlist}) async {
    final selected = await showSymbolSearchSheet(
      context,
      widget.repository,
      title: addToWatchlist ? 'Add Indian Equity' : 'Browse Indian Equities',
    );
    if (!mounted || selected == null) {
      return;
    }

    final symbol = selected['symbol']?.toString() ?? '';
    if (symbol.isEmpty) {
      return;
    }

    if (!addToWatchlist) {
      Navigator.pushNamed(context, '/stock', arguments: symbol);
      return;
    }

    if (_isAddingAsset) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isAddingAsset = true);
    try {
      final watchlist = await _future;
      final existingSymbols = asListOfMaps(
        watchlist['assets'],
      ).map((item) => item['symbol']?.toString().toUpperCase() ?? '').toSet();
      if (existingSymbols.contains(symbol.toUpperCase())) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text('$symbol is already in your watchlist.')),
        );
        return;
      }

      await widget.repository.addWatchlistAsset(
        symbol,
        selected['displayName']?.toString() ?? symbol,
        0,
      );
      if (!mounted) return;
      setState(() => _future = widget.repository.fetchWatchlist());
      messenger.showSnackBar(
        SnackBar(content: Text('$symbol added to your watchlist.')),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingAsset = false);
      }
    }
  }

  Future<void> _addAsset() => _openSymbolSearch(addToWatchlist: true);

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      activeTab: NavTab.watch,
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primary,
          ),
        ),
      ],
      child: AsyncPage(
        future: _future,
        builder: (context, data) {
          final assets = asListOfMaps(data['assets']);
          final insight = asMap(data['insight']);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchField(
                  placeholder:
                      data['searchPlaceholder']?.toString() ?? 'Search',
                  readOnly: true,
                  onTap: () => _openSymbolSearch(addToWatchlist: false),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.filter_list_rounded),
                        label: const Text('Filter'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.onSurfaceVariant,
                          side: const BorderSide(
                            color: AppColors.outlineVariant,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isAddingAsset ? null : _addAsset,
                        icon: const Icon(Icons.add),
                        label: Text(_isAddingAsset ? 'Adding...' : 'Add Asset'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data['title']?.toString() ?? 'Active Watchlist',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '${data['trackedCount']} Assets Tracked',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...assets.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/stock',
                        arguments: item['symbol']?.toString(),
                      ),
                      borderRadius: BorderRadius.circular(18),
                      child: SurfaceCard(
                        padding: const EdgeInsets.all(16),
                        accent: AppColors.secondary,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.surfaceHigh,
                              child: Text(
                                ((item['symbol']?.toString() ?? '?').isNotEmpty)
                                    ? item['symbol']!.toString().substring(0, 1)
                                    : '?',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['symbol']?.toString() ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['name']?.toString() ?? '',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  money(
                                    number(item['price']),
                                    decimals: 2,
                                    compact: false,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                SignalPill(
                                  label: signedPercent(
                                    number(item['changePct']),
                                  ),
                                  tone: number(item['changePct']) > 0
                                      ? SignalTone.positive
                                      : number(item['changePct']) < 0
                                      ? SignalTone.negative
                                      : SignalTone.neutral,
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.online_prediction_outlined,
                                  color: signalToneFromText(
                                    item['signalTone']?.toString(),
                                  ).color,
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 72,
                                  child: Text(
                                    item['signal']?.toString().toUpperCase() ??
                                        '',
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: signalToneFromText(
                                            item['signalTone']?.toString(),
                                          ).color,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF544BFF), Color(0xFF4630D9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -24,
                        top: 0,
                        bottom: 0,
                        child: Icon(
                          Icons.bubble_chart_rounded,
                          size: 160,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight['title']?.toString() ?? '',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            insight['description']?.toString() ?? '',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.white70, height: 1.6),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              backgroundColor: Colors.white,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                            ),
                            child: Text(
                              insight['cta']?.toString() ??
                                  'View Detailed Report',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MarketAnalyticsScreen extends StatelessWidget {
  const MarketAnalyticsScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      activeTab: NavTab.market,
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
      child: AsyncPage(
        future: repository.fetchAnalytics(),
        builder: (context, data) {
          final sentiment = asMap(data['sentiment']);
          final sectors = asListOfMaps(data['sectors']);
          final movers = asListOfMaps(data['movers']);
          final signal = asMap(data['signal']);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title']?.toString() ?? 'Market Analytics',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'System-wide sentiment, sector rotation, and model-detected opportunities.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Market Sentiment',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircularScore(
                            score: number(sentiment['score']) / 100,
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sentiment['label']?.toString() ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  sentiment['description']?.toString() ?? '',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sector Performance',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...sectors.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(item['name']?.toString() ?? ''),
                                  ),
                                  Text(
                                    signedPercent(
                                      number(item['performance']),
                                      digits: 1,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color:
                                              number(item['performance']) >= 0
                                              ? AppColors.secondary
                                              : AppColors.error,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: (number(item['performance']).abs() / 5)
                                      .clamp(0.1, 1.0),
                                  minHeight: 10,
                                  backgroundColor: AppColors.surfaceHigh,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    number(item['performance']) >= 0
                                        ? AppColors.secondaryContainer
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trade Volume',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          values: numbers(data['tradeVolume']),
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Market Movers',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...movers.map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item['symbol']?.toString() ?? ''),
                          subtitle: Text(
                            item['direction']?.toString() == 'up'
                                ? 'Bullish breakout'
                                : 'Short-term weakness',
                          ),
                          trailing: Text(
                            signedPercent(number(item['movePct']), digits: 1),
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: number(item['movePct']) >= 0
                                      ? AppColors.secondary
                                      : AppColors.error,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  accent: AppColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        signal['title']?.toString() ?? '',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(signal['description']?.toString() ?? ''),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PredictionScreen extends StatelessWidget {
  const PredictionScreen({
    super.key,
    required this.repository,
    required this.symbol,
  });

  final AppRepository repository;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      activeTab: NavTab.predict,
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
      child: AsyncPage(
        future: repository.fetchPrediction(symbol),
        builder: (context, data) {
          final factors = asListOfMaps(data['factors']);
          final series = asListOfMaps(data['sevenDayForecast']);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['companyName']?.toString() ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(fontSize: 42),
                ),
                const SizedBox(height: 8),
                Text(
                  '${data['symbol']}  •  ${money(number(data['currentPrice']))}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '7-Day Prediction Model',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          SignalPill(
                            label: data['direction']?.toString() ?? '',
                            tone:
                                (data['direction']
                                        ?.toString()
                                        .toLowerCase()
                                        .contains('buy') ??
                                    false)
                                ? SignalTone.positive
                                : SignalTone.negative,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: ForecastChart(
                          points: series
                              .map(
                                (item) => ChartPoint(
                                  item['day']?.toString() ?? '',
                                  number(item['value']),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: MetricMiniCard(
                              title: 'Confidence',
                              value:
                                  '${number(data['confidence']).toStringAsFixed(1)}%',
                              tone: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricMiniCard(
                              title: 'Current Price',
                              value: money(number(data['currentPrice'])),
                              tone: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$appBrandName Synthesis',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(data['synthesis']?.toString() ?? ''),
                      const SizedBox(height: 18),
                      ...factors.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['label']?.toString() ?? '',
                                    ),
                                  ),
                                  Text(
                                    number(item['score']).toStringAsFixed(2),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: number(item['score']) >= 0
                                              ? AppColors.secondary
                                              : AppColors.error,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: number(
                                    item['score'],
                                  ).abs().clamp(0, 1),
                                  minHeight: 10,
                                  backgroundColor: AppColors.surfaceHigh,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    number(item['score']) >= 0
                                        ? AppColors.secondaryContainer
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StockDetailsScreen extends StatefulWidget {
  const StockDetailsScreen({
    super.key,
    required this.repository,
    required this.symbol,
  });

  final AppRepository repository;
  final String symbol;

  @override
  State<StockDetailsScreen> createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _tradeMessage = '';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _trade(String side) async {
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    final response = await widget.repository.createTrade(
      widget.symbol,
      side,
      amount,
    );
    if (!mounted) return;
    setState(
      () => _tradeMessage = '${response['side']} order ${response['status']}',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Trade executed: ${response['side']} ${response['symbol']}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      activeTab: NavTab.market,
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
      child: AsyncPage(
        future: widget.repository.fetchStockDetails(widget.symbol),
        builder: (context, data) {
          if (_amountController.text.isEmpty) {
            _amountController.text = number(
              data['defaultInvestmentAmount'],
            ).toStringAsFixed(2);
          }
          final stats = asListOfMaps(data['marketStats']);
          final insights = asListOfMaps(data['insights']);
          final compactStockDetails = MediaQuery.sizeOf(context).width < 430;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              widget.symbol.substring(0, 1),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['companyName']?.toString() ?? '',
                                style: (compactStockDetails
                                        ? Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                        : Theme.of(context)
                                            .textTheme
                                            .headlineLarge)
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              SignalPill(
                                label: data['symbol']?.toString() ?? '',
                                tone: SignalTone.neutral,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        money(
                          number(data['price']),
                          decimals: 2,
                          compact: false,
                        ),
                        maxLines: 1,
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(fontSize: compactStockDetails ? 40 : 46),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        Icon(
                          number(data['changePct']) >= 0
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: number(data['changePct']) >= 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        Text(
                          '${number(data['priceChange']) >= 0 ? '+' : ''}${money(number(data['priceChange']), decimals: 2)} (${signedPercent(number(data['changePct']))})',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: number(data['changePct']) >= 0
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SurfaceCard(
                      padding: const EdgeInsets.all(16),
                      accent: AppColors.primary,
                      child: compactStockDetails
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircularScore(
                                      score:
                                          number(data['predictionAccuracy']) /
                                          100,
                                      size: 64,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$appBrandName Prediction Confidence',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelMedium,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            data['predictionLabel']
                                                    ?.toString() ??
                                                '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  data['predictionNote']?.toString() ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                CircularScore(
                                  score:
                                      number(data['predictionAccuracy']) / 100,
                                  size: 66,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$appBrandName Prediction Confidence',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        data['predictionLabel']?.toString() ??
                                            '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        data['predictionNote']?.toString() ?? '',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: asListOfStrings(data['timeframeOptions'])
                            .map(
                              (label) => ChoiceChip(
                                label: Text(label),
                                selected:
                                    label ==
                                    data['selectedTimeframe']?.toString(),
                                selectedColor: AppColors.primary,
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color:
                                          label ==
                                              data['selectedTimeframe']
                                                  ?.toString()
                                          ? Colors.white
                                          : AppColors.onSurfaceVariant,
                                    ),
                                onSelected: (_) {},
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 280,
                        child: CandlestickChart(
                          candles: asListOfMaps(
                            data['candles'],
                          ).map(CandlePoint.fromJson).toList(),
                          forecast: asListOfMaps(
                            data['forecastPath'],
                          ).map(OffsetPoint.fromJson).toList(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$appBrandName Forecast Engine Active',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trade ${data['symbol']}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Investment Amount',
                          prefixText: '₹ ',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _trade('buy'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Buy'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _trade('sell'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.onSurfaceVariant,
                                side: const BorderSide(
                                  color: AppColors.outlineVariant,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Sell'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Available cash balance: ${money(number(data['availableCash']), decimals: 2, compact: false)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (_tradeMessage.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _tradeMessage,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Market Stats',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...stats.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(item['label']?.toString() ?? ''),
                              ),
                              Text(
                                item['value']?.toString() ?? '',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Neural Insight Analysis',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...insights.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SurfaceCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                iconFromName(item['icon']?.toString()),
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                item['title']?.toString() ?? '',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(item['description']?.toString() ?? ''),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      activeTab: NavTab.profile,
      actions: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
      child: AsyncPage(
        future: repository.fetchNotifications(),
        builder: (context, data) {
          final items = asListOfMaps(data['items']);
          final upgradeCard = asMap(data['upgradeCard']);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title']?.toString() ?? 'Notifications',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SurfaceCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleBadge(
                            icon: switch (item['type']?.toString()) {
                              'prediction' => Icons.online_prediction_outlined,
                              'alert' => Icons.campaign_outlined,
                              'security' => Icons.lock_outline,
                              _ => Icons.check_circle_outline,
                            },
                            color: item['unread'] == true
                                ? AppColors.primary
                                : AppColors.outline,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['title']?.toString() ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    if (item['unread'] == true)
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(item['message']?.toString() ?? ''),
                                const SizedBox(height: 8),
                                Text(
                                  item['time']?.toString() ?? '',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0C1724), Color(0xFF2D3755)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        upgradeCard['title']?.toString() ?? '',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        upgradeCard['description']?.toString() ?? '',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      activeTab: NavTab.profile,
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/settings'),
          icon: const Icon(
            Icons.settings_outlined,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
      child: AsyncPage(
        future: repository.fetchProfile(),
        builder: (context, data) {
          final stats = asListOfMaps(data['stats']);
          final insights = asListOfStrings(data['insights']);
          final security = asListOfStrings(data['security']);
          final preferences = asListOfMaps(data['preferences']);
          final portfolioSummary = asMap(data['portfolioSummary']);
          final sectorExposure = asListOfMaps(
            portfolioSummary['exposureBySector'],
          );
          sectorExposure.sort(
            (a, b) => number(b['value']).compareTo(number(a['value'])),
          );
          final topSectorExposure = sectorExposure.take(3).toList();
          final preferenceHighlights = preferences
              .expand((section) {
                final title = section['title']?.toString() ?? '';
                return asListOfMaps(section['items']).map(
                  (item) => {
                    'section': title,
                    'label': item['label']?.toString() ?? '',
                    'value': item['value'],
                    'kind': item['kind']?.toString() ?? 'detail',
                  },
                );
              })
              .take(4)
              .toList();
          final watchlistCount = data['watchlistCount']?.toString() ?? '0';
          final notificationCount = data['notificationCount']?.toString() ?? '0';
          final memberSince = data['memberSince']?.toString() ?? '';
          final verificationState =
              data['verificationState']?.toString() ?? 'pending';
          final compactProfile = MediaQuery.sizeOf(context).width < 390;
          final pageWidth = MediaQuery.sizeOf(context).width - 32;
          final profileGridWidth = (pageWidth - 12) / 2;
          final heroGridWidth = (pageWidth - 44 - 12) / 2;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFAFBFF), Color(0xFFF0EEFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.outlineSoft),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 22,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: compactProfile ? 72 : 82,
                            height: compactProfile ? 72 : 82,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFE7E0FF),
                                  Color(0xFFDAD7FF),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                data['avatarInitials']?.toString() ?? 'AV',
                                style: Theme.of(context).textTheme.headlineMedium
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name']?.toString() ?? '',
                                  style: (compactProfile
                                          ? Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                          : Theme.of(context)
                                              .textTheme
                                              .headlineLarge)
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        height: 1.05,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  data['email']?.toString() ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    SignalPill(
                                      label: data['role']?.toString() ?? '',
                                      tone: SignalTone.primary,
                                    ),
                                    SignalPill(
                                      label: verificationState == 'verified'
                                          ? 'Verified Account'
                                          : 'Verification Pending',
                                      tone: verificationState == 'verified'
                                          ? SignalTone.positive
                                          : SignalTone.neutral,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        data['bio']?.toString() ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.55,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.68),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.outlineSoft),
                        ),
                        child: Text(
                          data['tierDescription']?.toString() ??
                              'Advanced workflow access enabled for this account.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(height: 1.45),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ProfileActionCard(
                            width: heroGridWidth,
                            icon: Icons.remove_red_eye_outlined,
                            title: 'Watchlist',
                            subtitle: '$watchlistCount tracked',
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/watchlist',
                            ),
                          ),
                          ProfileActionCard(
                            width: heroGridWidth,
                            icon: Icons.notifications_active_outlined,
                            title: 'Alerts',
                            subtitle: '$notificationCount unread',
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/notifications',
                            ),
                          ),
                          ProfileActionCard(
                            width: heroGridWidth,
                            icon: Icons.online_prediction_outlined,
                            title: 'Predict',
                            subtitle: 'Model outlook',
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/predict',
                            ),
                          ),
                          ProfileActionCard(
                            width: heroGridWidth,
                            icon: Icons.query_stats_rounded,
                            title: 'Market',
                            subtitle: 'Sector pulse',
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/market',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: stats
                      .map(
                        (item) => ProfileStatCard(
                          title: item['label']?.toString() ?? '',
                          value: item['value']?.toString() ?? '',
                          width: compactProfile ? profileGridWidth : 236,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),
                SurfaceCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Portfolio Pulse',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          SignalPill(
                            label: memberSince.isEmpty
                                ? 'Active Member'
                                : 'Since $memberSince',
                            tone: SignalTone.neutral,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Portfolio Value',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    money(
                                      number(data['portfolioValue']),
                                      decimals: 2,
                                      compact: false,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF162234),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Activity',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$watchlistCount tracked • $notificationCount alerts',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (topSectorExposure.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Top exposure by sector',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 10),
                        ...topSectorExposure.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ProfileSectorBar(
                              label: item['sector']?.toString() ?? '',
                              value: number(item['value']),
                              maxValue: number(
                                topSectorExposure.first['value'],
                              ).clamp(1, double.infinity),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Predictive Insights',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...insights.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProfileInsightTile(
                            icon: Icons.auto_awesome,
                            title: item,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Automation & Preferences',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...preferenceHighlights.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ProfilePreferenceTile(
                            section: item['section']?.toString() ?? '',
                            label: item['label']?.toString() ?? '',
                            value: item['value'],
                            kind: item['kind']?.toString() ?? 'detail',
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/settings',
                        ),
                        icon: const Icon(Icons.tune_rounded),
                        label: const Text('Open Settings'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account & Security',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...security.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ProfileInsightTile(
                            icon: Icons.verified_user_outlined,
                            title: item,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            InfoRow(
                              label: 'Location',
                              value: data['location']?.toString() ?? '',
                            ),
                            const SizedBox(height: 10),
                            InfoRow(
                              label: 'Risk Profile',
                              value: data['riskProfile']?.toString() ?? '',
                            ),
                            const SizedBox(height: 10),
                            InfoRow(
                              label: 'Verification',
                              value: verificationState == 'verified'
                                  ? 'Verified'
                                  : 'Pending',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileActionCard extends StatelessWidget {
  const ProfileActionCard({
    super.key,
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF6F4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.outlineSoft),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const Spacer(),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.arrow_outward_rounded,
                    size: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Open',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileStatCard extends StatelessWidget {
  const ProfileStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.width,
  });

  final String title;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outlineSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: title.toLowerCase().contains('accuracy')
                    ? 0.9
                    : title.toLowerCase().contains('wins')
                    ? 0.67
                    : 0.78,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileInsightTile extends StatelessWidget {
  const ProfileInsightTile({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePreferenceTile extends StatelessWidget {
  const ProfilePreferenceTile({
    super.key,
    required this.section,
    required this.label,
    required this.value,
    required this.kind,
  });

  final String section;
  final String label;
  final dynamic value;
  final String kind;

  @override
  Widget build(BuildContext context) {
    final valueLabel = value is bool
        ? (value ? 'Enabled' : 'Disabled')
        : value?.toString() ?? '';
    final tone = value is bool
        ? (value ? SignalTone.positive : SignalTone.neutral)
        : SignalTone.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SignalPill(label: valueLabel, tone: tone),
        ],
      ),
    );
  }
}

class ProfileSectorBar extends StatelessWidget {
  const ProfileSectorBar({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
  });

  final String label;
  final double value;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    final progress = maxValue <= 0
        ? 0.0
        : (value / maxValue).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Text(
              money(value, decimals: 0, compact: true),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.surfaceHigh,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<JsonMap> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.fetchSettings();
  }

  Future<void> _update(String sectionTitle, String label, dynamic value) async {
    await widget.repository.updateSetting(sectionTitle, label, value);
    setState(() => _future = widget.repository.fetchSettings());
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      activeTab: NavTab.profile,
      actions: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
      child: AsyncPage(
        future: _future,
        builder: (context, data) {
          final sections = asListOfMaps(data['sections']);
          final upgradeCard = asMap(data['upgradeCard']);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Control your account, data, and predictive environment.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                ...sections.map(
                  (section) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: SurfaceCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section['title']?.toString() ?? '',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          ...asListOfMaps(section['items']).map(
                            (item) => item['kind'] == 'toggle'
                                ? SwitchListTile.adaptive(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      item['label']?.toString() ?? '',
                                    ),
                                    value: item['value'] == true,
                                    activeThumbColor: AppColors.primary,
                                    activeTrackColor: AppColors.primary
                                        .withValues(alpha: 0.35),
                                    onChanged: (value) => _update(
                                      section['title']?.toString() ?? '',
                                      item['label']?.toString() ?? '',
                                      value,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: InfoRow(
                                      label: item['label']?.toString() ?? '',
                                      value: item['value']?.toString() ?? '',
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF3525CD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        upgradeCard['title']?.toString() ?? '',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        upgradeCard['description']?.toString() ?? '',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          upgradeCard['cta']?.toString() ?? 'Upgrade',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      activeTab: NavTab.profile,
      actions: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
      child: AsyncPage(
        future: repository.fetchAdmin(),
        builder: (context, data) {
          final topMetrics = asListOfMaps(data['topMetrics']);
          final modelMetrics = asListOfMaps(data['modelMetrics']);
          final datasetStatus = asListOfMaps(data['datasetStatus']);
          final events = asListOfMaps(data['systemEvents']);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title']?.toString() ?? '',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['subtitle']?.toString() ?? '',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: topMetrics
                      .map(
                        (item) => SizedBox(
                          width: (MediaQuery.sizeOf(context).width - 44) / 2,
                          child: MetricMiniCard(
                            title: item['label']?.toString() ?? '',
                            value: item['value']?.toString() ?? '',
                            subtitle: item['trend']?.toString(),
                            tone: AppColors.primary,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Global Server Load',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          values: numbers(data['serverLoad']),
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$appBrandName Model Metrics',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...modelMetrics.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: InfoRow(
                            label: item['label']?.toString() ?? '',
                            value: item['value']?.toString() ?? '',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dataset Status',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...datasetStatus.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(item['name']?.toString() ?? ''),
                              ),
                              SignalPill(
                                label: item['status']?.toString() ?? '',
                                tone:
                                    (item['status']?.toString().toLowerCase() ==
                                        'healthy')
                                    ? SignalTone.positive
                                    : SignalTone.neutral,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent System Events',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...events.map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleBadge(
                            icon: Icons.bolt_outlined,
                            color: AppColors.primary,
                          ),
                          title: Text(item['message']?.toString() ?? ''),
                          subtitle: Text(item['time']?.toString() ?? ''),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.accent,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceLowest,
            borderRadius: borderRadius,
            border: Border.all(color: AppColors.outlineSoft),
          ),
          child: Stack(
            children: [
              if (accent != null)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(18),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: padding.add(
                  EdgeInsets.only(left: accent != null ? 4 : 0),
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.placeholder,
    this.onTap,
    this.readOnly = false,
  });

  final String placeholder;
  final VoidCallback? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.outline),
      ),
    );
  }
}

class BrandLockup extends StatelessWidget {
  const BrandLockup({
    super.key,
    this.color = AppColors.primary,
    this.logoSize = 24,
    this.fontSize = 20,
  });

  final Color color;
  final double logoSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      appLogoAssetPath,
      height: fontSize * 1.7,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      appLogoAssetPath,
      width: size * 1.6,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

Future<JsonMap?> showSymbolSearchSheet(
  BuildContext context,
  AppRepository repository, {
  String title = 'Search Indian Equities',
  String placeholder = 'Search NSE stock, company, or sector...',
}) {
  return showModalBottomSheet<JsonMap>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SymbolSearchSheet(
      repository: repository,
      title: title,
      placeholder: placeholder,
    ),
  );
}

class SymbolSearchSheet extends StatefulWidget {
  const SymbolSearchSheet({
    super.key,
    required this.repository,
    required this.title,
    required this.placeholder,
  });

  final AppRepository repository;
  final String title;
  final String placeholder;

  @override
  State<SymbolSearchSheet> createState() => _SymbolSearchSheetState();
}

class _SymbolSearchSheetState extends State<SymbolSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  late Future<JsonMap> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.fetchSymbols('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    setState(() {
      _future = widget.repository.fetchSymbols(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.82;
    return SafeArea(
      top: false,
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 56,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.outline,
                  ),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _controller.clear();
                            _search('');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<JsonMap>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final items = asListOfMaps(snapshot.data?['items']);
                  if (items.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No matching Indian equities found.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final symbol = item['symbol']?.toString() ?? '?';
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => Navigator.pop(context, item),
                        child: SurfaceCard(
                          padding: const EdgeInsets.all(16),
                          accent: AppColors.primary,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.surfaceHigh,
                                child: Text(
                                  symbol.isNotEmpty
                                      ? symbol.substring(0, 1)
                                      : '?',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      symbol,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['displayName']?.toString() ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item['sector']} • ${item['marketCapBucket']}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: AppColors.outline,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  const FeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(description, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.onSurface,
        side: const BorderSide(color: AppColors.outlineSoft),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.helper,
    this.actionLabel,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? helper;
  final String? actionLabel;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null) ...[
              const Spacer(),
              Text(
                actionLabel!,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.outline),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(
            helper!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

enum SignalTone { primary, positive, negative, neutral }

extension on SignalTone {
  Color get color => switch (this) {
    SignalTone.primary => AppColors.primary,
    SignalTone.positive => AppColors.secondaryContainer,
    SignalTone.negative => AppColors.error,
    SignalTone.neutral => AppColors.outline,
  };

  Color get background => switch (this) {
    SignalTone.primary => AppColors.primary.withValues(alpha: 0.12),
    SignalTone.positive => AppColors.secondaryContainer.withValues(alpha: 0.14),
    SignalTone.negative => AppColors.errorContainer,
    SignalTone.neutral => AppColors.surfaceHigh,
  };
}

class SignalPill extends StatelessWidget {
  const SignalPill({super.key, required this.label, required this.tone});

  final String label;
  final SignalTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: tone.color),
      ),
    );
  }
}

class CircleBadge extends StatelessWidget {
  const CircleBadge({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class MetricMiniCard extends StatelessWidget {
  const MetricMiniCard({
    super.key,
    required this.title,
    required this.value,
    required this.tone,
    this.subtitle,
  });

  final String title;
  final String value;
  final Color tone;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: tone,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class CircularScore extends StatelessWidget {
  const CircularScore({super.key, required this.score, this.size = 72});

  final double score;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 1,
            color: AppColors.surfaceHighest,
            strokeWidth: 8,
          ),
          CircularProgressIndicator(
            value: score.clamp(0, 1),
            color: AppColors.primary,
            strokeWidth: 8,
          ),
          Center(
            child: Text(
              '${(score * 100).toStringAsFixed(0)}%',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class SparklineChart extends StatelessWidget {
  const SparklineChart({super.key, required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SparklinePainter(values: values, color: color),
    );
  }
}

class SparklinePainter extends CustomPainter {
  SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final span = (maxValue - minValue).abs() < 0.001
        ? 1.0
        : (maxValue - minValue);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - ((values[i] - minValue) / span) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.quadraticBezierTo(x - size.width / (values.length * 2), y, x, y);
      }
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class BarChart extends StatelessWidget {
  const BarChart({super.key, required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BarChartPainter(values: values, color: color),
    );
  }
}

class BarChartPainter extends CustomPainter {
  BarChartPainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxValue = values.reduce(math.max);
    final barWidth = size.width / (values.length * 1.8);
    final gap = barWidth * 0.8;
    final paint = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      final height = size.height * (values[i] / maxValue);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * (barWidth + gap),
          size.height - height,
          barWidth,
          height,
        ),
        const Radius.circular(10),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class ForecastChart extends StatelessWidget {
  const ForecastChart({super.key, required this.points});

  final List<ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: ForecastChartPainter(points: points));
  }
}

class ForecastChartPainter extends CustomPainter {
  ForecastChartPainter({required this.points});

  final List<ChartPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final values = points.map((e) => e.value).toList();
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final span = (maxValue - minValue).abs() < 0.001
        ? 1.0
        : (maxValue - minValue);
    final path = Path();
    final fill = Path();
    for (var i = 0; i < points.length; i++) {
      final x = i / (points.length - 1) * size.width;
      final y =
          size.height -
          ((points[i].value - minValue) / span) * (size.height - 24) -
          12;
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = AppColors.primary);
      final tp = textPainter(
        points[i].label,
        const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
      );
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - 16));
    }
    fill.lineTo(size.width, size.height);
    fill.close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x334F46E5), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant ForecastChartPainter oldDelegate) =>
      oldDelegate.points != points;
}

class CandlestickChart extends StatelessWidget {
  const CandlestickChart({
    super.key,
    required this.candles,
    required this.forecast,
  });

  final List<CandlePoint> candles;
  final List<OffsetPoint> forecast;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CandlestickPainter(candles: candles, forecast: forecast),
    );
  }
}

class CandlestickPainter extends CustomPainter {
  CandlestickPainter({required this.candles, required this.forecast});

  final List<CandlePoint> candles;
  final List<OffsetPoint> forecast;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.outlineSoft
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final candleWidth = 14.0;
    for (final candle in candles) {
      final color = candle.tone == 'up' ? AppColors.success : AppColors.error;
      final wickPaint = Paint()
        ..color = color
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(candle.x, candle.high),
        Offset(candle.x, candle.low),
        wickPaint,
      );
      final top = math.min(candle.open, candle.close);
      final bottom = math.max(candle.open, candle.close);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            candle.x - candleWidth / 2,
            top,
            candleWidth,
            bottom - top,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = color,
      );
    }
    if (forecast.isNotEmpty) {
      final path = Path()..moveTo(forecast.first.x, forecast.first.y);
      for (final point in forecast.skip(1)) {
        path.lineTo(point.x, point.y);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.primary
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CandlestickPainter oldDelegate) =>
      oldDelegate.candles != candles || oldDelegate.forecast != forecast;
}

class OnboardingHeroOne extends StatelessWidget {
  const OnboardingHeroOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surface,
                  AppColors.primary.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 180,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            Icons.laptop_mac_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 30, 18, 18),
                    child: SparklineChart(
                      values: [14, 16, 18, 15, 21, 28, 32, 30, 38],
                      color: AppColors.secondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingHeroTwo extends StatelessWidget {
  const OnboardingHeroTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Signal Stream',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                const Expanded(
                  child: SparklineChart(
                    values: [10, 14, 12, 18, 16, 24, 22, 28],
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: const [
              Expanded(
                child: MetricMiniCard(
                  title: 'Signals',
                  value: '128',
                  tone: AppColors.primary,
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: MetricMiniCard(
                  title: 'Accuracy',
                  value: '94.2%',
                  tone: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OnboardingHeroThree extends StatelessWidget {
  const OnboardingHeroThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Expanded(
              child: SignalPill(label: 'RELIANCE', tone: SignalTone.primary),
            ),
            SizedBox(width: 10),
            Expanded(
              child: SignalPill(label: 'TCS', tone: SignalTone.neutral),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: SignalPill(label: 'INFY', tone: SignalTone.positive),
            ),
            SizedBox(width: 10),
            Expanded(
              child: SignalPill(label: 'HDFCBANK', tone: SignalTone.neutral),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: SurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personalized Engine',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const Expanded(
                  child: SparklineChart(
                    values: [9, 12, 14, 13, 18, 20, 22, 28],
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class ChartPoint {
  const ChartPoint(this.label, this.value);

  final String label;
  final double value;
}

class CandlePoint {
  CandlePoint({
    required this.x,
    required this.open,
    required this.close,
    required this.high,
    required this.low,
    required this.tone,
  });

  final double x;
  final double open;
  final double close;
  final double high;
  final double low;
  final String tone;

  factory CandlePoint.fromJson(JsonMap json) {
    return CandlePoint(
      x: number(json['x']),
      open: number(json['open']),
      close: number(json['close']),
      high: number(json['high']),
      low: number(json['low']),
      tone: json['tone']?.toString() ?? 'up',
    );
  }
}

class OffsetPoint {
  OffsetPoint({required this.x, required this.y});

  final double x;
  final double y;

  factory OffsetPoint.fromJson(JsonMap json) =>
      OffsetPoint(x: number(json['x']), y: number(json['y']));
}

JsonMap asMap(dynamic value) =>
    value is Map<String, dynamic> ? value : <String, dynamic>{};

List<JsonMap> asListOfMaps(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
  return <JsonMap>[];
}

List<String> asListOfStrings(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  return <String>[];
}

double number(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '0') ?? 0;
}

List<double> numbers(dynamic value) {
  if (value is List) {
    return value.map(number).toList();
  }
  return <double>[];
}

String money(double value, {int decimals = 2, bool compact = true}) {
  if (compact && value.abs() >= 100000) {
    return NumberFormat.compactCurrency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: decimals,
    ).format(value);
  }
  return NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: decimals,
  ).format(value);
}

String signedPercent(double value, {int digits = 2}) {
  final prefix = value > 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(digits)}%';
}

SignalTone signalToneFromText(String? value) {
  final normalized = (value ?? '').toLowerCase();
  if (normalized.contains('positive') || normalized.contains('buy')) {
    return SignalTone.positive;
  }
  if (normalized.contains('negative') || normalized.contains('sell')) {
    return SignalTone.negative;
  }
  return SignalTone.neutral;
}

Color accentColor(String? name) {
  switch ((name ?? '').toLowerCase()) {
    case 'secondary':
      return AppColors.secondary;
    case 'tertiary':
      return AppColors.tertiary;
    case 'primary':
      return AppColors.primary;
    case 'error':
      return AppColors.error;
    default:
      return AppColors.primary;
  }
}

IconData iconFromName(String? name) {
  switch (name) {
    case 'rocket_launch':
      return Icons.rocket_launch_outlined;
    case 'energy_savings_leaf':
      return Icons.energy_savings_leaf_outlined;
    case 'data_thresholding':
      return Icons.data_thresholding_outlined;
    case 'hub':
      return Icons.hub_outlined;
    case 'data_exploration':
      return Icons.analytics_outlined;
    case 'psychology_alt':
      return Icons.psychology_alt_outlined;
    default:
      return Icons.auto_awesome_outlined;
  }
}

TextPainter textPainter(String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter;
}

extension WidgetListSeparator on List<Widget> {
  List<Widget> separated(Widget separator) {
    if (isEmpty) return this;
    final result = <Widget>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i != length - 1) {
        result.add(separator);
      }
    }
    return result;
  }
}
