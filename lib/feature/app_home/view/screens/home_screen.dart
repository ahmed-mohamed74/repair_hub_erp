import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:repair_hub/core/routes/app_router.dart';
import 'package:repair_hub/feature/app_home/view/home_cubit/home_cubit.dart';
import 'package:repair_hub/feature/app_home/view/widgets/summary_header_widget.dart';
import 'package:repair_hub/feature/app_home/view/widgets/ticket_list_widget.dart';
import 'package:repair_hub/feature/app_home/view/widgets/ticket_search_delegate.dart'; // Import your delegate

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repair Shop Dashboard'),
        actions: [
          // Search Icon Button
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  if (state is HomeSuccess) {
                    showSearch(
                      context: context,
                      delegate: TicketSearchDelegate(allTickets: state.tickets),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context.read<HomeCubit>().loadTickets(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is HomeSuccess) {
            print("UI REBUILDING WITH ${state.tickets.length} TICKETS");
            return RefreshIndicator(
              onRefresh: () {
                return context.read<HomeCubit>().loadTickets();
              },
              child: Column(
                children: [
                  // Pass the tickets to update chips dynamically
                  SummaryHeaderWidget(tickets: state.tickets),
                  Expanded(
                    child: state.tickets.isEmpty
                        ? const Center(child: Text('No repair tickets found'))
                        : TicketListWidget(tickets: state.tickets),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(AppRoutes.addTicket);
          // Refresh data when returning from the Add Ticket screen
          if (context.mounted) {
            context.read<HomeCubit>().loadTickets();
          }
        },
        label: const Text('New Repair'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
