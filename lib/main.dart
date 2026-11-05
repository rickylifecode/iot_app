import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

String _authMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'That email address is not valid.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Incorrect email or password.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'email-already-in-use':
      return 'An account with this email already exists.';
    case 'weak-password':
      return 'Choose a stronger password (at least 6 characters).';
    case 'too-many-requests':
      return 'Too many attempts. Try again in a few minutes.';
    case 'network-request-failed':
      return 'No connection. Check your internet and try again.';
    default:
      return e.message ?? 'Something went wrong. Please try again.';
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data == null
            ? const LoginPage()
            : HomeDashboardPage(
                user: snapshot.data,
                onSignOut: () => _signOut(context),
              );
      },
    );
  }
}

Future<void> _signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  if (!context.mounted) return;
  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
}

class _AppColors {
  static const ink = Color(0xFF172B4D);
  static const muted = Color(0xFF5E6A71);
  static const green = Color(0xFF0A66C2);
  static const background = Color(0xFFF3F6F8);
  static const line = Color(0xFFDDE5EB);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _AppColors.green,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'prolıvıng — Smart living',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: _AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: _AppColors.background,
          foregroundColor: _AppColors.ink,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: _AppColors.ink,
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.5,
          ),
          headlineMedium: TextStyle(
            color: _AppColors.ink,
            fontSize: 27,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
          titleLarge: TextStyle(
            color: _AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(color: _AppColors.muted, height: 1.5),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          labelStyle: const TextStyle(color: _AppColors.muted),
          hintStyle: const TextStyle(color: Color(0xFFA3ACA6)),
          prefixIconColor: _AppColors.muted,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _AppColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _AppColors.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _AppColors.green, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _AppColors.green,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 52),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _AppColors.ink,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: const _AuthGate(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const HomeDashboardPage(),
        '/products': (context) => const DeviceStorePage(),
      },
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({this.light = false});

  final bool light;

  @override
  Widget build(BuildContext context) {
    final foreground = light ? Colors.white : _AppColors.ink;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: light ? Colors.white.withOpacity(0.14) : _AppColors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.sensors_rounded,
              color: light ? Colors.white : Colors.white, size: 23),
        ),
        const SizedBox(width: 10),
        Text(
          'prolıvıng',
          style: TextStyle(
            color: foreground,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.2,
          ),
        ),
      ],
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (route) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_authMessage(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 48 : 24,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: isWide
                  ? Row(
                      children: [
                        const Expanded(child: _WelcomePanel()),
                        const SizedBox(width: 72),
                        Expanded(child: _loginForm(context)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Brand(),
                        const SizedBox(height: 44),
                        _loginForm(context),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginForm(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (MediaQuery.sizeOf(context).width >= 900) ...[
                const _Brand(),
                const SizedBox(height: 48),
              ],
              Text('Welcome home',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text('Sign in to make your space a little smarter.'),
              const SizedBox(height: 32),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return 'Enter your email address';
                  if (!email.contains('@') || !email.contains('.')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _login(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip:
                        _obscurePassword ? 'Show password' : 'Hide password',
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                ),
                validator: (value) => (value == null || value.length < 6)
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _login,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.arrow_forward_rounded, size: 19),
                  label: Text(_loading ? 'Signing in…' : 'Sign in'),
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    const Text('New to prolıvıng? ',
                        style: TextStyle(color: _AppColors.muted)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        'Create an account',
                        style: TextStyle(
                          color: _AppColors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'By continuing, you agree to our Terms & Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 540),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A66C2), Color(0xFF004182)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -80,
            bottom: -90,
            child: Icon(Icons.sensors_rounded,
                size: 330, color: Colors.white.withOpacity(0.06)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Brand(light: true),
              const Spacer(),
              const Text(
                'A calmer home.\nA smarter life.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 45,
                  height: 1.08,
                  letterSpacing: -1.7,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Thoughtful technology that works quietly in the background, so you can focus on what matters.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.76),
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 38),
              const _Benefit(
                icon: Icons.tune_rounded,
                title: 'Everything, in one place',
              ),
              const SizedBox(height: 16),
              const _Benefit(
                icon: Icons.energy_savings_leaf_rounded,
                title: 'Smarter, more sustainable living',
              ),
              const Spacer(),
              Text(
                'MADE FOR THE WAY YOU LIVE',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: const Color(0xFFB8DCFF)),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      await cred.user?.updateDisplayName(_name.text.trim());
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (route) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_authMessage(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Brand(),
                    const SizedBox(height: 38),
                    Text('Make yourself at home',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    const Text(
                        'Create your account and bring it all together.'),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? 'Enter your name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Enter your email address';
                        if (!email.contains('@') || !email.contains('.')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _register(),
                      decoration: InputDecoration(
                        labelText: 'Create a password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (value) => (value == null || value.length < 6)
                          ? 'Use at least 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        child: Text(
                            _loading ? 'Creating account…' : 'Create account'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Text('Already have an account? ',
                              style: TextStyle(color: _AppColors.muted)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                color: _AppColors.green,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key, this.user, this.onSignOut});

  final User? user;
  final Future<void> Function()? onSignOut;

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  static const _rooms = ['Living Room', 'Bedroom', 'Kitchen', 'Bathroom'];
  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _demoDevices = [
    _DemoDevice(
      id: 'light',
      name: 'Living room lights',
      room: 'Living Room',
      icon: Icons.lightbulb_rounded,
      color: _DashColors.amber,
      control: _DemoControl.light,
    ),
    _DemoDevice(
      id: 'climate',
      name: 'Bedroom climate',
      room: 'Bedroom',
      icon: Icons.thermostat_rounded,
      color: _DashColors.cyan,
      control: _DemoControl.climate,
    ),
    _DemoDevice(
      id: 'fan',
      name: 'Ceiling fan',
      room: 'Living Room',
      icon: Icons.mode_fan_off_rounded,
      color: _DashColors.blue,
      control: _DemoControl.fan,
    ),
    _DemoDevice(
      id: 'socket',
      name: 'Kitchen socket',
      room: 'Kitchen',
      icon: Icons.power_rounded,
      color: _DashColors.violet,
      control: _DemoControl.power,
    ),
    _DemoDevice(
      id: 'lock',
      name: 'Front door',
      room: 'Living Room',
      icon: Icons.lock_rounded,
      color: _DashColors.green,
      control: _DemoControl.lock,
    ),
    _DemoDevice(
      id: 'camera',
      name: 'Entry camera',
      room: 'Living Room',
      icon: Icons.videocam_rounded,
      color: _DashColors.cyan,
      control: _DemoControl.camera,
    ),
    _DemoDevice(
      id: 'temperature',
      name: 'Room sensor',
      room: 'Bedroom',
      icon: Icons.device_thermostat_rounded,
      color: _DashColors.amber,
      control: _DemoControl.temperature,
    ),
    _DemoDevice(
      id: 'water',
      name: 'Water sensor',
      room: 'Bathroom',
      icon: Icons.water_drop_rounded,
      color: _DashColors.blue,
      control: _DemoControl.water,
    ),
    _DemoDevice(
      id: 'alarm',
      name: 'Security alarm',
      room: 'Living Room',
      icon: Icons.shield_rounded,
      color: _DashColors.rose,
      control: _DemoControl.alarm,
    ),
  ];

  int _selectedTab = 0;
  String? _roomFilter;
  bool _awayMode = false;
  DateTime _now = DateTime.now();
  late final Timer _clock;
  final Map<String, bool> _demoPower = {
    'light': true,
    'fan': false,
    'socket': true,
    'lock': true,
    'alarm': false,
  };
  double _brightness = 68;
  double _fanSpeed = 45;
  double _setTemperature = 21;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  String get _greeting {
    if (_now.hour < 12) return 'Good morning';
    if (_now.hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String get _firstName {
    final name = widget.user?.displayName?.trim();
    if (name != null && name.isNotEmpty) return name.split(' ').first;
    final emailName = widget.user?.email?.split('@').first;
    return emailName == null || emailName.isEmpty ? 'there' : emailName;
  }

  String get _formattedDate =>
      '${_weekdays[_now.weekday - 1]}, ${_months[_now.month - 1]} ${_now.day}';

  String get _formattedTime {
    final hour = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final minute = _now.minute.toString().padLeft(2, '0');
    final period = _now.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DashColors.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.012),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(_selectedTab),
            child: _buildPage(),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        backgroundColor: _DashColors.surface,
        indicatorColor: _DashColors.blue.withOpacity(0.16),
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.meeting_room_outlined),
            selectedIcon: Icon(Icons.meeting_room_rounded),
            label: 'Rooms',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Devices',
          ),
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt_rounded),
            label: 'Energy',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (_selectedTab) {
      case 1:
        return _roomsPage();
      case 2:
        return _devicesPage();
      case 3:
        return _energyPage();
      case 4:
        return _settingsPage();
      default:
        return _homePage();
    }
  }

  Widget _pageShell(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 420 ? 16.0 : 24.0;
        return SingleChildScrollView(
          key: PageStorageKey(_selectedTab),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            20,
            horizontalPadding,
            30,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _pageHeader({
    required String eyebrow,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: const TextStyle(
                  color: _DashColors.cyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                title,
                style: const TextStyle(
                  color: _DashColors.text,
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _DashColors.muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing,
        ],
      ],
    );
  }

  Widget _homePage() {
    return _pageShell(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              return Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _DashColors.blue.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.sensors_rounded,
                      color: _DashColors.cyan,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Flexible(
                    child: Text(
                      'prolıvıng',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _DashColors.text,
                        fontSize: compact ? 15 : 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: compact ? 0.6 : 2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _ConnectionBadge(compact: compact),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          Text(
            '$_greeting, $_firstName',
            style: const TextStyle(
              color: _DashColors.text,
              fontSize: 29,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$_formattedDate  ·  $_formattedTime',
            style: const TextStyle(color: _DashColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 22),
          _homeHero(),
          const SizedBox(height: 18),
          _liveStats(),
          const SizedBox(height: 30),
          _sectionTitle(
            'Your rooms',
            trailing: TextButton(
              onPressed: () => setState(() => _selectedTab = 1),
              child: const Text('See all'),
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _rooms.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) => _RoomTile(
                room: _rooms[index],
                icon: _roomIcon(_rooms[index]),
                onTap: () => _openRoom(_rooms[index]),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _sectionTitle('Quick access'),
          const SizedBox(height: 12),
          _quickAccessCard(),
        ],
      ),
    );
  }

  Widget _homeHero() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A66C2), Color(0xFF0756A2), Color(0xFF004182)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -25,
            bottom: -34,
            child: Icon(
              Icons.home_rounded,
              size: 205,
              color: Colors.white.withOpacity(0.055),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    const heading = Text(
                      'Your home,\nin harmony.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        height: 1.13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    );
                    final presence = Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(22),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _awayMode
                                ? Icons.near_me_rounded
                                : Icons.home_rounded,
                            color: _DashColors.cyan,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _awayMode ? 'Away' : 'Home',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                    if (constraints.maxWidth < 340) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          heading,
                          const SizedBox(height: 12),
                          presence,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        const Expanded(child: heading),
                        const SizedBox(width: 8),
                        presence,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 13),
                Text(
                  'Presence mode is a local preference; it does not trigger devices.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 19),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _awayMode = !_awayMode),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.28)),
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  icon: Icon(
                    _awayMode ? Icons.home_rounded : Icons.near_me_rounded,
                    size: 17,
                  ),
                  label: Text(_awayMode ? 'Set home mode' : 'Set away mode'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 20) / 3;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: cardWidth,
              child: const _StatCard(
                icon: Icons.devices_rounded,
                label: 'Connected',
                value: '0',
                color: _DashColors.cyan,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _StatCard(
                icon: Icons.power_settings_new_rounded,
                label: 'Active',
                value: '0',
                color: _DashColors.green,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _StatCard(
                icon: Icons.power_off_rounded,
                label: 'Inactive',
                value: '0',
                color: _DashColors.muted,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _quickAccessCard() {
    return _Panel(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _DashColors.cyan.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: _DashColors.cyan,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device controls',
                  style: TextStyle(
                    color: _DashColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Explore clearly labeled local previews',
                  style: TextStyle(color: _DashColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Open device previews',
            onPressed: () => setState(() => _selectedTab = 2),
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: _DashColors.cyan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roomsPage() {
    return _pageShell(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            eyebrow: 'Spaces',
            title: 'Rooms',
            subtitle: 'A clear view of every space in your home.',
          ),
          const SizedBox(height: 22),
          const _Panel(
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: _DashColors.cyan, size: 20),
                SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'No hardware is connected yet. Room device counts reflect confirmed connections only.',
                    style: TextStyle(
                      color: _DashColors.muted,
                      height: 1.45,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 700
                  ? (constraints.maxWidth - 14) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: _rooms
                    .map(
                      (room) => SizedBox(
                        width: width,
                        child: _RoomCard(
                          room: room,
                          icon: _roomIcon(room),
                          onTap: () => _openRoom(room),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 22),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _roomFilter = null;
                _selectedTab = 2;
              });
            },
            icon: const Icon(Icons.grid_view_rounded),
            label: const Text('View all device statuses'),
          ),
        ],
      ),
    );
  }

  Widget _devicesPage() {
    final devices = _demoDevices
        .where((device) => _roomFilter == null || device.room == _roomFilter)
        .toList();
    return _pageShell(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            eyebrow: 'Control center',
            title: _roomFilter ?? 'Devices',
            subtitle: 'Live status is shown only for connected hardware.',
            trailing: _roomFilter == null
                ? null
                : IconButton(
                    tooltip: 'Show all devices',
                    onPressed: () => setState(() => _roomFilter = null),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: _DashColors.muted,
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          const _EmptyHardwareCard(),
          const SizedBox(height: 26),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Control previews',
                  style: TextStyle(
                    color: _DashColors.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: _DashColors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'DEMO ONLY',
                  style: TextStyle(
                    color: _DashColors.amber,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'These controls update local preview state only. No device commands are sent.',
            style: TextStyle(
              color: _DashColors.muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          if (devices.isEmpty)
            const _EmptyPreview()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth >= 760
                    ? (constraints.maxWidth - 14) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: devices
                      .map(
                        (device) => SizedBox(
                          width: width,
                          child: _DemoDeviceCard(
                            device: device,
                            control: _demoControl(device),
                            isOn: _demoPower[device.id] ?? false,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _demoControl(_DemoDevice device) {
    switch (device.control) {
      case _DemoControl.light:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Power · local preview',
                    style: TextStyle(color: _DashColors.muted, fontSize: 11),
                  ),
                ),
                Switch.adaptive(
                  value: _demoPower[device.id] ?? false,
                  onChanged: (value) => _setDemoPower(device, value),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.brightness_6_rounded,
                    color: _DashColors.muted, size: 16),
                Expanded(
                  child: Slider(
                    value: _brightness,
                    min: 0,
                    max: 100,
                    onChanged: (value) => setState(() => _brightness = value),
                  ),
                ),
                Text(
                  '${_brightness.round()}%',
                  style: const TextStyle(
                    color: _DashColors.text,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        );
      case _DemoControl.climate:
        return Row(
          children: [
            const Expanded(
              child: Text(
                'Target · local preview',
                style: TextStyle(color: _DashColors.muted, fontSize: 11),
              ),
            ),
            IconButton(
              tooltip: 'Decrease preview temperature',
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() {
                _setTemperature = (_setTemperature - 1).clamp(16, 30);
              }),
              icon: const Icon(Icons.remove_rounded, size: 18),
            ),
            Text(
              '${_setTemperature.round()}°',
              style: const TextStyle(
                color: _DashColors.text,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            IconButton(
              tooltip: 'Increase preview temperature',
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() {
                _setTemperature = (_setTemperature + 1).clamp(16, 30);
              }),
              icon: const Icon(Icons.add_rounded, size: 18),
            ),
          ],
        );
      case _DemoControl.fan:
        return Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Power · local preview',
                    style: TextStyle(color: _DashColors.muted, fontSize: 11),
                  ),
                ),
                Switch.adaptive(
                  value: _demoPower[device.id] ?? false,
                  onChanged: (value) => _setDemoPower(device, value),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.air_rounded,
                    color: _DashColors.muted, size: 16),
                Expanded(
                  child: Slider(
                    value: _fanSpeed,
                    min: 0,
                    max: 100,
                    onChanged: (value) => setState(() => _fanSpeed = value),
                  ),
                ),
                Text(
                  '${_fanSpeed.round()}%',
                  style: const TextStyle(
                    color: _DashColors.text,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        );
      case _DemoControl.power:
        return Row(
          children: [
            const Expanded(
              child: Text(
                'Power · local preview',
                style: TextStyle(color: _DashColors.muted, fontSize: 11),
              ),
            ),
            Switch.adaptive(
              value: _demoPower[device.id] ?? false,
              onChanged: (value) => _setDemoPower(device, value),
            ),
          ],
        );
      case _DemoControl.lock:
        final locked = _demoPower[device.id] ?? true;
        return Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await _confirmPreviewAction(
                title: locked ? 'Unlock demo door?' : 'Lock demo door?',
                message:
                    'This is only a local preview. No real door is connected.',
                action: locked ? 'Unlock preview' : 'Lock preview',
              );
              if (confirmed) _setDemoPower(device, !locked);
            },
            icon: Icon(locked ? Icons.lock_open_rounded : Icons.lock_rounded),
            label: Text(locked ? 'Unlock preview' : 'Lock preview'),
          ),
        );
      case _DemoControl.camera:
        return Container(
          height: 76,
          decoration: BoxDecoration(
            color: _DashColors.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off_rounded,
                  color: _DashColors.muted, size: 18),
              SizedBox(width: 8),
              Text(
                'No live video · demo',
                style: TextStyle(color: _DashColors.muted, fontSize: 11),
              ),
            ],
          ),
        );
      case _DemoControl.temperature:
        return const _DemoReading(
          icon: Icons.thermostat_rounded,
          value: '22.4°',
          caption: 'Sample temperature · demo',
          color: _DashColors.amber,
        );
      case _DemoControl.water:
        return const _DemoReading(
          icon: Icons.water_drop_rounded,
          value: 'Dry',
          caption: 'Sample moisture reading · demo',
          color: _DashColors.blue,
        );
      case _DemoControl.alarm:
        final armed = _demoPower[device.id] ?? false;
        return Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await _confirmPreviewAction(
                title:
                    armed ? 'Deactivate demo alarm?' : 'Activate demo alarm?',
                message:
                    'This changes local preview state only. No alarm hardware is connected.',
                action: armed ? 'Deactivate preview' : 'Activate preview',
              );
              if (confirmed) _setDemoPower(device, !armed);
            },
            icon: Icon(
              armed ? Icons.shield_outlined : Icons.shield_moon_outlined,
            ),
            label: Text(armed ? 'Deactivate preview' : 'Activate preview'),
          ),
        );
    }
  }

  Future<bool> _confirmPreviewAction({
    required String title,
    required String message,
    required String action,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: _DashColors.surfaceRaised,
            title: Text(title, style: const TextStyle(color: _DashColors.text)),
            content: Text(
              message,
              style: const TextStyle(color: _DashColors.muted, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _setDemoPower(_DemoDevice device, bool value) {
    setState(() => _demoPower[device.id] = value);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content:
              Text('Demo only — changed locally; no hardware command sent.'),
        ),
      );
  }

  Widget _energyPage() {
    return _pageShell(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            eyebrow: 'Insights',
            title: 'Energy',
            subtitle: 'Understand your home’s energy at a glance.',
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _DashColors.blue.withOpacity(0.08),
              border: Border.all(color: _DashColors.blue.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    color: _DashColors.cyan, size: 20),
                SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'No energy meter or device telemetry is configured. Real consumption and device-level usage are unavailable.',
                    style: TextStyle(
                      color: _DashColors.muted,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: width,
                    child: const _EnergyMetric(
                      title: 'Today',
                      value: '—',
                      unit: 'no measured data',
                      icon: Icons.today_rounded,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: const _EnergyMetric(
                      title: 'This week',
                      value: '—',
                      unit: 'no measured data',
                      icon: Icons.date_range_rounded,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Usage overview',
                        style: TextStyle(
                          color: _DashColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _DashColors.amber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ILLUSTRATION',
                        style: TextStyle(
                          color: _DashColors.amber,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  'Example shape only · not measured from your home',
                  style: TextStyle(color: _DashColors.muted, fontSize: 11),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: CustomPaint(painter: _EnergyChartPainter()),
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ChartLabel('Mon'),
                    _ChartLabel('Tue'),
                    _ChartLabel('Wed'),
                    _ChartLabel('Thu'),
                    _ChartLabel('Fri'),
                    _ChartLabel('Sat'),
                    _ChartLabel('Sun'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _Panel(
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, color: _DashColors.amber),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Connect a supported meter or device integration to see real usage here.',
                    style: TextStyle(
                      color: _DashColors.muted,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsPage() {
    final email = widget.user?.email ?? 'No signed-in account';
    return _pageShell(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            eyebrow: 'Preferences',
            title: 'Settings',
            subtitle: 'Your account and connected services.',
          ),
          const SizedBox(height: 22),
          _Panel(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: _DashColors.blue.withOpacity(0.15),
                  child: Text(
                    _firstName.isEmpty ? '?' : _firstName[0].toUpperCase(),
                    style: const TextStyle(
                      color: _DashColors.cyan,
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
                        widget.user?.displayName ?? 'Your prolıvıng account',
                        style: const TextStyle(
                          color: _DashColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _DashColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _Panel(
            child: Column(
              children: [
                _ServiceRow(
                  icon: Icons.verified_user_rounded,
                  title: 'Account security',
                  status: 'Firebase Authentication',
                  color: _DashColors.green,
                ),
                Divider(height: 24, color: _DashColors.line),
                _ServiceRow(
                  icon: Icons.hub_rounded,
                  title: 'Smart home hub',
                  status: 'Not configured',
                  color: _DashColors.amber,
                ),
                Divider(height: 24, color: _DashColors.line),
                _ServiceRow(
                  icon: Icons.sensors_rounded,
                  title: 'Device connection',
                  status: 'No IoT integration in this project',
                  color: _DashColors.muted,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/products'),
              icon: const Icon(Icons.storefront_rounded),
              label: const Text('Explore the prolıvıng device store'),
            ),
          ),
          if (widget.onSignOut != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () async => widget.onSignOut!(),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
                style: TextButton.styleFrom(
                  foregroundColor: _DashColors.rose,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, {Widget? trailing}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _DashColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  IconData _roomIcon(String room) {
    switch (room) {
      case 'Living Room':
        return Icons.weekend_rounded;
      case 'Bedroom':
        return Icons.bed_rounded;
      case 'Kitchen':
        return Icons.kitchen_rounded;
      default:
        return Icons.bathtub_rounded;
    }
  }

  void _openRoom(String room) {
    setState(() {
      _roomFilter = room;
      _selectedTab = 2;
    });
  }
}

enum _DemoControl {
  light,
  climate,
  fan,
  power,
  lock,
  camera,
  temperature,
  water,
  alarm,
}

class _DemoDevice {
  const _DemoDevice({
    required this.id,
    required this.name,
    required this.room,
    required this.icon,
    required this.color,
    required this.control,
  });

  final String id;
  final String name;
  final String room;
  final IconData icon;
  final Color color;
  final _DemoControl control;
}

class _DashColors {
  static const background = Color(0xFFF3F6F8);
  static const surface = Colors.white;
  static const surfaceRaised = Colors.white;
  static const line = Color(0xFFDDE5EB);
  static const text = Color(0xFF172B4D);
  static const muted = Color(0xFF5E6A71);
  static const blue = Color(0xFF0A66C2);
  static const cyan = Color(0xFF378FE9);
  static const green = Color(0xFF168B5B);
  static const amber = Color(0xFFB86E00);
  static const violet = Color(0xFF7956C8);
  static const rose = Color(0xFFC94355);
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DashColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _DashColors.line.withOpacity(0.72)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172B4D).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = compact ? 'No hub' : 'No hub connected';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _DashColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _DashColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 8, color: _DashColors.amber),
          const SizedBox(width: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _DashColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: _DashColors.text,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _DashColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.room,
    required this.icon,
    required this.onTap,
  });

  final String room;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Material(
        color: _DashColors.surface,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: _DashColors.cyan, size: 21),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _DashColors.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      '0 connected',
                      style: TextStyle(
                        color: _DashColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.room,
    required this.icon,
    required this.onTap,
  });

  final String room;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _DashColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _DashColors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: _DashColors.cyan),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room,
                      style: const TextStyle(
                        color: _DashColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '0 connected devices',
                      style: TextStyle(
                        color: _DashColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: _DashColors.muted, size: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHardwareCard extends StatelessWidget {
  const _EmptyHardwareCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _DashColors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.hub_outlined, color: _DashColors.amber),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No devices connected',
                  style: TextStyle(
                    color: _DashColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'This project currently includes Firebase sign-in only. Live device pairing and command confirmation are not configured.',
                  style: TextStyle(
                    color: _DashColors.muted,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();

  @override
  Widget build(BuildContext context) {
    return const _Panel(
      child: Row(
        children: [
          Icon(Icons.meeting_room_outlined, color: _DashColors.muted),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No preview controls are assigned to this room.',
              style: TextStyle(color: _DashColors.muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoDeviceCard extends StatelessWidget {
  const _DemoDeviceCard({
    required this.device,
    required this.control,
    required this.isOn,
  });

  final _DemoDevice device;
  final Widget control;
  final bool isOn;

  String get _previewStatus {
    switch (device.control) {
      case _DemoControl.light:
      case _DemoControl.fan:
      case _DemoControl.power:
        return isOn ? 'Demo · On' : 'Demo · Off';
      case _DemoControl.lock:
        return isOn ? 'Demo · Locked' : 'Demo · Unlocked';
      case _DemoControl.alarm:
        return isOn ? 'Demo · Armed' : 'Demo · Disarmed';
      case _DemoControl.camera:
        return 'Demo · No feed';
      case _DemoControl.temperature:
      case _DemoControl.water:
        return 'Demo reading';
      case _DemoControl.climate:
        return 'Demo · Setpoint';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DashColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _DashColors.line.withOpacity(0.78)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: device.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(device.icon, color: device.color, size: 21),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _DashColors.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      device.room,
                      style: const TextStyle(
                        color: _DashColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: device.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _previewStatus,
                style: const TextStyle(
                  color: _DashColors.muted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          control,
        ],
      ),
    );
  }
}

class _DemoReading extends StatelessWidget {
  const _DemoReading({
    required this.icon,
    required this.value,
    required this.caption,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 9),
        Text(
          value,
          style: const TextStyle(
            color: _DashColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _DashColors.muted, fontSize: 10),
          ),
        ),
      ],
    );
  }
}

class _EnergyMetric extends StatelessWidget {
  const _EnergyMetric({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _DashColors.cyan, size: 18),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: _DashColors.muted, fontSize: 11),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: _DashColors.text,
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(unit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _DashColors.muted, fontSize: 9)),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.icon,
    required this.title,
    required this.status,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 19),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _DashColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                status,
                style: const TextStyle(
                  color: _DashColors.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartLabel extends StatelessWidget {
  const _ChartLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(color: _DashColors.muted, fontSize: 10),
    );
  }
}

class _EnergyChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = _DashColors.line
      ..strokeWidth = 1;
    for (var index = 0; index < 4; index++) {
      final y = size.height * index / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    const values = [0.72, 0.57, 0.66, 0.38, 0.5, 0.27, 0.42];
    final points = List<Offset>.generate(
      values.length,
      (index) => Offset(
        size.width * index / (values.length - 1),
        size.height * values[index],
      ),
    );
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      final previous = points[index - 1];
      final current = points[index];
      final middleX = (previous.dx + current.dx) / 2;
      path.cubicTo(
          middleX, previous.dy, middleX, current.dy, current.dx, current.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          _DashColors.blue.withOpacity(0.3),
          _DashColors.blue.withOpacity(0.01),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(
      path,
      Paint()
        ..color = _DashColors.cyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    final pointPaint = Paint()..color = _DashColors.cyan;
    for (final point in points) {
      canvas.drawCircle(point, 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EnergyChartPainter oldDelegate) => false;
}

class _Product {
  const _Product({
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.icon,
    required this.colors,
    required this.tag,
  });

  final String name;
  final String category;
  final String description;
  final String price;
  final IconData icon;
  final List<Color> colors;
  final String tag;
}

const _products = [
  _Product(
    name: 'Smart Thermostat',
    category: 'Climate',
    description: 'Comfort that learns your routine.',
    price: '\$129',
    icon: Icons.device_thermostat_rounded,
    colors: [Color(0xFFE4EFE7), Color(0xFFC9DED0)],
    tag: 'BESTSELLER',
  ),
  _Product(
    name: 'Soil Sensor',
    category: 'Garden',
    description: 'Keep every plant thriving.',
    price: '\$49',
    icon: Icons.yard_rounded,
    colors: [Color(0xFFE9E9D8), Color(0xFFD8DFBD)],
    tag: 'PLANT CARE',
  ),
  _Product(
    name: 'Smart Lighting Kit',
    category: 'Lighting',
    description: 'The right light, every moment.',
    price: '\$79',
    icon: Icons.light_rounded,
    colors: [Color(0xFFF3E8D4), Color(0xFFE9D3A9)],
    tag: 'NEW',
  ),
  _Product(
    name: 'Air Quality Monitor',
    category: 'Climate',
    description: 'Breathe easier, every day.',
    price: '\$89',
    icon: Icons.air_rounded,
    colors: [Color(0xFFE0E9EF), Color(0xFFC6D7E2)],
    tag: 'WELLNESS',
  ),
];

class DeviceStorePage extends StatefulWidget {
  const DeviceStorePage({super.key});

  @override
  State<DeviceStorePage> createState() => _DeviceStorePageState();
}

class _DeviceStorePageState extends State<DeviceStorePage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _favoritesOnly = false;
  final Set<String> _favorites = {};
  int _cartCount = 0;

  static const _categories = ['All', 'Climate', 'Lighting', 'Garden'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Product> get _visibleProducts {
    final query = _searchController.text.trim().toLowerCase();
    return _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
      final matchesFavorite =
          !_favoritesOnly || _favorites.contains(product.name);
      return matchesCategory && matchesQuery && matchesFavorite;
    }).toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final horizontalPadding = constraints.maxWidth >= 1200
                ? (constraints.maxWidth - 1160) / 2
                : wide
                    ? 36.0
                    : 20.0;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        horizontalPadding, 18, horizontalPadding, 0),
                    child: _topBar(wide),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        horizontalPadding, 32, horizontalPadding, 0),
                    child: _heroBanner(wide),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        horizontalPadding, 34, horizontalPadding, 0),
                    child: _catalogHeader(wide),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        horizontalPadding, 18, horizontalPadding, 0),
                    child: _categoryFilters(),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                      horizontalPadding, 20, horizontalPadding, 40),
                  sliver: _productGrid(
                      constraints.maxWidth - 2 * horizontalPadding),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _topBar(bool wide) {
    return Row(
      children: [
        const _Brand(),
        if (wide) ...[
          const SizedBox(width: 48),
          const Text('Discover', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 28),
          TextButton(
            onPressed: () => setState(() => _favoritesOnly = !_favoritesOnly),
            style: TextButton.styleFrom(
              foregroundColor:
                  _favoritesOnly ? _AppColors.green : _AppColors.muted,
            ),
            child: const Text('Favorites'),
          ),
        ],
        const Spacer(),
        if (wide) _searchBox(width: 270),
        IconButton(
          tooltip: 'Shopping bag ($_cartCount items)',
          onPressed: () => _showMessage(_cartCount == 0
              ? 'Your bag is ready for something lovely.'
              : '$_cartCount ${_cartCount == 1 ? 'item' : 'items'} in your bag'),
          icon: Badge(
            isLabelVisible: _cartCount > 0,
            label: Text('$_cartCount'),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 19,
          backgroundColor: const Color(0xFFE1EEE5),
          child: Text(_userInitial(),
              style: const TextStyle(
                  color: _AppColors.green, fontWeight: FontWeight.w700)),
        ),
        if (!wide) ...[
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Log out',
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ],
    );
  }

  String _userInitial() {
    final user = FirebaseAuth.instance.currentUser;
    final source = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : (user?.email ?? '');
    return source.isEmpty ? '?' : source[0].toUpperCase();
  }

  Widget _searchBox({double? width}) {
    return SizedBox(
      width: width,
      height: 46,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search products',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
        ),
      ),
    );
  }

  Widget _heroBanner(bool wide) {
    return Container(
      constraints: const BoxConstraints(minHeight: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF0A66C2), Color(0xFF004182)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: wide ? 55 : -26,
            top: -50,
            bottom: -55,
            child: Icon(
              Icons.home_rounded,
              size: wide ? 320 : 245,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(wide ? 38 : 26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'THE THOUGHTFUL HOME',
                      style: TextStyle(
                        color: Color(0xFFD2E7D7),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Technology that feels like home.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: wide ? 32 : 27,
                      height: 1.14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Small, considered upgrades. A more comfortable everyday.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.76),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 22),
                  OutlinedButton.icon(
                    onPressed: () => Scrollable.ensureVisible(
                      context,
                      duration: const Duration(milliseconds: 450),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.48)),
                      minimumSize: const Size(0, 44),
                    ),
                    icon: const Icon(Icons.arrow_downward_rounded, size: 17),
                    label: const Text('Explore the collection'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _catalogHeader(bool wide) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('THE COLLECTION',
                  style: TextStyle(
                    color: _AppColors.green.withOpacity(0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  )),
              const SizedBox(height: 8),
              Text('Discover your next favorite',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: wide ? 27 : 23,
                      )),
            ],
          ),
        ),
        if (wide)
          TextButton.icon(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Log out'),
          ),
      ],
    );
  }

  Widget _categoryFilters() {
    return Wrap(
      spacing: 9,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ..._categories.map((category) {
          final selected = _selectedCategory == category;
          return ChoiceChip(
            label: Text(category),
            selected: selected,
            onSelected: (_) => setState(() => _selectedCategory = category),
            showCheckmark: false,
            labelStyle: TextStyle(
              color: selected ? Colors.white : _AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.white,
            selectedColor: _AppColors.green,
            side: BorderSide(
                color: selected ? _AppColors.green : _AppColors.line),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          );
        }),
        if (MediaQuery.sizeOf(context).width < 760)
          SizedBox(width: 230, child: _searchBox()),
        const SizedBox(width: 4),
        FilterChip(
          avatar: Icon(
            _favoritesOnly ? Icons.favorite_rounded : Icons.favorite_border,
            size: 17,
            color: _favoritesOnly ? Colors.white : _AppColors.muted,
          ),
          label: const Text('Favorites'),
          selected: _favoritesOnly,
          onSelected: (selected) => setState(() => _favoritesOnly = selected),
          showCheckmark: false,
          labelStyle: TextStyle(
            color: _favoritesOnly ? Colors.white : _AppColors.muted,
            fontSize: 13,
          ),
          backgroundColor: Colors.white,
          selectedColor: _AppColors.green,
          side: BorderSide(
              color: _favoritesOnly ? _AppColors.green : _AppColors.line),
        ),
      ],
    );
  }

  Widget _productGrid(double width) {
    final products = _visibleProducts;
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 56),
          child: Column(
            children: [
              const Icon(Icons.search_off_rounded,
                  size: 42, color: _AppColors.muted),
              const SizedBox(height: 12),
              Text(
                _favoritesOnly && _favorites.isEmpty
                    ? 'Your favorites will live here.'
                    : 'No products found. Try another search.',
                style: const TextStyle(color: _AppColors.muted),
              ),
            ],
          ),
        ),
      );
    }

    final columns = width >= 1050
        ? 3
        : width >= 650
            ? 2
            : 1;
    final aspectRatio = columns == 3
        ? 0.78
        : columns == 2
            ? 0.92
            : 1.08;
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: aspectRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _ProductCard(
          product: products[index],
          isFavorite: _favorites.contains(products[index].name),
          onFavorite: () => setState(() {
            final name = products[index].name;
            if (!_favorites.add(name)) _favorites.remove(name);
          }),
          onOpen: () => _showProduct(products[index]),
        ),
        childCount: products.length,
      ),
    );
  }

  void _showProduct(_Product product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductDetailsSheet(
        product: product,
        onAdd: () {
          setState(() => _cartCount++);
          Navigator.pop(context);
          _showMessage('${product.name} added to your bag.');
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.isFavorite,
    required this.onFavorite,
    required this.onOpen,
  });

  final _Product product;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: _AppColors.line),
      ),
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: product.colors,
                      ),
                    ),
                    child: Center(
                      child: Icon(product.icon,
                          size: 82, color: const Color(0xFF0A66C2)),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    top: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.86),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.tag,
                        style: const TextStyle(
                          color: _AppColors.ink,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Material(
                      color: Colors.white.withOpacity(0.9),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        visualDensity: VisualDensity.compact,
                        onPressed: onFavorite,
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? const Color(0xFFD56666)
                              : _AppColors.ink,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 15, 17, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.category.toUpperCase(),
                      style: const TextStyle(
                        color: _AppColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      )),
                  const SizedBox(height: 5),
                  Text(product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: _AppColors.ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(product.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: _AppColors.muted, fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(product.price,
                          style: const TextStyle(
                              color: _AppColors.ink,
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      const Spacer(),
                      const Icon(Icons.arrow_outward_rounded,
                          size: 18, color: _AppColors.green),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailsSheet extends StatelessWidget {
  const _ProductDetailsSheet({required this.product, required this.onAdd});

  final _Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: _AppColors.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(colors: product.colors),
              ),
              child:
                  Icon(product.icon, size: 92, color: const Color(0xFF0A66C2)),
            ),
            const SizedBox(height: 20),
            Text(product.category.toUpperCase(),
                style: const TextStyle(
                    color: _AppColors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3)),
            const SizedBox(height: 6),
            Text(product.name,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 7),
            Text(product.description),
            const SizedBox(height: 22),
            Row(
              children: [
                Text(product.price,
                    style: const TextStyle(
                        color: _AppColors.ink,
                        fontSize: 23,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                  label: const Text('Add to bag'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
