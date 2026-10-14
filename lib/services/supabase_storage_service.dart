import 'dart:io';

import 'package:addproduct/constants/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  SupabaseStorageService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static String _productObjectPath(String fileName) {
    final safeName = fileName.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final unique = DateTime.now().millisecondsSinceEpoch;
    return '${SupabaseConfig.productImagesPath}/${unique}_$safeName';
  }

  /// Uploads a product image to the public `media` bucket and returns its public URL.
  static Future<String> uploadProductImage(File file, String fileName) async {
    final path = _productObjectPath(fileName);
    await _client.storage.from(SupabaseConfig.mediaBucket).upload(
          path,
          file,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );

    return _client.storage
        .from(SupabaseConfig.mediaBucket)
        .getPublicUrl(path);
  }

  /// Replaces an existing object path if [previousPublicUrl] points at our bucket.
  static Future<String> uploadProductImageReplacing({
    required File file,
    required String fileName,
    String? previousPublicUrl,
  }) async {
    if (previousPublicUrl != null && previousPublicUrl.isNotEmpty) {
      await deleteByPublicUrl(previousPublicUrl);
    }
    return uploadProductImage(file, fileName);
  }

  static Future<void> deleteByPublicUrl(String publicUrl) async {
    const marker =
        '/storage/v1/object/public/${SupabaseConfig.mediaBucket}/';
    final index = publicUrl.indexOf(marker);
    if (index == -1) return;

    final objectPath = publicUrl.substring(index + marker.length);
    if (objectPath.isEmpty) return;

    try {
      await _client.storage
          .from(SupabaseConfig.mediaBucket)
          .remove([objectPath]);
    } catch (_) {
      // Ignore delete failures so updates can still proceed.
    }
  }
}
