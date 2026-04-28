part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeFailure extends HomeState {
  final String message;
  HomeFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class HomeSuccess extends HomeState {
  final List<Map<String, dynamic>> tickets;
  // This helps Bloc know the state is different even if the data looks similar
  final DateTime timestamp;

  HomeSuccess(this.tickets) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [tickets, timestamp];
}
