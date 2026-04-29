part of 'web_tracking_cubit.dart';

abstract class WebTrackingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TrackingInitial extends WebTrackingState {}

class TrackingLoading extends WebTrackingState {}

class TrackingNotFound extends WebTrackingState {}

class TrackingFailure extends WebTrackingState {
  final String message;
  TrackingFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class TrackingSuccess extends WebTrackingState {
  final Map<String, dynamic> ticket;
  TrackingSuccess(this.ticket);
  @override
  List<Object?> get props => [ticket];
}
