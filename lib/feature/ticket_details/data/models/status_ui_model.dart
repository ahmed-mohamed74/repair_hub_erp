import 'package:flutter/material.dart';
import 'package:repair_hub/core/shared/models/ticket_status_enum.dart';

class StatusUI {
  final String label;
  final IconData icon;
  const StatusUI(this.label, this.icon);
}

final Map<TicketStatus, StatusUI> statusLookup = {
  TicketStatus.received: const StatusUI('Received', Icons.inventory_2_outlined),
  TicketStatus.diagnosing: const StatusUI('Diagnosing', Icons.troubleshoot_outlined),
  TicketStatus.waitingForParts: const StatusUI('Waiting for Parts', Icons.hourglass_empty_rounded),
  TicketStatus.repairing: const StatusUI('Repairing', Icons.build_circle_outlined),
  TicketStatus.readyForPickup: const StatusUI('Ready for Pickup', Icons.check_circle_outline_rounded),
  // Add any Status values enum might have
};