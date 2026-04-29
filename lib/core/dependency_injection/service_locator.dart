import 'package:get_it/get_it.dart';
import 'package:repair_hub/feature/app_home/view/home_cubit/home_cubit.dart';
import 'package:repair_hub/feature/ticket_details/data/repository/ticket_details_repo.dart';
import 'package:repair_hub/feature/ticket_details/presentation/cubit/ticket_details_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:repair_hub/core/shared/remote_data_sources/ticket_remote_data_source.dart';
import 'package:repair_hub/feature/add_ticket/data/repository/add_ticket_repo.dart';
import 'package:repair_hub/feature/add_ticket/presentation/add_ticket_cubit/add_ticket_cubit.dart';
import 'package:repair_hub/feature/app_home/data/repository/ticket_repository.dart'; // Add this
import '../supabase/supabase_service.dart';

final serviceLocator = GetIt.instance;

void configureDependencies() {
  // 1. External & Services
  serviceLocator.registerLazySingleton<SupabaseService>(
    () => SupabaseService(),
  );

  // Register the raw SupabaseClient
  serviceLocator.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // 2. Data Sources
  // Both Repositories will use this single Data Source
  serviceLocator.registerLazySingleton<TicketRemoteDataSource>(
    () => TicketRemoteDataSourceImpl(serviceLocator<SupabaseClient>()),
  );

  // 3. Repositories
  serviceLocator.registerLazySingleton<AddTicketRepository>(
    () => AddTicketRepository(serviceLocator<TicketRemoteDataSource>()),
  );

  // NEW: Register Home Repository
  serviceLocator.registerLazySingleton<TicketRepository>(
    () => TicketRepository(serviceLocator<TicketRemoteDataSource>()),
  );

  // NEW: Register Ticket Details Repository
  serviceLocator.registerLazySingleton<TicketDetailsRepository>(
    () => TicketDetailsRepository(serviceLocator<TicketRemoteDataSource>()),
  );

  // 4. Cubits

  // Add Ticket Cubit (Factory: Resets when opening the page)
  serviceLocator.registerFactory(
    () => AddTicketCubit(serviceLocator<AddTicketRepository>()),
  );

  // Use Factory if you want the list to refresh from scratch every time
  serviceLocator.registerFactory(
    () => HomeCubit(repository: serviceLocator<TicketRepository>()),
  );

  // NEW: Register Ticket Details Cubit
  serviceLocator.registerFactory(
    () => TicketDetailsCubit(serviceLocator<TicketDetailsRepository>()),
  );
}
