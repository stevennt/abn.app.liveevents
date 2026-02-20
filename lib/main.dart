import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/themes/app_theme.dart';
import 'features/app/screens/home_shell.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/state/auth_state.dart';
import 'features/events/repositories/events_repository.dart';
import 'features/events/services/events_service.dart';
import 'features/events/state/events_state.dart';
import 'features/location/services/location_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LiveEventsApp());
}

class LiveEventsApp extends StatelessWidget {
  const LiveEventsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
        Provider<AuthService>(
          create: (context) => AuthService(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<AuthState>(
          create: (context) => AuthState(context.read<AuthService>()),
        ),
        Provider<EventsService>(
          create: (context) => EventsService(context.read<ApiClient>()),
        ),
        Provider<EventsRepository>(
          create: (context) => EventsRepository(context.read<EventsService>()),
        ),
        Provider<LocationService>(create: (_) => const LocationService()),
        ChangeNotifierProvider<EventsState>(
          create: (context) => EventsState(
            repository: context.read<EventsRepository>(),
            locationService: context.read<LocationService>(),
            authState: context.read<AuthState>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'LiveEvents',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: AppTheme.lightTheme,
        home: const HomeShell(),
      ),
    );
  }
}
