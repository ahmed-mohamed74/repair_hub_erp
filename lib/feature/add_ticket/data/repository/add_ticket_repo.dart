import 'package:dartz/dartz.dart';
import 'package:repair_hub/core/shared/remote_data_sources/ticket_remote_data_source.dart';

class AddTicketRepository {
  final TicketRemoteDataSource dataSource;
  AddTicketRepository(this.dataSource);

  Future<Either<String, String>> submitTicket({
    required String name,
    required String phone,
    required String brand,
    required String model,
    required String imei,
    required String description,
    required double price,
    required List<String> photoPaths,
  }) async {
    try {
      final ticketId = await dataSource.createFullTicket(
        name: name,
        phone: phone,
        brand: brand,
        model: model,
        imei: imei,
        description: description,
        price: price,
        localPhotoPaths: photoPaths,
      );
      return Right(ticketId);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
