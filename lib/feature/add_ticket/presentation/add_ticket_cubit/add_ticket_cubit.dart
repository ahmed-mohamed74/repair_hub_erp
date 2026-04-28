import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_hub/feature/add_ticket/data/repository/add_ticket_repo.dart';
import 'add_ticket_state.dart';

class AddTicketCubit extends Cubit<AddTicketState> {
  final AddTicketRepository _repository;

  AddTicketCubit(this._repository) : super(const AddTicketState());

  void updateBrand(String brand) {
    emit(state.copyWith(brand: brand, errorMessage: null));
  }

  void updatePhoto(int index, String path) {
    final newPaths = List<String>.from(state.photoPaths);
    newPaths[index] = path;
    emit(state.copyWith(photoPaths: newPaths));
  }

  void clearPhoto(int index) {
    final newPaths = List<String>.from(state.photoPaths);
    newPaths[index] = '';
    emit(state.copyWith(photoPaths: newPaths));
  }

  Future<void> submit({
    required String name,
    required String phone,
    required String imei,
    required String model,
    required String description,
    required String priceString,
  }) async {
    emit(
      state.copyWith(
        status: AddTicketStatus.loading,
        errorMessage: null,
        successTicketId: null,
      ),
    );
    final price = double.tryParse(priceString) ?? 0.0;
    final result = await _repository.submitTicket(
      name: name,
      phone: phone,
      brand: state.brand,
      model: model,
      imei: imei,
      description: description,
      price: price,
      photoPaths: state.photoPaths,
    );

    result.fold(
      (error) => emit(
        state.copyWith(status: AddTicketStatus.failure, errorMessage: error),
      ),
      (id) => emit(
        state.copyWith(status: AddTicketStatus.success, successTicketId: id),
      ),
    );
  }
}
