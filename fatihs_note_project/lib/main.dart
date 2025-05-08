import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> notlar = [];
  TextEditingController noteCtr = TextEditingController();

  @override
  void dispose() {
    noteCtr.dispose();
    super.dispose();
  }

  Future<void> _loadNotlar() async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    setState(() {
      notlar = _preferences.getStringList('notes') ?? [];
    });
  }

  Future<void> _saveNotes() async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    await _preferences.setStringList('notes', notlar);
  }

  @override
  void initState() {
    super.initState();
    _loadNotlar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notlar')),
      body: Center(
        child: notlar.isEmpty
            ? Text('Henüz not yok')
            : ListView.builder(
          itemCount: notlar.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                color: Colors.red,
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                setState(() {
                  notlar.removeAt(index);
                  _saveNotes(); // Silme sonrası kaydet
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    title: Text(notlar[index]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: noteCtr,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: 'Not Ekle',
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          String not = noteCtr.text.trim();
                          if (not.isNotEmpty) {
                            setState(() {
                              notlar.add(not);
                              _saveNotes(); // Ekleme sonrası kaydet
                              noteCtr.clear(); // Alanı temizle
                              Navigator.pop(context);
                            });
                          }
                        },
                        child: Text('Ekle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
