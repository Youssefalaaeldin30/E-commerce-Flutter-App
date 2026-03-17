part of 'onboarding_cubit.dart';

abstract class OnboardingState {}

class OnboardingInitial extends OnboardingState {}

class OnboardingSelected extends OnboardingState {
  final String gender;
  OnboardingSelected(this.gender);
}

class OnboardingSkipped extends OnboardingState {}
