import 'package:flutter/material.dart';

class SummaryHeaderWidget extends StatelessWidget {
  final List<Map<String, dynamic>> tickets;
  const SummaryHeaderWidget({super.key, required this.tickets});

  @override
  Widget build(BuildContext context) {
    final inProgress = tickets.where((t) {
      final s = t['status'].toString().toLowerCase();
      return s == 'repairing' || s == 'diagnosing' || s == 'received';
    }).length;

    final ready = tickets.where((t) {
      final s = t['status'].toString().toLowerCase();
      return s == 'readyforpickup' || s == 'ready_for_pickup';
    }).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          _buildStatusChip(
            'Active Repairs',
            Colors.orange,
            inProgress.toString(),
          ),
          const SizedBox(width: 12),
          _buildStatusChip('Ready', Colors.green, ready.toString()),
        ],
      ),
    );
  }
}

Widget _buildStatusChip(String label, Color color, String count) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    ),
  );
}
