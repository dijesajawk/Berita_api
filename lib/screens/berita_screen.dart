import 'package:flutter/material.dart';
import '../models/berita_model.dart';
import '../services/berita_service.dart';

class BeritaScreen extends StatefulWidget {
  const BeritaScreen({super.key});

  @override
  State<BeritaScreen> createState() => _BeritaScreenState();
}

class _BeritaScreenState extends State<BeritaScreen> {
  final BeritaService _beritaService = BeritaService();

  // late supaya bisa di-assign ulang saat ganti kategori / refresh
  late Future<BeritaResponse> _futureBerita;

  String _kategoriAktif = 'nasional';

  final List<String> _daftarKategori = [
    'nasional',
    'internasional',
    'ekonomi',
    'olahraga',
    'teknologi',
    'hiburan',
    'gaya-hidup',
  ];

  @override
  void initState() {
    super.initState();
    _futureBerita = _beritaService.getCnnNews(kategori: _kategoriAktif);
  }

  void _gantiKategori(String kategori) {
    setState(() {
      _kategoriAktif = kategori;
      _futureBerita = _beritaService.getCnnNews(kategori: kategori);
    });
  }

  Future<void> _refreshBerita() async {
    setState(() {
      _futureBerita = _beritaService.getCnnNews(kategori: _kategoriAktif);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita CNN Indonesia'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ---- Filter Kategori (horizontal scroll) ----
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _daftarKategori.length,
              itemBuilder: (context, index) {
                final kategori = _daftarKategori[index];
                final aktif = kategori == _kategoriAktif;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(kategori),
                    selected: aktif,
                    onSelected: (_) => _gantiKategori(kategori),
                    selectedColor: Colors.red,
                    labelStyle: TextStyle(
                      color: aktif ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),

          // ---- Daftar Berita ----
          Expanded(
            child: FutureBuilder<BeritaResponse>(
              future: _futureBerita,
              builder: (context, snapshot) {
                // 1. Sedang loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Ada error
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(
                            'Gagal memuat berita.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _refreshBerita,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // 3. Data kosong
                final listBerita = snapshot.data?.data ?? [];
                if (listBerita.isEmpty) {
                  return const Center(child: Text('Tidak ada berita.'));
                }

                // 4. Data berhasil ditampilkan
                return RefreshIndicator(
                  onRefresh: _refreshBerita,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: listBerita.length,
                    itemBuilder: (context, index) {
                      final berita = listBerita[index];
                      return _BeritaCard(berita: berita);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Widget terpisah untuk 1 card berita ----
class _BeritaCard extends StatelessWidget {
  final Berita berita;

  const _BeritaCard({required this.berita});

  String _formatTanggal(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return '${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Nanti bisa dibuka pakai url_launcher, atau
          // pindah ke halaman detail berita
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar berita
            if (berita.image != null && berita.image!.small.isNotEmpty)
              Image.network(
                berita.image!.small,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 48),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 180,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                },
              ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    berita.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    berita.contentSnippet,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTanggal(berita.isoDate),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}