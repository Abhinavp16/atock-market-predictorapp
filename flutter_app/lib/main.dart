import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' hide TextDirection;

typedef JsonMap = Map<String, dynamic>;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(LstmInsightApp(repository: AppRepository()));
}

class LstmInsightApp extends StatelessWidget {
  const LstmInsightApp({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.hankenGroteskTextTheme().copyWith(
      displayLarge: GoogleFonts.hankenGrotesk(
        fontSize: 48,
        height: 56 / 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.96,
        color: AppColors.onSurface,
      ),
      headlineLarge: GoogleFonts.hankenGrotesk(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.32,
        color: AppColors.onSurface,
      ),
      headlineMedium: GoogleFonts.hankenGrotesk(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      titleLarge: GoogleFonts.hankenGrotesk(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      ),
      bodyLarge: GoogleFonts.hankenGrotesk(
        fontSize: 16,
        height: 24 / 16,
        color: AppColors.onSurfaceVariant,
      ),
      bodyMedium: GoogleFonts.hankenGrotesk(
        fontSize: 14,
        height: 20 / 14,
        color: AppColors.onSurfaceVariant,
      ),
      labelMedium: GoogleFonts.hankenGrotesk(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: AppColors.onSurfaceVariant,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LSTM Insight',
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
      routes: {
        '/': (_) => SplashScreen(repository: repository),
        '/onboarding': (_) => OnboardingScreen(repository: repository),
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

String resolveApiBaseUrl() {
  const override = String.fromEnvironment('API_BASE_URL');
  if (override.isNotEmpty) {
    return override;
  }
  if (kIsWeb) {
    return 'http://localhost:3000/api';
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:3000/api';
    default:
      return 'http://localhost:3000/api';
  }
}

class AppRepository {
  AppRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? resolveApiBaseUrl();

  final http.Client _client;
  final String _baseUrl;

  Future<JsonMap> _get(String path) async {
    final response = await _client
        .get(Uri.parse('$_baseUrl$path'))
        .timeout(const Duration(seconds: 10));
    return _decodeMap(response);
  }

  Future<JsonMap> _post(String path, JsonMap body) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    return _decodeMap(response);
  }

  Future<JsonMap> _patch(String path, JsonMap body) async {
    final response = await _client
        .patch(
          Uri.parse('$_baseUrl$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    return _decodeMap(response);
  }

  JsonMap _decodeMap(http.Response response) {
    final dynamic decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    if (response.statusCode >= 400) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']
          : 'Request failed.';
      throw Exception(message);
    }
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception('Unexpected response payload.');
  }

  Future<JsonMap> fetchBootstrap() => _get('/bootstrap');
  Future<JsonMap> fetchHealth() => _get('/health');
  Future<JsonMap> login(String email, String password) =>
      _post('/auth/login', {'email': email, 'password': password});
  Future<JsonMap> register(String fullName, String email, String password) =>
      _post('/auth/register', {
        'fullName': fullName,
        'email': email,
        'password': password,
      });
  Future<JsonMap> fetchDashboard() => _get('/dashboard');
  Future<JsonMap> fetchWatchlist() => _get('/watchlist');
  Future<JsonMap> addWatchlistAsset(String symbol, String name, double price) =>
      _post('/watchlist', {'symbol': symbol, 'name': name, 'price': price});
  Future<JsonMap> fetchAnalytics() => _get('/market/analytics');
  Future<JsonMap> fetchPrediction(String symbol) =>
      _get('/predictions/${symbol.toUpperCase()}');
  Future<JsonMap> fetchStockDetails(String symbol) =>
      _get('/stocks/${symbol.toUpperCase()}');
  Future<JsonMap> createTrade(String symbol, String side, double amount) =>
      _post('/trade', {'symbol': symbol, 'side': side, 'amount': amount});
  Future<JsonMap> fetchNotifications() => _get('/notifications');
  Future<JsonMap> fetchProfile() => _get('/profile');
  Future<JsonMap> fetchSettings() => _get('/settings');
  Future<JsonMap> updateSetting(
    String sectionTitle,
    String itemLabel,
    dynamic value,
  ) => _patch('/settings', {
    'sectionTitle': sectionTitle,
    'itemLabel': itemLabel,
    'value': value,
  });
  Future<JsonMap> fetchAdmin() => _get('/admin');
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
                      child: Row(
                        children: [
                          const Icon(
                            Icons.analytics_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'LSTM Insight',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
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
                              child: const Icon(
                                Icons.auto_awesome,
                                color: AppColors.primary,
                                size: 72,
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
                          splash['title']?.toString() ?? 'Oracle AI',
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
                            onPressed: () =>
                                Navigator.pushNamed(context, '/onboarding'),
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
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/home'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.onSurface,
                              side: const BorderSide(
                                color: AppColors.outlineVariant,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('View Live Market'),
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
                      const Icon(
                        Icons.analytics_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'LSTM Insight',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
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
  final _fullName = TextEditingController(text: 'John Doe');
  final _email = TextEditingController(text: 'name@company.com');
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
      setState(() => _message = '$error');
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
                  const Icon(
                    Icons.analytics_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'LSTM Insight',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
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
                  'Advanced Neural Forecasting',
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
                  '© 2024 LSTM Insight. All rights reserved. Precise memory, infinite potential.',
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
  final _email = TextEditingController(text: 'alex@lstminsight.ai');
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
      setState(() => _message = '$error');
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
                    child: const Icon(
                      Icons.analytics_outlined,
                      color: AppColors.onPrimaryContainer,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'LSTM Insight',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Institutional Access',
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
                                icon: Icons.apple,
                                label: 'Apple',
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

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key, required this.repository});

  final AppRepository repository;

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
      child: AsyncPage(
        future: repository.fetchDashboard(),
        builder: (context, data) {
          final liveCards = asListOfMaps(data['liveCards']);
          final trending = asListOfMaps(data['trendingInsights']);
          final watchlist = asListOfMaps(data['watchlistPreview']);
          final aiPrediction = asMap(data['aiPrediction']);
          final featured = asMap(data['featuredAnalysis']);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['greeting']?.toString() ?? '',
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
                SearchField(
                  placeholder:
                      data['searchPlaceholder']?.toString() ?? 'Search',
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
                                  style: Theme.of(context).textTheme.labelMedium
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
                SurfaceCard(
                  padding: const EdgeInsets.all(18),
                  accent: AppColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SignalPill(
                            label:
                                aiPrediction['badge']?.toString() ??
                                'AI PREDICTION',
                            tone: SignalTone.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            aiPrediction['symbol']?.toString() ?? '',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        aiPrediction['title']?.toString() ?? '',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Text(aiPrediction['description']?.toString() ?? ''),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              const Icon(
                                Icons.online_prediction_outlined,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Text(
                      'Trending Insights',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    TextButton(onPressed: () {}, child: const Text('View All')),
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
                                  style: Theme.of(context).textTheme.titleLarge
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
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Price',
                                style: Theme.of(context).textTheme.labelMedium,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late Future<JsonMap> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.fetchWatchlist();
  }

  Future<void> _addAsset() async {
    final symbolController = TextEditingController(text: 'NFLX');
    final nameController = TextEditingController(text: 'Netflix');
    final priceController = TextEditingController(text: '612.42');
    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLowest,
        title: const Text('Add Asset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: symbolController,
              decoration: const InputDecoration(labelText: 'Symbol'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (submitted != true) {
      return;
    }
    await widget.repository.addWatchlistAsset(
      symbolController.text,
      nameController.text,
      double.tryParse(priceController.text) ?? 0,
    );
    setState(() => _future = widget.repository.fetchWatchlist());
  }

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
                        onPressed: _addAsset,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Asset'),
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
                        'Oracle Synthesis',
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
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
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
                          Text(
                            money(
                              number(data['price']),
                              decimals: 2,
                              compact: false,
                            ),
                            style: Theme.of(
                              context,
                            ).textTheme.displayLarge?.copyWith(fontSize: 46),
                          ),
                          const SizedBox(height: 6),
                          Row(
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
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SurfaceCard(
                      padding: const EdgeInsets.all(16),
                      accent: AppColors.primary,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularScore(
                            score: number(data['predictionAccuracy']) / 100,
                            size: 66,
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LSTM Prediction Accuracy',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                data['predictionLabel']?.toString() ?? '',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(data['predictionNote']?.toString() ?? ''),
                            ],
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
                          'LSTM Predictive Forecast Active',
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
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.14,
                      ),
                      child: Text(
                        data['avatarInitials']?.toString() ?? 'AV',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
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
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(data['email']?.toString() ?? ''),
                          const SizedBox(height: 8),
                          SignalPill(
                            label: data['role']?.toString() ?? '',
                            tone: SignalTone.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  data['bio']?.toString() ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 20),
                Row(
                  children: stats
                      .map(
                        (item) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: item == stats.last ? 0 : 12,
                            ),
                            child: MetricMiniCard(
                              title: item['label']?.toString() ?? '',
                              value: item['value']?.toString() ?? '',
                              tone: AppColors.primary,
                            ),
                          ),
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
                      Text(
                        'Predictive Insights',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...insights.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(item)),
                            ],
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
                        'Account & Security',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...security.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.verified_user_outlined,
                                size: 18,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(item)),
                            ],
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
                        'Workspace',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      InfoRow(
                        label: 'Location',
                        value: data['location']?.toString() ?? '',
                      ),
                      InfoRow(
                        label: 'Risk Profile',
                        value: data['riskProfile']?.toString() ?? '',
                      ),
                      InfoRow(
                        label: 'Portfolio Value',
                        value: money(
                          number(data['portfolioValue']),
                          decimals: 2,
                          compact: false,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/settings'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.onSurface,
                          side: const BorderSide(
                            color: AppColors.outlineVariant,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Settings'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/admin'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Admin Panel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
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
                        'LSTM Model Metrics',
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (accent != null)
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(18),
                  ),
                ),
              ),
            Expanded(
              child: Padding(padding: padding, child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.placeholder});

  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.outline),
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
  const SocialButton({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
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
                  'Live LSTM Stream',
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
