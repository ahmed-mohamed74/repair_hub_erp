import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:repair_hub/core/routes/app_router.dart';
import 'package:repair_hub/core/shared/models/ticket_model.dart';
import 'package:repair_hub/core/shared/models/ticket_status_enum.dart';
import 'package:repair_hub/feature/ticket_details/data/models/status_ui_model.dart';
import 'package:repair_hub/feature/ticket_details/presentation/cubit/ticket_details_cubit.dart';

class TicketDetailsPage extends StatefulWidget {
  final String ticketId;

  const TicketDetailsPage({super.key, required this.ticketId});

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  bool _isInitialLoad = true;
  @override
  void initState() {
    super.initState();
    context.read<TicketDetailsCubit>().loadTicket(widget.ticketId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TicketDetailsCubit, TicketDetailsState>(
      listener: (context, state) {
        if (state is TicketDetailsFailure) {
          _isInitialLoad = false; // Also turn off on failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is TicketDetailsSuccess) {
          if (_isInitialLoad) {
            _isInitialLoad = false;
            return;
          }
          context.go(AppRoutes.home);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Update saved successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text(
              'Repair Tracking',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: switch (state) {
            TicketDetailsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            TicketDetailsSuccess(ticket: var t) => _TicketDetailsBody(
              ticket: t,
            ),
            _ => const Center(child: Text('Error loading ticket')),
          },
        );
      },
    );
  }
}

class _TicketDetailsBody extends StatefulWidget {
  final TicketModel ticket;
  const _TicketDetailsBody({required this.ticket});

  @override
  State<_TicketDetailsBody> createState() => _TicketDetailsBodyState();
}

class _TicketDetailsBodyState extends State<_TicketDetailsBody>
    with SingleTickerProviderStateMixin {
  late TextEditingController _notesController;
  late TicketStatus _selectedStatus;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.ticket.internalNotes);
    _selectedStatus = widget.ticket.status;
    _notesController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = _notesController.text.trim().isNotEmpty;

    return Column(
      children: [
        // 1. Scrollable Content Area
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryCard(
                    ticket: widget.ticket,
                    currentLocalStatus: _selectedStatus,
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Update Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _RepairTimelineView(
                    currentStatus: _selectedStatus,
                    onStatusSelected: (newStatus) =>
                        setState(() => _selectedStatus = newStatus),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Technician Notes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Describe the work done...',
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.blue,
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        // 2. Static Footer Area (Always visible)
        Container(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              _CircleButton(
                icon: Icons.phone_rounded,
                onTap: () {},
                color: Colors.blue.withOpacity(0.1),
                iconColor: Colors.blue,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 56,
                  child: FilledButton(
                    onPressed: isEnabled
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              context.read<TicketDetailsCubit>().updateTicket(
                                widget.ticket.id,
                                _notesController.text,
                                _selectedStatus,
                              );
                            }
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: isEnabled ? 4 : 0,
                    ),
                    child: const Text(
                      'Save Updates',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RepairTimelineView extends StatelessWidget {
  final TicketStatus currentStatus;
  final Function(TicketStatus) onStatusSelected;

  const _RepairTimelineView({
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: TicketStatus.values.map((status) {
        final index = TicketStatus.values.indexOf(status);
        final isCompleted = currentStatus.index > index;
        final isCurrent = currentStatus == status;
        final isLast = index == TicketStatus.values.length - 1;
        final ui =
            statusLookup[status] ?? const StatusUI('Processing', Icons.sync);

        return _PhaseTile(
          label: ui.label,
          icon: ui.icon,
          isDone: isCompleted,
          isCurrent: isCurrent,
          isLast: isLast,
          onTap: () => onStatusSelected(status),
        );
      }).toList(),
    );
  }
}

class _PhaseTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDone, isCurrent, isLast;
  final VoidCallback onTap;

  const _PhaseTile({
    required this.label,
    required this.icon,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = isDone || isCurrent
        ? colorScheme.primary
        : colorScheme.outline.withOpacity(0.2);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrent ? 36 : 32,
                  height: isCurrent ? 36 : 32,
                  decoration: BoxDecoration(
                    color: isDone
                        ? colorScheme.primary
                        : (isCurrent
                              ? colorScheme.primaryContainer
                              : Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: primaryColor, width: 2),
                  ),
                  child: Icon(
                    isDone ? Icons.check_rounded : icon,
                    size: 18,
                    color: isDone
                        ? colorScheme.onPrimary
                        : (isCurrent
                              ? colorScheme.primary
                              : colorScheme.outline),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 30,
                    color: primaryColor.withOpacity(0.3),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    fontSize: 15,
                    color: isDone || isCurrent ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color, iconColor;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: iconColor),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final TicketModel ticket;
  final TicketStatus currentLocalStatus;
  const _SummaryCard({required this.ticket, required this.currentLocalStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ticket ID',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '#REP-${ticket.ticketNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  currentLocalStatus.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoTile(
                label: 'Device',
                value: 'iPhone 14 Pro Max',
                icon: Icons.phone_iphone_rounded,
              ),
              _InfoTile(
                label: 'Estimate',
                value: '\$${ticket.estimatedPrice}',
                icon: Icons.payments_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
