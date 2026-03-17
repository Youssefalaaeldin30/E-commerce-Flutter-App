import 'package:bloc/bloc.dart';
part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingInitial());

  String? selectedGender;

  void selectGender(String gender) {
    selectedGender = gender;
    emit(OnboardingSelected(gender));
  }

  void skip() {
    selectedGender = null;
    emit(OnboardingSkipped());
  }
}
