import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> informasiList = [];
  bool isLoading = true;
  final String apiUrl = 'https://praktikum-cpanel-unbin.com/kelompok_rio/api.php?endpoint=informasi';

  @override
  void initState() {
    super.initState();
    fetchInformasi();
  }

  Future<void> fetchInformasi() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            informasiList = json.decode(response.body);
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load informasi');
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 16.0, bottom: 16.0, right: 20.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue[700]!, Colors.blue[400]!],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Belajar Lebih Mudah',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Dengan E-learning Mobile',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Implementasi aksi untuk tombol
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[700],
                        ),
                        child: const Text('Mulai Belajar'),
                      ),
                    ],
                  ),
                ),
              ),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMenuCard(context, 'Materi', Icons.book, const Color(0xFF8B9DC3)),
                  _buildMenuCard(context, 'Tugas', Icons.assignment, const Color(0xFF8FBC8F)),
                  _buildMenuCard(context, 'Diskusi', Icons.chat, const Color(0xFFDEB887)),
                  _buildMenuCard(context, 'Nilai', Icons.score, const Color(0xFFCD5C5C)),
                  _buildMenuCard(context, 'Kalender', Icons.calendar_today, const Color(0xFF9370DB)),
                  _buildMenuCard(context, 'Library', Icons.library_books, const Color(0xFF5F9EA0)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0, right: 20.0),
                child: Text(
                  'Pengumuman Terbaru',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                height: 300, // Adjust this value as needed
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : informasiList.isEmpty
                    ? const Center(child: Text('Tidak ada pengumuman'))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: informasiList.length,
                        itemBuilder: (context, index) {
                          final informasi = informasiList[index];
                          return _buildAnnouncementCard(
                            informasi['judul_info'] ?? 'No Title',
                            informasi['isi_info'] ?? 'No Content',
                            informasi['tgl_post_info'] ?? '',
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 4,
      color: color,
      child: InkWell(
        onTap: () {
          // TODO: Implementasi navigasi ke halaman yang sesuai
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(String title, String content, String date) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(content),
            const SizedBox(height: 8),
            Text(
              'Posted: ${_formatDate(date)}',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }
}
