import 'package:dartz/dartz.dart';
import 'package:repair_hub/core/shared/models/ticket_model.dart';
import 'package:repair_hub/core/shared/models/ticket_status_enum.dart';
import 'package:repair_hub/core/shared/remote_data_sources/ticket_remote_data_source.dart';

class TicketDetailsRepository {
  final TicketRemoteDataSource dataSource;
  TicketDetailsRepository(this.dataSource);

Future<Either<String, TicketModel>> fetchTicketDetails(String id) async {
  try {
    final data = await dataSource.getTicketById(id);
    return Right(TicketModel.fromMap(data));
  } catch (e) {
    return Left(e.toString());
  }
}

Future<Either<String, void>> updateStatus(String id, TicketStatus status) async {
  try {
    await dataSource.updateTicketStatus(id, status.name);
    return const Right(null);
  } catch (e) {
    return Left(e.toString());
  }
}
}