import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:repair_hub/core/routes/app_router.dart';
import 'package:repair_hub/feature/add_ticket/presentation/add_ticket_cubit/add_ticket_cubit.dart';
import 'package:repair_hub/feature/add_ticket/presentation/add_ticket_cubit/add_ticket_state.dart';
import 'package:repair_hub/feature/add_ticket/presentation/widgets/brand_drop_down_widget.dart';
import 'package:repair_hub/feature/add_ticket/presentation/widgets/field_label_widget.dart';
import 'package:repair_hub/feature/add_ticket/presentation/widgets/header_section.dart';
import 'package:repair_hub/feature/add_ticket/presentation/widgets/imei_scanner_sheet.dart';
import 'package:repair_hub/feature/add_ticket/presentation/widgets/photo_row_widget.dart';
import 'package:repair_hub/feature/add_ticket/presentation/widgets/photo_slot_action_sheet.dart';

class AddTicketPage extends StatefulWidget {
  const AddTicketPage({super.key});

  @override
  State<AddTicketPage> createState() => _AddTicketPageState();
}

class _AddTicketPageState extends State<AddTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _imeiController = TextEditingController();
  final _modelController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _imeiController.dispose();
    _modelController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _openImeiScanner() async {
    final scanned = await showImeiScanner(context);
    if (!mounted || scanned == null) return;
    _imeiController.text = scanned;
  }

  Future<void> _onPhotoSlotTap(int index, AddTicketState state) async {
    final path = state.photoPaths[index];
    final choice = await showPhotoSlotActions(
      context,
      hasExistingPhoto: path.isNotEmpty,
    );

    if (!mounted || choice == null) return;
    final cubit = context.read<AddTicketCubit>();

    if (choice == PhotoSlotChoice.remove) {
      cubit.clearPhoto(index);
      return;
    }

    final source = choiceToSource(choice);
    if (source != null) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        cubit.updatePhoto(index, pickedFile.path);
      }
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AddTicketCubit>().submit(
      name: _customerNameController.text.trim(),
      phone: _customerPhoneController.text.trim(),
      imei: _imeiController.text.trim(),
      model: _modelController.text.trim(),
      description: _descriptionController.text.trim(),
      priceString: _priceController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
      child: BlocListener<AddTicketCubit, AddTicketState>(
        listener: (context, state) {
          if (state.status == AddTicketStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Repair Ticket Created Successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.pushReplacement(
              AppRoutes.ticketDetails,
              extra: state.successTicketId,
            );
          } else if (state.status == AddTicketStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<AddTicketCubit, AddTicketState>(
          builder: (context, state) {
            final isSubmitting = state.status == AddTicketStatus.loading;

            return Scaffold(
              appBar: AppBar(
                title: const Text('New Repair Ticket'),
                centerTitle: true,
              ),
              // --- Static Bottom Button ---
              bottomNavigationBar: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: FilledButton(
                    onPressed: isSubmitting ? null : _submitForm,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Repair Ticket',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HeaderSection(),
                      const SizedBox(height: 24),

                      // --- Customer Information Section ---
                      _buildSectionTitle(context, 'Customer Details'),
                      _buildInputCard([
                        _buildTextField(
                          label: 'Full Name',
                          controller: _customerNameController,
                          icon: Icons.person_outline,
                          hint: 'e.g. John Doe',
                          enabled: !isSubmitting,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Contact Number',
                          controller: _customerPhoneController,
                          icon: Icons.phone_outlined,
                          hint: '01XXXXXXXXX',
                          keyboardType: TextInputType.phone,
                          enabled: !isSubmitting,
                        ),
                      ]),

                      const SizedBox(height: 24),

                      // --- Device Information Section ---
                      _buildSectionTitle(context, 'Device Details'),
                      _buildInputCard([
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'IMEI / Serial Number',
                                controller: _imeiController,
                                icon: Icons.fingerprint,
                                hint: 'Enter or scan IMEI',
                                enabled: !isSubmitting,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(top: 28),
                              child: IconButton.filledTonal(
                                onPressed: isSubmitting
                                    ? null
                                    : _openImeiScanner,
                                icon: const Icon(Icons.qr_code_scanner),
                                tooltip: 'Scan IMEI',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: BrandDropdown(
                                currentBrand: state.brand,
                                onChanged: isSubmitting
                                    ? null
                                    : (val) => context
                                          .read<AddTicketCubit>()
                                          .updateBrand(val!),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 3,
                              child: _buildTextField(
                                label: 'Model',
                                controller: _modelController,
                                hint: 'e.g. iPhone 15 Pro',
                                enabled: !isSubmitting,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Estimated Price (EGP)',
                          controller: _priceController,
                          icon: Icons.payments_outlined,
                          hint: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          enabled: !isSubmitting,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Required';
                            if (double.tryParse(val) == null) return 'Invalid';
                            return null;
                          },
                        ),
                      ]),

                      const SizedBox(height: 24),

                      // --- Problem & Photos Section ---
                      _buildSectionTitle(context, 'Issue Description'),
                      _buildInputCard([
                        _buildTextField(
                          label: 'Problem Details',
                          controller: _descriptionController,
                          hint: 'Describe what needs fixing...',
                          maxLines: 4,
                          enabled: !isSubmitting,
                        ),
                        const SizedBox(height: 20),
                        const FieldLabel('Device Photos'),
                        const SizedBox(height: 8),
                        PhotoRow(
                          photoPaths: state.photoPaths,
                          onSlotTap: (i) => _onPhotoSlotTap(i, state),
                        ),
                      ]),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildInputCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator:
              validator ?? (val) => val!.trim().isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
