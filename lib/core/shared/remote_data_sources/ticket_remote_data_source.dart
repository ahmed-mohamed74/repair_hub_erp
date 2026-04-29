import 'dart:io';
import 'package:repair_hub/core/constants/db_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class TicketRemoteDataSource {
  Future<List<Map<String, dynamic>>> getTickets();
  Future<List<Map<String, dynamic>>> searchTickets(String query);
  Future<Map<String, dynamic>> getTicketById(String ticketId);
  Future<void> updateTicket(String ticketId, String status, String notes);
  Future<Map<String, dynamic>?> getTicketByIdOrImei(String query);

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

    // 1. Upload Photos to Supabase Storage
    for (var path in localPhotoPaths) {
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

    // 2. Call the (PostgreSQL Function)
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
  Future<void> updateTicket(
    String ticketId,
    String status,
    String notes,
  ) async {
    await client
        .from('tickets')
        .update({
          'status': status,
          'internal_notes': notes,
          'public_notes': notes,
        })
        .eq('id', ticketId);
  }

  @override
  Future<Map<String, dynamic>?> getTicketByIdOrImei(String query) async {
    try {
      final int? ticketNum = int.tryParse(query);

      var supabaseQuery = client.from(DbKeys.viewTicketTracking).select();

      if (ticketNum != null) {
        return await supabaseQuery
            .or('${DbKeys.ticketNumber}.eq.$ticketNum,imei.eq.$query')
            .maybeSingle();
      } else {
        return await supabaseQuery.eq('imei', query).maybeSingle();
      }
    } catch (e) {
      throw Exception("Failed to fetch tracking data: $e");
    }
  }
}
