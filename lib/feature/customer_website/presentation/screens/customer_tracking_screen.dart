import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_hub/core/constants/app_secrets.dart';
import 'package:repair_hub/core/constants/db_constants.dart';
import 'package:repair_hub/feature/customer_website/presentation/cubit/web_tracking_cubit.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CustomerTrackingScreen extends StatefulWidget {
  const CustomerTrackingScreen({super.key});

  @override
  State<CustomerTrackingScreen> createState() => _CustomerTrackingScreenState();
}

class _CustomerTrackingScreenState extends State<CustomerTrackingScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<WebTrackingCubit>().searchTicket(query);
    }
  }

  Future<void> _launchWhatsApp(Map<String, dynamic> ticket) async {
    final ticketId = ticket['ticket_number'] ?? ticket['ticket_id'];
    const phone = AppSecrets.phoneNumber;
    final message = "Hello! I am inquiring about my Repair Ticket #$ticketId.";
    final url = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _generatePdfReceipt(Map<String, dynamic> ticket) async {
    try {
      final pdf = pw.Document();
      final String ticketNo = (ticket[DbKeys.ticketNumber] ?? "N/A").toString();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(30),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "REPAIR HUB SERVICE RECEIPT",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(),
                  pw.SizedBox(height: 20),
                  pw.Text("Ticket ID: #$ticketNo"),
                  pw.Text(
                    "Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    "Customer: ${ticket['customer_name'] ?? 'Valued Customer'}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    "Device: ${ticket['brand_name']} ${ticket['model_name']}",
                  ),
                  pw.Text("IMEI: ${ticket['imei']}"),
                  pw.SizedBox(height: 20),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "Estimated Total:",
                        style: pw.TextStyle(fontSize: 16),
                      ),
                      pw.Text(
                        "\$${ticket['estimated_price']}",
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 40),
                  pw.Center(
                    child: pw.Text("Thank you for choosing Repair Hub!"),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Using layoutPdf triggers the browser's PDF viewer.
      // From there, users on Web can click the 'Download' icon.
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Receipt_$ticketNo.pdf',
      );
    } catch (e) {
      debugPrint("PDF Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double horizontalPadding = constraints.maxWidth > 800 ? 24 : 16;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 40,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    _buildHeader(constraints.maxWidth),
                    const SizedBox(height: 32),
                    _buildSearchBar(constraints.maxWidth),
                    const SizedBox(height: 40),
                    _buildBlocConsumer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(double width) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction:
                  TextInputAction.search, // Changes Enter key to Search icon
              onSubmitted: (_) => _handleSearch(), // Handles 'Enter' key press
              decoration: const InputDecoration(
                hintText: "IMEI or Ticket ID",
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _handleSearch,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: width > 600 ? 24 : 12,
                vertical: 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Track"),
          ),
        ],
      ),
    );
  }

  Widget _buildBlocConsumer() {
    return BlocBuilder<WebTrackingCubit, WebTrackingState>(
      builder: (context, state) {
        if (state is TrackingLoading) {
          return const Padding(
            padding: EdgeInsets.only(top: 40),
            child: CircularProgressIndicator(),
          );
        }
        if (state is TrackingNotFound) {
          return _buildStatusMessage(
            "No Record Found",
            "Check your ID and try again.",
            Icons.search_off,
            Colors.orange,
          );
        }
        if (state is TrackingFailure) {
          return _buildStatusMessage(
            "Error",
            state.message,
            Icons.error_outline,
            Colors.red,
          );
        }
        if (state is TrackingSuccess) {
          final ticket = state.ticket;
          return LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  _buildMainTicketCard(ticket, constraints.maxWidth),
                  const SizedBox(height: 24),
                  _buildLatestUpdateCard(ticket),
                  const SizedBox(height: 24),
                  _buildActionButtons(ticket, constraints.maxWidth),
                ],
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      title: const Text(
        "RepairHub",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHeader(double width) {
    return Column(
      children: [
        Text(
          "Track Your Repair",
          style: TextStyle(
            fontSize: width > 600 ? 42 : 30,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Instant updates on your device repair status",
          style: TextStyle(fontSize: 16, color: Colors.blueGrey),
        ),
      ],
    );
  }

  Widget _buildMainTicketCard(Map<String, dynamic> ticket, double screenWidth) {
    final status = ticket['status'] ?? 'pending';
    return Container(
      padding: EdgeInsets.all(screenWidth > 600 ? 32 : 20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "#${(ticket[DbKeys.ticketNumber] ?? "---")}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStatusChip(status.toUpperCase()),
            ],
          ),
          const Divider(height: 40),
          Wrap(
            spacing: 40,
            runSpacing: 20,
            children: [
              _infoTile(
                "Device",
                "${ticket['brand_name']} ${ticket['model_name']}",
              ),
              _infoTile("Estimated Cost", "\$${ticket['estimated_price']}"),
            ],
          ),
          const SizedBox(height: 32),
          LinearProgressIndicator(
            value: _calculateProgress(status),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 32),
          _buildStepIcons(_getStatusStep(status), screenWidth),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> ticket, double screenWidth) {
    bool isMobile = screenWidth < 600;
    final buttons = [
      Expanded(flex: isMobile ? 0 : 1, child: _receiptButton(ticket, isMobile)),
      SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 12 : 0),
      Expanded(
        flex: isMobile ? 0 : 1,
        child: _whatsappButton(ticket, isMobile),
      ),
    ];

    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buttons,
          )
        : Row(children: buttons);
  }

  Widget _receiptButton(Map<String, dynamic> ticket, bool isMobile) {
    return OutlinedButton.icon(
      onPressed: () => _generatePdfReceipt(ticket),
      icon: const Icon(Icons.download),
      label: const Text("Download Receipt"),
      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 60)),
    );
  }

  Widget _whatsappButton(Map<String, dynamic> ticket, bool isMobile) {
    return ElevatedButton.icon(
      onPressed: () => _launchWhatsApp(ticket),
      icon: const Icon(Icons.chat, color: Colors.white),
      label: const Text(
        "Contact Support",
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00A884),
        minimumSize: const Size(0, 60),
      ),
    );
  }

  Widget _infoTile(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    ],
  );

  Widget _buildStatusChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.blue[50],
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: Colors.blue[700],
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  Widget _buildLatestUpdateCard(Map<String, dynamic> ticket) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Latest Update",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          ticket['public_notes'] ?? "No public notes available.",
          style: const TextStyle(color: Colors.black87),
        ),
      ],
    ),
  );

  Widget _buildStatusMessage(String t, String d, IconData i, Color c) => Column(
    children: [
      Icon(i, color: c, size: 48),
      const SizedBox(height: 16),
      Text(
        t,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      Text(d),
    ],
  );

  double _calculateProgress(String s) {
    if (s.contains('ready')) return 1.0;
    if (s.contains('repair')) return 0.75;
    if (s.contains('diag')) return 0.5;
    return 0.25;
  }

  int _getStatusStep(String s) => (s.contains('ready'))
      ? 4
      : (s.contains('repair'))
      ? 2
      : (s.contains('diag'))
      ? 1
      : 0;

  Widget _buildStepIcons(int step, double w) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Icon(Icons.check_circle, color: step >= 0 ? Colors.blue : Colors.grey),
      Icon(Icons.build, color: step >= 1 ? Colors.blue : Colors.grey),
      Icon(Icons.settings, color: step >= 2 ? Colors.blue : Colors.grey),
      Icon(Icons.verified, color: step >= 4 ? Colors.blue : Colors.grey),
    ],
  );
}
