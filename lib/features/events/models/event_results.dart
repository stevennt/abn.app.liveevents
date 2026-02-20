import 'live_event.dart';

class FeedLoadResult {
  const FeedLoadResult({
    required this.events,
    this.warningMessage,
    this.usedFallback = false,
  });

  final List<LiveEvent> events;
  final String? warningMessage;
  final bool usedFallback;
}

class EventMutationResult {
  const EventMutationResult({
    required this.event,
    this.warningMessage,
    this.usedFallback = false,
    this.shouldPromptLogin = false,
  });

  final LiveEvent event;
  final String? warningMessage;
  final bool usedFallback;
  final bool shouldPromptLogin;
}
