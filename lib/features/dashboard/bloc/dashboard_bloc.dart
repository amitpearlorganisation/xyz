import 'package:bloc/bloc.dart';

class DashboardBloc extends Cubit<int> {
  DashboardBloc() : super(0);

  ChangeIndex(int currentIndex) {
    emit(currentIndex);
  }
}
