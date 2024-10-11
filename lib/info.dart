import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:async';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  List<dynamic> informasiList = [];
  bool isLoading = true;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final String apiUrl = 'https://praktikum-cpanel-unbin.com/kelompok_rio/api.php?endpoint=informasi';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchInformasi();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        fetchInformasi();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> fetchInformasi() async {
    if (!mounted) return;
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

  Future<void> addInformasi() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'judul_info': _titleController.text,
          'isi_info': _contentController.text,
          'tgl_post_info': DateTime.now().toIso8601String(),
          'status_info': _statusController.text,
          'kd_petugas': '1', // Assuming a default value, adjust as needed
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        await fetchInformasi();
        if (mounted) Navigator.pop(context);
      } else {
        throw Exception('Failed to add informasi');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> updateInformasi(String id) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl&kd_info=$id'),
        body: json.encode({
          'kd_info': id,
          'judul_info': _titleController.text,
          'isi_info': _contentController.text,
          'tgl_post_info': DateTime.now().toIso8601String(),
          'status_info': _statusController.text,
          'kd_petugas': '1', // Assuming a default value, adjust as needed
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        await fetchInformasi();
        if (mounted) Navigator.pop(context);
      } else {
        throw Exception('Failed to update informasi');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> deleteInformasi(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl&kd_info=$id'));
      if (response.statusCode == 200) {
        await fetchInformasi();
      } else {
        throw Exception('Failed to delete informasi');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showInformasiDialog({Map<String, dynamic>? informasi}) {
    if (informasi != null) {
      _titleController.text = informasi['judul_info'] ?? '';
      _contentController.text = informasi['isi_info'] ?? '';
      _statusController.text = informasi['status_info'] ?? '';
    } else {
      _titleController.clear();
      _contentController.clear();
      _statusController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          informasi == null ? 'Add Informasi' : 'Edit Informasi',
          style: TextStyle(color: Colors.blue[800]),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul',
                  labelStyle: TextStyle(color: Colors.blue[600]),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Isi',
                  labelStyle: TextStyle(color: Colors.blue[600]),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                maxLines: 3,
              ),
              TextField(
                controller: _statusController,
                decoration: InputDecoration(
                  labelText: 'Status',
                  labelStyle: TextStyle(color: Colors.blue[600]),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.blue[800])),
          ),
          ElevatedButton(
            onPressed: () {
              if (informasi == null) {
                addInformasi();
              } else {
                updateInformasi(informasi['kd_info']);
              }
            },
            child: Text(informasi == null ? 'Add' : 'Update'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: informasiList.length,
              itemBuilder: (context, index) {
                final informasi = informasiList[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                informasi['judul_info'] ?? 'No Title',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showInformasiDialog(informasi: informasi),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: Text('Delete Informasi', style: TextStyle(color: Colors.blue[800])),
                                      content: const Text('Apakah anda yakin ingin menghapus informasi ini?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('Cancel', style: TextStyle(color: Colors.blue[800])),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            deleteInformasi(informasi['kd_info']);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Delete'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          informasi['isi_info'] ?? 'No Description',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Posted: ${_formatDate(informasi['tgl_post_info'])}',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Status: ${informasi['status_info']}',
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInformasiDialog(),
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Informasi',
        backgroundColor: Colors.blue,
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
