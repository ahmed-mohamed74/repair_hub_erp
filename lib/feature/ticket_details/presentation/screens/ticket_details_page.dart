import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:repair_hub/core/shared/models/ticket_model.dart';
import 'package:repair_hub/core/shared/models/ticket_status_enum.dart';
import 'package:repair_hub/feature/ticket_details/presentation/cubit/ticket_details_cubit.dart';

class TicketDetailsPage extends StatefulWidget {
  final String ticketId;
  const TicketDetailsPage({super.key, required this.ticketId});

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  @override
  void initState() {
    super.initState();
    print("DEBUG: Navigating to Ticket ID: ${widget.ticketId}");
    context.read<TicketDetailsCubit>().loadTicket(widget.ticketId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Details'), elevation: 0),
      body: BlocBuilder<TicketDetailsCubit, TicketDetailsState>(
        builder: (context, state) {
          if (state is TicketDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TicketDetailsFailure) {
            return Center(child: Text(state.message));
          } else if (state is TicketDetailsSuccess) {
            final ticket = state.ticket;
            return _buildContent(context, ticket);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TicketModel ticket) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Card (ID & Status)
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ticket Number',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        '#${ticket.ticketNumber.toString().padLeft(4, '0')}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(ticket.status),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Info Grid
          Row(
            children: [
              _infoTile(
                context,
                'Created',
                DateFormat('MMM d, yyyy').format(ticket.createdAt),
              ),
              _infoTile(
                context,
                'Estimate',
                '\$${ticket.estimatedPrice.toStringAsFixed(2)}',
              ),
            ],
          ),
          const Divider(height: 32),

          // 3. Description Section
          const Text(
            'Description',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(ticket.description ?? 'No description provided'),
          const SizedBox(height: 20),

          // 4. Photos Section
          if (ticket.imageUrls.isNotEmpty) ...[
            const Text(
              'Device Photos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ticket.imageUrls.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      ticket.imageUrls[index],
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 5. Notes Sections
          _notesBox(
            context,
            'Internal Notes (Technician Only)',
            ticket.internalNotes,
          ),
          const SizedBox(height: 12),
          _notesBox(
            context,
            'Public Notes (Shown to Customer)',
            ticket.publicNotes,
          ),
        ],
      ),
    );
  }

  Widget _infoTile(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _notesBox(BuildContext context, String title, String? content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            content ?? 'No notes added yet.',
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(TicketStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.received:
        return Colors.blue;
      case TicketStatus.diagnosing:
        return Colors.orange;
      case TicketStatus.repairing:
        return Colors.purple;
      case TicketStatus.readyForPickup:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
