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
    // 1. Trigger the built-in validators
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Additional check for photos if you want them required
    // if (context.read<AddTicketCubit>().state.photoPaths.every((p) => p.isEmpty)) {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one photo')));
    //   return;
    // }

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
    return BlocListener<AddTicketCubit, AddTicketState>(
      listener: (context, state) {
        if (state.status == AddTicketStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Repair Ticket Created Successfully!'),
              backgroundColor: Colors.green,
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
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('New Repair Ticket')),
        body: BlocBuilder<AddTicketCubit, AddTicketState>(
          builder: (context, state) {
            final isSubmitting = state.status == AddTicketStatus.loading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Form(
                key: _formKey, // Added Form key
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeaderSection(),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const FieldLabel('Customer Name'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _customerNameController,
                              enabled: !isSubmitting,
                              decoration: const InputDecoration(
                                hintText: 'Full name',
                              ),
                              validator: (val) =>
                                  val!.trim().isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            const FieldLabel('Contact Number'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _customerPhoneController,
                              enabled: !isSubmitting,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: '01XXXXXXXXX',
                              ),
                              validator: (val) =>
                                  val!.trim().isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 20),
                            const FieldLabel('IMEI / Serial Number'),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _imeiController,
                                    enabled: !isSubmitting,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter or scan IMEI',
                                    ),
                                    validator: (val) =>
                                        val!.trim().isEmpty ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: IconButton.filled(
                                    onPressed: isSubmitting
                                        ? null
                                        : _openImeiScanner,
                                    icon: const Icon(Icons.qr_code_scanner),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
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
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: _modelController,
                                    enabled: !isSubmitting,
                                    decoration: const InputDecoration(
                                      labelText: 'Model',
                                      hintText: 'e.g., iPhone 15',
                                    ),
                                    validator: (val) =>
                                        val!.trim().isEmpty ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const FieldLabel('Estimated Price (EGP)'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _priceController,
                              enabled: !isSubmitting,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                hintText: '0.00',
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(val) == null) {
                                  return 'Invalid amount';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            const FieldLabel('Problem Description'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descriptionController,
                              enabled: !isSubmitting,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: 'Describe the issue...',
                              ),
                              validator: (val) =>
                                  val!.trim().isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 24),
                            const FieldLabel('Device Photos'),
                            const SizedBox(height: 12),
                            PhotoRow(
                              photoPaths: state.photoPaths,
                              onSlotTap: (i) => _onPhotoSlotTap(i, state),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: isSubmitting ? null : _submitForm,
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create Repair Ticket'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
