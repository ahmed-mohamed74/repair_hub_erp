import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:repair_hub/core/constants/db_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class TicketRemoteDataSource {
  Future<List<Map<String, dynamic>>> getTickets();
  Future<List<Map<String, dynamic>>> searchTickets(String query);
  Future<Map<String, dynamic>> getTicketById(String ticketId);
  Future<void> updateTicket(String ticketId, String status, String notes);
  Future<Map<String, dynamic>?> getTicketByIdOrImei(String query);

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
        .from(DbKeys.viewTicketTracking)
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
    // 1. Parallel Uploading for better performance
    final validPaths = localPhotoPaths
        .where((path) => path.isNotEmpty && path != 'path')
        .toList();

    final uploadFutures = validPaths.map((path) async {
      final fileName = '${DateTime.now().microsecondsSinceEpoch}_${path.split('/').last}';
      final storagePath = 'ticket_images/$fileName';

      if (kIsWeb) {
        // Cross-platform support for Flutter Web using Bytes
        final bytes = await File(path).readAsBytes();
        await client.storage.from('repairs').uploadBinary(storagePath, bytes);
      } else {
        final file = File(path);
        await client.storage.from('repairs').upload(storagePath, file);
      }

      return client.storage.from('repairs').getPublicUrl(storagePath);
    });

    final List<String> remoteUrls = await Future.wait(uploadFutures);

    // 2. Call PostgreSQL RPC Function
    final response = await client.rpc(
      'create_full_ticket',
      params: {
        'p_customer_name': name.trim(),
        'p_customer_phone': phone.trim(),
        'p_brand_name': brand.trim(),
        'p_model_name': model.trim(),
        'p_imei': imei.trim(),
        'p_description': description.trim(),
        'p_image_urls': remoteUrls,
        'p_estimated_price': price,
      },
    );

    return response as String;
  }

  @override
  Future<void> updateTicket(
    String ticketId,
    String status,
    String notes,
  ) async {
    await client
        .from(DbKeys.tableTickets)
        .update({
          'status': status,
          'internal_notes': notes,
          'public_notes': notes,
        })
        .eq(DbKeys.id, ticketId);
  }

  @override
  Future<Map<String, dynamic>?> getTicketByIdOrImei(String query) async {
    try {
      final trimmedQuery = query.trim();
      final int? ticketNum = int.tryParse(trimmedQuery);

      var supabaseQuery = client.from(DbKeys.viewTicketTracking).select();

      if (ticketNum != null) {
        return await supabaseQuery
            .or('${DbKeys.ticketNumber}.eq.$ticketNum,imei.eq.$trimmedQuery')
            .maybeSingle();
      } else {
        return await supabaseQuery.eq('imei', trimmedQuery).maybeSingle();
      }
    } catch (e) {
      throw Exception("Failed to fetch tracking data: $e");
    }
  }
}