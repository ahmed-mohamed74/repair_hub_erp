import 'package:flutter/material.dart';
import 'package:repair_hub/feature/app_home/view/widgets/ticket_list_widget.dart';

class TicketSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> allTickets;

  TicketSearchDelegate({required this.allTickets});

  // Actions for the search bar (e.g., clear button)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  // Leading icon (e.g., back button)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  // What happens when someone hits "Enter"
  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  // What happens while typing (Suggestions)
  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final q = query.toLowerCase();
    
    // Perform the local filter
    final filtered = allTickets.where((ticket) {
      final name = (ticket['customer_name'] ?? '').toString().toLowerCase();
      final imei = (ticket['imei'] ?? '').toString().toLowerCase();
      final ticketId = (ticket['ticket_id'] ?? '').toString().toLowerCase();
      
      return name.contains(q) || imei.contains(q) || ticketId.contains(q);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No matching tickets found.'));
    }

    // Reuse your existing list widget
    return TicketListWidget(tickets: filtered);
  }
}