import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:repair_hub/core/routes/app_router.dart';
import 'package:repair_hub/feature/app_home/view/home_cubit/home_cubit.dart';
import 'package:repair_hub/feature/app_home/view/widgets/summary_header_widget.dart';
import 'package:repair_hub/feature/app_home/view/widgets/ticket_list_widget.dart';
import 'package:repair_hub/feature/app_home/view/widgets/ticket_search_delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: theme.colorScheme.surface,
        title: const Text(
          'Repair Hub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.search_rounded),
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
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<HomeCubit, HomeState>(
        // Fixed buildWhen to ensure the UI updates when data changes
        buildWhen: (previous, current) => previous != current,
        listener: (context, state) {
          if (state is HomeFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is HomeSuccess) {
            return RefreshIndicator(
              onRefresh: () {
                context.go(AppRoutes.home);
                setState(() {});
                return context.read<HomeCubit>().loadTickets();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SummaryHeaderWidget(tickets: state.tickets),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      "Recent Tickets",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    child: state.tickets.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                              ),
                              const Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No tickets found',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : TicketListWidget(
                            key: UniqueKey(),
                            tickets: state.tickets,
                          ),
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
          if (context.mounted) {
            context.read<HomeCubit>().loadTickets();
          }
        },
        elevation: 4,
        label: const Text('New Repair'),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }
}
