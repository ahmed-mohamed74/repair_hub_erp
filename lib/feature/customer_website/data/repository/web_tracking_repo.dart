import 'package:dartz/dartz.dart';
import 'package:repair_hub/core/shared/remote_data_sources/ticket_remote_data_source.dart'; // Standard for result.fold

class WebTrackingRepository {
  final TicketRemoteDataSource remoteDataSource;

  WebTrackingRepository(this.remoteDataSource);

  Future<Either<String, Map<String, dynamic>?>> fetchTicketByIdOrImei(
    String query,
  ) async {
    try {
      final result = await remoteDataSource.getTicketByIdOrImei(query);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
