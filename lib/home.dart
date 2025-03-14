import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Reader',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const PDFReaderPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PDFReaderPage extends StatefulWidget {
  const PDFReaderPage({super.key});

  @override
  State<PDFReaderPage> createState() => _PDFReaderPageState();
}

class _PDFReaderPageState extends State<PDFReaderPage> {
  String? localPath;

  @override
  void initState() {
    super.initState();
    loadPDF();
  }

  Future<void> loadPDF() async {
    final byteData = await rootBundle.load('assets/pdf/chem.pdf');
    final file = File('${(await getTemporaryDirectory()).path}/chem.pdf');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    setState(() {
      localPath = file.path;
    });
  }

  void _showChapters() {
    // Placeholder for chapter view
    showModalBottomSheet(
      context: context,
      builder: (_) => const Center(child: Text("Chapters List Placeholder")),
    );
  }

  void _openSettings() {
    // Placeholder for settings
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(title: Text("Settings Placeholder")),
    );
  }

  void _showOptions() {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        const PopupMenuItem<int>(value: 0, child: Text("Option 1")),
        const PopupMenuItem<int>(value: 1, child: Text("Option 2")),
      ],
    );
  }

  void _startTextToSpeech() {
    // Placeholder for text-to-speech functionality
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Text-to-Speech started")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF86363),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Some Book Grade 9', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.white),
            onPressed: _startTextToSpeech,
          ),
          IconButton(
            icon: const Icon(Icons.menu_book, color: Colors.white),
            onPressed: _showChapters,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _openSettings,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showOptions,
          ),
        ],
      ),
      body: localPath != null
          ? Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SfPdfViewer.file(
                File(localPath!),
                enableTextSelection: true,
              ),
            ),
          ),

          BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.deepOrange,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark),
                label: 'Bookmark',
              ),

            ],
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.chat),
        onPressed: () {},
      ),
    );
  }
}
