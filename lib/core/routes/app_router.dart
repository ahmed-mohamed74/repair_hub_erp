import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:repair_hub/core/dependency_injection/service_locator.dart';
import 'package:repair_hub/feature/add_ticket/presentation/add_ticket_cubit/add_ticket_cubit.dart';
import 'package:repair_hub/feature/add_ticket/presentation/screens/add_ticket_page.dart';
import 'package:repair_hub/feature/app_home/view/home_cubit/home_cubit.dart';
import 'package:repair_hub/feature/app_home/view/screens/home_screen.dart';
import 'package:repair_hub/feature/customer_website/presentation/cubit/web_tracking_cubit.dart';
import 'package:repair_hub/feature/customer_website/presentation/screens/customer_tracking_screen.dart';
import 'package:repair_hub/feature/ticket_details/presentation/cubit/ticket_details_cubit.dart';
import 'package:repair_hub/feature/ticket_details/presentation/screens/ticket_details_page.dart';

class AppRoutes {
  static const home = '/';
  static const addTicket = '/add-ticket';
  static const ticketDetails = '/ticket-details';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: kIsWeb ? '/track' : AppRoutes.home,
    routes: [
      GoRoute(
        name: 'home',
        path: AppRoutes.home,
        builder: (context, state) => BlocProvider.value(
          value: serviceLocator<HomeCubit>()..loadTickets(),
          child: HomeScreen(),
        ),
      ),
      GoRoute(
        name: 'add-ticket',
        path: AppRoutes.addTicket,
        builder: (context, state) => BlocProvider.value(
          value: serviceLocator<AddTicketCubit>(),
          child: AddTicketPage(),
        ),
      ),
      GoRoute(
        name: 'ticket-details',
        path: AppRoutes.ticketDetails,
        builder: (context, state) {
          final ticketId = state.extra as String;
          return BlocProvider.value(
            value: serviceLocator<TicketDetailsCubit>(),
            child: TicketDetailsPage(ticketId: ticketId),
          );
        },
      ),
      GoRoute(
        path: '/track',
        builder: (context, state) => BlocProvider.value(
          value: serviceLocator<WebTrackingCubit>(),
          child: const CustomerTrackingScreen(),
        ),
      ),
    ],
  );
}
