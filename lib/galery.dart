import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GaleryScreen extends StatefulWidget {
  const GaleryScreen({super.key});

  @override
  _GaleryScreenState createState() => _GaleryScreenState();
}

class _GaleryScreenState extends State<GaleryScreen> {
  List<dynamic> galeryData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGaleryData();
  }

  Future<void> fetchGaleryData() async {
    final response = await http.get(Uri.parse('https://praktikum-cpanel-unbin.com/kelompok_rio/api.php?endpoint=galery'));
    if (response.statusCode == 200) {
      setState(() {
        galeryData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load galery data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8, // Adjusted for a slightly taller card
              ),
              itemCount: galeryData.length,
              itemBuilder: (context, index) {
                final item = galeryData[index];
                return Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: Image.network(
                          item['isi_galery'] ?? '',
                          width: double.infinity,
                          height: 150, // Fixed height for the image
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, size: 50),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['judul_galery'] ?? 'No Title',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14, // Slightly smaller font size
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // const SizedBox(height: 4),
                            // Text(
                            //   item['isi_galery'] ?? 'No Description',
                            //   style: const TextStyle(fontSize: 12),
                            //   maxLines: 2,
                            //   overflow: TextOverflow.ellipsis,
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
