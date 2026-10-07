import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/berita_model.dart';

class BeritaService {
  // Base URL dari Berita Indo API
  static const String baseUrl = 'https://berita-indo-api-next.vercel.app/api';

  // Fungsi untuk mengambil berita CNN berdasarkan kategori
  // kategori default: 'nasional'
  Future<BeritaResponse> getCnnNews({String kategori = 'nasional'}) async {
    final url = Uri.parse('$baseUrl/cnn-news/$kategori');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // decode response body ke Map
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return BeritaResponse.fromJson(jsonData);
      } else {
        throw Exception('Gagal memuat berita. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}