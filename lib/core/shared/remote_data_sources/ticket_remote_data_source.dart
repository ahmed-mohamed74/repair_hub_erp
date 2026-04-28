import 'dart:io';
import 'package:repair_hub/core/constants/db_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class TicketRemoteDataSource {
  Future<List<Map<String, dynamic>>> getTickets();
  Future<List<Map<String, dynamic>>> searchTickets(String query);
  Future<Map<String, dynamic>> getTicketById(String ticketId);
  Future<void> updateTicketStatus(String ticketId, String status);

  // Updated to handle the full intake process including photos
  Future<String> createFullTicket({
    required String name,
    required String phone,
    required String brand,
    required String model,
    required String imei,
    required String description,
    required double price,
    required List<String> localPhotoPaths,
  });
}

class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  final SupabaseClient client;
  TicketRemoteDataSourceImpl(this.client);

  @override
  Future<List<Map<String, dynamic>>> getTickets() async {
    return await client
        .from(DbKeys.viewTicketTracking)
        .select()
        .order(DbKeys.createdAt, ascending: false);
  }

  @override
  Future<Map<String, dynamic>> getTicketById(String ticketId) async {
    return await client
        .from(DbKeys.tableTickets)
        .select()
        .eq(DbKeys.id, ticketId)
        .single();
  }

  @override
  Future<List<Map<String, dynamic>>> searchTickets(String query) async {
    return await client
        .from('ticket_tracking_view')
        .select()
        .or('imei.ilike.%$query%,customer_name.ilike.%$query%');
  }

  @override
  Future<String> createFullTicket({
    required String name,
    required String phone,
    required String brand,
    required String model,
    required String imei,
    required String description,
    required double price,
    required List<String> localPhotoPaths,
  }) async {
    List<String> remoteUrls = [];

    // 1. Upload Photos to Supabase Storage first
    for (var path in localPhotoPaths) {
      // Basic check: skip empty paths or stubs
      if (path.isEmpty || path == 'path') continue;

      final file = File(path);
      final fileName = '${DateTime.now().microsecondsSinceEpoch}.jpg';
      final storagePath = 'ticket_images/$fileName';

      // Uploading to a bucket named 'repairs' (make sure this exists in Supabase)
      await client.storage.from('repairs').upload(storagePath, file);

      // Get the URL to save in the database
      final url = client.storage.from('repairs').getPublicUrl(storagePath);
      remoteUrls.add(url);
    }

    // 2. Call the RPC (PostgreSQL Function)
    // This ensures Customer, Device, and Ticket are created in ONE atomic transaction.
    final response = await client.rpc(
      'create_full_ticket',
      params: {
        'p_customer_name': name,
        'p_customer_phone': phone,
        'p_brand_name': brand,
        'p_model_name': model,
        'p_imei': imei,
        'p_description': description,
        'p_image_urls': remoteUrls,
        'p_estimated_price': price,
      },
    );

    return response as String; // This returns the generated Ticket UUID
  }

  @override
  Future<void> updateTicketStatus(String ticketId, String status) async {
    await client.from('tickets').update({'status': status}).eq('id', ticketId);
  }
}
