import 'package:dartz/dartz.dart';
import 'package:repair_hub/core/shared/remote_data_sources/ticket_remote_data_source.dart';

class TicketRepository {
  final TicketRemoteDataSource dataSource;
  TicketRepository(this.dataSource);

  Future<Either<String, List<Map<String, dynamic>>>> fetchAllTickets() async {
    try {
      final tickets = await dataSource.getTickets();
      return Right(tickets);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<Map<String, dynamic>>>> searchTickets(String query) async {
    try {
      final tickets = await dataSource.searchTickets(query);
      return Right(tickets);
    } catch (e) {
      return Left(e.toString());
    }
  }
}