import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:repair_hub/core/constants/db_constants.dart';
import 'package:repair_hub/core/routes/app_router.dart';

class TicketListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> tickets;
  const TicketListWidget({super.key, required this.tickets});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: ValueKey(tickets.length),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return GestureDetector(
          onTap: () {
            context.push(
              AppRoutes.ticketDetails,
              extra: ticket[DbKeys.ticketId].toString(),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: ListTile(
              title: Text(
                '${ticket[DbKeys.brandName]} ${ticket[DbKeys.modelName]} - ${ticket[DbKeys.customerName]}',
              ),
              subtitle: Text(
                'Ticket #${ticket[DbKeys.ticketNumber]} • IMEI: ${ticket[DbKeys.imei]}',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\$${ticket[DbKeys.estimatedPrice]}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    ticket[DbKeys.status].toString().toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
