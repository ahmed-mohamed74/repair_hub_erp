enum TicketStatus {
  received,
  diagnosing,
  waitingForParts,
  repairing,
  readyForPickup,
  completed,
  cancelled;

  // Helper to get enum from string safely
  static TicketStatus fromString(String status) {
    return TicketStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => TicketStatus.received,
    );
  }
}
