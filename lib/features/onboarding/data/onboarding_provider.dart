import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingState {
  const OnboardingState({required this.isReady, required this.hasSeen});

  final bool isReady;
  final bool hasSeen;

  OnboardingState copyWith({bool? isReady, bool? hasSeen}) {
    return OnboardingState(
      isReady: isReady ?? this.isReady,
      hasSeen: hasSeen ?? this.hasSeen,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier()
    : super(const OnboardingState(isReady: false, hasSeen: false)) {
    _load();
  }

  static const _key = 'hasSeenOnboarding';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_key) ?? false;
    state = OnboardingState(isReady: true, hasSeen: seen);
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = state.copyWith(isReady: true, hasSeen: true);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      return OnboardingNotifier();
    });
