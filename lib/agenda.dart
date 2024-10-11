import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  List<dynamic> agendaData = [];
  bool isLoading = true;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final String apiUrl = 'https://praktikum-cpanel-unbin.com/kelompok_rio/api.php?endpoint=agenda';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchAgendaData();
    // Set up a timer to fetch data every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => fetchAgendaData());
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    _titleController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> fetchAgendaData() async {
    if (!mounted) return; // Check if the widget is still mounted
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            agendaData = json.decode(response.body);
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load agenda data');
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

  Future<void> addAgenda() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'judul_agenda': _titleController.text,
          'tgl_agenda': _dateController.text,
          'isi_agenda': _descriptionController.text,
          'tgl_post_agenda': DateTime.now().toIso8601String(),
          'status_agenda': 'active',
          'kd_petugas': '1', // Assuming a default value, adjust as needed
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        await fetchAgendaData();
        if (mounted) Navigator.pop(context);
      } else {
        throw Exception('Failed to add agenda');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> updateAgenda(String id) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl&kd_agenda=$id'),
        body: json.encode({
          'kd_agenda': id,
          'judul_agenda': _titleController.text,
          'tgl_agenda': _dateController.text,
          'isi_agenda': _descriptionController.text,
          'tgl_post_agenda': DateTime.now().toIso8601String(),
          'status_agenda': 'active',
          'kd_petugas': '1', // Assuming a default value, adjust as needed
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        await fetchAgendaData();
        if (mounted) Navigator.pop(context);
      } else {
        throw Exception('Failed to update agenda');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> deleteAgenda(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl&kd_agenda=$id'));
      if (response.statusCode == 200) {
        await fetchAgendaData();
      } else {
        throw Exception('Failed to delete agenda');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showAgendaDialog({Map<String, dynamic>? agenda}) {
    if (agenda != null) {
      _titleController.text = agenda['judul_agenda'] ?? '';
      _descriptionController.text = agenda['isi_agenda'] ?? '';
      _dateController.text = agenda['tgl_agenda'] ?? '';
    } else {
      _titleController.clear();
      _dateController.clear();
      _descriptionController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          agenda == null ? 'Add Agenda' : 'Edit Agenda',
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
                ),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  labelStyle: TextStyle(color: Colors.blue[600]),
                ),
                maxLines: 3,
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Tanggal',
                  labelStyle: TextStyle(color: Colors.blue[600]),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: Colors.blue,
                          colorScheme: const ColorScheme.light(primary: Colors.blue),
                          buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    _dateController.text = pickedDate.toIso8601String().split('T')[0];
                  }
                },
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
              if (agenda == null) {
                addAgenda();
              } else {
                updateAgenda(agenda['kd_agenda']);
              }
            },
            child: Text(agenda == null ? 'Add' : 'Update'),
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
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: agendaData.length,
              itemBuilder: (context, index) {
                final agenda = agendaData[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    title: Text(
                      agenda['judul_agenda'] ?? 'No Title',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(agenda['tgl_agenda'] ?? 'No Date'),
                        Text(agenda['isi_agenda'] ?? 'No Description'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAgendaDialog(agenda: agenda),
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
                              title: Text('Delete Agenda', style: TextStyle(color: Colors.blue[800])),
                              content: const Text('Apakah anda yakin ingin menghapus agenda ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel', style: TextStyle(color: Colors.blue[800])),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    deleteAgenda(agenda['kd_agenda']);
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
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAgendaDialog(),
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Agenda',
        backgroundColor: Colors.blue,
      ),
    );
  }
}
